using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;
using static src.services.ServiceMap;
using static src.services.StudentPortalFormat;

namespace src.services
{
    public static class StudentPaymentReader
    {
        // Insert one PAID payment for the logged-in student; returns the generated invoice no.
        public static string RecordPayment(UserContext user, decimal amount, string description, string termLabel, string method)
        {
            if (!IsStudent(user) || amount <= 0m) return null;

            var account = StudentProfileReader.GetAccount(user);
            if (account == null) return null;

            const string sql =
                "DECLARE @inv VARCHAR(30); " +
                "INSERT INTO PAYMENTS (invoice_no, student_id, description, term_label, method, amount, status, paid_date) " +
                "VALUES ('PENDING', @studentId, @description, @termLabel, @method, @amount, 'PAID', GETDATE()); " +
                "SET @inv = 'INV-' + CONVERT(VARCHAR(4), YEAR(GETDATE())) + '-' + RIGHT('0000' + CONVERT(VARCHAR(10), SCOPE_IDENTITY()), 4); " +
                "UPDATE PAYMENTS SET invoice_no = @inv WHERE payment_id = SCOPE_IDENTITY(); " +
                // Each successful payment advances the student to the next semester.
                "UPDATE STUDENTS SET semester = ISNULL(semester, 0) + 1 WHERE student_id = @studentId; " +
                "SELECT @inv";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@studentId", account.StudentId);
                cmd.Parameters.AddWithValue("@description", (object)description ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@termLabel", (object)termLabel ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@method", (object)method ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@amount", amount);
                var result = cmd.ExecuteScalar();
                return result == null ? null : result.ToString();
            }
        }

        public static StudentPaymentHistoryPage GetHistoryPage(UserContext user)
        {
            var page = new StudentPaymentHistoryPage { Rows = new List<StudentPaymentRow>() };
            if (!IsStudent(user)) return page;

            var account = StudentProfileReader.GetAccount(user);
            if (account == null) return page;

            const string sql =
                "SELECT invoice_no, description, term_label, paid_date, method, amount, status " +
                "FROM PAYMENTS WHERE student_id = @studentId ORDER BY paid_date DESC, payment_id DESC";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@studentId", account.StudentId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var status = Text(reader["status"]);
                        var amount = DecimalValue(reader["amount"]) ?? 0m;
                        var paid = DateValue(reader["paid_date"]) ?? DateTime.Today;
                        page.Rows.Add(new StudentPaymentRow
                        {
                            InvoiceNo = Text(reader["invoice_no"]),
                            Description = Text(reader["description"]),
                            TermLabel = Text(reader["term_label"]),
                            PaidDate = paid,
                            Method = MethodLabel(Text(reader["method"])),
                            Amount = amount,
                            Status = status
                        });

                        page.ReceiptCount++;
                        if (string.Equals(status, "REFUNDED", StringComparison.OrdinalIgnoreCase))
                            page.Refunded += amount;
                        else
                        {
                            page.TotalPaid += amount;
                            if (paid.Year == DateTime.Today.Year) page.PaidThisYear += amount;
                        }
                    }
                }
            }
            return page;
        }

        private static string MethodLabel(string method)
        {
            switch ((method ?? "").ToLowerInvariant())
            {
                case "card": return "Credit / Debit Card";
                case "bank": return "FPX Online Banking";
                case "ewallet": return "E-Wallet";
                default: return string.IsNullOrEmpty(method) ? "—" : method;
            }
        }
    }
}
