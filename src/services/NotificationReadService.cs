using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    public static class NotificationReadService
    {
        public static HashSet<int> GetReadIds(UserContext user)
        {
            var ids = new HashSet<int>();
            if (user == null || user.UserId <= 0) return ids;

            EnsureTable();
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                "SELECT announcement_id FROM NOTIFICATION_READS WHERE user_id = @userId", conn))
            {
                cmd.Parameters.AddWithValue("@userId", user.UserId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        ids.Add(Convert.ToInt32(reader["announcement_id"]));
                }
            }
            return ids;
        }

        public static void Import(UserContext user, IEnumerable<int> announcementIds)
        {
            if (user == null || announcementIds == null) return;
            foreach (int announcementId in announcementIds)
                MarkRead(user, announcementId);
        }

        public static bool MarkRead(UserContext user, int announcementId)
        {
            if (user == null || user.UserId <= 0 || announcementId <= 0) return false;
            EnsureTable();

            const string sql =
                "IF EXISTS (SELECT 1 FROM ANNOUNCEMENTS WHERE announcement_id = @announcementId) " +
                "AND NOT EXISTS (SELECT 1 FROM NOTIFICATION_READS WHERE user_id = @userId AND announcement_id = @announcementId) " +
                "INSERT INTO NOTIFICATION_READS (user_id, announcement_id) VALUES (@userId, @announcementId)";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                AddParameters(cmd, user.UserId, announcementId);
                cmd.ExecuteNonQuery();
                return true;
            }
        }

        public static bool MarkUnread(UserContext user, int announcementId)
        {
            if (user == null || user.UserId <= 0 || announcementId <= 0) return false;
            EnsureTable();

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                "DELETE FROM NOTIFICATION_READS WHERE user_id = @userId AND announcement_id = @announcementId", conn))
            {
                AddParameters(cmd, user.UserId, announcementId);
                cmd.ExecuteNonQuery();
                return true;
            }
        }

        public static void MarkAllRead(UserContext user, IEnumerable<int> announcementIds)
        {
            if (user == null || announcementIds == null) return;
            foreach (int announcementId in announcementIds)
                MarkRead(user, announcementId);
        }

        private static void EnsureTable()
        {
            const string sql =
                "IF OBJECT_ID('dbo.NOTIFICATION_READS', 'U') IS NULL " +
                "BEGIN " +
                "CREATE TABLE dbo.NOTIFICATION_READS (" +
                "user_id int NOT NULL, " +
                "announcement_id int NOT NULL, " +
                "read_at datetime2 NOT NULL CONSTRAINT DF_NOTIFICATION_READS_read_at DEFAULT SYSUTCDATETIME(), " +
                "CONSTRAINT PK_NOTIFICATION_READS PRIMARY KEY (user_id, announcement_id), " +
                "CONSTRAINT FK_NOTIFICATION_READS_USERS FOREIGN KEY (user_id) REFERENCES dbo.USERS(user_id) ON DELETE CASCADE, " +
                "CONSTRAINT FK_NOTIFICATION_READS_ANNOUNCEMENTS FOREIGN KEY (announcement_id) REFERENCES dbo.ANNOUNCEMENTS(announcement_id) ON DELETE CASCADE" +
                "); END";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
                cmd.ExecuteNonQuery();
        }

        private static void AddParameters(SqlCommand cmd, int userId, int announcementId)
        {
            cmd.Parameters.Add("@userId", SqlDbType.Int).Value = userId;
            cmd.Parameters.Add("@announcementId", SqlDbType.Int).Value = announcementId;
        }
    }
}
