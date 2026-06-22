using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using src.db;
using static src.services.ServiceMap;
using static src.services.StudentPortalFormat;

namespace src.services
{
    public static class AcademicTermReader
    {
        // Credit-load bounds used when a session row leaves them unset (NULL).
        private const int DefaultMinCredits = 12;
        private const int DefaultMaxCredits = 21;

        // The enrollment portal opens 7 days before a session starts and closes
        // 7 days after it starts. These bounds are derived from start_date alone.
        private const int WindowDaysBeforeStart = 7;
        private const int WindowDaysAfterStart = 7;

        public static StudentRegistrationTerm GetCurrentTerm()
        {
            AcademicIntakeSchema.Ensure();
            const string sql =
                "SELECT TOP 1 s.session_id, s.academic_year, s.semester, s.start_date, s.end_date, " +
                "s.intake_id, i.intake_name, s.min_credits, s.max_credits " +
                "FROM ACADEMIC_SESSIONS " +
                "s LEFT JOIN INTAKES i ON i.intake_id=s.intake_id " +
                "WHERE s.start_date <= @today AND s.end_date >= @today " +
                "ORDER BY s.start_date DESC";
            return GetTerm(sql);
        }

        public static StudentRegistrationTerm GetRegistrationTerm()
        {
            return GetRegistrationTerm(null);
        }

        public static StudentRegistrationTerm GetRegistrationTerm(UserContext user)
        {
            AcademicIntakeSchema.Ensure();
            // If the current term's own add/drop window (start .. start+7) is still live,
            // that is the relevant term — a student mid-term shouldn't be bounced ahead
            // to the next term's pre-registration window. Otherwise registration is for
            // the next upcoming term (the one that has not started yet), so the window
            // sits before that term begins. Fall back to the current term only when there
            // is no future session in the calendar.
            var current = user == null ? GetCurrentTerm() : GetCurrentTermForUser(user);
            if (current != null && DateTime.Today <= current.StartDate.AddDays(WindowDaysAfterStart))
                return current;

            string intakeFilter = user != null && user.IsStudent
                ? " AND (s.intake_id=(SELECT intake_id FROM STUDENTS WHERE user_id=@userId) OR " +
                  "(SELECT intake_id FROM STUDENTS WHERE user_id=@userId) IS NULL)"
                : "";
            const string sqlBase =
                "SELECT TOP 1 s.session_id, s.academic_year, s.semester, s.start_date, s.end_date, " +
                "s.intake_id, i.intake_name, s.min_credits, s.max_credits " +
                "FROM ACADEMIC_SESSIONS s LEFT JOIN INTAKES i ON i.intake_id=s.intake_id " +
                "WHERE DATEADD(day,-7,s.start_date)<=@today AND DATEADD(day,7,s.start_date)>=@today";
            var result = GetTerm(sqlBase + intakeFilter + " ORDER BY s.start_date", user) ?? current;
            // When no session matches the student's specific intake, fall back to any
            // registration-open session — handles students whose intake_id was set to a
            // future cohort (e.g. NOV2026) while the currently open window belongs to
            // a different intake (e.g. JUN2026).
            if (result == null && intakeFilter.Length > 0)
                result = GetTerm(sqlBase + " ORDER BY s.start_date", user);
            return result;
        }

        private static StudentRegistrationTerm GetCurrentTermForUser(UserContext user)
        {
            const string sql =
                "SELECT TOP 1 s.session_id, s.academic_year, s.semester, s.start_date, s.end_date, " +
                "s.intake_id, i.intake_name, s.min_credits, s.max_credits " +
                "FROM ACADEMIC_SESSIONS s LEFT JOIN INTAKES i ON i.intake_id=s.intake_id " +
                "WHERE s.start_date<=@today AND s.end_date>=@today " +
                "AND (s.intake_id=(SELECT intake_id FROM STUDENTS WHERE user_id=@userId) OR " +
                "(SELECT intake_id FROM STUDENTS WHERE user_id=@userId) IS NULL) ORDER BY s.start_date DESC";
            return GetTerm(sql, user);
        }

