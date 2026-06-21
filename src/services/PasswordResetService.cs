using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using src.db;

namespace src.services
{
    /// <summary>
    /// Backs the "Forgot password" flow. Issues single-use, time-limited reset
    /// tokens (stored hashed in PASSWORD_RESET_TOKENS) and consumes them to set a
    /// new password. Passwords are saved as a lowercase SHA-256 hex digest in
    /// USERS.password_hash, matching login.aspx.cs and AccountPasswordService.
    /// </summary>
    public static class PasswordResetService
    {
        /// <summary>Reset links stay valid for one hour after being issued.</summary>
        private static readonly TimeSpan TokenLifetime = TimeSpan.FromHours(1);

        public class IssueResult
        {
            public bool Found;        // false when no account matches the email
            public string RawToken;   // the unhashed token to embed in the reset URL
            public string Username;    // used to personalise the email greeting
        }

        public class ResetResult
        {
            public bool Ok;
            public string Message;
        }

        /// <summary>
        /// Creates a reset token for the account with this email. Returns
        /// Found = false (and no token) when the email has no account, so the
        /// caller can show a neutral message without leaking which emails exist.
        /// </summary>
        public static IssueResult CreateToken(string email)
        {
            email = (email ?? "").Trim();
            if (email.Length == 0) return new IssueResult { Found = false };

            using (var conn = Db.OpenConnection())
            {
                int userId;
                string username;
                using (var cmd = new SqlCommand(
                    "SELECT user_id, username FROM USERS WHERE email = @email", conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) return new IssueResult { Found = false };
                        userId = (int)reader["user_id"];
                        username = reader["username"].ToString();
                    }
                }

                string rawToken = NewToken();
                using (var cmd = new SqlCommand(
                    "INSERT INTO PASSWORD_RESET_TOKENS (token_hash, user_id, expires_at) " +
                    "VALUES (@hash, @uid, @exp)", conn))
                {
                    cmd.Parameters.AddWithValue("@hash", Sha256Hex(rawToken));
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.Parameters.AddWithValue("@exp", DateTime.Now.Add(TokenLifetime));
                    cmd.ExecuteNonQuery();
                }

                return new IssueResult { Found = true, RawToken = rawToken, Username = username };
            }
        }

        /// <summary>
        /// True when the raw token exists, is unused, and has not expired. Used by
        /// the reset page to decide whether to show the form or an "invalid link".
        /// </summary>
        public static bool IsTokenValid(string rawToken)
        {
            if (string.IsNullOrWhiteSpace(rawToken)) return false;

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                "SELECT 1 FROM PASSWORD_RESET_TOKENS " +
                "WHERE token_hash = @hash AND used = 0 AND expires_at > @now", conn))
            {
                cmd.Parameters.AddWithValue("@hash", Sha256Hex(rawToken));
                cmd.Parameters.AddWithValue("@now", DateTime.Now);
                return cmd.ExecuteScalar() != null;
            }
        }

        /// <summary>
        /// Consumes the token and sets the new password. Validates token validity
        /// and password strength, updates USERS.password_hash, and marks the token
        /// used so the link cannot be replayed.
        /// </summary>
        public static ResetResult ResetWithToken(string rawToken, string newPassword, string confirmPassword)
        {
            if (string.IsNullOrWhiteSpace(rawToken))
                return Fail("This reset link is invalid.");
            if (string.IsNullOrEmpty(newPassword) || string.IsNullOrEmpty(confirmPassword))
                return Fail("Please fill in both password fields.");
            if (newPassword != confirmPassword)
                return Fail("The two passwords do not match.");

            string strengthError = AccountPasswordService.ValidateStrength(newPassword);
            if (strengthError != null) return Fail(strengthError);

            string tokenHash = Sha256Hex(rawToken);

            using (var conn = Db.OpenConnection())
            {
                int userId;
                using (var cmd = new SqlCommand(
                    "SELECT user_id FROM PASSWORD_RESET_TOKENS " +
                    "WHERE token_hash = @hash AND used = 0 AND expires_at > @now", conn))
                {
                    cmd.Parameters.AddWithValue("@hash", tokenHash);
                    cmd.Parameters.AddWithValue("@now", DateTime.Now);
                    var result = cmd.ExecuteScalar();
                    if (result == null || result == DBNull.Value)
                        return Fail("This reset link is invalid or has expired. Please request a new one.");
                    userId = (int)result;
                }

                using (var cmd = new SqlCommand(
                    "UPDATE USERS SET password_hash = @hash WHERE user_id = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@hash", Sha256Hex(newPassword));
                    cmd.Parameters.AddWithValue("@uid", userId);
                    cmd.ExecuteNonQuery();
                }

                using (var cmd = new SqlCommand(
                    "UPDATE PASSWORD_RESET_TOKENS SET used = 1 WHERE token_hash = @hash", conn))
                {
                    cmd.Parameters.AddWithValue("@hash", tokenHash);
                    cmd.ExecuteNonQuery();
                }
            }

            return new ResetResult { Ok = true, Message = "Your password has been reset. You can now sign in." };
        }

        // ---- Helpers --------------------------------------------------------

        private static ResetResult Fail(string message)
        {
            return new ResetResult { Ok = false, Message = message };
        }

        /// <summary>256 bits of cryptographically-random data as a hex string.</summary>
        private static string NewToken()
        {
            var bytes = new byte[32];
            using (var rng = RandomNumberGenerator.Create())
                rng.GetBytes(bytes);
            return ToHex(bytes);
        }

        private static string Sha256Hex(string value)
        {
            using (var sha = SHA256.Create())
                return ToHex(sha.ComputeHash(Encoding.UTF8.GetBytes(value)));
        }

        private static string ToHex(byte[] bytes)
        {
            var sb = new StringBuilder(bytes.Length * 2);
            foreach (var b in bytes) sb.Append(b.ToString("x2"));
            return sb.ToString();
        }
    }
}
