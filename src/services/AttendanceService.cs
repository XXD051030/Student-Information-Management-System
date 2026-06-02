using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using src.db;

namespace src.services
{
    /// <summary>All data needed to render the student attendance page.</summary>
    public class AttendancePageData
    {
        public string SemesterName { get; set; }
        public DateTime? SemesterStartDate { get; set; }
        public DateTime? SemesterEndDate { get; set; }
        public int CurrentSemesterNo { get; set; }
        public List<AttendanceCourse> Courses { get; set; }

        public AttendancePageData()
        {
            Courses = new List<AttendanceCourse>();
        }

        public int CourseCount
        {
            get { return Courses.Count; }
        }

        public int PresentCount
        {
            get { return Courses.Sum(c => c.PresentCount); }
        }

        public int LateCount
        {
            get { return Courses.Sum(c => c.LateCount); }
        }

        public int AbsentCount
        {
            get { return Courses.Sum(c => c.AbsentCount); }
        }

        public int TotalCount
        {
            get { return Courses.Sum(c => c.TotalCount); }
        }

        public decimal? AttendanceRate
        {
            get
            {
                return TotalCount == 0
                    ? (decimal?)null
                    : Math.Round(PresentCount / (decimal)TotalCount, 4);
            }
        }

        public AttendanceCourse SelectedCourse
        {
            get { return Courses.FirstOrDefault(); }
        }
    }

    /// <summary>One course attendance summary for any of the student's semesters.</summary>
    public class AttendanceCourse
    {
        public int OfferingId { get; set; }
        public int SemesterId { get; set; }
        public string SemesterName { get; set; }
        public bool IsCurrent { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public string LecturerName { get; set; }
        public string Color { get; set; }
        public List<AttendanceSession> Sessions { get; set; }

        public AttendanceCourse()
        {
            Sessions = new List<AttendanceSession>();
        }

        public int PresentCount
        {
            get { return Sessions.Count(s => IsStatus(s.Status, "PRESENT")); }
        }

        public int LateCount
        {
            get { return Sessions.Count(s => IsStatus(s.Status, "LATE")); }
        }

        public int AbsentCount
        {
            get { return Sessions.Count(s => IsStatus(s.Status, "ABSENT")); }
        }

        public int TotalCount
        {
            get { return Sessions.Count; }
        }

        public decimal? AttendanceRate
        {
            get
            {
                return TotalCount == 0
                    ? (decimal?)null
                    : Math.Round(PresentCount / (decimal)TotalCount, 4);
            }
        }

        private static bool IsStatus(string value, string expected)
        {
            return string.Equals(value, expected, StringComparison.OrdinalIgnoreCase);
        }
    }

    /// <summary>One attendance record joined with course and timetable context.</summary>
    public class AttendanceSession
    {
        public int AttendanceId { get; set; }
        public int OfferingId { get; set; }
        public DateTime AttendanceDate { get; set; }
        public string Status { get; set; }
        public string Venue { get; set; }
        public TimeSpan? StartTime { get; set; }
        public TimeSpan? EndTime { get; set; }
        public string SessionType { get; set; }
    }

    internal class AttendanceHeader
    {
        public string SemesterName { get; set; }
        public DateTime? SemesterStartDate { get; set; }
        public DateTime? SemesterEndDate { get; set; }
        public int CurrentSemesterNo { get; set; }
    }

    /// <summary>
    /// Read-only access to a student's attendance rate and attendance page data.
    /// SQL exceptions are not caught here; they propagate to the caller.
    /// </summary>
    public static class AttendanceService
    {
        // Present-vs-total counts over the current semester's enrolments only.
        // Only PRESENT is credited; LATE and ABSENT count against the rate.
        private const string SelectCounts =
            "SELECT SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END) AS present_count, " +
            "COUNT(*) AS total_count " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ATTENDANCE a ON a.enrolment_id = e.enrolment_id " +
            "WHERE s.user_id = @userId AND sem.is_current = 1";

        private const string SelectHeader =
            "SELECT sem.name AS semester_name, sem.start_date, sem.end_date, " +
            "ISNULL(vs.current_semester_no, 1) AS current_semester_no " +
            "FROM STUDENTS s " +
            "LEFT JOIN vw_student_semester vs ON vs.student_id = s.student_id " +
            "LEFT JOIN SEMESTERS sem ON sem.is_current = 1 " +
            "WHERE s.user_id = @userId";

