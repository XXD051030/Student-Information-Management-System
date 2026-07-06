using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace src.controls
{
    public partial class lecturer_sidebar : System.Web.UI.UserControl
    {
        private int _unreadNotificationCount;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["user_id"] == null) return;
            var user = src.services.UserContextFactory.FromSession(Session);
            var readIds = src.services.NotificationReadService.GetReadIds(user);
            foreach (var announcement in src.services.LecturerPortalService.GetAnnouncements(user, null))
            {
                if (!readIds.Contains(announcement.AnnouncementId))
                    _unreadNotificationCount++;
            }

            var adminReadIds = src.services.AdminNotificationService.GetReadIds(user);
            foreach (var notification in src.services.AdminNotificationService.GetForUser(user, adminReadIds))
            {
                if (!notification.IsRead)
                    _unreadNotificationCount++;
            }

            foreach (var notification in src.services.SubmissionNotificationService.GetForUser(user))
            {
                if (!notification.IsRead)
                    _unreadNotificationCount++;
            }
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
