using System;
using System.Web.UI;

namespace student_information_management_system.controls
{
    public partial class Topbar : UserControl
    {
        // True when the current visitor is a lecturer. Resolved from the role
        // stored in Session at login; falls back to the URL (pages under
        // ~/lecturer/ are lecturer pages) so the control still renders
        // correctly when a page is opened directly without signing in.
        protected bool IsLecturer;

        protected void Page_Load(object sender, EventArgs e)
        {
            string role = Session["role"] as string;
            if (!string.IsNullOrEmpty(role))
            {
                IsLecturer = role.Equals("lecturer", StringComparison.OrdinalIgnoreCase);
            }
            else
            {
                string path = Request.AppRelativeCurrentExecutionFilePath ?? string.Empty;
                IsLecturer = path.StartsWith("~/lecturer/", StringComparison.OrdinalIgnoreCase);
            }
        }
    }
}
