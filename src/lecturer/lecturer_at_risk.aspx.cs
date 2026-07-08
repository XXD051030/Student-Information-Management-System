using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using src.services;

namespace student_information_management_system
{
    public partial class lecturer_at_risk : src.security.LecturerPage
    {
        private List<LecturerAcademicPerformanceRow> rows = new List<LecturerAcademicPerformanceRow>();

        protected void Page_Load(object sender, EventArgs e)
        {
            var user = UserContextFactory.FromSession(Session);
            if (LecturerPortalService.GetProfile(user) == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            if (IsPostBack) return;

            var allRows = LecturerPortalService.GetAcademicPerformance(user);
            var courses = LecturerPortalService.GetCourses(user);
            InitializeFilters(courses);
            BindPage(allRows);
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            var user = UserContextFactory.FromSession(Session);
            var allRows = LecturerPortalService.GetAcademicPerformance(user);
            var courses = LecturerPortalService.GetCourses(user);

            if (sender == academicYearFilter)
            {
                PopulateSemesterFilter(courses, "all");
                PopulateCourseFilter(courses, "all");
            }
            else if (sender == semesterFilter)
            {
                PopulateCourseFilter(courses, "all");
            }

            BindPage(allRows);
        }

        private void InitializeFilters(List<LecturerCourseCard> courses)
        {
            var sessions = AcademicTermReader.GetSessionOptions();
            academicYearFilter.Items.Clear();
            academicYearFilter.Items.Add(new ListItem("All academic years", "all"));
            foreach (var year in sessions.Select(s => s.AcademicYear)
                .Concat(courses.Select(r => r.AcademicYear)).Where(HasValue).Distinct().OrderBy(v => v))
                academicYearFilter.Items.Add(new ListItem(StudentPortalFormat.AcademicYearLabel(year), year));

            PopulateSemesterFilter(courses, "all");
            PopulateCourseFilter(courses, "all");
        }

        private void PopulateSemesterFilter(List<LecturerCourseCard> courses, string preferredValue)
        {
            var selectedYear = academicYearFilter.SelectedValue;
            var semesters = AcademicTermReader.GetSessionOptions()
                .Where(r => selectedYear == "all" || r.AcademicYear == selectedYear)
                .Select(r => r.Semester)
                .Concat(courses
                .Where(r => selectedYear == "all" || r.AcademicYear == selectedYear)
                .Select(r => r.Semester))
                .Where(HasValue)
                .Distinct()
                .OrderBy(SemesterOrder)
                .ToList();

            semesterFilter.Items.Clear();
            semesterFilter.Items.Add(new ListItem("All semesters", "all"));
            foreach (var semester in semesters)
                semesterFilter.Items.Add(new ListItem(StudentPortalFormat.SemesterLabel(semester), semester));

            var preferred = semesterFilter.Items.FindByValue(preferredValue ?? "");
            if (preferred != null) semesterFilter.SelectedValue = preferred.Value;
            else semesterFilter.SelectedValue = "all";
        }

        private void PopulateCourseFilter(List<LecturerCourseCard> courses, string preferredValue)
        {
            var selectedYear = academicYearFilter.SelectedValue;
            var selectedSemester = semesterFilter.SelectedValue;
            var availableCourses = courses
                .Where(r => (selectedYear == "all" || r.AcademicYear == selectedYear)
                    && (selectedSemester == "all" || r.Semester == selectedSemester))
                .OrderBy(r => r.CourseCode)
                .ToList();

            courseFilter.Items.Clear();
            courseFilter.Items.Add(new ListItem("All courses", "all"));
            foreach (var course in availableCourses)
                courseFilter.Items.Add(new ListItem(
                    course.CourseCode + " - " + course.CourseName,
                    course.OfferingId.ToString(CultureInfo.InvariantCulture)));

            var preferred = courseFilter.Items.FindByValue(preferredValue ?? "");
            courseFilter.SelectedValue = preferred != null ? preferred.Value : "all";
        }

        private void BindPage(List<LecturerAcademicPerformanceRow> allRows)
        {
            var selectedYear = academicYearFilter.SelectedValue;
            var selectedSemester = semesterFilter.SelectedValue;
            var selectedCourse = courseFilter.SelectedValue;
            int selectedOfferingId;
            int.TryParse(selectedCourse, out selectedOfferingId);

            rows = allRows.Where(r =>
                    (selectedYear == "all" || r.AcademicYear == selectedYear)
                    && (selectedSemester == "all" || r.OfferingSemester == selectedSemester)
                    && (selectedOfferingId == 0 || r.OfferingId == selectedOfferingId))
                .ToList();

            studentRepeater.DataSource = rows;
            studentRepeater.DataBind();
            riskRepeater.DataSource = rows.Where(r => r.IsAtRisk).ToList();
            riskRepeater.DataBind();
            topRepeater.DataSource = rows.Where(r => r.AverageMarks.HasValue && r.AverageMarks.Value >= 80m)
                .OrderByDescending(r => r.AverageMarks).ToList();
            topRepeater.DataBind();

            attendanceRepeater.DataSource = rows
                .GroupBy(r => new { r.CourseCode, r.CourseName, r.ProgrammeCode })
                .Select(g => new
                {
                    g.Key.CourseCode,
                    g.Key.CourseName,
                    g.Key.ProgrammeCode,
                    Enrolled = g.Select(r => r.StudentId).Distinct().Count(),
                    AverageAttendance = NullableAverage(g.Select(r => r.AttendanceRate))
                }).ToList();
            attendanceRepeater.DataBind();
        }

        protected int StudentCount { get { return rows.Select(r => r.StudentId).Distinct().Count(); } }
        protected int AtRiskCount { get { return rows.Count(r => r.IsAtRisk); } }
        protected int TopPerformerCount { get { return rows.Count(r => r.AverageMarks.HasValue && r.AverageMarks.Value >= 80m); } }
        protected decimal AverageGpa { get { return rows.Count == 0 ? 0m : rows.Average(r => r.GradePoint); } }
        protected decimal AverageMarks { get { return NullableAverage(rows.Select(r => r.AverageMarks)) ?? 0m; } }
        protected decimal PassRate { get { return Rate(rows.Count(r => r.Status == "Pass"), rows.Count(r => r.Status != "Pending")); } }
        protected decimal FailRate { get { return Rate(rows.Count(r => r.Status == "Fail"), rows.Count(r => r.Status != "Pending")); } }

        protected decimal GradeBandPercent(decimal minimum, decimal maximum)
        {
            var marked = rows.Where(r => r.AverageMarks.HasValue).ToList();
            if (marked.Count == 0) return 0m;
            return Rate(marked.Count(r => r.AverageMarks.Value >= minimum && r.AverageMarks.Value < maximum), marked.Count);
        }

        protected string Html(object value) { return HttpUtility.HtmlEncode(value == null ? "" : value.ToString()); }
        protected string Marks(object value) { return NumberOrDash(value, "0.0", "%"); }
        protected string Gpa(object value) { return NumberOrDash(value, "0.00", ""); }
        protected string Percent(decimal value) { return value.ToString("0.0", CultureInfo.InvariantCulture) + "%"; }
        protected int BarWidth(decimal value) { return (int)Math.Max(0m, Math.Min(100m, Math.Round(value))); }

        protected string StatusClass(object value)
        {
            var status = value == null ? "" : value.ToString();
            if (status == "Pass") return "bg-emerald-50 text-emerald-700 border-emerald-100";
            if (status == "Fail") return "bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20";
            return "bg-slate-100 text-slate-600 border-slate-200";
        }

        protected string RiskClass(object value)
        {
            return value != null && value.ToString() == "High"
                ? "bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20"
                : "bg-amber-50 text-amber-700 border-amber-100";
        }

        private static int SemesterOrder(string value)
        {
            int number;
            var digits = new string((value ?? "").Where(char.IsDigit).ToArray());
            return int.TryParse(digits, out number) ? number : Int32.MaxValue;
        }

        private static bool HasValue(string value) { return !String.IsNullOrWhiteSpace(value); }

        private static string NumberOrDash(object value, string format, string suffix)
        {
            if (value == null || value == DBNull.Value) return "-";
            return Convert.ToDecimal(value).ToString(format, CultureInfo.InvariantCulture) + suffix;
        }

        private static decimal? NullableAverage(IEnumerable<decimal?> values)
        {
            var available = values.Where(v => v.HasValue).Select(v => v.Value).ToList();
            return available.Count == 0 ? (decimal?)null : Math.Round(available.Average(), 1);
        }

        private static decimal Rate(int count, int total)
        {
            return total == 0 ? 0m : Math.Round((decimal)count * 100m / total, 1);
        }
    }
}
