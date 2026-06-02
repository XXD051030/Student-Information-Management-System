using System;
using System.Web.UI;

namespace src.controls
{
    public partial class lecturer_topbar : UserControl
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected string DisplayName
        {
            get { return Session["username"] as string ?? "Lecturer"; }
        }

        protected string RoleLabel
        {
            get { return "Lecturer"; }
        }
    }
}
