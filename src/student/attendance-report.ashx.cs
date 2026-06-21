using System;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using src.services;

namespace src.student
{
    public class AttendanceReportDownloadHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            var user = UserContextFactory.FromSession(context.Session);
            if (user == null || !user.IsStudent)
            {
                WriteError(context, 401, "Please sign in as a student to export attendance.");
                return;
            }

            var account = StudentPortalService.GetAccount(user);
            var attendance = StudentPortalService.GetAttendancePage(user);
            if (account == null || attendance == null)
            {
                WriteError(context, 404, "Attendance data is not available.");
                return;
            }

            int semesterId;
            if (int.TryParse(context.Request.QueryString["semesterId"], out semesterId) && semesterId > 0)
            {
                attendance.Courses = attendance.Courses
                    .Where(course => course.SemesterId == semesterId)
                    .ToList();
            }

            var pdf = AttendancePdfService.Create(account, attendance, DateTime.Now);
            var safeId = string.IsNullOrWhiteSpace(account.StudentId) ? "student" : account.StudentId;

            context.Response.Clear();
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            context.Response.ContentType = "application/pdf";
            context.Response.AddHeader(
                "Content-Disposition",
                "attachment; filename=INTI-Attendance-" + safeId + "-" +
                DateTime.Now.ToString("yyyyMMdd", CultureInfo.InvariantCulture) + ".pdf");
            context.Response.OutputStream.Write(pdf, 0, pdf.Length);
            context.ApplicationInstance.CompleteRequest();
        }

        private static void WriteError(HttpContext context, int statusCode, string message)
        {
            context.Response.StatusCode = statusCode;
            context.Response.ContentType = "text/plain";
            context.Response.Write(message);
        }
    }
}
