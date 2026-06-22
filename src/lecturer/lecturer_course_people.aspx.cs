using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using src.services;

namespace src.lecturer
{
    public partial class lecturer_course_people : src.security.LecturerPage
    {
        private int _offeringId;
        private LecturerCourseCard _course;
        private List<EnrolledStudentRow> _students = new List<EnrolledStudentRow>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["user_id"] == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            var user = UserContextFactory.FromSession(Session);
            var profile = LecturerPortalService.GetProfile(user);
            if (profile == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            if (!int.TryParse(Request.QueryString["offering"], out _offeringId))
            {
                Response.Redirect("~/lecturer/lecturer_courses.aspx");
                return;
            }

            foreach (var course in LecturerPortalService.GetCourses(user))
            {
                if (course.OfferingId == _offeringId)
                {
                    _course = course;
                    break;
                }
            }

            if (_course == null)
            {
                Response.Redirect("~/lecturer/lecturer_courses.aspx");
                return;
            }

            _students = LecturerPortalService.GetRoster(user, _offeringId);
            studentsRepeater.DataSource = _students;
            studentsRepeater.DataBind();
            emptyPanel.Visible = _students.Count == 0;
        }

        protected string CourseCode { get { return _course != null ? _course.CourseCode : ""; } }
        protected string CourseName { get { return _course != null ? _course.CourseName : ""; } }

        protected string EnrolledLabel
        {
            get
            {
                int enrolled = _students.Count(s => !s.IsPending);
                int pending = _students.Count(s => s.IsPending);
                string label = enrolled + (enrolled == 1 ? " student enrolled" : " students enrolled");
                if (pending > 0)
                    label += ", " + pending + " pending";
                return label;
            }
        }

        protected string BackUrl
        {
            get { return ResolveUrl("~/lecturer/lecturer_course_dashboard.aspx") + "?offering=" + _offeringId.ToString(CultureInfo.InvariantCulture); }
        }

        protected string Html(object value)
        {
            return HttpUtility.HtmlEncode(value == null ? "" : value.ToString());
        }
    }
}
