using System;
using System.Globalization;
using System.Web;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class payment_history : src.security.StudentPage
    {
        // Student identity used to render the "billed to" section of the invoice PDF.
        protected string StudentName = "";
        protected string StudentNo = "";
        protected string ProgrammeName = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            var user = UserContextFactory.FromSession(Session);

            var account = StudentPortalService.GetAccount(user);
            if (account != null)
            {
                StudentName = account.FullName ?? "";
                StudentNo = account.StudentId ?? "";
                ProgrammeName = account.ProgrammeName ?? "";
            }

            var page = StudentPortalService.GetPaymentHistory(user);

            litTotalPaid.Text = page.TotalPaid.ToString("N0", CultureInfo.InvariantCulture);
            litThisYear.Text = page.PaidThisYear.ToString("N0", CultureInfo.InvariantCulture);
            litRefunded.Text = page.Refunded.ToString("N0", CultureInfo.InvariantCulture);
            litReceipts.Text = page.ReceiptCount.ToString();
            litShown.Text = page.Rows.Count + " of " + page.Rows.Count;

            rptPayments.DataSource = page.Rows;
            rptPayments.DataBind();
        }

        protected string FormatStatus(object status)
        {
            var s = (status ?? "").ToString();
            if (string.IsNullOrEmpty(s)) return "Paid";
            return char.ToUpper(s[0]) + s.Substring(1).ToLowerInvariant();
        }

        // HTML-attribute-encode a bound value for use inside a data-* attribute.
        protected string Attr(object value)
        {
            return HttpUtility.HtmlAttributeEncode((value ?? "").ToString());
        }
    }
}
