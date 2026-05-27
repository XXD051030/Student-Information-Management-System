using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using src.services;

namespace src.shared
{
    public partial class notification : System.Web.UI.Page
    {
        protected List<StudentNotification> Notifications = new List<StudentNotification>();

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);

            if (Session["user_id"] == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            int userId = (int)Session["user_id"];
            Notifications = AnnouncementService.GetAllForStudent(userId);

            notificationsRepeater.DataSource = Notifications;
            notificationsRepeater.DataBind();
            emptyPanel.Visible = Notifications.Count == 0;
        }

        protected int UnreadCount
        {
            get { return Notifications.Count(n => !n.IsRead); }
        }

        protected string ReadFlag(object isRead)
        {
            return ((bool)isRead) ? "true" : "false";
        }

        // ADMIN-authored posts read as system notices; everything else is a
        // course announcement. Used for the badge label and colour.
        protected string Category(object role)
        {
            return string.Equals(role as string, "ADMIN", StringComparison.OrdinalIgnoreCase)
                ? "SYSTEM"
                : "ANNOUNCEMENT";
        }

        protected string CourseLabel(StudentNotification n)
        {
            return n.CourseCode + " · " + n.CourseName;
        }

        // Compact stamp for the list column.
        protected string ListTime(DateTime dt)
        {
            DateTime now = DateTime.Now;
            if (dt.Date == now.Date) return dt.ToString("h:mm tt");
            if (dt.Date == now.Date.AddDays(-1)) return "Yesterday";
            if (dt.Year == now.Year) return dt.ToString("d MMM");
            return dt.ToString("d MMM yyyy");
        }

        // Full stamp for the detail header.
        protected string FullTime(DateTime dt)
        {
            return dt.ToString("d MMM yyyy · HH:mm");
        }

        protected string PinnedFlag(object isPinned)
        {
            return ((bool)isPinned) ? "true" : "false";
        }

        private static int CurrentUserIdOrReject()
        {
            HttpContext context = HttpContext.Current;
            if (context == null || context.Session == null || context.Session["user_id"] == null)
            {
                if (context != null) context.Response.StatusCode = 401;
                return 0;
            }

            return (int)context.Session["user_id"];
        }

        private static string BadgeText(int unreadCount)
        {
            return unreadCount > 9 ? "9+" : unreadCount.ToString();
        }

        private static object CountResponse(int userId)
        {
            int unreadCount = AnnouncementService.GetUnreadCountForStudent(userId);
            return new
            {
                ok = true,
                unreadCount = unreadCount,
                badgeText = BadgeText(unreadCount)
            };
        }

        [WebMethod(EnableSession = true)]
        public static object MarkRead(int announcementId)
        {
            int userId = CurrentUserIdOrReject();
            if (userId == 0) return new { ok = false };

            AnnouncementService.MarkRead(userId, announcementId);
            return CountResponse(userId);
        }

        [WebMethod(EnableSession = true)]
        public static object MarkUnread(int announcementId)
        {
            int userId = CurrentUserIdOrReject();
            if (userId == 0) return new { ok = false };

            AnnouncementService.MarkUnread(userId, announcementId);
            return CountResponse(userId);
        }

        [WebMethod(EnableSession = true)]
        public static object MarkAllRead()
        {
            int userId = CurrentUserIdOrReject();
            if (userId == 0) return new { ok = false };

            AnnouncementService.MarkAllRead(userId);
            return CountResponse(userId);
        }
    }
}
