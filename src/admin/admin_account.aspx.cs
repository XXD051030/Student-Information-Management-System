using System;
using System.Web.Services;
using src.services;

namespace src.admin
{
    public partial class admin_account : src.security.AdminPage
    {
        [WebMethod(EnableSession = true)]
        public static object ChangePassword(string currentPassword, string newPassword)
        {
            return AccountWebMethods.ChangePassword(currentPassword, newPassword);
        }

        protected void Page_Load(object sender, EventArgs e) { }

        protected string DisplayName
        {
            get { return Session["username"] as string ?? "Administrator"; }
        }

        protected string RoleLabel
        {
            get { return "Administrator"; }
        }

        // First letters of the first two words of the name, e.g. "Admin One" -> "AO".
        protected string Initials
        {
            get
            {
                var name = DisplayName;
                if (string.IsNullOrEmpty(name)) return "";
                var parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                string initials = parts[0].Substring(0, 1);
                if (parts.Length > 1) initials += parts[1].Substring(0, 1);
                return initials.ToUpperInvariant();
            }
        }
    }
}
