using System;
using System.Web.UI;
using src.services;

namespace src.controls
{
    public partial class lecturer_topbar : UserControl
    {
        private LecturerProfile _lecturer;
        private int _unreadNotificationCount;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["user_id"] == null) return;
            var user = UserContextFactory.FromSession(Session);
            _lecturer = LecturerPortalService.GetProfile(user);
            var readIds = NotificationReadService.GetReadIds(user);
            foreach (var announcement in LecturerPortalService.GetAnnouncements(user, null))
            {
                if (!readIds.Contains(announcement.AnnouncementId))
                    _unreadNotificationCount++;
            }
        }

        protected string FullName
        {
            get { return _lecturer != null ? _lecturer.FullName : (Session["username"] as string ?? "Lecturer"); }
        }

        protected string Subtitle
        {
            get { return _lecturer != null ? _lecturer.DepartmentId : "Lecturer"; }
        }

        protected string NotificationBadgeText
        {
            get { return _unreadNotificationCount > 9 ? "9+" : _unreadNotificationCount.ToString(); }
        }

        protected string NotificationBadgeVisibilityClass
        {
            get { return _unreadNotificationCount > 0 ? "" : " hidden"; }
        }

        protected string IconUrl
        {
            get
            {
                if (_lecturer == null || string.IsNullOrEmpty(_lecturer.IconPath)) return "";
                return ResolveUrl("~/" + _lecturer.IconPath.TrimStart('/'));
            }
        }

        // First letters of the first two words of the name, e.g. "Dr. Sarah Tan" -> "DS".
        protected string Initials
        {
            get
            {
                if (_lecturer == null || string.IsNullOrEmpty(_lecturer.FullName)) return "";
                var parts = _lecturer.FullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                string initials = parts[0].Substring(0, 1);
                if (parts.Length > 1) initials += parts[1].Substring(0, 1);
                return initials.ToUpperInvariant();
            }
        }
    }
}
