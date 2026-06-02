using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// One course the student is (or was) enrolled in, across any semester.
    /// </summary>
    public class EnrolledCourse
    {
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string LecturerName { get; set; }
        public string SemesterName { get; set; }
        public string Status { get; set; }
        public string Color { get; set; }
    }

    /// <summary>
    /// One course offering shown on the enrollment page, with everything the
    /// card needs and the current student's own enrolment status (null when the
    /// student has no enrolment row for this offering).
    /// </summary>
    public class OfferingForRegistration
    {
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string Color { get; set; }
        public string Description { get; set; }
        public string LecturerName { get; set; }
        public string Schedule { get; set; }
        public int EnrolledCount { get; set; }
        public int Capacity { get; set; }
        public decimal FeePerCredit { get; set; }
        public string Prerequisites { get; set; }
        public string MyStatus { get; set; }
    }

    /// <summary>
    /// Registration / add-drop windows for a semester, plus the phase that is
    /// active today. <see cref="IsOpen"/> is true only during the registration
    /// window, when new enrolments are accepted.
    /// </summary>
    public class RegistrationWindow
    {
        public DateTime? RegistrationStart { get; set; }
        public DateTime? RegistrationEnd { get; set; }
        public DateTime? AddDropStart { get; set; }
        public DateTime? AddDropEnd { get; set; }

        public bool IsOpen
        {
            get
            {
                var today = DateTime.Today;
                return RegistrationStart.HasValue && RegistrationEnd.HasValue
                    && today >= RegistrationStart.Value && today <= RegistrationEnd.Value;
            }
        }

        /// <summary>1 = registration, 2 = add/drop, 3 = locked.</summary>
        public int ActivePhase
        {
            get
            {
                var today = DateTime.Today;
                if (RegistrationStart.HasValue && RegistrationEnd.HasValue
                    && today >= RegistrationStart.Value && today <= RegistrationEnd.Value)
                    return 1;
                if (AddDropEnd.HasValue && today > AddDropEnd.Value)
                    return 3;
                if (RegistrationEnd.HasValue && today > RegistrationEnd.Value)
                    return 2; // registration closed: in or approaching add/drop
                return 1; // before registration opens, still show phase 1
            }
        }
    }

    /// <summary>
    /// Read-only access to a student's complete enrolment history. Returns an
    /// empty list when the student has no enrolments. SQL exceptions are not
    /// caught here; they propagate to the caller.
    /// </summary>
    public static class EnrolmentService
    {
        // Every enrolment for the student, all statuses and semesters, one row
        // each. OUTER APPLY TOP 1 picks a single lecturer per offering so an
        // offering with multiple lecturers does not duplicate the course row.
        private const string SelectCourses =
            "SELECT e.offering_id, c.course_code, c.course_name, c.credit_hours, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, sem.name AS semester_name, e.status, c.color " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "OUTER APPLY (" +
            "SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE s.user_id = @userId " +
            "ORDER BY sem.name, c.course_code";

        public static List<EnrolledCourse> GetCourses(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectCourses, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var courses = new List<EnrolledCourse>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        courses.Add(new EnrolledCourse
                        {
                            OfferingId = (int)reader["offering_id"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            LecturerName = reader["lecturer_name"].ToString(),
                            SemesterName = reader["semester_name"].ToString(),
                            Status = reader["status"].ToString(),
                            Color = reader["color"] == System.DBNull.Value ? "" : reader["color"].ToString()
                        });
                    }
                }
                return courses;
            }
        }

        // Current-semester enrolled courses only, for the dashboard "My Courses"
        // widget. Same projection as GetCourses, filtered to is_current + ENROLLED.
        private const string SelectCurrentCourses =
            "SELECT e.offering_id, c.course_code, c.course_name, c.credit_hours, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, sem.name AS semester_name, e.status, c.color " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "OUTER APPLY (" +
            "SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' " +
            "ORDER BY c.course_code";

        public static List<EnrolledCourse> GetCurrentCourses(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectCurrentCourses, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var courses = new List<EnrolledCourse>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        courses.Add(new EnrolledCourse
                        {
                            OfferingId = (int)reader["offering_id"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            LecturerName = reader["lecturer_name"].ToString(),
                            SemesterName = reader["semester_name"].ToString(),
                            Status = reader["status"].ToString(),
                            Color = reader["color"] == System.DBNull.Value ? "" : reader["color"].ToString()
                        });
                    }
                }
                return courses;
            }
        }

        // The upcoming term open for registration: the next semester whose start
        // date is after the current semester's start date.
        public static Semester GetRegistrationSemester()
        {
            const string sql =
                "SELECT TOP 1 semester_id, name, start_date, end_date " +
                "FROM SEMESTERS " +
                "WHERE start_date > (SELECT MAX(start_date) FROM SEMESTERS WHERE is_current = 1) " +
                "ORDER BY start_date";
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            using (var reader = cmd.ExecuteReader())
            {
                if (!reader.Read()) return null;
                return new Semester
                {
                    SemesterId = (int)reader["semester_id"],
                    Name = reader["name"].ToString(),
                    StartDate = (DateTime)reader["start_date"],
                    EndDate = (DateTime)reader["end_date"]
                };
            }
        }

        // Registration + add/drop windows for the given semester.
        public static RegistrationWindow GetRegistrationWindow(int semesterId)
        {
            const string sql =
                "SELECT event_type, start_date, end_date FROM ACADEMIC_CALENDAR " +
                "WHERE semester_id = @sem AND event_type IN ('REGISTRATION', 'ADD_DROP')";
            var window = new RegistrationWindow();
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@sem", semesterId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var type = reader["event_type"].ToString();
                        var start = (DateTime)reader["start_date"];
                        var end = (DateTime)reader["end_date"];
                        if (type == "REGISTRATION")
                        {
                            window.RegistrationStart = start;
                            window.RegistrationEnd = end;
                        }
                        else if (type == "ADD_DROP")
                        {
                            window.AddDropStart = start;
                            window.AddDropEnd = end;
                        }
                    }
                }
            }
            return window;
        }

        // The student's current semester number (e.g. 3) from vw_student_semester,
        // used to label the registration term's year of study. Returns 0 when the
        // student has no row in the view.
        public static int GetStudentSemesterNo(int userId)
        {
            const string sql =
                "SELECT v.current_semester_no FROM vw_student_semester v " +
                "JOIN STUDENTS s ON v.student_id = s.student_id " +
                "WHERE s.user_id = @userId";
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var result = cmd.ExecuteScalar();
                return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
            }
        }

        // Every offering in the given semester, with the current student's own
        // enrolment status (null when not enrolled) and the live enrolled count.
        private const string SelectOfferingsForRegistration =
            "SELECT o.offering_id, c.course_code, c.course_name, c.credit_hours, " +
            "ISNULL(c.color, '') AS color, ISNULL(c.description, '') AS description, " +
            "ISNULL(c.prerequisites, '') AS prerequisites, " +
            "ISNULL(c.fee_per_credit, 150) AS fee_per_credit, " +
            "ISNULL(o.capacity, 0) AS capacity, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, " +
            "(SELECT COUNT(*) FROM ENROLMENTS en WHERE en.offering_id = o.offering_id " +
            "AND en.status IN ('ENROLLED', 'PENDING')) AS enrolled_count, " +
            "(SELECT TOP 1 e.status FROM ENROLMENTS e " +
            "JOIN STUDENTS s ON e.student_id = s.student_id " +
            "WHERE s.user_id = @userId AND e.offering_id = o.offering_id) AS my_status, " +
            "(SELECT STUFF((SELECT ' / ' + tt.day_of_week + ' ' " +
            "+ CONVERT(varchar(5), tt.start_time, 108) + '-' + CONVERT(varchar(5), tt.end_time, 108) " +
            "FROM TIMETABLES tt WHERE tt.offering_id = o.offering_id " +
            "ORDER BY tt.start_time FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 3, '')) AS schedule " +
            "FROM COURSE_OFFERINGS o " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "OUTER APPLY (SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE o.semester_id = @semesterId " +
            "ORDER BY c.course_code";

        public static List<OfferingForRegistration> GetOfferingsForRegistration(int userId, int semesterId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectOfferingsForRegistration, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@semesterId", semesterId);
                var list = new List<OfferingForRegistration>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new OfferingForRegistration
                        {
                            OfferingId = (int)reader["offering_id"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            Color = reader["color"].ToString(),
                            Description = reader["description"].ToString(),
                            LecturerName = reader["lecturer_name"].ToString(),
                            Schedule = reader["schedule"] == DBNull.Value ? "" : reader["schedule"].ToString(),
                            EnrolledCount = Convert.ToInt32(reader["enrolled_count"]),
                            Capacity = Convert.ToInt32(reader["capacity"]),
                            FeePerCredit = Convert.ToDecimal(reader["fee_per_credit"]),
                            Prerequisites = reader["prerequisites"].ToString(),
                            MyStatus = reader["my_status"] == DBNull.Value ? null : reader["my_status"].ToString()
                        });
                    }
                }
                return list;
            }
        }

        // Enrols the student (by user id) into the given offerings for the
        // registration semester. Skips offerings that are not in that semester,
        // already enrolled, or full. New rows use status 'PENDING' (payment
        // pending). Returns the number of rows inserted.
        public static int Enrol(int userId, IEnumerable<int> offeringIds)
        {
            if (offeringIds == null) return 0;

            var regSemester = GetRegistrationSemester();
            if (regSemester == null) return 0;

            const string insertSql =
                "INSERT INTO ENROLMENTS (student_id, offering_id, status) " +
                "SELECT s.student_id, o.offering_id, 'PENDING' " +
                "FROM COURSE_OFFERINGS o " +
                "JOIN STUDENTS s ON s.user_id = @userId " +
                "WHERE o.offering_id = @offeringId AND o.semester_id = @semesterId " +
                "AND NOT EXISTS (SELECT 1 FROM ENROLMENTS e " +
                "WHERE e.student_id = s.student_id AND e.offering_id = o.offering_id) " +
                "AND (SELECT COUNT(*) FROM ENROLMENTS e2 WHERE e2.offering_id = o.offering_id " +
                "AND e2.status IN ('ENROLLED', 'PENDING')) < ISNULL(o.capacity, 0)";

            int inserted = 0;
            using (var conn = Db.OpenConnection())
            {
                foreach (var offeringId in offeringIds)
                {
                    using (var cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        cmd.Parameters.AddWithValue("@offeringId", offeringId);
                        cmd.Parameters.AddWithValue("@semesterId", regSemester.SemesterId);
                        inserted += cmd.ExecuteNonQuery();
                    }
                }
            }
            return inserted;
        }
    }
}
