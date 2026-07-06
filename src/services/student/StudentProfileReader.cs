using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using src.db;
using static src.services.ServiceMap;
using static src.services.StudentPortalFormat;

namespace src.services
{
    public static class StudentProfileReader
    {
        public static StudentAccountProfile GetAccount(UserContext user)
        {
            if (!IsStudent(user)) return null;
            AcademicIntakeSchema.Ensure();

            const string sql =
                "SELECT TOP 1 s.student_id, u.username, s.student_name, s.student_email, s.phone, s.mailing_address, " +
                "s.semester, s.session, s.icon, s.status, ISNULL(p.programme_name, '') AS programme_name, " +
                "ISNULL(p.semester_count, 0) AS semester_count, ISNULL(p.semesters_per_year, 3) AS semesters_per_year, " +
                "COALESCE(ac.start_date, i.intake_month) AS start_date " +
                "FROM STUDENTS s " +
                "JOIN USERS u ON u.user_id = s.user_id " +
                "LEFT JOIN PROGRAMMES p ON p.programme_id = s.programme_id " +
                "LEFT JOIN ACADEMIC_SESSIONS ac ON s.session = ac.academic_year + ' ' + ac.semester " +
                "LEFT JOIN INTAKES i ON i.intake_id = s.intake_id " +
                "WHERE s.user_id = @userId";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", user.UserId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;
                    return new StudentAccountProfile
                    {
                        StudentId = Text(reader["student_id"]),
                        Username = Text(reader["username"]),
                        FullName = Text(reader["student_name"]),
                        Email = Text(reader["student_email"]),
                        Phone = Text(reader["phone"]),
                        MailingAddress = Text(reader["mailing_address"]),
                        CurrentSemesterNo = IntValue(reader["semester"]),
                        ProgrammeSemesterCount = IntValue(reader["semester_count"]),
                        SemestersPerYear = IntValue(reader["semesters_per_year"]),
                        CurrentSession = Text(reader["session"]),
                        IconPath = Text(reader["icon"]),
                        Status = Text(reader["status"]),
                        ProgrammeName = Text(reader["programme_name"]),
                        IntakeDate = DateValue(reader["start_date"])
                    };
                }
            }
        }
    }
}
