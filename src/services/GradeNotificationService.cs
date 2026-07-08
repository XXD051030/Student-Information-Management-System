using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using src.db;
using static src.services.ServiceMap;

namespace src.services
{
    public static class GradeNotificationService
    {
        public const string NotificationType = "GRADE";

        public static void EnsureTables()
        {
            const string sql =
                "IF COL_LENGTH('dbo.SUBMISSIONS', 'auto_zero_notified') IS NULL BEGIN " +
                "ALTER TABLE dbo.SUBMISSIONS ADD auto_zero_notified bit NOT NULL " +
                "CONSTRAINT DF_SUBMISSIONS_auto_zero_notified DEFAULT(0); " +
                "EXEC(N'UPDATE dbo.SUBMISSIONS SET auto_zero_notified = 1 WHERE status = ''MISSING'''); END; " +
                "IF OBJECT_ID('dbo.GRADE_NOTIFICATIONS', 'U') IS NULL BEGIN " +
                "CREATE TABLE dbo.GRADE_NOTIFICATIONS (" +
                "notification_id int IDENTITY(1,1) NOT NULL PRIMARY KEY, " +
                "student_id varchar(20) NOT NULL, assignment_id int NOT NULL, offer_id int NOT NULL, " +
                "previous_marks decimal(5,2) NULL, published_marks decimal(5,2) NOT NULL, " +
                "created_at datetime2 NOT NULL CONSTRAINT DF_GRADE_NOTIFICATIONS_created_at DEFAULT SYSDATETIME(), " +
                "CONSTRAINT FK_GRADE_NOTIFICATIONS_STUDENTS FOREIGN KEY (student_id) REFERENCES dbo.STUDENTS(student_id) ON DELETE CASCADE, " +
                "CONSTRAINT FK_GRADE_NOTIFICATIONS_ASSIGNMENTS FOREIGN KEY (assignment_id) REFERENCES dbo.ASSIGNMENTS(assignment_id) ON DELETE CASCADE" +
                "); " +
                "CREATE INDEX IX_GRADE_NOTIFICATIONS_student_created ON dbo.GRADE_NOTIFICATIONS(student_id, created_at DESC); END; " +
                "IF OBJECT_ID('dbo.GRADE_NOTIFICATION_READS', 'U') IS NULL BEGIN " +
                "CREATE TABLE dbo.GRADE_NOTIFICATION_READS (" +
                "user_id int NOT NULL, notification_id int NOT NULL, " +
                "read_at datetime2 NOT NULL CONSTRAINT DF_GRADE_NOTIFICATION_READS_read_at DEFAULT SYSDATETIME(), " +
                "CONSTRAINT PK_GRADE_NOTIFICATION_READS PRIMARY KEY (user_id, notification_id), " +
                "CONSTRAINT FK_GRADE_NOTIFICATION_READS_USERS FOREIGN KEY (user_id) REFERENCES dbo.USERS(user_id) ON DELETE CASCADE, " +
                "CONSTRAINT FK_GRADE_NOTIFICATION_READS_NOTIFICATIONS FOREIGN KEY (notification_id) REFERENCES dbo.GRADE_NOTIFICATIONS(notification_id) ON DELETE CASCADE" +
                "); END;";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
                cmd.ExecuteNonQuery();
        }

        public static int InsertChangedMarks(SqlConnection conn, SqlTransaction transaction, int assignmentId)
        {
            const string sql =
                "INSERT INTO GRADE_NOTIFICATIONS " +
                "(student_id, assignment_id, offer_id, previous_marks, published_marks, created_at) " +
                "SELECT sub.student_id, sub.assignment_id, a.offer_id, " +
                "sub.published_marks_obtained, sub.marks_obtained, SYSDATETIME() " +
                "FROM SUBMISSIONS sub WITH (UPDLOCK, HOLDLOCK) JOIN ASSIGNMENTS a ON a.assignment_id = sub.assignment_id " +
                "WHERE sub.assignment_id = @assignmentId AND sub.marks_obtained IS NOT NULL " +
                "AND (sub.published_at IS NULL OR sub.published_marks_obtained IS NULL " +
                "OR sub.published_marks_obtained <> sub.marks_obtained);";
            using (var cmd = new SqlCommand(sql, conn, transaction))
            {
                cmd.Parameters.Add("@assignmentId", SqlDbType.Int).Value = assignmentId;
                return cmd.ExecuteNonQuery();
            }
        }

