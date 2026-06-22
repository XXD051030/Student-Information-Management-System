using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using src.db;
using src.services;

namespace src.services.admin
{
    public class StudentBulkImportService
    {
        private static readonly string[] RequiredHeaders =
        {
            "Full Name", "Institutional Email", "Personal Email", "Phone", "Programme Code", "Status"
        };

        public StudentBulkPreview Prepare(Stream stream, DateTime registrationDate)
        {
            AcademicIntakeSchema.Ensure();
            var rows = ReadWorkbook(stream);
            var preview = new StudentBulkPreview
            {
                RegistrationDate = registrationDate.Date,
                Rows = rows,
                IntakeOptions = GetIntakes()
            };

            var automatic = MatchIntake(registrationDate.Date);
            preview.IntakeId = automatic == null ? "" : automatic.Id;
            preview.IntakeName = automatic == null ? "" : automatic.Name;
            preview.IntakeMatchMessage = automatic == null
                ? "No intake is configured. Create an academic intake before importing."
                : automatic.IsRegistrationWindowMatch
                    ? "Matched from the configured registration window."
                    : "No registration window matched, so the nearest upcoming active intake was selected.";

            Validate(preview.Rows);
            return preview;
        }

        public StudentBulkImportResult Import(IEnumerable<StudentBulkRow> sourceRows, string intakeId)
        {
            AcademicIntakeSchema.Ensure();
            var rows = (sourceRows ?? Enumerable.Empty<StudentBulkRow>()).ToList();
            if (rows.Count == 0) throw new ArgumentException("There are no students to import.");
            Validate(rows);
            if (rows.Any(r => !r.IsValid))
                throw new ArgumentException("Fix the validation errors before importing.");
            if (string.IsNullOrWhiteSpace(intakeId))
                throw new ArgumentException("Select an intake before importing.");

            var result = new StudentBulkImportResult { IntakeId = intakeId };
            using (var conn = Db.OpenConnection())
            using (var tx = conn.BeginTransaction())
            {
                if (!Exists(conn, tx, "SELECT 1 FROM INTAKES WHERE intake_id=@id",
                    cmd => cmd.Parameters.AddWithValue("@id", intakeId)))
                    throw new ArgumentException("The selected intake no longer exists.");

                var nextUserId = NextInt(conn, tx, "USERS", "user_id");
                foreach (var row in rows)
                {
                    var programmeId = ResolveProgrammeExact(conn, tx, row.ProgrammeCode);
                    if (string.IsNullOrWhiteSpace(programmeId))
                        throw new ArgumentException("Unknown programme code: " + row.ProgrammeCode);

                    var userId = nextUserId++;
                    var studentId = "S" + userId.ToString("00000");
                    var password = GenerateTempPassword();
                    var username = UniqueUsername(conn, tx, row.InstitutionalEmail, userId);
                    var status = NormalizeStatus(row.Status);

                    using (var cmd = new SqlCommand(
                        "INSERT INTO USERS (user_id,username,email,password_hash,role,status,created_at) " +
                        "VALUES (@id,@username,@email,@hash,'STUDENT',@status,GETDATE())", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@id", userId);
                        cmd.Parameters.AddWithValue("@username", username);
                        cmd.Parameters.AddWithValue("@email", row.InstitutionalEmail.Trim());
                        cmd.Parameters.AddWithValue("@hash", Sha256Hex(password));
                        cmd.Parameters.AddWithValue("@status", status);
                        cmd.ExecuteNonQuery();
                    }

                    using (var cmd = new SqlCommand(
                        "INSERT INTO STUDENTS (student_id,user_id,programme_id,student_name,student_email,phone," +
                        "semester,current_standing,session,intake_id,status) " +
                        "VALUES (@sid,@uid,@programme,@name,@email,@phone,1,'Good Standing','',@intake,@status)",
                        conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@programme", programmeId);
                        cmd.Parameters.AddWithValue("@name", row.FullName.Trim());
                        cmd.Parameters.AddWithValue("@email", row.InstitutionalEmail.Trim());
                        cmd.Parameters.AddWithValue("@phone", string.IsNullOrWhiteSpace(row.Phone)
                            ? (object)DBNull.Value : row.Phone.Trim());
                        cmd.Parameters.AddWithValue("@intake", intakeId);
                        cmd.Parameters.AddWithValue("@status", status);
                        cmd.ExecuteNonQuery();
                    }

                    result.Created.Add(new StudentBulkCreatedAccount
                    {
                        StudentId = studentId,
                        FullName = row.FullName.Trim(),
                        InstitutionalEmail = row.InstitutionalEmail.Trim(),
                        PersonalEmail = string.IsNullOrWhiteSpace(row.PersonalEmail)
                            ? row.InstitutionalEmail.Trim() : row.PersonalEmail.Trim(),
                        ProgrammeId = programmeId,
                        TemporaryPassword = password
                    });
                }
                tx.Commit();
            }
            return result;
        }

        public StudentIntakeMatch MatchIntake(DateTime registrationDate)
        {
            AcademicIntakeSchema.Ensure();
            using (var conn = Db.OpenConnection())
            {
                const string exactSql =
                    "SELECT TOP 1 i.intake_id,i.intake_name " +
                    "FROM ACADEMIC_SESSIONS s JOIN INTAKES i ON i.intake_id=s.intake_id " +
                    "WHERE @date BETWEEN DATEADD(day,-7,s.start_date) AND DATEADD(day,7,s.start_date) " +
                    "ORDER BY s.start_date";
                using (var cmd = new SqlCommand(exactSql, conn))
                {
                    cmd.Parameters.AddWithValue("@date", registrationDate.Date);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                            return new StudentIntakeMatch
                            {
                                Id = Convert.ToString(reader["intake_id"]),
                                Name = Convert.ToString(reader["intake_name"]),
                                IsRegistrationWindowMatch = true
                            };
                    }
                }

                const string fallbackSql =
                    "SELECT TOP 1 i.intake_id,i.intake_name " +
                    "FROM INTAKES i LEFT JOIN ACADEMIC_SESSIONS s ON s.intake_id=i.intake_id " +
                    "WHERE UPPER(ISNULL(i.status,'ACTIVE'))='ACTIVE' " +
                    "ORDER BY CASE WHEN ISNULL(s.start_date,i.intake_month)>=@date THEN 0 ELSE 1 END," +
                    "ABS(DATEDIFF(day,@date,ISNULL(s.start_date,i.intake_month)))";
                using (var cmd = new SqlCommand(fallbackSql, conn))
                {
                    cmd.Parameters.AddWithValue("@date", registrationDate.Date);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return null;
                        return new StudentIntakeMatch
                        {
                            Id = Convert.ToString(reader["intake_id"]),
                            Name = Convert.ToString(reader["intake_name"])
                        };
                    }
                }
            }
        }

