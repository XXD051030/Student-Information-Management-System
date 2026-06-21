using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using src.db;

namespace src.services
{
    /// <summary>
    /// Self-service password change shared by the student, lecturer, and admin
    /// account pages. Passwords live in USERS.password_hash as a lowercase
    /// SHA-256 hex digest, matching the login flow in login.aspx.cs.
    /// </summary>
    public static class AccountPasswordService
    {
        public class ChangeResult
        {
            public bool Ok;
            public string Message;
        }

        /// <summary>
        /// Enforces the standard format: at least 8 characters with an uppercase
        /// letter, a lowercase letter, a digit, and a symbol. Returns an error
        /// message, or null when the password satisfies every rule.
        /// </summary>
        public static string ValidateStrength(string password)
        {
            if (string.IsNullOrEmpty(password) || password.Length < 8)
                return "New password must be at least 8 characters.";

            bool hasUpper = false, hasLower = false, hasDigit = false, hasSymbol = false;
            foreach (char c in password)
            {
                if (char.IsUpper(c)) hasUpper = true;
                else if (char.IsLower(c)) hasLower = true;
                else if (char.IsDigit(c)) hasDigit = true;
                else hasSymbol = true;
            }

            if (!hasUpper) return "New password must include an uppercase letter.";
            if (!hasLower) return "New password must include a lowercase letter.";
            if (!hasDigit) return "New password must include a number.";
            if (!hasSymbol) return "New password must include a symbol.";
            return null;
        }

        public static ChangeResult ChangePassword(int userId, string currentPassword, string newPassword)
        {
            if (string.IsNullOrEmpty(currentPassword) || string.IsNullOrEmpty(newPassword))
                return Fail("Please fill in all password fields.");

            string strengthError = ValidateStrength(newPassword);
            if (strengthError != null) return Fail(strengthError);

            string currentHash = Sha256Hex(currentPassword);
            string newHash = Sha256Hex(newPassword);

            using (var conn = Db.OpenConnection())
            {
                string storedHash;
                using (var cmd = new SqlCommand("SELECT password_hash FROM USERS WHERE user_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", userId);
                    var result = cmd.ExecuteScalar();
                    if (result == null || result == DBNull.Value)
                        return Fail("Account not found.");
                    storedHash = result.ToString();
                }

                if (!string.Equals(storedHash, currentHash, StringComparison.OrdinalIgnoreCase))
                    return Fail("Current password is incorrect.");

                if (string.Equals(storedHash, newHash, StringComparison.OrdinalIgnoreCase))
                    return Fail("New password must differ from the current one.");

                using (var cmd = new SqlCommand("UPDATE USERS SET password_hash = @hash WHERE user_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@hash", newHash);
                    cmd.Parameters.AddWithValue("@id", userId);
                    cmd.ExecuteNonQuery();
                }
            }

            return new ChangeResult { Ok = true, Message = "Password updated successfully." };
        }

        private static ChangeResult Fail(string message)
        {
            return new ChangeResult { Ok = false, Message = message };
        }

        private static string Sha256Hex(string value)
        {
            using (var sha = SHA256.Create())
            {
                var bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(value));
                var sb = new StringBuilder(bytes.Length * 2);
                foreach (var b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }
    }
}
