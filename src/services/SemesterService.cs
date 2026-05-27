using System;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// The current academic semester, read from the SEMESTERS table.
    /// </summary>
    public class Semester
    {
        public int SemesterId { get; set; }
        public string Name { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

        /// <summary>Total number of teaching weeks in the semester.</summary>
        public int TotalWeeks
        {
            get { return ((EndDate - StartDate).Days / 7) + 1; }
        }

        /// <summary>
        /// The current teaching week, counting from the start date and clamped to
        /// the semester range so it never reads below 1 or beyond the last week.
        /// </summary>
        public int CurrentWeek
        {
            get
            {
                int week = ((DateTime.Today - StartDate).Days / 7) + 1;
                if (week < 1) return 1;
                if (week > TotalWeeks) return TotalWeeks;
                return week;
            }
        }
    }

    /// <summary>
    /// Read-only access to semester information. Returns null when no current
    /// semester is configured. SQL exceptions are not caught here; they
    /// propagate to the caller.
    /// </summary>
    public static class SemesterService
    {
        private const string SelectSemester =
            "SELECT semester_id, name, start_date, end_date FROM SEMESTERS ";

        public static Semester GetCurrent()
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectSemester + "WHERE is_current = 1", conn))
            {
                using (var reader = cmd.ExecuteReader())
                {
                    return reader.Read() ? MapSemester(reader) : null;
                }
            }
        }

        private static Semester MapSemester(SqlDataReader reader)
        {
            return new Semester
            {
                SemesterId = (int)reader["semester_id"],
                Name = reader["name"].ToString(),
                StartDate = (DateTime)reader["start_date"],
                EndDate = (DateTime)reader["end_date"]
            };
        }
    }
}
