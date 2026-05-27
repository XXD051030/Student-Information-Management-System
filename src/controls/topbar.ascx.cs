using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using src.services;

namespace src.controls
{
    public partial class topbar : UserControl
    {
        private Student _student;
        private int _unreadNotificationCount;

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
            Response.Cache.SetNoStore();

            if (Session["user_id"] == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            _student = StudentService.GetByUserId((int)Session["user_id"]);
            _unreadNotificationCount = AnnouncementService.GetUnreadCountForStudent((int)Session["user_id"]);
            if (_student == null)
            {
                // Session belongs to a non-student (e.g. admin/lecturer) — no profile to show.
                Response.Redirect("~/shared/login.aspx");
                return;
            }
        }
        protected string IconUrl
        {
            get
            {
                if (_student == null || string.IsNullOrEmpty(_student.IconPath)) return "";
                return ResolveUrl("~/" + _student.IconPath.TrimStart('/'));
            }
        }
        protected string FullName
        {
            get { return _student != null ? _student.FullName : ""; }
        }

        protected string ProgrammeName
        {
            get { return _student != null ? _student.ProgrammeName : ""; }
        }

        protected int UnreadNotificationCount
        {
            get { return _unreadNotificationCount; }
        }

        protected string NotificationBadgeText
        {
            get { return _unreadNotificationCount > 9 ? "9+" : _unreadNotificationCount.ToString(); }
        }

        protected string NotificationBadgeVisibilityClass
        {
            get { return _unreadNotificationCount > 0 ? "" : " hidden"; }
        }
    }
}
