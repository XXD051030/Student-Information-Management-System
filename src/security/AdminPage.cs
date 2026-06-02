using System;

namespace src.security
{
    public abstract class AdminPage : SecurePage
    {
        protected override void EnforceRole()
        {
            if (!string.Equals(CurrentRole, RoleRoutes.Admin, StringComparison.OrdinalIgnoreCase))
                Response.Redirect(RoleRoutes.HomePageFor(CurrentRole));
        }
    }
}