        public static List<StudentPortalNotification> GetForUser(UserContext user)
        {
            var rows = new List<StudentPortalNotification>();
            if (user == null || !user.IsStudent || user.UserId <= 0) return rows;
            LecturerGradeReader.EnsureReviewColumns();
            EnsureTables();
            EnsureAutomaticZeroNotifications(user);

            const string sql =
                "SELECT n.notification_id, n.offer_id, n.previous_marks, n.published_marks, n.created_at, " +
                "a.title AS assessment_title, c.course_code, c.course_name, " +
                "ISNULL(l.lecturer_name, 'Lecturer') AS lecturer_name, " +
                "CASE WHEN r.notification_id IS NULL THEN 0 ELSE 1 END AS is_read " +
                "FROM GRADE_NOTIFICATIONS n " +
                "JOIN STUDENTS s ON s.student_id = n.student_id AND s.user_id = @userId " +
                "JOIN ASSIGNMENTS a ON a.assignment_id = n.assignment_id " +
                "JOIN COURSE_OFFERINGS co ON co.offer_id = n.offer_id " +
                "JOIN COURSES c ON c.course_id = co.course_id " +
                "LEFT JOIN LECTURERS l ON l.lecturer_id = co.lecturer_id " +
                "LEFT JOIN GRADE_NOTIFICATION_READS r ON r.notification_id = n.notification_id AND r.user_id = @userId " +
                "ORDER BY n.created_at DESC, n.notification_id DESC";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@userId", SqlDbType.Int).Value = user.UserId;
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int id = IntValue(reader["notification_id"]);
                        string assessment = Text(reader["assessment_title"]);
                        decimal? previous = DecimalValue(reader["previous_marks"]);
                        decimal published = DecimalValue(reader["published_marks"]).GetValueOrDefault();
                        string content = previous.HasValue
                            ? "Your mark for " + assessment + " changed from " +
                              FormatMark(previous.Value) + "/100 to " + FormatMark(published) + "/100."
                            : "Your mark for " + assessment + " is " + FormatMark(published) + "/100.";
                        rows.Add(new StudentPortalNotification
                        {
                            NotificationId = id,
                            NotificationType = NotificationType,
                            AnnouncementId = id,
                            OfferId = IntValue(reader["offer_id"]),
                            CourseCode = Text(reader["course_code"]),
                            CourseName = Text(reader["course_name"]),
                            Title = "Marks published: " + assessment,
                            Content = content,
                            AuthorName = Text(reader["lecturer_name"]),
                            AuthorRole = "GRADE",
                            IsPinned = false,
                            HasAttachment = false,
                            FileUrl = "",
                            CreatedAt = DateValue(reader["created_at"]) ?? DateTime.Now,
                            IsRead = Convert.ToBoolean(reader["is_read"])
                        });
                    }
                }
            }
            return rows;
        }

        private static void EnsureAutomaticZeroNotifications(UserContext user)
        {
            using (var conn = Db.OpenConnection())
            using (var transaction = conn.BeginTransaction(IsolationLevel.Serializable))
            {
                const string expireSql =
                    "UPDATE sub SET status = 'MISSING', marks_obtained = 0 " +
                    "FROM SUBMISSIONS sub WITH (UPDLOCK, HOLDLOCK) " +
                    "JOIN ASSIGNMENTS a ON a.assignment_id = sub.assignment_id " +
                    "JOIN STUDENTS s ON s.student_id = sub.student_id AND s.user_id = @userId " +
                    "WHERE ISNULL(a.submission_mode, 'FILE') IN ('FILE','LINK') " +
                    "AND sub.status = 'EXTENDED' AND sub.file_url IS NULL " +
                    "AND sub.extension_deadline < GETDATE();";
                using (var expire = new SqlCommand(expireSql, conn, transaction))
                {
                    expire.Parameters.Add("@userId", SqlDbType.Int).Value = user.UserId;
                    expire.ExecuteNonQuery();
                }

                const string createMissingSql =
                    "INSERT INTO SUBMISSIONS " +
                    "(assignment_id, student_id, submitted_at, file_url, marks_obtained, status, " +
                    "published_marks_obtained, published_at, auto_zero_notified) " +
                    "SELECT a.assignment_id, s.student_id, NULL, NULL, 0, 'MISSING', 0, GETDATE(), 0 " +
                    "FROM STUDENTS s JOIN ENROLLMENTS e ON e.student_id = s.student_id AND e.status = 'ENROLLED' " +
                    "JOIN ASSIGNMENTS a ON a.offer_id = e.offer_id " +
                    "WHERE s.user_id = @userId AND ISNULL(a.submission_mode, 'FILE') IN ('FILE','LINK') " +
                    "AND a.due_date IS NOT NULL AND a.due_date < GETDATE() " +
                    "AND NOT EXISTS (SELECT 1 FROM SUBMISSIONS existing WITH (UPDLOCK, HOLDLOCK) " +
                    "WHERE existing.assignment_id = a.assignment_id AND existing.student_id = s.student_id);";
                using (var create = new SqlCommand(createMissingSql, conn, transaction))
                {
                    create.Parameters.Add("@userId", SqlDbType.Int).Value = user.UserId;
                    create.ExecuteNonQuery();
                }

                const string prepareMissingSql =
                    "UPDATE sub SET marks_obtained = 0, published_marks_obtained = 0, " +
                    "published_at = ISNULL(published_at, GETDATE()) " +
                    "FROM SUBMISSIONS sub WITH (UPDLOCK, HOLDLOCK) " +
                    "JOIN STUDENTS s ON s.student_id = sub.student_id AND s.user_id = @userId " +
                    "WHERE sub.status = 'MISSING' AND sub.auto_zero_notified = 0;";
                using (var prepare = new SqlCommand(prepareMissingSql, conn, transaction))
                {
                    prepare.Parameters.Add("@userId", SqlDbType.Int).Value = user.UserId;
                    prepare.ExecuteNonQuery();
                }

                const string notifySql =
                    "INSERT INTO GRADE_NOTIFICATIONS " +
                    "(student_id, assignment_id, offer_id, previous_marks, published_marks, created_at) " +
                    "SELECT sub.student_id, sub.assignment_id, a.offer_id, NULL, 0, SYSDATETIME() " +
                    "FROM SUBMISSIONS sub WITH (UPDLOCK, HOLDLOCK) " +
                    "JOIN ASSIGNMENTS a ON a.assignment_id = sub.assignment_id " +
                    "JOIN STUDENTS s ON s.student_id = sub.student_id AND s.user_id = @userId " +
                    "WHERE sub.status = 'MISSING' AND sub.auto_zero_notified = 0; " +
                    "UPDATE sub SET auto_zero_notified = 1 " +
                    "FROM SUBMISSIONS sub JOIN STUDENTS s ON s.student_id = sub.student_id AND s.user_id = @userId " +
                    "WHERE sub.status = 'MISSING' AND sub.auto_zero_notified = 0;";
                using (var notify = new SqlCommand(notifySql, conn, transaction))
                {
                    notify.Parameters.Add("@userId", SqlDbType.Int).Value = user.UserId;
                    notify.ExecuteNonQuery();
                }

                transaction.Commit();
            }
        }

        public static bool MarkRead(UserContext user, int notificationId)
        {
            if (user == null || !user.IsStudent || notificationId <= 0) return false;
            EnsureTables();
            const string sql =
                "IF EXISTS (SELECT 1 FROM GRADE_NOTIFICATIONS n JOIN STUDENTS s ON s.student_id = n.student_id " +
                "WHERE n.notification_id = @notificationId AND s.user_id = @userId) " +
                "AND NOT EXISTS (SELECT 1 FROM GRADE_NOTIFICATION_READS " +
                "WHERE user_id = @userId AND notification_id = @notificationId) " +
                "INSERT INTO GRADE_NOTIFICATION_READS (user_id, notification_id) VALUES (@userId, @notificationId);";
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                AddReadParameters(cmd, user.UserId, notificationId);
                cmd.ExecuteNonQuery();
                return true;
            }
        }

        public static bool MarkUnread(UserContext user, int notificationId)
        {
            if (user == null || !user.IsStudent || notificationId <= 0) return false;
            EnsureTables();
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                "DELETE r FROM GRADE_NOTIFICATION_READS r " +
                "JOIN GRADE_NOTIFICATIONS n ON n.notification_id = r.notification_id " +
                "JOIN STUDENTS s ON s.student_id = n.student_id " +
                "WHERE r.user_id = @userId AND r.notification_id = @notificationId AND s.user_id = @userId", conn))
            {
                AddReadParameters(cmd, user.UserId, notificationId);
                cmd.ExecuteNonQuery();
                return true;
            }
        }

        public static void MarkAllRead(UserContext user, IEnumerable<int> notificationIds)
        {
            if (notificationIds == null) return;
            foreach (int id in notificationIds) MarkRead(user, id);
        }

        private static void AddReadParameters(SqlCommand cmd, int userId, int notificationId)
        {
            cmd.Parameters.Add("@userId", SqlDbType.Int).Value = userId;
            cmd.Parameters.Add("@notificationId", SqlDbType.Int).Value = notificationId;
        }

        private static string FormatMark(decimal mark)
        {
            return mark.ToString("0.##", System.Globalization.CultureInfo.InvariantCulture);
        }
    }
}
