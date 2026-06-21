using System;
using System.Globalization;
using System.Web;
using System.Web.SessionState;
using src.services;

namespace src.student
{
    public class TranscriptDownloadHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            var user = UserContextFactory.FromSession(context.Session);
            if (user == null || !user.IsStudent)
            {
                context.Response.StatusCode = 401;
                context.Response.ContentType = "text/plain";
                context.Response.Write("Please sign in as a student to download your transcript.");
                return;
            }

            var account = StudentPortalService.GetAccount(user);
            var grades = StudentPortalService.GetGradePage(user);
            if (account == null || grades == null)
            {
                context.Response.StatusCode = 404;
                context.Response.ContentType = "text/plain";
                context.Response.Write("Transcript data is not available.");
                return;
            }

            var pdf = TranscriptPdfService.Create(
                account,
                grades,
                context.Server.MapPath("~/img/inti_logo.png"),
                DateTime.Now);

            var safeId = string.IsNullOrWhiteSpace(account.StudentId) ? "student" : account.StudentId;
            context.Response.Clear();
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            context.Response.ContentType = "application/pdf";
            context.Response.AddHeader(
                "Content-Disposition",
                "attachment; filename=INTI-Transcript-" + safeId + "-" + DateTime.Now.ToString("yyyyMMdd", CultureInfo.InvariantCulture) + ".pdf");
            context.Response.OutputStream.Write(pdf, 0, pdf.Length);
            context.ApplicationInstance.CompleteRequest();
        }
    }
}