        public List<StudentIntakeMatch> GetIntakes()
        {
            AcademicIntakeSchema.Ensure();
            var result = new List<StudentIntakeMatch>();
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                "SELECT intake_id,intake_name FROM INTAKES ORDER BY intake_month DESC", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                    result.Add(new StudentIntakeMatch
                    {
                        Id = Convert.ToString(reader["intake_id"]),
                        Name = Convert.ToString(reader["intake_name"])
                    });
            }
            return result;
        }

        private static void Validate(List<StudentBulkRow> rows)
        {
            var fileEmails = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var programmes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var existingEmails = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            using (var conn = Db.OpenConnection())
            {
                using (var cmd = new SqlCommand("SELECT programme_id FROM PROGRAMMES UNION SELECT programme_code FROM PROGRAMMES", conn))
                using (var reader = cmd.ExecuteReader())
                    while (reader.Read()) programmes.Add(Convert.ToString(reader[0]));

                using (var cmd = new SqlCommand("SELECT email FROM USERS", conn))
                using (var reader = cmd.ExecuteReader())
                    while (reader.Read()) existingEmails.Add(Convert.ToString(reader[0]));
            }

            foreach (var row in rows)
            {
                var errors = new List<string>();
                if (string.IsNullOrWhiteSpace(row.FullName)) errors.Add("Full name is required.");
                if (!IsEmail(row.InstitutionalEmail)) errors.Add("A valid institutional email is required.");
                if (!string.IsNullOrWhiteSpace(row.PersonalEmail) && !IsEmail(row.PersonalEmail))
                    errors.Add("Personal email is invalid.");
                if (string.IsNullOrWhiteSpace(row.ProgrammeCode) || !programmes.Contains(row.ProgrammeCode.Trim()))
                    errors.Add("Programme code was not found.");
                if (!string.IsNullOrWhiteSpace(row.InstitutionalEmail))
                {
                    if (!fileEmails.Add(row.InstitutionalEmail.Trim())) errors.Add("Email is duplicated in this file.");
                    if (existingEmails.Contains(row.InstitutionalEmail.Trim())) errors.Add("Email already exists.");
                }
                var status = (row.Status ?? "").Trim().ToUpperInvariant();
                if (status != "" && status != "ACTIVE" && status != "PENDING" && status != "INACTIVE")
                    errors.Add("Status must be Active, Pending, or Inactive.");
                row.Errors = errors;
            }
        }

