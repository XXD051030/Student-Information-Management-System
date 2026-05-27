using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class courses : System.Web.UI.Page
    {
        private List<EnrolledCourse> _courses;
        private string _currentSemesterName;

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
            _courses = EnrolmentService.GetCourses(userId);

            var current = SemesterService.GetCurrent();
            _currentSemesterName = current != null ? current.Name : null;

            coursesRepeater.DataSource = _courses;
            coursesRepeater.DataBind();
        }

        /// <summary>Total number of courses the student is enrolled in (all semesters).</summary>
        protected int EnrolledCount
        {
            get { return _courses != null ? _courses.Count : 0; }
        }

        /// <summary>True when the given semester name matches the current semester.</summary>
        protected bool IsCurrent(string semesterName)
        {
            return _currentSemesterName != null
                && string.Equals(semesterName, _currentSemesterName, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Course accent color from the DB. Returns a neutral slate fallback when
        /// unset or when the stored value is not a plain hex color, so a malformed
        /// value can never break out of the inline style attribute it is written into.
        /// </summary>
        protected string AccentColor(string color)
        {
            if (string.IsNullOrEmpty(color)) return "#64748b";
            // Require a 6-digit hex (#rrggbb): the icon tint appends an alpha suffix
            // ("...15"), which only forms valid CSS for a 6-digit color.
            return System.Text.RegularExpressions.Regex.IsMatch(color, @"^#[0-9A-Fa-f]{6}$")
                ? color : "#64748b";
        }

        /// <summary>Lowercased "code name lecturer" string used by the client-side search filter.</summary>
        protected string SearchKey(string code, string name, string lecturer)
        {
            return ((code ?? "") + " " + (name ?? "") + " " + (lecturer ?? "")).ToLowerInvariant();
        }
    }
}
