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
            if (Session["user_id"] == null) return;

            _student = StudentService.GetByUserId((int)Session["user_id"]);
            if (_student != null)
            {
                _unreadNotificationCount = AnnouncementService.GetUnreadCountForStudent((int)Session["user_id"]);
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
