using System;
using System.Web.UI;

namespace student_information_management_system
{
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect("~/shared/login.aspx");
        }
    }
}
