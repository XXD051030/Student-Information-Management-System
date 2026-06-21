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
            const string sql =
                "SELECT TOP 1 session_id, academic_year, semester, start_date, end_date " +
                "FROM ACADEMIC_SESSIONS " +
                "WHERE start_date <= @today AND end_date >= @today " +
                "ORDER BY start_date DESC";
            return GetTerm(sql);
        }

        public static StudentRegistrationTerm GetRegistrationTerm()
        {
            // If the current term's own add/drop window (start .. start+7) is still live,
            // that is the relevant term — a student mid-term shouldn't be bounced ahead
            // to the next term's pre-registration window. Otherwise registration is for
            // the next upcoming term (the one that has not started yet), so the window
            // sits before that term begins. Fall back to the current term only when there
            // is no future session in the calendar.
            var current = GetCurrentTerm();
            if (current != null && DateTime.Today <= current.StartDate.AddDays(WindowDaysAfterStart))
                return current;

            const string sql =
                "SELECT TOP 1 session_id, academic_year, semester, start_date, end_date " +
                "FROM ACADEMIC_SESSIONS " +
                "WHERE start_date > @today " +
                "ORDER BY start_date";
            return GetTerm(sql) ?? current;
        }

        private static StudentRegistrationTerm GetTerm(string sql)
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
                    ? sql.Replace(
                        "start_date, end_date ",
                        "start_date, end_date, min_credits, max_credits ")
                    : sql;

                using (var cmd = new SqlCommand(compatibleSql, conn))
                {
                    cmd.Parameters.AddWithValue("@today", DateTime.Today);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return null;
                        return new StudentRegistrationTerm
                        {
                            SessionId = Text(reader["session_id"]),
                            AcademicYear = Text(reader["academic_year"]),
                            Name = Text(reader["semester"]),
                            StartDate = DateValue(reader["start_date"]) ?? DateTime.Today,
                            EndDate = DateValue(reader["end_date"]) ?? DateTime.Today.AddMonths(4),
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
            var registrationStart = term.StartDate.AddDays(-WindowDaysBeforeStart);
            var registrationEnd = term.StartDate.AddDays(-1);
            var addDropStart = term.StartDate;
            var addDropEnd = term.StartDate.AddDays(WindowDaysAfterStart);

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
    }
}
