using System;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using src.db;
using src.services;

namespace src
{
    public class IconUploadHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        private static readonly string[] AllowedExt = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
        private const int MaxBytes = 2 * 1024 * 1024;

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            var js = new JavaScriptSerializer();

            try
            {
                var user = UserContextFactory.FromSession(context.Session);
                if (user == null)
                {
                    Write(context, js, false, "Session expired. Please log in again.", "");
                    return;
                }

                var upload = context.Request.Files["icon"];
                if (upload == null || upload.ContentLength <= 0)
                    throw new InvalidOperationException("Please choose an image to upload.");

                var ext = Path.GetExtension(upload.FileName ?? "").ToLowerInvariant();
                if (Array.IndexOf(AllowedExt, ext) < 0)
                    throw new InvalidOperationException("Only JPG, PNG, GIF, and WebP images are accepted.");
                if (upload.ContentLength > MaxBytes)
                    throw new InvalidOperationException("Image must be smaller than 2 MB.");

                string folder = context.Server.MapPath("~/uploads/usericon");
                Directory.CreateDirectory(folder);

                string fileName = user.UserId +
                    "-" + DateTime.Now.ToString("yyyyMMddHHmmssfff", CultureInfo.InvariantCulture) +
                    ext;
                upload.SaveAs(Path.Combine(folder, fileName));

                string iconPath = "uploads/usericon/" + fileName;
                SaveIcon(user, iconPath);

                string appBase = context.Request.ApplicationPath.TrimEnd('/');
                string iconUrl = appBase + "/" + iconPath;

                Write(context, js, true, "Profile photo updated.", iconUrl);
            }
            catch (InvalidOperationException ex)
            {
                Write(context, js, false, ex.Message, "");
            }
            catch
            {
                Write(context, js, false, "Photo could not be saved. Please try again.", "");
            }
        }

        private static void SaveIcon(UserContext user, string iconPath)
        {
            string sql;
            if (user.IsStudent)
                sql = "UPDATE STUDENTS SET icon = @icon WHERE user_id = @uid";
            else if (user.IsLecturer)
                sql = "UPDATE LECTURERS SET icon = @icon WHERE user_id = @uid";
            else
                sql = "UPDATE ADMINS SET icon = @icon WHERE user_id = @uid";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@icon", iconPath);
                cmd.Parameters.AddWithValue("@uid", user.UserId);
                cmd.ExecuteNonQuery();
            }
        }

        private static void Write(HttpContext ctx, JavaScriptSerializer js, bool ok, string msg, string url)
        {
            ctx.Response.Write(js.Serialize(new { success = ok, message = msg, iconUrl = url }));
        }
    }
}
