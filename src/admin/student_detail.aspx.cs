using System;
using System.Globalization;
using System.Text;
using System.Web;
using src.services.admin;

namespace src.admin
{
    public partial class student_detail : src.security.AdminPage
    {
        private readonly AdminPortalService service = new AdminPortalService();

        protected AdminStudentDetailSummary Student { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            Student = service.GetStudentDetail(Request.QueryString["id"]);
        }

        protected string Html(string value) { return HttpUtility.HtmlEncode(value ?? ""); }
        protected string Initials()
        {
            if (Student == null || string.IsNullOrWhiteSpace(Student.Name)) return "ST";
            var parts = Student.Name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpperInvariant();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpperInvariant();
        }
        protected string DecimalNumber(decimal value) { return value.ToString("0.00"); }
        protected string Percent(decimal value) { return value.ToString("0.0") + "%"; }

        // Builds the CGPA trend chart (SVG + legend) from the student's per-semester GPA in
        // the database. The y-axis zooms into the actual data band so the line reads as a
        // real trend instead of a flat line pinned to the top of a 0–4 scale.
        protected string CgpaTrendChart()
        {
            var trend = Student == null ? null : Student.CgpaTrend;
            if (trend == null || trend.Count == 0)
            {
                return "<div class=\"flex flex-col items-center justify-center py-12 text-center\">" +
                       "<i data-lucide=\"line-chart\" class=\"h-8 w-8 text-slate-300\"></i>" +
                       "<p class=\"mt-2 text-slate-500\" style=\"font-size:13px\">No graded semesters yet to chart.</p></div>";
            }

            var ci = CultureInfo.InvariantCulture;
            int n = trend.Count;

            double padLeft = 44, padRight = 24, padTop = 18, padBottom = 36;
            double w = 720, h = 240;
            double plotLeft = padLeft, plotRight = w - padRight;
            double plotTop = padTop, plotBottom = h - padBottom;
            double plotW = plotRight - plotLeft, plotH = plotBottom - plotTop;

            double dataMin = 4.0;
            foreach (var p in trend)
            {
                dataMin = Math.Min(dataMin, (double)p.SemesterGpa);
                dataMin = Math.Min(dataMin, (double)p.CumulativeGpa);
            }
            double yMax = 4.0, yMin, step;
            if (dataMin >= 3.0) { yMin = 3.0; step = 0.25; }
            else if (dataMin >= 2.0) { yMin = 2.0; step = 0.5; }
            else { yMin = 0.0; step = 1.0; }

            Func<double, double> xAt = i => n == 1 ? plotLeft + plotW / 2 : plotLeft + (plotW * i) / (n - 1);
            Func<double, double> yAt = v =>
            {
                var clamped = Math.Max(yMin, Math.Min(yMax, v));
                return plotBottom - ((clamped - yMin) / (yMax - yMin)) * plotH;
            };
            Func<double, string> F = x => x.ToString("0.#", ci);

            var sb = new StringBuilder();
            sb.Append("<svg viewBox=\"0 0 720 240\" class=\"w-full\" style=\"min-width:")
              .Append((int)Math.Max(560, n * 110)).Append("px\">");

            for (double v = yMin; v <= yMax + 0.0001; v += step)
            {
                double y = yAt(v);
                sb.Append("<line x1=\"").Append(F(plotLeft)).Append("\" x2=\"").Append(F(plotRight))
                  .Append("\" y1=\"").Append(F(y)).Append("\" y2=\"").Append(F(y))
                  .Append("\" stroke=\"#f1f5f9\" stroke-width=\"1\" />");
                sb.Append("<text x=\"").Append(F(plotLeft - 8)).Append("\" y=\"").Append(F(y + 3.5))
                  .Append("\" text-anchor=\"end\" font-size=\"10\" fill=\"#94a3b8\">").Append(v.ToString("0.00", ci)).Append("</text>");
            }

            for (int i = 0; i < n; i++)
            {
                sb.Append("<text x=\"").Append(F(xAt(i))).Append("\" y=\"").Append(F(plotBottom + 18))
                  .Append("\" text-anchor=\"middle\" font-size=\"11\" fill=\"#64748b\" font-weight=\"600\">")
                  .Append(Html(trend[i].SemesterLabel)).Append("</text>");
            }

            var cgpaPath = new StringBuilder();
            var semPath = new StringBuilder();
            for (int i = 0; i < n; i++)
            {
                cgpaPath.Append(i == 0 ? "M " : "L ").Append(F(xAt(i))).Append(' ').Append(F(yAt((double)trend[i].CumulativeGpa))).Append(' ');
                semPath.Append(i == 0 ? "M " : "L ").Append(F(xAt(i))).Append(' ').Append(F(yAt((double)trend[i].SemesterGpa))).Append(' ');
            }
            sb.Append("<path d=\"").Append(semPath.ToString().Trim()).Append("\" fill=\"none\" stroke=\"#94a3b8\" stroke-width=\"2\" stroke-dasharray=\"4 4\" />");
            sb.Append("<path d=\"").Append(cgpaPath.ToString().Trim()).Append("\" fill=\"none\" stroke=\"#e0162b\" stroke-width=\"2.5\" />");

            for (int i = 0; i < n; i++)
            {
                double xs = xAt(i);
                double ys = yAt((double)trend[i].SemesterGpa);
                double yc = yAt((double)trend[i].CumulativeGpa);
                sb.Append("<circle cx=\"").Append(F(xs)).Append("\" cy=\"").Append(F(ys)).Append("\" r=\"3.5\" fill=\"#fff\" stroke=\"#94a3b8\" stroke-width=\"2\" />");
                sb.Append("<circle cx=\"").Append(F(xs)).Append("\" cy=\"").Append(F(yc)).Append("\" r=\"4.5\" fill=\"#fff\" stroke=\"#e0162b\" stroke-width=\"2.5\" />");
                sb.Append("<text x=\"").Append(F(xs)).Append("\" y=\"").Append(F(yc - 10))
                  .Append("\" text-anchor=\"middle\" font-size=\"10.5\" fill=\"#a01020\" font-weight=\"700\">")
                  .Append(trend[i].CumulativeGpa.ToString("0.00", ci)).Append("</text>");
            }

            sb.Append("</svg>");

            sb.Append("<div class=\"mt-2 flex items-center gap-4 px-2 text-slate-500\" style=\"font-size:12px\">")
              .Append("<span class=\"inline-flex items-center gap-1.5\"><span class=\"h-0.5 w-5 bg-[#e0162b]\"></span> CGPA</span>")
              .Append("<span class=\"inline-flex items-center gap-1.5\"><span class=\"h-0.5 w-5 border-t-2 border-dashed border-slate-300\"></span> Semester GPA</span>")
              .Append("</div>");

            return sb.ToString();
        }