        private static StudentRegistrationTerm GetTerm(string sql, UserContext user = null)
        {
            using (var conn = Db.OpenConnection())
            {
                bool hasCreditBounds;
                using (var schemaCmd = new SqlCommand(
                    "SELECT CASE WHEN " +
                    "COL_LENGTH('dbo.ACADEMIC_SESSIONS', 'min_credits') IS NOT NULL AND " +
                    "COL_LENGTH('dbo.ACADEMIC_SESSIONS', 'max_credits') IS NOT NULL " +
                    "THEN 1 ELSE 0 END",
                    conn))
                {
                    hasCreditBounds = Convert.ToInt32(schemaCmd.ExecuteScalar()) == 1;
                }

                string compatibleSql = hasCreditBounds
                    ? sql
                    : sql.Replace(", s.min_credits, s.max_credits ", " ");

                using (var cmd = new SqlCommand(compatibleSql, conn))
                {
                    cmd.Parameters.AddWithValue("@today", DateTime.Today);
                    if (sql.Contains("@userId")) cmd.Parameters.AddWithValue("@userId", user == null ? 0 : user.UserId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return null;
                        return new StudentRegistrationTerm
                        {
                            SessionId = Text(reader["session_id"]),
                            AcademicYear = Text(reader["academic_year"]),
                            IntakeId = HasColumn(reader, "intake_id") ? Text(reader["intake_id"]) : "",
                            IntakeName = HasColumn(reader, "intake_name") ? Text(reader["intake_name"]) : "",
                            Name = Text(reader["semester"]),
                            StartDate = DateValue(reader["start_date"]) ?? DateTime.Today,
                            EndDate = DateValue(reader["end_date"]) ?? DateTime.Today.AddMonths(4),
                            RegistrationStart = (DateValue(reader["start_date"]) ?? DateTime.Today).AddDays(-WindowDaysBeforeStart),
                            RegistrationEnd = (DateValue(reader["start_date"]) ?? DateTime.Today).AddDays(-1),
                            AddDropEnd = (DateValue(reader["start_date"]) ?? DateTime.Today).AddDays(WindowDaysAfterStart),
                            MinCredits = hasCreditBounds
                                ? NullableInt(reader["min_credits"]) ?? DefaultMinCredits
                                : DefaultMinCredits,
                            MaxCredits = hasCreditBounds
                                ? NullableInt(reader["max_credits"]) ?? DefaultMaxCredits
                                : DefaultMaxCredits
                        };
                    }
                }
            }
        }

        public static StudentRegistrationWindow BuildRegistrationWindow(StudentRegistrationTerm term, bool hasEnrollment)
        {
            if (term == null) return new StudentRegistrationWindow();

            var today = DateTime.Today;

            // The portal opens 7 days before classes start and closes 7 days after.
            // Phase 1 (registration) runs from start-7 up to the day before classes.
            // Once classes start, a student with no enrollment yet stays in Phase 1
            // (direct self-registration) through start+7; Phase 2 (request-based
            // add/drop) only applies once the student actually holds an enrollment.
            var registrationStart = term.RegistrationStart;
            var registrationEnd = term.RegistrationEnd;
            var addDropStart = term.StartDate;
            var addDropEnd = term.AddDropEnd;

            int activePhase;
            if (today <= registrationEnd) activePhase = 1;
            else if (today > addDropEnd) activePhase = 3;
            else activePhase = hasEnrollment ? 2 : 1;

            return new StudentRegistrationWindow
            {
                RegistrationStart = registrationStart,
                RegistrationEnd = registrationEnd,
                AddDropStart = addDropStart,
                AddDropEnd = addDropEnd,
                IsOpen = today >= registrationStart && today <= addDropEnd,
                ActivePhase = activePhase
            };
        }

        private static bool HasColumn(SqlDataReader reader, string name)
        {
            for (var i = 0; i < reader.FieldCount; i++)
                if (string.Equals(reader.GetName(i), name, StringComparison.OrdinalIgnoreCase)) return true;
            return false;
        }

        /// <summary>
        /// Returns true when today falls inside the registration phase (Phase 1):
        /// the 7 days before the registration term's start date, or — once classes
        /// start — any time before add/drop+7 as long as the student has no enrollment yet.
        /// </summary>
        public static bool IsRegistrationOpen(bool hasEnrollment)
        {
            var term = GetRegistrationTerm();
            if (term == null) return false;
            var window = BuildRegistrationWindow(term, hasEnrollment);
            return window.IsOpen && window.ActivePhase == 1;
        }

        /// <summary>Returns true when today falls inside the add/drop window (ActivePhase == 2), which requires an existing enrollment.</summary>
        public static bool IsAddDropOpen(bool hasEnrollment)
        {
            var term = GetRegistrationTerm();
            if (term == null) return false;
            var window = BuildRegistrationWindow(term, hasEnrollment);
            return window.ActivePhase == 2;
        }

        public static Dictionary<string, DateTime> GetSessionLookup()
        {
            var lookup = new Dictionary<string, DateTime>(StringComparer.OrdinalIgnoreCase);
            const string sql = "SELECT academic_year, semester, start_date FROM ACADEMIC_SESSIONS";
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    lookup[Text(reader["academic_year"]) + " " + Text(reader["semester"])] = DateValue(reader["start_date"]) ?? DateTime.Today;
                }
            }
            return lookup;
        }

        public static List<AcademicSessionOption> GetSessionOptions()
        {
            var options = new List<AcademicSessionOption>();
            const string sql =
                "SELECT academic_year, semester, MIN(start_date) AS start_date, MAX(end_date) AS end_date " +
                "FROM ACADEMIC_SESSIONS GROUP BY academic_year, semester " +
                "ORDER BY MIN(start_date), academic_year, semester";
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    options.Add(new AcademicSessionOption
                    {
                        AcademicYear = Text(reader["academic_year"]),
                        Semester = Text(reader["semester"]),
                        StartDate = DateValue(reader["start_date"]) ?? DateTime.Today,
                        EndDate = DateValue(reader["end_date"]) ?? DateTime.Today.AddMonths(4)
                    });
                }
            }
            return options;
        }
    }
}
