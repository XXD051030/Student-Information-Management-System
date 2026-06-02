using System;
using System.Web.UI;
using src.services;

namespace src.controls
{
    public partial class sidebar : UserControl
    {
        private int _unreadNotificationCount;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["user_id"] == null) return;

            _unreadNotificationCount = AnnouncementService.GetUnreadCountForStudent((int)Session["user_id"]);
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
