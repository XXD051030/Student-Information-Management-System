using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>Course header + sidebar fields for one offering.</summary>
    public class CourseHeader
    {
        public int CourseId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string Color { get; set; }
        public string Description { get; set; }
        public string LevelLabel { get; set; }
        public string LecturerName { get; set; }
        public string SemesterName { get; set; }
        public int ModuleCount { get; set; }
        public string Mode { get; set; }
        public string ContactHours { get; set; }
        public string Prerequisites { get; set; }
        public string Textbook { get; set; }
        public string OfficeHours { get; set; }
    }

    /// <summary>One learning-outcome bullet.</summary>
    public class LearningOutcome { public string Text { get; set; } }

    /// <summary>
    /// Read-only course-detail header for an offering, scoped to a student. Returns
    /// null when the student behind <paramref name="userId"/> is not enrolled in the
    /// offering (callers redirect). SQL exceptions propagate to the caller.
    /// </summary>
    public static class CourseDetailService
    {
        // Header for an offering the student is enrolled in. OUTER APPLY TOP 1
        // picks one lecturer; the module count is a correlated subquery.
        private const string SelectHeader =
            "SELECT c.course_id, c.course_code, c.course_name, c.credit_hours, c.color, " +
            "c.description, c.level_label, c.mode, c.contact_hours, c.prerequisites, " +
            "c.textbook, c.office_hours, sem.name AS semester_name, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, " +
            "(SELECT COUNT(*) FROM MODULES m WHERE m.offering_id = o.offering_id) AS module_count " +
            "FROM COURSE_OFFERINGS o " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id AND s.user_id = @userId " +
            "OUTER APPLY (SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE o.offering_id = @offeringId";

        public static CourseHeader GetHeader(int offeringId, int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectHeader, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;   // not enrolled / no such offering
                    return new CourseHeader
                    {
                        CourseId = (int)reader["course_id"],
                        CourseCode = reader["course_code"].ToString(),
                        CourseName = reader["course_name"].ToString(),
                        CreditHours = (int)reader["credit_hours"],
                        Color = reader["color"] == System.DBNull.Value ? "" : reader["color"].ToString(),
                        Description = Str(reader["description"]),
                        LevelLabel = Str(reader["level_label"]),
                        LecturerName = reader["lecturer_name"].ToString(),
                        SemesterName = reader["semester_name"].ToString(),
                        ModuleCount = (int)reader["module_count"],
                        Mode = Str(reader["mode"]),
                        ContactHours = Str(reader["contact_hours"]),
                        Prerequisites = Str(reader["prerequisites"]),
                        Textbook = Str(reader["textbook"]),
                        OfficeHours = Str(reader["office_hours"])
                    };
                }
            }
        }

        private const string SelectOutcomes =
            "SELECT outcome_text FROM LEARNING_OUTCOMES " +
            "WHERE course_id = @courseId ORDER BY sort_order";

        public static List<LearningOutcome> GetLearningOutcomes(int courseId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectOutcomes, conn))
            {
                cmd.Parameters.AddWithValue("@courseId", courseId);
                var list = new List<LearningOutcome>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        list.Add(new LearningOutcome { Text = reader["outcome_text"].ToString() });
                }
                return list;
            }
        }

        private static string Str(object value)
        {
            return value == System.DBNull.Value ? "" : value.ToString();
        }
    }
}
