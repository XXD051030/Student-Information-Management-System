using System;

namespace src.security
{
    public abstract class LecturerPage : SecurePage
    {
        protected override void EnforceRole()
        {
            if (!string.Equals(CurrentRole, RoleRoutes.Lecturer, StringComparison.OrdinalIgnoreCase))
                Response.Redirect(RoleRoutes.HomePageFor(CurrentRole));
        }
    }
}
