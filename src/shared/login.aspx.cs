using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Services;
using src.db;

namespace src.shared
{
    public partial class login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, System.EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(System.DateTime.UtcNow.AddDays(-1));
            Response.Cache.SetNoStore();

            if (Session["user_id"] != null)
            {
                Response.Redirect(src.security.RoleRoutes.HomePageFor(Session["role"] as string));
                return;
            }

            var cookie = Request.Cookies["auth_token"];
            if (cookie == null || string.IsNullOrEmpty(cookie.Value)) return;

            try
            {
                var tokenHash = Sha256Hex(cookie.Value);
                int userId = 0;
                string role = null;
                System.DateTime expiresAt = System.DateTime.MinValue;
                bool found = false;

                using (var conn = Db.OpenConnection())
                using (var cmd = new SqlCommand(
                    "SELECT u.user_id, u.role, t.expires_at " +
                    "FROM AUTH_TOKENS t JOIN USERS u ON t.user_id = u.user_id " +
                    "WHERE t.token_hash = @hash", conn))
                {
                    cmd.Parameters.AddWithValue("@hash", tokenHash);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            userId = (int)reader["user_id"];
                            role = reader["role"].ToString();
                            expiresAt = (System.DateTime)reader["expires_at"];
                            found = true;
                        }
                    }
                }

                if (!found)
                {
                    ExpireAuthCookie();
                    return;
                }

                if (expiresAt <= System.DateTime.UtcNow)
                {
                    using (var conn = Db.OpenConnection())
                    using (var cmd = new SqlCommand("DELETE FROM AUTH_TOKENS WHERE token_hash = @hash", conn))
                    {
                        cmd.Parameters.AddWithValue("@hash", tokenHash);
                        cmd.ExecuteNonQuery();
                    }
                    ExpireAuthCookie();
                    return;
                }

                Session["user_id"] = userId;
                Session["role"] = role;
                Response.Redirect(src.security.RoleRoutes.HomePageFor(role));
            }
            catch (System.Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Remember-me auto-login failed: " + ex.Message);
            }
        }

        [WebMethod]
        public static object CheckEmail(string email)
        {
            email = (email ?? "").Trim();

            if (email.Length > 0)
            {
                using (var conn = Db.OpenConnection())
                using (var cmd = new SqlCommand("SELECT 1 FROM USERS WHERE email = @email", conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    if (cmd.ExecuteScalar() != null)
                    {
                        return new { ok = true };
                    }
                }
            }

            var ctx = HttpContext.Current;
            ctx.Response.StatusCode = 404;
            ctx.Response.SuppressContent = true;
            return null;
        }

        [WebMethod(EnableSession = true)]
        public static object VerifyPassword(string email, string password, bool remember)
        {
            email = (email ?? "").Trim();
            password = password ?? "";

            if (email.Length > 0 && password.Length > 0)
            {
                var inputHash = Sha256Hex(password);

                int userId = 0;
                string role = null;
                bool authenticated = false;

                using (var conn = Db.OpenConnection())
                using (var cmd = new SqlCommand("SELECT user_id, password_hash, role, username FROM USERS WHERE email = @email", conn))
                {
                    cmd.Parameters.AddWithValue("@email", email);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            var dbHash = reader["password_hash"].ToString();
                            if (string.Equals(dbHash, inputHash, System.StringComparison.OrdinalIgnoreCase))
                            {
                                userId = (int)reader["user_id"];
                                role = reader["role"].ToString();
                                HttpContext.Current.Session["user_id"] = userId;
                                HttpContext.Current.Session["role"] = role;
                                HttpContext.Current.Session["username"] = reader["username"].ToString();
                                authenticated = true;
                            }
                        }
                    }
                }

                if (authenticated)
                {
                    if (remember)
                    {
                        try
                        {
                            IssueRememberMeCookie(userId);
                        }
                        catch (System.Exception ex)
                        {
                            System.Diagnostics.Debug.WriteLine("IssueRememberMeCookie failed: " + ex.Message);
                        }
                    }
                    return new { ok = true, redirect = VirtualPathUtility.ToAbsolute(src.security.RoleRoutes.HomePageFor(role)) };
                }
            }

            var ctx = HttpContext.Current;
            ctx.Response.StatusCode = 401;
            ctx.Response.SuppressContent = true;
            return null;
        }

        [WebMethod(EnableSession = true)]
        public static object Logout()
        {
            var ctx = HttpContext.Current;
            var cookie = ctx.Request.Cookies["auth_token"];

            if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
            {
                try
                {
                    var tokenHash = Sha256Hex(cookie.Value);
                    using (var conn = Db.OpenConnection())
                    using (var cmd = new SqlCommand("DELETE FROM AUTH_TOKENS WHERE token_hash = @hash", conn))
                    {
                        cmd.Parameters.AddWithValue("@hash", tokenHash);
                        cmd.ExecuteNonQuery();
                    }
                }
                catch (System.Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Logout token cleanup failed: " + ex.Message);
                }
            }

            ExpireAuthCookie();
            ctx.Session.Abandon();
            return new { ok = true };
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

        private static string GenerateRawToken()
        {
            var bytes = new byte[32];
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(bytes);
            }
            return System.Convert.ToBase64String(bytes);
        }

        private static void IssueRememberMeCookie(int userId)
        {
            var rawToken = GenerateRawToken();
            var tokenHash = Sha256Hex(rawToken);
            var expiresAt = System.DateTime.UtcNow.AddDays(30);

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                "INSERT INTO AUTH_TOKENS (user_id, token_hash, expires_at) VALUES (@uid, @hash, @exp)", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@hash", tokenHash);
                cmd.Parameters.AddWithValue("@exp", expiresAt);
                cmd.ExecuteNonQuery();
            }

            var ctx = HttpContext.Current;
            var cookie = new HttpCookie("auth_token", rawToken)
            {
                HttpOnly = true,
                Secure = ctx.Request.IsSecureConnection,
                Expires = System.DateTime.Now.AddDays(30),
                Path = "/"
            };
            ctx.Response.Cookies.Add(cookie);
        }

        private static void ExpireAuthCookie()
        {
            var ctx = HttpContext.Current;
            var expired = new HttpCookie("auth_token", "")
            {
                HttpOnly = true,
                Expires = System.DateTime.Now.AddDays(-1),
                Path = "/"
            };
            ctx.Response.Cookies.Add(expired);
        }
    }
}
