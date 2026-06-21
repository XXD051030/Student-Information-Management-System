using System;
using System.Web;
using System.Web.UI.WebControls;
using src.services;

namespace src.login
{
    public partial class reset_password : System.Web.UI.Page
    {
        protected HiddenField TokenField;
        protected HiddenField ShowInvalid;
        protected HiddenField ShowSuccess;
        protected HiddenField ServerError;

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
            Response.Cache.SetNoStore();

            if (IsPostBack) return;

            ShowInvalid.Value = "";
            ShowSuccess.Value = "";
            ServerError.Value = "";

            // Validate the link the moment the page opens, before showing the form.
            string token = (Request.QueryString["token"] ?? "").Trim();
            if (PasswordResetService.IsTokenValid(token))
                TokenField.Value = token;
            else
                ShowInvalid.Value = "true";
        }

        protected void ResetSubmit_Click(object sender, EventArgs e)
        {
            ServerError.Value = "";

            string token = (TokenField.Value ?? "").Trim();
            string password = Request.Form["password"] ?? "";
            string confirm = Request.Form["confirm"] ?? "";

            var result = PasswordResetService.ResetWithToken(token, password, confirm);
            if (result.Ok)
                ShowSuccess.Value = "true";
            else
                ServerError.Value = result.Message;
        }
    }
}
