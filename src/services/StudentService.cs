using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// Read-only view of a student's profile, joined across
    /// STUDENTS, USERS and PROGRAMMES.
    /// </summary>
    public class Student
    {
        public int StudentId { get; set; }
        public int UserId { get; set; }
        public int ProgrammeId { get; set; }
        public string FullName { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string Status { get; set; }
        public string Email { get; set; }
        public string Username { get; set; }
        public string ProgrammeName { get; set; }
        public string ProgrammeCode { get; set; }
        public string Phone { get; set; }
        public string MailingAddress { get; set; }

        /// <summary>Path to the user's profile image (relative to app root); null/empty when none set.</summary>
        public string IconPath { get; set; }

        /// <summary>Start date of the student's intake semester; null when unknown.</summary>
        public DateTime? IntakeDate { get; set; }

        /// <summary>The student's current semester of study, derived from their intake term.</summary>
        public int CurrentSemesterNo { get; set; }

        /// <summary>Today's scheduled classes for this student (current semester).</summary>
        public List<ClassSession> TodayClasses { get; set; }

        /// <summary>Assignments due within the next 7 days for this student.</summary>
        public List<Assignment> AssignmentsDueThisWeek { get; set; }

        /// <summary>Credit-weighted cumulative GPA; null when no published grades.</summary>
        public decimal? Cgpa { get; set; }

        /// <summary>Total credit hours from all published grades (pass and fail).</summary>
        public int CreditsEarned { get; set; }

        /// <summary>Current-semester attendance rate (0..1); null when no records.</summary>
        public decimal? AttendanceRate { get; set; }

        /// <summary>Every course the student is or was enrolled in, all semesters.</summary>
        public List<EnrolledCourse> Courses { get; set; }

        /// <summary>Courses the student is enrolled in for the current semester only.</summary>
        public List<EnrolledCourse> CurrentCourses { get; set; }

        /// <summary>Current-semester assignments the student has not yet submitted.</summary>
        public int PendingTaskCount { get; set; }

        /// <summary>Recent announcements targeting the student's current courses.</summary>
        public List<Announcement> Announcements { get; set; }
    }

    /// <summary>
    /// Read-only data access for student profiles. Returns null when no
    /// matching student exists. SQL exceptions are not caught here; they
    /// propagate to the caller.
    /// </summary>
    public static class StudentService
    {
        private const string SelectProfile =
            "SELECT s.student_id, s.user_id, s.programme_id, s.full_name, " +
            "s.date_of_birth, s.status, u.email, u.username, " +
            "u.phone, u.mailing_address, u.icon_path, " +
            "p.programme_name, p.programme_code, " +
            "ISNULL(vs.current_semester_no, 1) AS current_semester_no, " +
            "si.start_date AS intake_date " +
            "FROM STUDENTS s " +
            "JOIN USERS u ON s.user_id = u.user_id " +
            "JOIN PROGRAMMES p ON s.programme_id = p.programme_id " +
            "LEFT JOIN vw_student_semester vs ON vs.student_id = s.student_id " +
            "LEFT JOIN SEMESTERS si ON si.semester_id = s.intake_semester_id ";

        public static Student GetByUserId(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectProfile + "WHERE s.user_id = @userId", conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    return reader.Read() ? MapStudent(reader) : null;
                }
            }
        }

        public static Student GetByStudentId(int studentId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectProfile + "WHERE s.student_id = @studentId", conn))
            {
                cmd.Parameters.AddWithValue("@studentId", studentId);
                using (var reader = cmd.ExecuteReader())
                {
                    return reader.Read() ? MapStudent(reader) : null;
                }
            }
        }

        private static Student MapStudent(SqlDataReader reader)
        {
            int userId = (int)reader["user_id"];
            var gradeSummary = GradeService.GetSummary(userId);

            return new Student
            {
                StudentId = (int)reader["student_id"],
                UserId = userId,
                ProgrammeId = (int)reader["programme_id"],
                FullName = reader["full_name"].ToString(),
                DateOfBirth = reader["date_of_birth"] == DBNull.Value
                    ? (DateTime?)null
                    : (DateTime)reader["date_of_birth"],
                Status = reader["status"].ToString(),
                Email = reader["email"].ToString(),
                Username = reader["username"].ToString(),
                ProgrammeName = reader["programme_name"].ToString(),
                ProgrammeCode = reader["programme_code"].ToString(),
                Phone = reader["phone"] == DBNull.Value ? "" : reader["phone"].ToString(),
                MailingAddress = reader["mailing_address"] == DBNull.Value ? "" : reader["mailing_address"].ToString(),
                IconPath = reader["icon_path"] == DBNull.Value ? "" : reader["icon_path"].ToString(),
                IntakeDate = reader["intake_date"] == DBNull.Value
                    ? (DateTime?)null
                    : (DateTime)reader["intake_date"],
                CurrentSemesterNo = (int)reader["current_semester_no"],
                TodayClasses = TimetableService.GetTodayClasses(userId),
                AssignmentsDueThisWeek = AssignmentService.GetDueThisWeek(userId),
                PendingTaskCount = AssignmentService.GetPendingTaskCount(userId),
                Cgpa = gradeSummary.Cgpa,
                CreditsEarned = gradeSummary.CreditsEarned,
                AttendanceRate = AttendanceService.GetCurrentSemesterRate(userId),
                Courses = EnrolmentService.GetCourses(userId),
                CurrentCourses = EnrolmentService.GetCurrentCourses(userId),
                Announcements = AnnouncementService.GetForStudent(userId)
            };
        }
    }
}
