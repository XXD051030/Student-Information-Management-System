using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using src.db;
using static src.services.ServiceMap;
using static src.services.StudentPortalFormat;

namespace src.services
{
    public static class LecturerTimetableReader
    {
        public static List<LecturerClassSession> GetManageableClassSessions(UserContext user)
        {
            var list = new List<LecturerClassSession>();
            if (user == null || !user.IsLecturer) return list;

            string sql =
                "SELECT t.timetable_id, t.offer_id, t.day_of_week, t.start_time, t.end_time, t.room, " +
                "c.course_code, c.course_name, c.colour " +
                "FROM TIMETABLES t " +
                "JOIN COURSE_OFFERINGS co ON co.offer_id = t.offer_id " +
                "JOIN COURSES c ON c.course_id = co.course_id " +
                "WHERE " + ServiceAccess.VisibleOfferScope("co") + " " +
                "ORDER BY CASE t.day_of_week WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 " +
                "WHEN 'Wednesday' THEN 3 WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 " +
                "WHEN 'Saturday' THEN 6 ELSE 7 END, t.start_time";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                ServiceAccess.AddUserContextParameters(cmd, user);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        list.Add(MapSession(reader));
                }
            }
            return list;
        }

        public static int SaveClassSession(UserContext user, int timetableId, int offerId,
            string dayOfWeek, TimeSpan startTime, TimeSpan endTime, string room)
        {
            if (user == null || !user.IsLecturer) throw new UnauthorizedAccessException();
            if (endTime <= startTime) throw new ArgumentException("End time must be later than start time.");

            var allowedDays = new[] { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };
            var day = allowedDays.FirstOrDefault(x => string.Equals(x, dayOfWeek, StringComparison.OrdinalIgnoreCase));
            if (day == null) throw new ArgumentException("Select a valid day.");

            using (var conn = Db.OpenConnection())
            {
                if (!ServiceAccess.CanManageOffer(conn, user, offerId)) throw new UnauthorizedAccessException();

                if (timetableId > 0)
                {
                    if (!CanManageTimetable(conn, user, timetableId)) throw new UnauthorizedAccessException();
                    const string updateSql =
                        "UPDATE TIMETABLES SET offer_id=@offerId, day_of_week=@day, start_time=@start, " +
                        "end_time=@end, room=@room WHERE timetable_id=@id";
                    using (var cmd = new SqlCommand(updateSql, conn))
                    {
                        AddSaveParameters(cmd, offerId, day, startTime, endTime, room);
                        cmd.Parameters.AddWithValue("@id", timetableId);
                        cmd.ExecuteNonQuery();
                    }
                    return timetableId;
                }

                const string insertSql =
                    "INSERT INTO TIMETABLES (offer_id, day_of_week, start_time, end_time, room) " +
                    "OUTPUT INSERTED.timetable_id VALUES (@offerId, @day, @start, @end, @room)";
                using (var cmd = new SqlCommand(insertSql, conn))
                {
                    AddSaveParameters(cmd, offerId, day, startTime, endTime, room);
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
        }

        public static bool DeleteClassSession(UserContext user, int timetableId)
        {
            if (user == null || !user.IsLecturer) return false;
            using (var conn = Db.OpenConnection())
            {
                if (!CanManageTimetable(conn, user, timetableId)) return false;
                using (var cmd = new SqlCommand("DELETE FROM TIMETABLES WHERE timetable_id=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", timetableId);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        // Current-semester weekly class sessions for the lecturer's offerings.
        public static List<LecturerClassSession> GetClassSessions(UserContext user)
        {
            var list = new List<LecturerClassSession>();
            if (user == null || !user.IsLecturer) return list;

            var currentLabel = TermLabel(AcademicTermReader.GetCurrentTerm());

            string sql =
                "SELECT t.timetable_id, t.offer_id, t.day_of_week, t.start_time, t.end_time, t.room, " +
                "c.course_code, c.course_name, c.colour, " +
                "co.academic_year + ' ' + co.semester AS semester_name " +
                "FROM TIMETABLES t " +
                "JOIN COURSE_OFFERINGS co ON co.offer_id = t.offer_id " +
                "JOIN COURSES c ON c.course_id = co.course_id " +
                "WHERE " + ServiceAccess.VisibleOfferScope("co");

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                ServiceAccess.AddUserContextParameters(cmd, user);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var semesterName = Text(reader["semester_name"]);
                        if (!string.IsNullOrEmpty(currentLabel) && !IsSameTerm(semesterName, currentLabel)) continue;
                        var code = Text(reader["course_code"]);
                        list.Add(new LecturerClassSession
                        {
                            TimetableId = IntValue(reader["timetable_id"]),
                            OfferingId = IntValue(reader["offer_id"]),
                            CourseCode = code,
                            CourseName = Text(reader["course_name"]),
                            DayOfWeek = Text(reader["day_of_week"]),
                            StartTime = TimeValue(reader["start_time"]) ?? new TimeSpan(8, 0, 0),
                            EndTime = TimeValue(reader["end_time"]) ?? new TimeSpan(9, 0, 0),
                            Venue = string.IsNullOrWhiteSpace(Text(reader["room"])) ? "TBA" : Text(reader["room"]),
                            Color = ColorOrFallback(Text(reader["colour"]), code)
                        });
                    }
                }
            }
            return list;
        }

        private static LecturerClassSession MapSession(SqlDataReader reader)
        {
            var code = Text(reader["course_code"]);
            return new LecturerClassSession
            {
                TimetableId = IntValue(reader["timetable_id"]),
                OfferingId = IntValue(reader["offer_id"]),
                CourseCode = code,
                CourseName = Text(reader["course_name"]),
                DayOfWeek = Text(reader["day_of_week"]),
                StartTime = TimeValue(reader["start_time"]) ?? new TimeSpan(8, 0, 0),
                EndTime = TimeValue(reader["end_time"]) ?? new TimeSpan(9, 0, 0),
                Venue = string.IsNullOrWhiteSpace(Text(reader["room"])) ? "TBA" : Text(reader["room"]),
                Color = ColorOrFallback(Text(reader["colour"]), code)
            };
        }

        private static void AddSaveParameters(SqlCommand cmd, int offerId, string day,
            TimeSpan startTime, TimeSpan endTime, string room)
        {
            cmd.Parameters.AddWithValue("@offerId", offerId);
            cmd.Parameters.AddWithValue("@day", day);
            cmd.Parameters.AddWithValue("@start", startTime);
            cmd.Parameters.AddWithValue("@end", endTime);
            cmd.Parameters.AddWithValue("@room", ServiceAccess.DbValue(room));
        }

        private static bool CanManageTimetable(SqlConnection conn, UserContext user, int timetableId)
        {
            using (var cmd = new SqlCommand(
                "SELECT offer_id FROM TIMETABLES WHERE timetable_id=@id", conn))
            {
                cmd.Parameters.AddWithValue("@id", timetableId);
                var value = cmd.ExecuteScalar();
                return value != null && value != DBNull.Value &&
                    ServiceAccess.CanManageOffer(conn, user, Convert.ToInt32(value));
            }
        }
    }
}