        // Builds the "Attendance by Semester" accordion from the student's per-course
        // attendance in the database, grouped by the semesters they were enrolled in.
        protected string AttendanceBySemesterHtml()
        {
            var semesters = Student == null ? null : Student.AttendanceBySemester;
            if (semesters == null || semesters.Count == 0)
            {
                return "<li><div class=\"flex flex-col items-center justify-center px-6 py-12 text-center\">" +
                       "<i data-lucide=\"calendar-x\" class=\"h-8 w-8 text-slate-300\"></i>" +
                       "<p class=\"mt-2 text-slate-500\" style=\"font-size:13px\">No attendance has been recorded for this student yet.</p></div></li>";
            }

            var html = new StringBuilder();
            foreach (var sem in semesters)
            {
                var status = AttendanceStatus(sem.Rate);
                var subtitle = string.IsNullOrWhiteSpace(sem.AcademicYear)
                    ? sem.Courses.Count + (sem.Courses.Count == 1 ? " course" : " courses")
                    : Html(sem.AcademicYear) + " &middot; " + sem.Courses.Count + (sem.Courses.Count == 1 ? " course" : " courses");

                html.Append("<li data-accordion>");
                html.Append("<button type=\"button\" data-accordion-toggle class=\"flex w-full items-center justify-between gap-3 px-6 py-3 text-left hover:bg-slate-50/60\">");
                html.Append("<div class=\"flex items-center gap-3\">");
                html.Append("<span data-accordion-icon class=\"inline-flex transition-transform\"><i data-lucide=\"chevron-down\" class=\"h-4 w-4 text-slate-500\"></i></span>");
                html.Append("<div><div class=\"text-slate-900\" style=\"font-size:13.5px;font-weight:700\">").Append(Html(sem.SemesterLabel)).Append("</div>");
                html.Append("<div class=\"text-slate-500\" style=\"font-size:12px\">").Append(subtitle).Append("</div></div>");
                html.Append("</div>");
                html.Append("<div class=\"flex items-center gap-3\">");
                html.Append("<div class=\"h-1.5 w-28 overflow-hidden rounded-full bg-slate-100\"><div class=\"h-full rounded-full ").Append(Bar(sem.Rate)).Append("\" style=\"width:").Append(Clamp(sem.Rate)).Append("%\"></div></div>");
                html.Append("<span class=\"tabular-nums text-slate-700\" style=\"font-size:13px;font-weight:600\">").Append(sem.Rate.ToString("0.0")).Append("%</span>");
                html.Append("<span class=\"inline-flex items-center gap-1 rounded-full border px-2 py-0.5 ").Append(Badge(status)).Append("\" style=\"font-size:11.5px;font-weight:600\">").Append(status).Append("</span>");
                html.Append("</div></button>");

                html.Append("<div data-accordion-body><div class=\"overflow-x-auto\"><table class=\"min-w-full\">");
                html.Append("<thead class=\"text-slate-500\"><tr>");
                html.Append("<th class=\"px-6 py-3 text-left uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Code</th>");
                html.Append("<th class=\"px-6 py-3 text-left uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Course</th>");
                html.Append("<th class=\"px-6 py-3 text-left uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Attendance</th>");
                html.Append("<th class=\"px-6 py-3 text-right uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Rate</th>");
                html.Append("<th class=\"px-6 py-3 text-left uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Status</th>");
                html.Append("</tr></thead><tbody>");
                foreach (var course in sem.Courses)
                {
                    var courseStatus = AttendanceStatus(course.Rate);
                    html.Append("<tr class=\"border-t border-slate-100\">");
                    html.Append("<td class=\"px-6 py-3 text-slate-500 font-medium\" style=\"font-size:12.5px\">").Append(Html(course.Code)).Append("</td>");
                    html.Append("<td class=\"px-6 py-3\" style=\"font-size:12.5px\"><span class=\"text-slate-900 font-medium\">").Append(Html(course.Name)).Append("</span></td>");
                    html.Append("<td class=\"px-6 py-3\" style=\"font-size:12.5px\"><div class=\"h-1.5 w-32 overflow-hidden rounded-full bg-slate-100\"><div class=\"h-full rounded-full ").Append(Bar(course.Rate)).Append("\" style=\"width:").Append(Clamp(course.Rate)).Append("%\"></div></div></td>");
                    html.Append("<td class=\"px-6 py-3 text-right tabular-nums\" style=\"font-size:12.5px\">").Append(course.Rate.ToString("0.0")).Append("%</td>");
                    html.Append("<td class=\"px-6 py-3\" style=\"font-size:12.5px\"><span class=\"inline-flex items-center gap-1 rounded-full border px-2 py-0.5 ").Append(Badge(courseStatus)).Append("\" style=\"font-size:11.5px;font-weight:600\">").Append(courseStatus).Append("</span></td>");
                    html.Append("</tr>");
                }
                html.Append("</tbody></table></div></div>");
                html.Append("</li>");
            }
            return html.ToString();
        }

