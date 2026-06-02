using System;

namespace src.security
{
    public abstract class StudentPage : SecurePage
    {
        protected override void EnforceRole()
        {
            if (!string.Equals(CurrentRole, RoleRoutes.Student, StringComparison.OrdinalIgnoreCase))
                Response.Redirect(RoleRoutes.HomePageFor(CurrentRole));
        }
    }
}
