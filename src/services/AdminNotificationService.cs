using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using src.db;
using static src.services.ServiceMap;

namespace src.services
{
    public class AdminNotificationInput
    {
        public int NotificationId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public string TargetRole { get; set; }
    }

    public class AdminNotificationItem
    {
        public int NotificationId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public string TargetRole { get; set; }
        public string CreatedByName { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsRead { get; set; }
    }

    public static class AdminNotificationService
    {
        public const string NotificationType = "ADMIN";

        public static List<AdminNotificationItem> GetAll()
        {
            EnsureTables();
            var rows = new List<AdminNotificationItem>();

            const string sql =
                "SELECT n.notification_id, n.title, CAST(n.message AS nvarchar(max)) AS message, " +
                "n.target_role, n.created_at, ISNULL(u.username, 'Administrator') AS created_by_name " +
                "FROM ADMIN_NOTIFICATIONS n " +
                "LEFT JOIN USERS u ON u.user_id = n.created_by " +
                "ORDER BY n.created_at DESC, n.notification_id DESC";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read()) rows.Add(Map(reader, null));
            }

            return rows;
        }

        public static List<AdminNotificationItem> GetForUser(UserContext user, ISet<int> readIds)
        {
            var rows = new List<AdminNotificationItem>();
            if (user == null || (!user.IsStudent && !user.IsLecturer)) return rows;

            EnsureTables();
            const string sql =
                "SELECT n.notification_id, n.title, CAST(n.message AS nvarchar(max)) AS message, " +
                "n.target_role, n.created_at, ISNULL(u.username, 'Administrator') AS created_by_name " +
                "FROM ADMIN_NOTIFICATIONS n " +
                "LEFT JOIN USERS u ON u.user_id = n.created_by " +
                "WHERE n.target_role = @role OR n.target_role = 'BOTH' " +
                "ORDER BY n.created_at DESC, n.notification_id DESC";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@role", SqlDbType.VarChar, 20).Value = user.NormalizedRole;
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read()) rows.Add(Map(reader, readIds));
                }
            }

            return rows;
        }

        public static HashSet<int> GetReadIds(UserContext user)
        {
            var ids = new HashSet<int>();
            if (user == null || user.UserId <= 0) return ids;

            EnsureTables();
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                "SELECT notification_id FROM ADMIN_NOTIFICATION_READS WHERE user_id = @userId", conn))
            {
                cmd.Parameters.Add("@userId", SqlDbType.Int).Value = user.UserId;
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read()) ids.Add(Convert.ToInt32(reader["notification_id"]));
                }
            }
            return ids;
        }

        public static int Save(UserContext admin, AdminNotificationInput input)
        {
            if (admin == null || !admin.IsAdmin) throw new UnauthorizedAccessException("Admin session required.");
            if (input == null) throw new ArgumentNullException("input");

            var title = (input.Title ?? "").Trim();
            var message = (input.Message ?? "").Trim();
            var targetRole = NormalizeTargetRole(input.TargetRole);

            if (string.IsNullOrWhiteSpace(title)) throw new ArgumentException("Title is required.");
            if (string.IsNullOrWhiteSpace(message)) throw new ArgumentException("Message is required.");

            EnsureTables();

            using (var conn = Db.OpenConnection())
            {
                if (input.NotificationId > 0)
                {
                    const string updateSql =
                        "UPDATE ADMIN_NOTIFICATIONS " +
                        "SET title = @title, message = @message, target_role = @targetRole " +
                        "WHERE notification_id = @id";
                    using (var cmd = new SqlCommand(updateSql, conn))
                    {
                        AddSaveParameters(cmd, title, message, targetRole);
                        cmd.Parameters.Add("@id", SqlDbType.Int).Value = input.NotificationId;
                        if (cmd.ExecuteNonQuery() == 0) throw new ArgumentException("Notification not found.");
                    }
                    return input.NotificationId;
                }

                const string insertSql =
                    "INSERT INTO ADMIN_NOTIFICATIONS (title, message, target_role, created_by, created_at) " +
                    "OUTPUT INSERTED.notification_id " +
                    "VALUES (@title, @message, @targetRole, @createdBy, @createdAt)";
                using (var cmd = new SqlCommand(insertSql, conn))
                {
                    AddSaveParameters(cmd, title, message, targetRole);
                    cmd.Parameters.Add("@createdBy", SqlDbType.Int).Value = admin.UserId;
                    cmd.Parameters.Add("@createdAt", SqlDbType.DateTime2).Value = DateTime.Now;
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
        }

        public static bool MarkRead(UserContext user, int notificationId)
        {
            if (user == null || user.UserId <= 0 || notificationId <= 0) return false;
            EnsureTables();

            const string sql =
                "IF EXISTS (SELECT 1 FROM ADMIN_NOTIFICATIONS WHERE notification_id = @notificationId " +
                "AND (target_role = @role OR target_role = 'BOTH')) " +
                "AND NOT EXISTS (SELECT 1 FROM ADMIN_NOTIFICATION_READS WHERE user_id = @userId AND notification_id = @notificationId) " +
                "INSERT INTO ADMIN_NOTIFICATION_READS (user_id, notification_id) VALUES (@userId, @notificationId)";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                AddReadParameters(cmd, user, notificationId);
                cmd.ExecuteNonQuery();
            }
            return true;
        }

        public static bool MarkUnread(UserContext user, int notificationId)
        {
            if (user == null || user.UserId <= 0 || notificationId <= 0) return false;
            EnsureTables();

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                "DELETE FROM ADMIN_NOTIFICATION_READS WHERE user_id = @userId AND notification_id = @notificationId", conn))
            {
                AddReadParameters(cmd, user, notificationId);
                cmd.ExecuteNonQuery();
            }
            return true;
        }

        public static void MarkAllRead(UserContext user, IEnumerable<int> notificationIds)
        {
            if (user == null || notificationIds == null) return;
            foreach (int notificationId in notificationIds)
                MarkRead(user, notificationId);
        }

        public static StudentPortalNotification ToStudentNotification(AdminNotificationItem item)
        {
            if (item == null) return null;
            return new StudentPortalNotification
            {
                NotificationId = item.NotificationId,
                NotificationType = NotificationType,
                AnnouncementId = item.NotificationId,
                OfferId = 0,
                CourseCode = "",
                CourseName = "",
                Title = item.Title,
                Content = item.Message,
                AuthorName = "Administrator",
                AuthorRole = "ADMIN",
                IsPinned = false,
                HasAttachment = false,
                FileUrl = "",
                CreatedAt = item.CreatedAt,
                IsRead = item.IsRead
            };
        }

        public static string AudienceLabel(string targetRole)
        {
            var role = NormalizeTargetRole(targetRole);
            if (role == "STUDENT") return "Students";
            if (role == "LECTURER") return "Lecturers";
            return "Students & Lecturers";
        }

        private static AdminNotificationItem Map(SqlDataReader reader, ISet<int> readIds)
        {
            var id = IntValue(reader["notification_id"]);
            return new AdminNotificationItem
            {
                NotificationId = id,
                Title = Text(reader["title"]),
                Message = Text(reader["message"]),
                TargetRole = Text(reader["target_role"]),
                CreatedByName = Text(reader["created_by_name"]),
                CreatedAt = DateValue(reader["created_at"]) ?? DateTime.MinValue,
                IsRead = readIds != null && readIds.Contains(id)
            };
        }

        private static string NormalizeTargetRole(string value)
        {
            var role = (value ?? "").Trim().ToUpperInvariant();
            if (role == "STUDENTS") role = "STUDENT";
            if (role == "LECTURERS") role = "LECTURER";
            if (role == "STUDENT" || role == "LECTURER" || role == "BOTH") return role;
            throw new ArgumentException("Target audience must be Student, Lecturer, or Both.");
        }

        private static void AddSaveParameters(SqlCommand cmd, string title, string message, string targetRole)
        {
            cmd.Parameters.Add("@title", SqlDbType.NVarChar, 150).Value = title;
            cmd.Parameters.Add("@message", SqlDbType.NVarChar, -1).Value = message;
            cmd.Parameters.Add("@targetRole", SqlDbType.VarChar, 20).Value = targetRole;
        }

        private static void AddReadParameters(SqlCommand cmd, UserContext user, int notificationId)
        {
            cmd.Parameters.Add("@userId", SqlDbType.Int).Value = user.UserId;
            cmd.Parameters.Add("@notificationId", SqlDbType.Int).Value = notificationId;
            cmd.Parameters.Add("@role", SqlDbType.VarChar, 20).Value = user.NormalizedRole;
        }

        private static void EnsureTables()
        {
            const string sql =
                "IF OBJECT_ID('dbo.ADMIN_NOTIFICATIONS', 'U') IS NULL " +
                "BEGIN " +
                "CREATE TABLE dbo.ADMIN_NOTIFICATIONS (" +
                "notification_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_ADMIN_NOTIFICATIONS PRIMARY KEY, " +
                "title nvarchar(150) NOT NULL, " +
                "message nvarchar(max) NOT NULL, " +
                "target_role varchar(20) NOT NULL, " +
                "created_by int NOT NULL, " +
                "created_at datetime2 NOT NULL CONSTRAINT DF_ADMIN_NOTIFICATIONS_created_at DEFAULT SYSDATETIME(), " +
                "CONSTRAINT CK_ADMIN_NOTIFICATIONS_target_role CHECK (target_role IN ('STUDENT','LECTURER','BOTH')), " +
                "CONSTRAINT FK_ADMIN_NOTIFICATIONS_USERS FOREIGN KEY (created_by) REFERENCES dbo.USERS(user_id)" +
                "); END; " +
                "IF OBJECT_ID('dbo.ADMIN_NOTIFICATION_READS', 'U') IS NULL " +
                "BEGIN " +
                "CREATE TABLE dbo.ADMIN_NOTIFICATION_READS (" +
                "user_id int NOT NULL, " +
                "notification_id int NOT NULL, " +
                "read_at datetime2 NOT NULL CONSTRAINT DF_ADMIN_NOTIFICATION_READS_read_at DEFAULT SYSDATETIME(), " +
                "CONSTRAINT PK_ADMIN_NOTIFICATION_READS PRIMARY KEY (user_id, notification_id), " +
                "CONSTRAINT FK_ADMIN_NOTIFICATION_READS_USERS FOREIGN KEY (user_id) REFERENCES dbo.USERS(user_id) ON DELETE CASCADE, " +
                "CONSTRAINT FK_ADMIN_NOTIFICATION_READS_NOTIFICATIONS FOREIGN KEY (notification_id) REFERENCES dbo.ADMIN_NOTIFICATIONS(notification_id) ON DELETE CASCADE" +
                "); END";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
                cmd.ExecuteNonQuery();
        }
    }
}