        // Builds the "Semester Results" accordion from the student's course grades in the
        // database, grouped by semester with per-semester GPA and cumulative CGPA.
        protected string SemesterResultsHtml()
        {
            var semesters = Student == null ? null : Student.SemesterResults;
            if (semesters == null || semesters.Count == 0)
            {
                return "<li><div class=\"flex flex-col items-center justify-center px-6 py-12 text-center\">" +
                       "<i data-lucide=\"file-text\" class=\"h-8 w-8 text-slate-300\"></i>" +
                       "<p class=\"mt-2 text-slate-500\" style=\"font-size:13px\">No graded semesters yet for this student.</p></div></li>";
            }

            var html = new StringBuilder();
            foreach (var sem in semesters)
            {
                var subtitle = string.IsNullOrWhiteSpace(sem.AcademicYear)
                    ? sem.Courses.Count + (sem.Courses.Count == 1 ? " course" : " courses")
                    : Html(sem.AcademicYear) + " &middot; " + sem.Courses.Count + (sem.Courses.Count == 1 ? " course" : " courses");

                html.Append("<li data-accordion>");
                html.Append("<button type=\"button\" data-accordion-toggle class=\"flex w-full items-center justify-between gap-3 px-6 py-4 text-left hover:bg-slate-50/60\">");
                html.Append("<div class=\"flex items-center gap-3\">");
                html.Append("<span data-accordion-icon class=\"inline-flex transition-transform\"><i data-lucide=\"chevron-down\" class=\"h-4 w-4 text-slate-500\"></i></span>");
                html.Append("<div><div class=\"text-slate-900\" style=\"font-size:14px;font-weight:700\">").Append(Html(sem.SemesterLabel)).Append("</div>");
                html.Append("<div class=\"text-slate-500\" style=\"font-size:12px\">").Append(subtitle).Append("</div></div>");
                html.Append("</div>");
                html.Append("<div class=\"flex items-center gap-6\">");
                html.Append("<div class=\"text-right\"><div class=\"text-slate-400 uppercase\" style=\"font-size:10.5px;font-weight:600;letter-spacing:0.06em\">Sem GPA</div><div class=\"text-emerald-600\" style=\"font-size:16px;font-weight:700\">").Append(sem.SemGpa.ToString("0.00")).Append("</div></div>");
                html.Append("<div class=\"text-right\"><div class=\"text-slate-400 uppercase\" style=\"font-size:10.5px;font-weight:600;letter-spacing:0.06em\">CGPA</div><div class=\"text-emerald-600\" style=\"font-size:16px;font-weight:700\">").Append(sem.Cgpa.ToString("0.00")).Append("</div></div>");
                html.Append("</div></button>");

                html.Append("<div data-accordion-body><div class=\"border-t border-slate-100 bg-slate-50/40\"><div class=\"overflow-x-auto\"><table class=\"min-w-full\">");
                html.Append("<thead class=\"text-slate-500\"><tr>");
                html.Append("<th class=\"px-6 py-3 text-left uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Code</th>");
                html.Append("<th class=\"px-6 py-3 text-left uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Course</th>");
                html.Append("<th class=\"px-6 py-3 text-center uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Credits</th>");
                html.Append("<th class=\"px-6 py-3 text-center uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">Grade</th>");
                html.Append("<th class=\"px-6 py-3 text-right uppercase\" style=\"font-size:11px;font-weight:600;letter-spacing:0.05em\">GPA Points</th>");
                html.Append("</tr></thead><tbody>");
                foreach (var course in sem.Courses)
                {
                    html.Append("<tr class=\"border-t border-slate-100\">");
                    html.Append("<td class=\"px-6 py-3 text-slate-500 font-medium\" style=\"font-size:12.5px\">").Append(Html(course.Code)).Append("</td>");
                    html.Append("<td class=\"px-6 py-3\" style=\"font-size:12.5px\"><span class=\"text-slate-900 font-medium\">").Append(Html(course.Name)).Append("</span></td>");
                    html.Append("<td class=\"px-6 py-3 text-center text-slate-700\" style=\"font-size:12.5px\">").Append(course.Credits).Append("</td>");
                    html.Append("<td class=\"px-6 py-3 text-center\" style=\"font-size:12.5px\"><span class=\"inline-flex items-center gap-1 rounded-full border px-2 py-0.5 ").Append(GradeBadge(course.LetterGrade)).Append("\" style=\"font-size:11.5px;font-weight:600\">").Append(Html(string.IsNullOrWhiteSpace(course.LetterGrade) ? "-" : course.LetterGrade)).Append("</span></td>");
                    html.Append("<td class=\"px-6 py-3 text-right text-slate-700\" style=\"font-size:12.5px\">").Append(course.GradePoint.ToString("0.00")).Append("</td>");
                    html.Append("</tr>");
                }
                html.Append("</tbody></table></div></div></div>");
                html.Append("</li>");
            }
            return html.ToString();
        }

        private static string GradeBadge(string letter)
        {
            var g = (letter ?? "").Trim().ToUpperInvariant();
            if (g == "F") return "bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20";
            if (g == "D" || g == "D+" || g == "C-") return "bg-amber-50 text-amber-700 border-amber-100";
            return "bg-emerald-50 text-emerald-700 border-emerald-100";
        }

        private static string AttendanceStatus(decimal rate)
        {
            if (rate >= 85) return "Healthy";
            if (rate >= 70) return "Warning";
            return "Critical";
        }

        private static string Bar(decimal value)
        {
            if (value >= 85) return "bg-emerald-500";
            if (value >= 60) return "bg-amber-500";
            return "bg-[#e0162b]";
        }

        private static string Badge(string status)
        {
            if (status == "Healthy") return "bg-emerald-50 text-emerald-700 border-emerald-100";
            if (status == "Warning") return "bg-amber-50 text-amber-700 border-amber-100";
            return "bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20";
        }

        private static int Clamp(decimal value)
        {
            if (value < 0) return 0;
            if (value > 100) return 100;
            return (int)Math.Round(value);
        }
    }
}
