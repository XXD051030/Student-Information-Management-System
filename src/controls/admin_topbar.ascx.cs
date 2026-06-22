using System;
using System.Data.SqlClient;
using System.Web.UI;
using src.db;

namespace src.controls
{
    public partial class admin_topbar : UserControl
    {
        private string _iconPath = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["user_id"] == null) return;
            var userId = Convert.ToInt32(Session["user_id"]);
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand("SELECT icon FROM ADMINS WHERE user_id = @uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                var val = cmd.ExecuteScalar();
                _iconPath = val == null || val == DBNull.Value ? "" : val.ToString();
            }
        }

        protected string DisplayName
        {
            get { return Session["username"] as string ?? "Administrator"; }
        }

        protected string RoleLabel
        {
            get { return "Administrator"; }
        }

        protected string IconUrl
        {
            get
            {
                if (string.IsNullOrEmpty(_iconPath)) return "";
                return ResolveUrl("~/" + _iconPath.TrimStart('/'));
            }
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
