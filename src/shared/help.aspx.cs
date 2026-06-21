using System;
using src.security;

namespace src.shared
{
    /// <summary>
    /// A single Help &amp; Support page shared by every role. The surrounding
    /// chrome (sidebar/topbar) is chosen by swapping the master page in
    /// Page_PreInit — mirroring shared/material_preview.aspx — while the body
    /// content (intro + FAQ) branches on role via the IsStudent/IsLecturer/IsAdmin
    /// flags. Login and the "any signed-in user" gate are handled by SecurePage.
    /// </summary>
    public partial class help : SecurePage
    {
        protected bool IsStudent;
        protected bool IsLecturer;
        protected bool IsAdmin;

        protected void Page_PreInit(object sender, EventArgs e)
        {
            string role = CurrentRole ?? "";
            IsAdmin = string.Equals(role, RoleRoutes.Admin, StringComparison.OrdinalIgnoreCase);
            IsLecturer = string.Equals(role, RoleRoutes.Lecturer, StringComparison.OrdinalIgnoreCase);
            IsStudent = !IsAdmin && !IsLecturer;

            if (IsAdmin)
                MasterPageFile = "~/admin/AdminLayout.master";
            else if (IsLecturer)
                MasterPageFile = "~/lecturer/LecturerLayout.master";
            else
                MasterPageFile = "~/student/StudentLayout.master";
        }

        protected string Subtitle
        {
            get
            {
                if (IsAdmin) return "Guides and contacts for managing the INTI Portal.";
                if (IsLecturer) return "Guides and contacts for teaching on the INTI Portal.";
                return "Find answers to common questions and get in touch with our team.";
            }
        }

        protected string Intro
        {
            get
            {
                if (IsAdmin)
                    return "Welcome to the admin portal. Below are quick answers about managing programmes, courses, requests and reports — plus how to reach us when you need a hand.";
                if (IsLecturer)
                    return "Welcome to your lecturer portal. Below are quick answers about attendance, grades, materials and student performance — plus how to reach us when you need a hand.";
                return "Welcome to your student portal. Below are quick answers about enrolment, your timetable, grades and fees — plus how to reach us when you need a hand.";
            }
        }
    }
}
