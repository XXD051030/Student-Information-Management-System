using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.SessionState;
using src.services;

namespace src.lecturer
{
    public class LecturerNotificationItem
    {
        public int AnnouncementId { get; set; }
        public string CourseLabel { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public string AuthorName { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsPinned { get; set; }
        public bool IsRead { get; set; }
    }

    public partial class lecturer_notifications : src.security.LecturerPage
    {
        private const string ReadNotificationIdsKey = "lecturer_notification_read_ids";
        protected List<LecturerNotificationItem> Notifications = new List<LecturerNotificationItem>();

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            var user = UserContextFactory.FromSession(Session);
            var profile = LecturerPortalService.GetProfile(user);
            if (profile == null)
            {
                Response.Redirect("~/login/login.aspx");
                return;
            }

            Notifications = GetNotifications(user, profile.FullName, ReadIds(Session));
            notificationsRepeater.DataSource = Notifications;
            notificationsRepeater.DataBind();
            emptyPanel.Visible = Notifications.Count == 0;
        }

        protected int UnreadCount { get { return Notifications.Count(n => !n.IsRead); } }
        protected string ReadFlag(object value) { return Convert.ToBoolean(value) ? "true" : "false"; }
        protected string PinnedFlag(object value) { return Convert.ToBoolean(value) ? "true" : "false"; }

        protected string ListTime(DateTime dt)
        {
            DateTime now = DateTime.Now;
            if (dt.Date == now.Date) return dt.ToString("h:mm tt");
            if (dt.Date == now.Date.AddDays(-1)) return "Yesterday";
            return dt.Year == now.Year ? dt.ToString("d MMM") : dt.ToString("d MMM yyyy");
        }

        protected string FullTime(DateTime dt) { return dt.ToString("d MMM yyyy - HH:mm"); }

        private static List<LecturerNotificationItem> GetNotifications(UserContext user, string authorName, ISet<int> readIds)
        {
            return LecturerPortalService.GetAnnouncements(user, null)
                .Select(a => new LecturerNotificationItem
                {
                    AnnouncementId = a.AnnouncementId,
                    CourseLabel = a.TargetCourses,
                    Title = a.Title,
                    Content = a.Content,
                    AuthorName = string.IsNullOrWhiteSpace(authorName) ? "Lecturer" : authorName,
                    CreatedAt = a.CreatedAt,
                    IsPinned = a.IsPinned,
                    IsRead = readIds != null && readIds.Contains(a.AnnouncementId)
                })
                .ToList();
        }

        private static UserContext CurrentLecturerOrReject()
        {
            HttpContext context = HttpContext.Current;
            if (context == null || context.Session == null || context.Session["user_id"] == null)
            {
                if (context != null) context.Response.StatusCode = 401;
                return null;
            }

            var user = UserContextFactory.FromSession(context.Session);
            if (user == null || !user.IsLecturer)
            {
                context.Response.StatusCode = 403;
                return null;
            }
            return user;
        }

        private static HashSet<int> ReadIds(HttpSessionState session)
        {
            var ids = session[ReadNotificationIdsKey] as HashSet<int>;
            if (ids != null) return ids;
            ids = new HashSet<int>();
            session[ReadNotificationIdsKey] = ids;
            return ids;
        }

        private static object CountResponse(UserContext user, HashSet<int> readIds)
        {
            int unread = LecturerPortalService.GetAnnouncements(user, null)
                .Count(a => !readIds.Contains(a.AnnouncementId));
            return new { ok = true, unreadCount = unread, badgeText = unread > 9 ? "9+" : unread.ToString() };
        }

        [WebMethod(EnableSession = true)]
        public static object MarkRead(int announcementId)
        {
            var user = CurrentLecturerOrReject();
            if (user == null) return new { ok = false };
            var ids = ReadIds(HttpContext.Current.Session);
            ids.Add(announcementId);
            return CountResponse(user, ids);
        }

        [WebMethod(EnableSession = true)]
        public static object MarkUnread(int announcementId)
        {
            var user = CurrentLecturerOrReject();
            if (user == null) return new { ok = false };
            var ids = ReadIds(HttpContext.Current.Session);
            ids.Remove(announcementId);
            return CountResponse(user, ids);
        }

        [WebMethod(EnableSession = true)]
        public static object MarkAllRead()
        {
            var user = CurrentLecturerOrReject();
            if (user == null) return new { ok = false };
            var ids = ReadIds(HttpContext.Current.Session);
            foreach (var item in LecturerPortalService.GetAnnouncements(user, null))
                ids.Add(item.AnnouncementId);
            return CountResponse(user, ids);
        }
    }
}
