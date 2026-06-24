using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class payment : src.security.StudentPage
    {
        private const string PaymentTokenKey = "payment:pending-token";

        protected void Page_Load(object sender, EventArgs e)
        {
            var user = UserContextFactory.FromSession(Session);
            var account = StudentPortalService.GetAccount(user);
            var termLabel = account != null && !string.IsNullOrWhiteSpace(account.CurrentSession)
                ? account.CurrentSession
                : "";

            litTermHeader.Text = Server.HtmlEncode(termLabel);
            litTermSummary.Text = Server.HtmlEncode(termLabel);
            litStudentName.Text = Server.HtmlEncode(account != null ? account.FullName : "");
            litStudentIdProgramme.Text = Server.HtmlEncode(account != null ? account.StudentId + " · " + account.ProgrammeName : "");
            litStudentEmail.Text = Server.HtmlEncode(account != null ? account.Email : "");

            if (!IsPostBack)
            {
                // One-time token guards against duplicate Pay submissions (e.g. double-click, resubmit).
                var token = Guid.NewGuid().ToString("N");
                Session[PaymentTokenKey] = token;
                hfPaymentToken.Value = token;
            }
        }

        protected void PayBtn_Click(object sender, EventArgs e)
        {
            var expectedToken = Session[PaymentTokenKey] as string;
            if (string.IsNullOrEmpty(expectedToken) || expectedToken != hfPaymentToken.Value)
                return; // already processed or token missing — ignore the duplicate submission

            decimal amount;
            if (!decimal.TryParse(hfAmount.Value, NumberStyles.Any, CultureInfo.InvariantCulture, out amount) || amount <= 0m)
                return;

            Session[PaymentTokenKey] = null; // consume the token so a resubmit is rejected

            var user = UserContextFactory.FromSession(Session);

            // Enrol the student in the carried courses first; the insert is a no-op for
            // offerings the student is already enrolled in (e.g. a stale invoice reloaded
            // after navigating back from payment-history). If nothing new was enrolled,
            // this invoice has already been paid for — don't charge it again.
            var ids = ParseOfferingIds(hfOfferingIds.Value);
            var newlyEnrolled = ids.Length > 0 ? StudentPortalService.Enrol(user, ids) : 0;
            if (ids.Length > 0 && newlyEnrolled == 0)
            {
                Response.Redirect("payment-history.aspx");
                return;
            }

            var account = StudentPortalService.GetAccount(user);
            var termLabel = account != null && !string.IsNullOrWhiteSpace(account.CurrentSession)
                ? account.CurrentSession
                : "";

            // No real gateway — "Pay" always succeeds: record the payment.
            StudentPortalService.RecordPayment(
                user,
                amount,
                string.IsNullOrEmpty(hfDescription.Value) ? "Tuition payment" : hfDescription.Value,
                termLabel,
                string.IsNullOrEmpty(hfMethod.Value) ? "card" : hfMethod.Value);

            Response.Redirect("payment-history.aspx");
        }

        private static int[] ParseOfferingIds(string csv)
        {
            if (string.IsNullOrWhiteSpace(csv)) return new int[0];
            var ids = new List<int>();
            foreach (var part in csv.Split(','))
            {
                int id;
                if (int.TryParse(part.Trim(), out id)) ids.Add(id);
            }
            return ids.Distinct().ToArray();
        }
    }
}