        private static List<StudentBulkRow> ReadWorkbook(Stream stream)
        {
            if (stream == null || !stream.CanRead) throw new ArgumentException("Choose an Excel file to upload.");
            using (var archive = new ZipArchive(stream, ZipArchiveMode.Read, true))
            {
                var sharedStrings = ReadSharedStrings(archive);
                var sheetEntry = archive.GetEntry("xl/worksheets/sheet1.xml");
                if (sheetEntry == null) throw new ArgumentException("The workbook must contain a first worksheet.");
                if (sheetEntry.Length > 10 * 1024 * 1024)
                    throw new ArgumentException("The worksheet is too large to import.");
                XDocument sheet;
                using (var input = sheetEntry.Open()) sheet = XDocument.Load(input);
                XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                var rows = sheet.Descendants(ns + "row").ToList();
                if (rows.Count == 0) throw new ArgumentException("The worksheet is empty.");

                XElement headerRow = null;
                List<string> headerValues = null;
                foreach (var candidate in rows.Take(20))
                {
                    var candidateValues = ReadRow(candidate, ns, sharedStrings);
                    if (RequiredHeaders.All(required =>
                        candidateValues.Any(value => string.Equals(
                            (value ?? "").Trim(), required, StringComparison.OrdinalIgnoreCase))))
                    {
                        headerRow = candidate;
                        headerValues = candidateValues;
                        break;
                    }
                }
                if (headerRow == null)
                    throw new ArgumentException("The template header row could not be found. Please use the downloaded template.");

                var headerMap = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
                for (var i = 0; i < headerValues.Count; i++)
                    if (!string.IsNullOrWhiteSpace(headerValues[i])) headerMap[headerValues[i].Trim()] = i;
                var missing = RequiredHeaders.Where(h => !headerMap.ContainsKey(h)).ToList();
                if (missing.Count > 0)
                    throw new ArgumentException("Missing template columns: " + string.Join(", ", missing));

                var result = new List<StudentBulkRow>();
                var headerIndex = rows.IndexOf(headerRow);
                for (var i = headerIndex + 1; i < rows.Count; i++)
                {
                    var values = ReadRow(rows[i], ns, sharedStrings);
                    Func<string, string> value = h =>
                    {
                        var index = headerMap[h];
                        return index < values.Count ? (values[index] ?? "").Trim() : "";
                    };
                    if (RequiredHeaders.All(h => string.IsNullOrWhiteSpace(value(h)))) continue;
                    int excelRowNumber;
                    if (!int.TryParse((string)rows[i].Attribute("r"), out excelRowNumber))
                        excelRowNumber = i + 1;
                    result.Add(new StudentBulkRow
                    {
                        RowNumber = excelRowNumber,
                        FullName = value("Full Name"),
                        InstitutionalEmail = value("Institutional Email"),
                        PersonalEmail = value("Personal Email"),
                        Phone = value("Phone"),
                        ProgrammeCode = value("Programme Code"),
                        Status = value("Status")
                    });
                }
                if (result.Count == 0) throw new ArgumentException("No student rows were found.");
                if (result.Count > 500) throw new ArgumentException("Import a maximum of 500 students at a time.");
                return result;
            }
        }

        private static List<string> ReadSharedStrings(ZipArchive archive)
        {
            var result = new List<string>();
            var entry = archive.GetEntry("xl/sharedStrings.xml");
            if (entry == null) return result;
            if (entry.Length > 10 * 1024 * 1024)
                throw new ArgumentException("The workbook text content is too large to import.");
            XDocument doc;
            using (var input = entry.Open()) doc = XDocument.Load(input);
            XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
            foreach (var item in doc.Descendants(ns + "si"))
                result.Add(string.Concat(item.Descendants(ns + "t").Select(t => t.Value)));
            return result;
        }

        private static List<string> ReadRow(XElement row, XNamespace ns, IList<string> sharedStrings)
        {
            var result = new List<string>();
            foreach (var cell in row.Elements(ns + "c"))
            {
                var reference = (string)cell.Attribute("r") ?? "";
                var columnIndex = ColumnIndex(reference);
                while (result.Count <= columnIndex) result.Add("");
                var type = (string)cell.Attribute("t") ?? "";
                string value;
                if (type == "inlineStr")
                    value = string.Concat(cell.Descendants(ns + "t").Select(t => t.Value));
                else
                {
                    value = (string)cell.Element(ns + "v") ?? "";
                    int sharedIndex;
                    if (type == "s" && int.TryParse(value, out sharedIndex) &&
                        sharedIndex >= 0 && sharedIndex < sharedStrings.Count)
                        value = sharedStrings[sharedIndex];
                }
                result[columnIndex] = value;
            }
            return result;
        }

        private static int ColumnIndex(string reference)
        {
            var letters = new string((reference ?? "").TakeWhile(char.IsLetter).ToArray()).ToUpperInvariant();
            var index = 0;
            foreach (var c in letters) index = index * 26 + (c - 'A' + 1);
            return Math.Max(0, index - 1);
        }

