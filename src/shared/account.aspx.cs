using System;
using System.Globalization;
using System.Web;
using System.Web.UI;
using src.services;

namespace src.shared
{
    public partial class account : System.Web.UI.Page
    {
        private Student _student;

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
            Response.Cache.SetNoStore();

            if (Session["user_id"] == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            _student = StudentService.GetByUserId((int)Session["user_id"]);
            if (_student == null)
            {
                // Session belongs to a non-student (e.g. admin/lecturer) — no profile to show.
                Response.Redirect("~/shared/login.aspx");
                return;
            }
        }

        protected string FullName
        {
            get { return _student != null ? _student.FullName : ""; }
        }

        // First letters of the first two words of the name, e.g. "Ong Zhi Bo" -> "OZ".
        protected string Initials
        {
            get
            {
                if (_student == null || string.IsNullOrEmpty(_student.FullName)) return "";
                var parts = _student.FullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                string initials = parts[0].Substring(0, 1);
                if (parts.Length > 1) initials += parts[1].Substring(0, 1);
                return initials.ToUpperInvariant();
            }
        }

        protected string ProgrammeName
        {
            get { return _student != null ? _student.ProgrammeName : ""; }
        }

        protected string StudentIdLabel
        {
            get { return _student != null ? _student.Username : ""; }
        }

        protected string Email
        {
            get { return _student != null ? _student.Email : ""; }
        }

        protected string StatusBadge
        {
            get
            {
                return _student != null && !string.IsNullOrEmpty(_student.Status)
                    ? _student.Status.ToUpperInvariant()
                    : "";
            }
        }

        // Intake month/year from the intake semester start date, e.g. "Aug 2025".
        protected string IntakeLabel
        {
            get
            {
                return _student != null && _student.IntakeDate.HasValue
                    ? _student.IntakeDate.Value.ToString("MMM yyyy", CultureInfo.InvariantCulture)
                    : "—";
            }
        }

        // "Year X · Trimester Y" from the 1-based current semester number.
        // 3 trimesters per academic year: year = ceil(n/3), trimester = ((n-1) mod 3) + 1.
        // "&middot;" is written raw because <%= %> does not HTML-encode.
        protected string StandingLabel
        {
            get
            {
                if (_student == null) return "";
                int n = _student.CurrentSemesterNo;
                int year = (n + 2) / 3;
                int semester = ((n - 1) % 3) + 1;
                return "Year " + year + " &middot; Trimester " + semester;
            }
        }

        protected string Phone
        {
            get { return _student != null ? _student.Phone : ""; }
        }

        protected string MailingAddress
        {
            get { return _student != null ? _student.MailingAddress : ""; }
        }

        // App-resolved URL of the profile image, or "" when none is set.
        protected string IconUrl
        {
            get
            {
                if (_student == null || string.IsNullOrEmpty(_student.IconPath)) return "";
                return ResolveUrl("~/" + _student.IconPath.TrimStart('/'));
            }
        }
    }
}
