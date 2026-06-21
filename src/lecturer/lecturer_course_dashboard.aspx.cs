using System;
using System.Globalization;
using System.Collections.Generic;
using System.Linq;
using src.services;

namespace src.lecturer
{
    public partial class lecturer_course_dashboard : src.security.LecturerPage
    {
        private int _offeringId;
        private CourseDashboardStats _stats;
        private int _announcementCount;
        private List<StudentCourseModule> _modules = new List<StudentCourseModule>();
        private List<LecturerMaterialRow> _assessments = new List<LecturerMaterialRow>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["user_id"] == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            if (!int.TryParse(Request.QueryString["offering"], out _offeringId))
            {
                Response.Redirect("~/lecturer/lecturer_courses.aspx");
                return;
            }

            var user = UserContextFactory.FromSession(Session);
            var profile = LecturerPortalService.GetProfile(user);
            if (profile == null)
            {
                Response.Redirect("~/lecturer/lecturer_courses.aspx");
                return;
            }

            // Returns null unless this lecturer teaches the offering (authorisation).
            _stats = LecturerPortalService.GetCourseStats(user, _offeringId);
            if (_stats == null)
            {
                Response.Redirect("~/lecturer/lecturer_courses.aspx");
                return;
            }

            var announcements = LecturerPortalService.GetAnnouncements(user, _offeringId);
            _announcementCount = announcements.Count;

            _modules = LecturerPortalService.GetCourseModules(user, _offeringId);
            modulesRepeater.DataSource = _modules;
            modulesRepeater.DataBind();

            _assessments = LecturerPortalService.GetMaterials(user, _offeringId)
                .Where(m => !string.Equals(m.MaterialType, "Lecture Notes", StringComparison.OrdinalIgnoreCase))
                .OrderBy(m => m.DueDate ?? DateTime.MaxValue)
                .ThenBy(m => m.Title)
                .ToList();
            assessmentsRepeater.DataSource = _assessments;
            assessmentsRepeater.DataBind();
        }

        // ----- Header -----

        protected string CourseCode { get { return _stats.CourseCode; } }
        protected string CourseName { get { return _stats.CourseName; } }
        protected string Description { get { return _stats.Description; } }
        protected string LevelLabel { get { return _stats.LevelLabel; } }
        protected int CreditHours { get { return _stats.CreditHours; } }
        protected string SemesterName { get { return _stats.SemesterName; } }

        /// <summary>Course accent color, or a neutral slate fallback for null/malformed values.</summary>
        protected string AccentColor
        {
            get
            {
                var color = _stats.Color;
                if (string.IsNullOrEmpty(color)) return "#64748b";
                return System.Text.RegularExpressions.Regex.IsMatch(color, @"^#[0-9A-Fa-f]{6}$")
                    ? color : "#64748b";
            }
        }

        // ----- Overview metrics -----

        protected int EnrolledCount { get { return _stats.EnrolledCount; } }
        protected int PendingGrading { get { return _stats.PendingGrading; } }

        /// <summary>Class average over published grades, e.g. "72.3%", or "—" when none.</summary>
        protected string AverageGradeDisplay
        {
            get
            {
                return _stats.AverageGrade.HasValue
                    ? _stats.AverageGrade.Value.ToString("0.#", CultureInfo.InvariantCulture) + "%"
                    : "—";
            }
        }

        /// <summary>Present-rate over recorded attendance, e.g. "92%", or "—" when none.</summary>
        protected string AttendanceDisplay
        {
            get
            {
                return _stats.AttendanceRate.HasValue
                    ? Math.Round(_stats.AttendanceRate.Value * 100).ToString("0", CultureInfo.InvariantCulture) + "%"
                    : "—";
            }
        }

        // ----- Card labels -----

        /// <summary>"28 students" / "1 student".</summary>
        protected string EnrolledLabel
        {
            get { return _stats.EnrolledCount + (_stats.EnrolledCount == 1 ? " student" : " students"); }
        }

        /// <summary>"3 announcements" / "1 announcement".</summary>
        protected string AnnouncementLabel
        {
            get { return _announcementCount + (_announcementCount == 1 ? " announcement" : " announcements"); }
        }

        /// <summary>"6 assessments" / "1 assessment".</summary>
        protected string AssessmentLabel
        {
            get { return _stats.AssessmentCount + (_stats.AssessmentCount == 1 ? " assessment" : " assessments"); }
        }

        /// <summary>"12 files" / "1 file".</summary>
        protected string MaterialLabel
        {
            get { return _stats.MaterialCount + (_stats.MaterialCount == 1 ? " file" : " files"); }
        }

        /// <summary>Number of announcements (drives the empty-state on the latest panel).</summary>
        protected int AnnouncementCount { get { return _announcementCount; } }
        protected int ModuleCount { get { return _modules.Count; } }
        protected int AssessmentCount { get { return _assessments.Count; } }

        // ----- Sub-page links (carry the offering id) -----

        protected string AnnouncementsUrl { get { return SubUrl("lecturer_announcement.aspx"); } }
        protected string PeopleUrl { get { return SubUrl("lecturer_course_people.aspx"); } }
        protected string GradesUrl { get { return SubUrl("lecturer_grades.aspx"); } }
        protected string MaterialsUrl { get { return SubUrl("lecturer_materials.aspx"); } }

        protected string MaterialPreviewUrl(object materialId)
        {
            return ResolveUrl("~/shared/material_preview.aspx?id=" + materialId);
        }

        protected string DueDateDisplay(object value)
        {
            return value == null || value == DBNull.Value
                ? "No due date"
                : Convert.ToDateTime(value).ToString("d MMM yyyy", CultureInfo.InvariantCulture);
        }

        protected string WeightDisplay(object value)
        {
            return value == null || value == DBNull.Value
                ? "Unweighted"
                : Convert.ToDecimal(value).ToString("0.##", CultureInfo.InvariantCulture) + "%";
        }

        protected string AssessmentIcon(object type)
        {
            string value = Convert.ToString(type);
            if (value == "Quiz") return "circle-help";
            if (value == "Test") return "clipboard-list";
            return "clipboard-check";
        }

        private string SubUrl(string page)
        {
            return ResolveUrl("~/lecturer/" + page) + "?offering=" + _offeringId;
        }
    }
}
