using System;
using System.Web;
using System.Web.UI.WebControls;
using src.services;
using src.services.email;

namespace src.login
{
    public partial class forgot_password : System.Web.UI.Page
    {
        protected HiddenField ShowSent;
        protected HiddenField ServerError;

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
            Response.Cache.SetNoStore();

            if (!IsPostBack)
            {
                ShowSent.Value = "";
                ServerError.Value = "";
            }
        }

        protected void SendSubmit_Click(object sender, EventArgs e)
        {
            ServerError.Value = "";

            string email = (Request.Form["email"] ?? "").Trim();
            if (email.Length == 0)
            {
                ServerError.Value = "Please enter your email.";
                return;
            }

            // Issue a token for the matching account. When no account matches we
            // still show the same confirmation, so this page never reveals which
            // emails are registered.
            var issued = PasswordResetService.CreateToken(email);
            if (issued.Found)
            {
                string resetUrl = new Uri(Request.Url,
                    ResolveUrl("~/login/reset_password.aspx?token=" + issued.RawToken)).ToString();

                EmailResult sent = EmailService.SendPasswordReset(email, issued.Username, resetUrl);
                if (!sent.Success)
                {
                    ServerError.Value = "We couldn't send the email right now. Please try again later.";
                    return;
                }
            }

            ShowSent.Value = "true";
        }
    }
}
