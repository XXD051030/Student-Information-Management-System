using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// One assignment on a student's enrolled courses.
    /// </summary>
    public class Assignment
    {
        public int AssignmentId { get; set; }
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public string Title { get; set; }
        public DateTime DueDate { get; set; }
    }

    /// <summary>One assignment on a course-detail page, with the student's submission state.</summary>
    public class CourseAssignment
    {
        public string Title { get; set; }
        public decimal? Weight { get; set; }
        public string AssignmentType { get; set; }
        public string GroupSize { get; set; }
        public string Description { get; set; }
        public DateTime DueDate { get; set; }
        /// <summary>"OPEN" (no submission), "SUBMITTED", or "MARKED".</summary>
        public string SubmissionStatus { get; set; }
        public decimal? Marks { get; set; }
    }

    /// <summary>
    /// Read-only access to assignments for a student's current-semester
    /// enrolled courses. Returns an empty list when there are none. SQL
    /// exceptions are not caught here; they propagate to the caller.
    /// </summary>
    public static class AssignmentService
    {
        private const string SelectAssignments =
            "SELECT a.assignment_id, o.offering_id, c.course_code, c.course_name, " +
            "a.title, a.due_date " +
            "FROM ASSIGNMENTS a " +
            "JOIN COURSE_OFFERINGS o ON a.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id " +
            "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' ";

        /// <summary>
        /// Assignments due within the next 7 days (today through today + 6 days),
        /// ordered by due date.
        /// </summary>
        public static List<Assignment> GetDueThisWeek(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                SelectAssignments +
                "AND a.due_date >= @weekStart AND a.due_date <= @weekEnd " +
                "ORDER BY a.due_date", conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@weekStart", DateTime.Today);
                cmd.Parameters.AddWithValue("@weekEnd", DateTime.Today.AddDays(6));
                return ReadAssignments(cmd);
            }
        }

        /// <summary>
        /// Count of current-semester assignments on the student's enrolled courses
        /// that the student has not yet submitted.
        /// </summary>
        public static int GetPendingTaskCount(int userId)
        {
            const string sql =
                "SELECT COUNT(*) " +
                "FROM ASSIGNMENTS a " +
                "JOIN COURSE_OFFERINGS o ON a.offering_id = o.offering_id " +
                "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
                "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
                "JOIN STUDENTS s ON e.student_id = s.student_id " +
                "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' " +
                "AND NOT EXISTS (SELECT 1 FROM SUBMISSIONS sub " +
                "WHERE sub.assignment_id = a.assignment_id AND sub.student_id = s.student_id)";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                return (int)cmd.ExecuteScalar();
            }
        }

        private static List<Assignment> ReadAssignments(SqlCommand cmd)
        {
            var assignments = new List<Assignment>();
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    assignments.Add(MapAssignment(reader));
                }
            }
            return assignments;
        }

        private static Assignment MapAssignment(SqlDataReader reader)
        {
            return new Assignment
            {
                AssignmentId = (int)reader["assignment_id"],
                OfferingId = (int)reader["offering_id"],
                CourseCode = reader["course_code"].ToString(),
                CourseName = reader["course_name"].ToString(),
                Title = reader["title"].ToString(),
                DueDate = (DateTime)reader["due_date"]
            };
        }

        // Assignments for one offering with the student's submission status/marks.
        // No submission row -> status defaults to OPEN.
        private const string SelectByOffering =
            "SELECT a.title, a.description, a.due_date, a.weight, a.assignment_type, a.group_size, " +
            "ISNULL(sub.status, 'OPEN') AS sub_status, sub.marks " +
            "FROM ASSIGNMENTS a " +
            "JOIN COURSE_OFFERINGS o ON a.offering_id = o.offering_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id AND s.user_id = @userId " +
            "LEFT JOIN SUBMISSIONS sub ON sub.assignment_id = a.assignment_id " +
            "AND sub.student_id = s.student_id " +
            "WHERE a.offering_id = @offeringId AND e.status = 'ENROLLED' " +
            "ORDER BY a.due_date";

        /// <summary>
        /// Assignments for a specific course offering, including the student's submission
        /// status and marks. Returns an empty list when there are no assignments.
        /// </summary>
        public static List<CourseAssignment> GetByOffering(int offeringId, int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectByOffering, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                cmd.Parameters.AddWithValue("@userId", userId);
                var list = new List<CourseAssignment>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new CourseAssignment
                        {
                            Title = reader["title"].ToString(),
                            Description = reader["description"] == DBNull.Value ? "" : reader["description"].ToString(),
                            DueDate = (DateTime)reader["due_date"],
                            Weight = reader["weight"] == DBNull.Value ? (decimal?)null : (decimal)reader["weight"],
                            AssignmentType = reader["assignment_type"] == DBNull.Value ? null : reader["assignment_type"].ToString(),
                            GroupSize = reader["group_size"] == DBNull.Value ? null : reader["group_size"].ToString(),
                            SubmissionStatus = reader["sub_status"].ToString(),
                            Marks = reader["marks"] == DBNull.Value ? (decimal?)null : (decimal)reader["marks"]
                        });
                    }
                }
                return list;
            }
        }
    }
}