        private static bool IsEmail(string value)
        {
            return !string.IsNullOrWhiteSpace(value) &&
                   Regex.IsMatch(value.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]+$");
        }

        private static int NextInt(SqlConnection conn, SqlTransaction tx, string table, string column)
        {
            using (var cmd = new SqlCommand("SELECT ISNULL(MAX(" + column + "),0)+1 FROM " + table, conn, tx))
                return Convert.ToInt32(cmd.ExecuteScalar(), CultureInfo.InvariantCulture);
        }

        private static string ResolveProgrammeExact(SqlConnection conn, SqlTransaction tx, string code)
        {
            using (var cmd = new SqlCommand(
                "SELECT TOP 1 programme_id FROM PROGRAMMES WHERE programme_id=@code OR programme_code=@code", conn, tx))
            {
                cmd.Parameters.AddWithValue("@code", (code ?? "").Trim());
                return Convert.ToString(cmd.ExecuteScalar());
            }
        }

        private static bool Exists(SqlConnection conn, SqlTransaction tx, string sql, Action<SqlCommand> bind)
        {
            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                if (bind != null) bind(cmd);
                return cmd.ExecuteScalar() != null;
            }
        }

        private static string UniqueUsername(SqlConnection conn, SqlTransaction tx, string email, int userId)
        {
            var name = (email ?? "").Split('@')[0];
            if (string.IsNullOrWhiteSpace(name)) name = "student";
            using (var cmd = new SqlCommand("SELECT 1 FROM USERS WHERE username=@name", conn, tx))
            {
                cmd.Parameters.AddWithValue("@name", name);
                return cmd.ExecuteScalar() == null ? name : name + userId;
            }
        }

        private static string NormalizeStatus(string status)
        {
            var value = (status ?? "ACTIVE").Trim().ToUpperInvariant();
            return value == "PENDING" || value == "INACTIVE" ? value : "ACTIVE";
        }

        private static string GenerateTempPassword()
        {
            const string upper = "ABCDEFGHJKLMNPQRSTUVWXYZ";
            const string lower = "abcdefghijkmnopqrstuvwxyz";
            const string digits = "23456789";
            const string symbols = "!@#$%&*";
            const string all = upper + lower + digits + symbols;
            var bytes = new byte[12];
            using (var rng = RandomNumberGenerator.Create()) rng.GetBytes(bytes);
            var chars = new char[12];
            chars[0] = upper[bytes[0] % upper.Length];
            chars[1] = lower[bytes[1] % lower.Length];
            chars[2] = digits[bytes[2] % digits.Length];
            chars[3] = symbols[bytes[3] % symbols.Length];
            for (var i = 4; i < chars.Length; i++) chars[i] = all[bytes[i] % all.Length];
            return new string(chars);
        }

        private static string Sha256Hex(string value)
        {
            using (var sha = SHA256.Create())
                return string.Concat(sha.ComputeHash(Encoding.UTF8.GetBytes(value ?? "")).Select(b => b.ToString("x2")));
        }
    }

    [Serializable]
    public class StudentBulkRow
    {
        public int RowNumber { get; set; }
        public string FullName { get; set; }
        public string InstitutionalEmail { get; set; }
        public string PersonalEmail { get; set; }
        public string Phone { get; set; }
        public string ProgrammeCode { get; set; }
        public string Status { get; set; }
        public List<string> Errors { get; set; } = new List<string>();
        public bool IsValid { get { return Errors == null || Errors.Count == 0; } }
    }

    [Serializable]
    public class StudentBulkPreview
    {
        public DateTime RegistrationDate { get; set; }
        public string IntakeId { get; set; }
        public string IntakeName { get; set; }
        public string IntakeMatchMessage { get; set; }
        public List<StudentIntakeMatch> IntakeOptions { get; set; } = new List<StudentIntakeMatch>();
        public List<StudentBulkRow> Rows { get; set; } = new List<StudentBulkRow>();
        public int ValidCount { get { return Rows.Count(r => r.IsValid); } }
        public int ErrorCount { get { return Rows.Count(r => !r.IsValid); } }
    }

    [Serializable]
    public class StudentIntakeMatch
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public bool IsRegistrationWindowMatch { get; set; }
    }

    public class StudentBulkImportResult
    {
        public string IntakeId { get; set; }
        public List<StudentBulkCreatedAccount> Created { get; set; } = new List<StudentBulkCreatedAccount>();
    }

    public class StudentBulkCreatedAccount
    {
        public string StudentId { get; set; }
        public string FullName { get; set; }
        public string InstitutionalEmail { get; set; }
        public string PersonalEmail { get; set; }
        public string ProgrammeId { get; set; }
        public string TemporaryPassword { get; set; }
    }
}
