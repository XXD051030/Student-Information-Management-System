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
            InitializeFilters(allRows);
            BindPage(allRows);
        }

        protected void FilterChanged(object sender, EventArgs e)
        {
            var user = UserContextFactory.FromSession(Session);
            var allRows = LecturerPortalService.GetAcademicPerformance(user);

            if (sender == academicYearFilter)
            {
                PopulateSemesterFilter(allRows, null);
                PopulateCourseFilter(allRows, null);
            }
            else if (sender == semesterFilter)
            {
                PopulateCourseFilter(allRows, null);
            }

            BindPage(allRows);
        }

        private void InitializeFilters(List<LecturerAcademicPerformanceRow> allRows)
        {
            academicYearFilter.Items.Clear();
            foreach (var year in allRows.Select(r => r.AcademicYear).Where(HasValue).Concat(new[] { "2026", "2027" }).Distinct().OrderBy(v => v))
            {
                academicYearFilter.Items.Add(new ListItem(AcademicYearLabel(year), year));
            }

            var defaultYear = academicYearFilter.Items.FindByValue("2026");
            if (defaultYear != null) academicYearFilter.SelectedValue = defaultYear.Value;
            else if (academicYearFilter.Items.Count > 0) academicYearFilter.SelectedIndex = 0;

            PopulateSemesterFilter(allRows, "Semester 1");
            PopulateCourseFilter(allRows, null);
        }

        private void PopulateSemesterFilter(List<LecturerAcademicPerformanceRow> allRows, string preferredValue)
        {
            var selectedYear = academicYearFilter.SelectedValue;
            var semesters = allRows
                .Where(r => !HasValue(selectedYear) || r.AcademicYear == selectedYear)
                .Select(r => r.OfferingSemester)
                .Where(HasValue)
                .Concat(new[] { "Semester 1", "Semester 2" })
                .Distinct()
                .OrderBy(SemesterOrder)
                .ToList();

            semesterFilter.Items.Clear();
            foreach (var semester in semesters)
                semesterFilter.Items.Add(new ListItem(SemesterLabel(semester), semester));

            var preferred = semesterFilter.Items.FindByValue(preferredValue ?? "");
            if (preferred != null) semesterFilter.SelectedValue = preferred.Value;
            else if (semesterFilter.Items.Count > 0) semesterFilter.SelectedIndex = 0;
        }

        private void PopulateCourseFilter(List<LecturerAcademicPerformanceRow> allRows, string preferredValue)
        {
            var selectedYear = academicYearFilter.SelectedValue;
            var selectedSemester = semesterFilter.SelectedValue;
            var courses = allRows
                .Where(r => (!HasValue(selectedYear) || r.AcademicYear == selectedYear)
                    && (!HasValue(selectedSemester) || r.OfferingSemester == selectedSemester))
                .Where(r => HasValue(r.CourseCode))
                .GroupBy(r => r.CourseCode)
                .Select(g => g.First())
                .OrderBy(r => r.CourseCode)
                .ToList();

            courseFilter.Items.Clear();
            courseFilter.Items.Add(new ListItem("All courses", ""));
            foreach (var course in courses)
                courseFilter.Items.Add(new ListItem(course.CourseCode + " - " + course.CourseName, course.CourseCode));

            var preferred = courseFilter.Items.FindByValue(preferredValue ?? "");
            courseFilter.SelectedValue = preferred != null ? preferred.Value : "";
        }

        private void BindPage(List<LecturerAcademicPerformanceRow> allRows)
        {
            var selectedYear = academicYearFilter.SelectedValue;
            var selectedSemester = semesterFilter.SelectedValue;
            var selectedCourse = courseFilter.SelectedValue;

            rows = allRows.Where(r =>
                    (!HasValue(selectedYear) || r.AcademicYear == selectedYear)
                    && (!HasValue(selectedSemester) || r.OfferingSemester == selectedSemester)
                    && (!HasValue(selectedCourse) || r.CourseCode == selectedCourse))
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

        private static string AcademicYearLabel(string value)
        {
            int year;
            return int.TryParse(value, out year) ? year + "/" + (year + 1) : value;
        }

        private static string SemesterLabel(string value)
        {
            return (value ?? "").Replace("Semester ", "Sem ");
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
