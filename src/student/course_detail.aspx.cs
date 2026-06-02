using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class course_detail : src.security.StudentPage
    {
        protected new CourseHeader Header;

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
            int userId = (int)Session["user_id"];

            int offeringId;
            if (!int.TryParse(Request.QueryString["offering"], out offeringId))
            {
                Response.Redirect("~/student/courses.aspx");
                return;
            }

            Header = CourseDetailService.GetHeader(offeringId, userId);
            if (Header == null)   // not enrolled / no such offering
            {
                Response.Redirect("~/student/courses.aspx");
                return;
            }

            outcomesRepeater.DataSource = CourseDetailService.GetLearningOutcomes(Header.CourseId);
            outcomesRepeater.DataBind();

            modulesRepeater.DataSource = ModuleService.GetModules(offeringId);
            modulesRepeater.DataBind();

            announcementsRepeater.DataSource = AnnouncementService.GetByOffering(offeringId);
            announcementsRepeater.DataBind();

            assignmentsRepeater.DataSource = AssignmentService.GetByOffering(offeringId, userId);
            assignmentsRepeater.DataBind();

            _gradebook = AssessmentService.GetGradebook(offeringId, userId);
            assessmentsRepeater.DataSource = _gradebook.Items;
            assessmentsRepeater.DataBind();
            barsRepeater.DataSource = _gradebook.Items;
            barsRepeater.DataBind();
        }

        private Gradebook _gradebook;

        /// <summary>Course accent color, or a neutral slate fallback for null/malformed values.</summary>
        protected string AccentColor(string color)
        {
            if (string.IsNullOrEmpty(color)) return "#64748b";
            return System.Text.RegularExpressions.Regex.IsMatch(color, @"^#[0-9A-Fa-f]{6}$")
                ? color : "#64748b";
        }

        /// <summary>Up to two uppercase initials from a full name (e.g. "Dr. Sarah Tan" -> "ST").</summary>
        protected string Initials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            var parts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            string letters = "";
            for (int i = parts.Length - 1; i >= 0 && letters.Length < 2; i--)
            {
                char c = parts[i][0];
                if (char.IsLetter(c)) letters = char.ToUpperInvariant(c) + letters;
            }
            return letters.Length == 0 ? "?" : letters;
        }

        /// <summary>Human file size ("3.4 MB"); empty for null (e.g. videos).</summary>
        protected string FileSize(object bytes)
        {
            if (bytes == null || bytes is DBNull) return "";
            int b = (int)bytes;
            if (b >= 1048576) return Math.Round(b / 1048576.0, 1) + " MB";
            if (b >= 1024) return Math.Round(b / 1024.0, 0) + " KB";
            return b + " B";
        }

        /// <summary>lucide icon name for a material file type.</summary>
        protected string FileIcon(string fileType)
        {
            switch ((fileType ?? "").ToLowerInvariant())
            {
                case "video": return "play-circle";
                case "pdf": return "file-text";
                case "docx": return "file-text";
                default: return "paperclip";
            }
        }

        /// <summary>Due/status line for an assignment card.</summary>
        protected string DueLabel(string status, DateTime due)
        {
            if (status == "MARKED") return "Graded · " + due.ToString("d MMM");
            if (status == "SUBMITTED") return "Submitted · " + due.ToString("d MMM");
            int days = (int)(due.Date - DateTime.Today).TotalDays;
            if (days < 0) return "Overdue · " + due.ToString("d MMM");
            if (days == 0) return "Today · 11:59 PM";
            if (days == 1) return "Tomorrow · 11:59 PM";
            return "In " + days + " days";
        }

        protected Gradebook Book { get { return _gradebook; } }

        /// <summary>Donut stroke-dashoffset for a 0-100 percentage over circumference 301.6.</summary>
        protected string DonutOffset(decimal? pct)
        {
            decimal p = pct ?? 0m;
            return Math.Round(301.6m * (1 - p / 100m), 1).ToString(System.Globalization.CultureInfo.InvariantCulture);
        }
    }
}