        private const string SelectAttendanceRows =
            "SELECT e.offering_id, sem.semester_id, sem.name AS semester_name, sem.is_current, " +
            "c.course_code, c.course_name, ISNULL(c.color, '') AS color, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, " +
            "a.attendance_id, a.attendance_date, a.status, " +
            "tt.venue, tt.start_time, tt.end_time " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "LEFT JOIN ATTENDANCE a ON a.enrolment_id = e.enrolment_id " +
            "OUTER APPLY (" +
            "SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "OUTER APPLY (" +
            "SELECT TOP 1 venue, start_time, end_time FROM TIMETABLES t " +
            "WHERE t.offering_id = o.offering_id " +
            "AND (a.attendance_date IS NULL OR t.day_of_week = DATENAME(WEEKDAY, a.attendance_date)) " +
            "ORDER BY t.start_time) tt " +
            "WHERE s.user_id = @userId AND e.status IN ('ENROLLED', 'COMPLETED') " +
            "ORDER BY sem.start_date DESC, c.course_code, a.attendance_date DESC, a.attendance_id DESC";

        /// <summary>
        /// Fraction (0..1) of current-semester attendance records marked PRESENT,
        /// or null when there are no records.
        /// </summary>
        public static decimal? GetCurrentSemesterRate(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectCounts, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;

                    int total = (int)reader["total_count"];
                    if (total == 0) return null;

                    int present = reader["present_count"] == DBNull.Value
                        ? 0
                        : Convert.ToInt32(reader["present_count"]);
                    return Math.Round((decimal)present / total, 4);
                }
            }
        }

        /// <summary>
        /// Current-semester attendance page data for the student behind
        /// <paramref name="userId"/>. Returns null when no student profile exists.
        /// </summary>
        public static AttendancePageData GetAttendancePage(int userId)
        {
            var header = GetHeader(userId);
            if (header == null) return null;

            var courses = GetCourses(userId);

            // Keep only semesters that actually have attendance records.
            var semestersWithAttendance = new HashSet<int>(
                courses.Where(c => c.TotalCount > 0).Select(c => c.SemesterId));
            courses = courses
                .Where(c => semestersWithAttendance.Contains(c.SemesterId))
                .ToList();

            return new AttendancePageData
            {
                SemesterName = header.SemesterName,
                SemesterStartDate = header.SemesterStartDate,
                SemesterEndDate = header.SemesterEndDate,
                CurrentSemesterNo = header.CurrentSemesterNo,
                Courses = courses
            };
        }

        private static AttendanceHeader GetHeader(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectHeader, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;

                    return new AttendanceHeader
                    {
                        SemesterName = reader["semester_name"] == DBNull.Value ? "" : reader["semester_name"].ToString(),
                        SemesterStartDate = reader["start_date"] == DBNull.Value ? (DateTime?)null : (DateTime)reader["start_date"],
                        SemesterEndDate = reader["end_date"] == DBNull.Value ? (DateTime?)null : (DateTime)reader["end_date"],
                        CurrentSemesterNo = Convert.ToInt32(reader["current_semester_no"])
                    };
                }
            }
        }

        private static List<AttendanceCourse> GetCourses(int userId)
        {
            var coursesByOffering = new Dictionary<int, AttendanceCourse>();

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectAttendanceRows, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int offeringId = (int)reader["offering_id"];
                        AttendanceCourse course;
                        if (!coursesByOffering.TryGetValue(offeringId, out course))
                        {
                            course = new AttendanceCourse
                            {
                                OfferingId = offeringId,
                                SemesterId = (int)reader["semester_id"],
                                SemesterName = reader["semester_name"].ToString(),
                                IsCurrent = Convert.ToBoolean(reader["is_current"]),
                                CourseCode = reader["course_code"].ToString(),
                                CourseName = reader["course_name"].ToString(),
                                LecturerName = reader["lecturer_name"].ToString(),
                                Color = reader["color"].ToString()
                            };
                            coursesByOffering.Add(offeringId, course);
                        }

                        if (reader["attendance_id"] == DBNull.Value)
                        {
                            continue;
                        }

                        course.Sessions.Add(new AttendanceSession
                        {
                            AttendanceId = (int)reader["attendance_id"],
                            OfferingId = offeringId,
                            AttendanceDate = (DateTime)reader["attendance_date"],
                            Status = reader["status"].ToString(),
                            Venue = reader["venue"] == DBNull.Value ? "" : reader["venue"].ToString(),
                            StartTime = reader["start_time"] == DBNull.Value ? (TimeSpan?)null : (TimeSpan)reader["start_time"],
                            EndTime = reader["end_time"] == DBNull.Value ? (TimeSpan?)null : (TimeSpan)reader["end_time"],
                            SessionType = "Class"
                        });
                    }
                }
            }

            return coursesByOffering.Values
                .OrderByDescending(c => c.SemesterId)
                .ThenBy(c => c.CourseCode)
                .ToList();
        }
    }
}
