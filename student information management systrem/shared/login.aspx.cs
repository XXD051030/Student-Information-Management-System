using System;
using System.Web.UI;

namespace student_information_management_system
{
    public partial class login : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        // Fake sign-in: passwords are not validated (the whole app is a static
        // mock). The role is inferred from the email domain — INTI students use
        // an "@student.*" address, staff/lecturers use the plain staff domain —
        // stored in Session, then the user is sent to the matching dashboard.
        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            string email = (hfEmail.Value ?? string.Empty).Trim().ToLowerInvariant();
            bool isLecturer = email.Length > 0 && !email.Contains("@student.");

            Session["role"] = isLecturer ? "lecturer" : "student";

            Response.Redirect(isLecturer
                ? "~/lecturer/dashboard.aspx"
                : "~/shared/dashboard.aspx");
        }
    }
}
