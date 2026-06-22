using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.SessionState;
using System.Web.UI.WebControls;
using src.services;

namespace src.lecturer
{
    public class LecturerNotificationItem
    {
        public int AnnouncementId { get; set; }
        public int OfferingId { get; set; }
        public string AcademicYear { get; set; }
        public string Semester { get; set; }
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

            ImportSessionReadIds(user);
            BindFilters(user);
            Notifications = GetNotifications(user, profile.FullName, NotificationReadService.GetReadIds(user));
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

        private void BindFilters(UserContext user)
        {
            var courses = LecturerPortalService.GetCourses(user);
            var sessions = AcademicTermReader.GetSessionOptions();

            yearFilter.Items.Clear();
            yearFilter.Items.Add(new ListItem("All years", "all"));
            foreach (var year in sessions.Select(s => s.AcademicYear)
                .Concat(courses.Select(c => c.AcademicYear)).Where(HasValue).Distinct())
                yearFilter.Items.Add(new ListItem(StudentPortalFormat.AcademicYearLabel(year), year));

            semesterFilter.Items.Clear();
            semesterFilter.Items.Add(new ListItem("All semesters", "all"));
            foreach (var semester in sessions.Select(s => s.Semester)
                .Concat(courses.Select(c => c.Semester)).Where(HasValue).Distinct())
                semesterFilter.Items.Add(new ListItem(StudentPortalFormat.SemesterLabel(semester), semester));

            courseFilter.Items.Clear();
            courseFilter.Items.Add(new ListItem("All courses", "all"));
            foreach (var course in courses)
            {
                var option = new ListItem(
                    course.CourseCode + " - " + course.CourseName,
                    course.OfferingId.ToString());
                option.Attributes["data-year"] = course.AcademicYear;
                option.Attributes["data-semester"] = course.Semester;
                courseFilter.Items.Add(option);
            }
        }

        private static bool HasValue(string value)
        {
            return !string.IsNullOrWhiteSpace(value);
        }

        private static List<LecturerNotificationItem> GetNotifications(UserContext user, string authorName, ISet<int> readIds)
        {
            return LecturerPortalService.GetAnnouncements(user, null)
                .Select(a => new LecturerNotificationItem
                {
                    AnnouncementId = a.AnnouncementId,
                    OfferingId = a.OfferingId,
                    AcademicYear = a.AcademicYear,
                    Semester = a.Semester,
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

        private void ImportSessionReadIds(UserContext user)
        {
            var ids = Session[ReadNotificationIdsKey] as IEnumerable<int>;
            if (ids == null) return;
            NotificationReadService.Import(user, ids);
            Session.Remove(ReadNotificationIdsKey);
        }

        private static object CountResponse(UserContext user)
        {
            var readIds = NotificationReadService.GetReadIds(user);
            int unread = LecturerPortalService.GetAnnouncements(user, null)
                .Count(a => !readIds.Contains(a.AnnouncementId));
            return new { ok = true, unreadCount = unread, badgeText = unread > 9 ? "9+" : unread.ToString() };
        }

        [WebMethod(EnableSession = true)]
        public static object MarkRead(int announcementId)
        {
            var user = CurrentLecturerOrReject();
            if (user == null) return new { ok = false };
            NotificationReadService.MarkRead(user, announcementId);
            return CountResponse(user);
        }

        [WebMethod(EnableSession = true)]
        public static object MarkUnread(int announcementId)
        {
            var user = CurrentLecturerOrReject();
            if (user == null) return new { ok = false };
            NotificationReadService.MarkUnread(user, announcementId);
            return CountResponse(user);
        }

        [WebMethod(EnableSession = true)]
        public static object MarkAllRead()
        {
            var user = CurrentLecturerOrReject();
            if (user == null) return new { ok = false };
            NotificationReadService.MarkAllRead(
                user,
                LecturerPortalService.GetAnnouncements(user, null).Select(a => a.AnnouncementId));
            return CountResponse(user);
        }
    }
}
