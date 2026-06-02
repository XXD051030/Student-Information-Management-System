using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using src.db;

namespace src.services
{
    /// <summary>
    /// Summary data and class meetings needed by the timetable page.
    /// </summary>
    public class TimetablePageData
    {
        public string ProgrammeName { get; set; }
        public string SemesterName { get; set; }
        public DateTime SemesterStartDate { get; set; }
        public DateTime SemesterEndDate { get; set; }
        public int CurrentSemesterNo { get; set; }
        public List<TimetableCourse> Courses { get; set; }
        public List<ClassSession> Sessions { get; set; }

        public TimetablePageData()
        {
            Courses = new List<TimetableCourse>();
            Sessions = new List<ClassSession>();
        }

        public int CourseCount
        {
            get { return Courses.Count; }
        }

        public int TotalCreditHours
        {
            get { return Courses.Sum(course => course.CreditHours); }
        }

        public decimal WeeklyContactHours
        {
            get
            {
                return Sessions.Sum(session => (decimal)(session.EndTime - session.StartTime).TotalHours);
            }
        }
    }

    /// <summary>
    /// One enrolled current-semester course shown in the timetable summary.
    /// </summary>
    public class TimetableCourse
    {
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string LecturerName { get; set; }
        public string Color { get; set; }
    }

    /// <summary>
    /// One scheduled class meeting on a student's timetable.
    /// </summary>
    public class ClassSession
    {
        public int TimetableId { get; set; }
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string LecturerName { get; set; }
        public string Venue { get; set; }
        public string DayOfWeek { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public string Color { get; set; }
    }

    /// <summary>
    /// Read-only access to a student's current-semester class schedule.
    /// Returns an empty list when there are no matching classes. SQL
    /// exceptions are not caught here; they propagate to the caller.
    /// </summary>
    public static class TimetableService
    {
        private const string SelectPageHeader =
            "SELECT TOP 1 p.programme_name, sem.name AS semester_name, " +
            "sem.start_date, sem.end_date, ISNULL(v.current_semester_no, 0) AS current_semester_no " +
            "FROM STUDENTS s " +
            "JOIN PROGRAMMES p ON s.programme_id = p.programme_id " +
            "CROSS JOIN SEMESTERS sem " +
            "LEFT JOIN vw_student_semester v ON s.student_id = v.student_id " +
            "WHERE s.user_id = @userId AND sem.is_current = 1 " +
            "ORDER BY sem.start_date DESC";

        private const string SelectCourses =
            "SELECT o.offering_id, c.course_code, c.course_name, c.credit_hours, c.color, " +
            "ISNULL(lecturer.full_name, 'Not assigned') AS lecturer_name " +
            "FROM COURSE_OFFERINGS o " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id " +
            "OUTER APPLY ( " +
            "    SELECT TOP 1 l.full_name " +
            "    FROM TEACHINGS tg " +
            "    JOIN LECTURERS l ON tg.lecturer_id = l.lecturer_id " +
            "    WHERE tg.offering_id = o.offering_id " +
            "    ORDER BY l.full_name " +
            ") lecturer " +
            "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' " +
            "ORDER BY c.course_code";

        private const string SelectSchedule =
            "SELECT t.timetable_id, o.offering_id, c.course_code, c.course_name, c.credit_hours, " +
            "ISNULL(lecturer.full_name, 'Not assigned') AS lecturer_name, " +
            "t.venue, t.day_of_week, t.start_time, t.end_time, c.color " +
            "FROM TIMETABLES t " +
            "JOIN COURSE_OFFERINGS o ON t.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id " +
            "OUTER APPLY ( " +
            "    SELECT TOP 1 l.full_name " +
            "    FROM TEACHINGS tg " +
            "    JOIN LECTURERS l ON tg.lecturer_id = l.lecturer_id " +
            "    WHERE tg.offering_id = o.offering_id " +
            "    ORDER BY l.full_name " +
            ") lecturer " +
            "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' ";

        private const string DayOrder =
            "CASE t.day_of_week " +
            "WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3 " +
            "WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 " +
            "WHEN 'Sunday' THEN 7 ELSE 8 END";

        public static TimetablePageData GetTimetablePage(int userId)
        {
            var timetable = GetPageHeader(userId);
            if (timetable == null)
            {
                return null;
            }

            timetable.Courses = GetCurrentCourses(userId);
            timetable.Sessions = GetWeeklyTimetable(userId);
            return timetable;
        }

        public static List<ClassSession> GetWeeklyTimetable(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                SelectSchedule + " ORDER BY " + DayOrder + ", t.start_time", conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                return ReadSessions(cmd);
            }
        }

        public static List<ClassSession> GetTodayClasses(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                SelectSchedule + " AND t.day_of_week = @today ORDER BY t.start_time", conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@today", DateTime.Now.DayOfWeek.ToString());
                return ReadSessions(cmd);
            }
        }

        private static TimetablePageData GetPageHeader(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectPageHeader, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);

                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    return new TimetablePageData
                    {
                        ProgrammeName = reader["programme_name"].ToString(),
                        SemesterName = reader["semester_name"].ToString(),
                        SemesterStartDate = (DateTime)reader["start_date"],
                        SemesterEndDate = (DateTime)reader["end_date"],
                        CurrentSemesterNo = (int)reader["current_semester_no"]
                    };
                }
            }
        }

        private static List<TimetableCourse> GetCurrentCourses(int userId)
        {
            var courses = new List<TimetableCourse>();

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectCourses, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);

                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        courses.Add(new TimetableCourse
                        {
                            OfferingId = (int)reader["offering_id"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            LecturerName = reader["lecturer_name"].ToString(),
                            Color = reader["color"] == DBNull.Value ? null : reader["color"].ToString()
                        });
                    }
                }
            }

            return courses;
        }

        private static List<ClassSession> ReadSessions(SqlCommand cmd)
        {
            var sessions = new List<ClassSession>();
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    sessions.Add(MapSession(reader));
                }
            }
            return sessions;
        }

        private static ClassSession MapSession(SqlDataReader reader)
        {
            return new ClassSession
            {
                TimetableId = (int)reader["timetable_id"],
                OfferingId = (int)reader["offering_id"],
                CourseCode = reader["course_code"].ToString(),
                CourseName = reader["course_name"].ToString(),
                CreditHours = (int)reader["credit_hours"],
                LecturerName = reader["lecturer_name"].ToString(),
                Venue = reader["venue"].ToString(),
                DayOfWeek = reader["day_of_week"].ToString(),
                StartTime = (TimeSpan)reader["start_time"],
                EndTime = (TimeSpan)reader["end_time"],
                Color = reader["color"] == DBNull.Value ? null : reader["color"].ToString()
            };
        }
    }
}
