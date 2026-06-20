using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
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

            rows = LecturerPortalService.GetAcademicPerformance(user);
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

            CourseOptionsHtml = BuildOptions(rows.Select(r => new KeyValuePair<string, string>(r.CourseCode, r.CourseCode + " - " + r.CourseName)), "All courses");
            ProgrammeOptionsHtml = BuildOptions(rows.Select(r => new KeyValuePair<string, string>(r.ProgrammeCode, r.ProgrammeCode)), "All programmes");
        }

        protected int StudentCount { get { return rows.Select(r => r.StudentId).Distinct().Count(); } }
        protected int AtRiskCount { get { return rows.Count(r => r.IsAtRisk); } }
        protected int TopPerformerCount { get { return rows.Count(r => r.AverageMarks.HasValue && r.AverageMarks.Value >= 80m); } }
        protected decimal AverageGpa { get { return rows.Count == 0 ? 0m : rows.Average(r => r.GradePoint); } }
        protected decimal AverageMarks { get { return NullableAverage(rows.Select(r => r.AverageMarks)) ?? 0m; } }
        protected decimal PassRate { get { return Rate(rows.Count(r => r.Status == "Pass"), rows.Count(r => r.Status != "Pending")); } }
        protected decimal FailRate { get { return Rate(rows.Count(r => r.Status == "Fail"), rows.Count(r => r.Status != "Pending")); } }
        protected string CourseOptionsHtml { get; private set; }
        protected string ProgrammeOptionsHtml { get; private set; }

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

        private static string BuildOptions(IEnumerable<KeyValuePair<string, string>> options, string placeholder)
        {
            var html = new StringBuilder();
            html.Append("<option value=\"\">").Append(HttpUtility.HtmlEncode(placeholder)).Append("</option>");
            foreach (var option in options.Where(o => !string.IsNullOrWhiteSpace(o.Key)).GroupBy(o => o.Key).Select(g => g.First()).OrderBy(o => o.Value))
            {
                html.Append("<option value=\"").Append(HttpUtility.HtmlAttributeEncode(option.Key)).Append("\">")
                    .Append(HttpUtility.HtmlEncode(option.Value)).Append("</option>");
            }
            return html.ToString();
        }
    }
}
