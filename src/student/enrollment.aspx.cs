using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class enrollment : src.security.StudentPage
    {
        private StudentRegistrationTerm _regSemester;
        private StudentRegistrationWindow _window;
        private List<StudentOfferingOption> _offerings;
        private int _semesterNo;
        private int _semesterCount;
        private int _alreadyRegisteredCount;

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
            Response.Cache.SetNoStore();

            if (Session["user_id"] == null)
            {
                Response.Redirect("~/login/login.aspx");
                return;
            }

            var user = UserContextFactory.FromSession(Session);
            var page = StudentPortalService.GetEnrollmentPage(user);
            if (page == null)
            {
                Response.Redirect("~/login/login.aspx");
                return;
            }

            _regSemester = page.Term;
            _window = page.Window;
            _offerings = page.Offerings ?? new List<StudentOfferingOption>();
            _semesterNo = page.SemesterNo;
            _semesterCount = page.SemesterCount;
            _alreadyRegisteredCount = page.AlreadyRegisteredCount;

            // Once enrollment is closed (Phase 3) there is nothing left to register,
            // drop or add — only show the courses the student actually ended up
            // enrolled in, instead of dumping the whole catalogue with no actions.
            if (ActivePhase == 3)
                _offerings = _offerings.Where(o => o.MyStatus == "ENROLLED").ToList();

            offeringsRepeater.DataSource = _offerings;
            offeringsRepeater.DataBind();
        }

        // --- Header -----------------------------------------------------------

        /// <summary>"Academic Year 2026 / 2027" from the registration term start year.</summary>
        protected string AcademicYearLabel
        {
            get
            {
                if (_regSemester == null) return "";
                int y = _regSemester.StartDate.Year;
                return "Academic Year " + y + " / " + (y + 1);
            }
        }

        /// <summary>Registration term name + month, e.g. "2026-S3 (Aug 2026)".</summary>
        protected string TermLabel
        {
            get
            {
                if (_regSemester == null) return "the upcoming semester";
                return _regSemester.IntakeName + " · " + _regSemester.Name;
            }
        }

        // --- Registration window ---------------------------------------------

        protected bool RegistrationOpen { get { return _window != null && _window.IsOpen; } }

        protected int ActivePhase { get { return _window != null ? _window.ActivePhase : 1; } }

        protected bool IsAddDropPhase { get { return ActivePhase == 2; } }

        /// <summary>"1 May - 15 Jun 2026" full portal-open date range (registration start through add/drop end), or "" if unset.</summary>
        protected string RegistrationDateRange
        {
            get
            {
                if (_window == null || !_window.RegistrationStart.HasValue || !_window.AddDropEnd.HasValue)
                    return "";
                return _window.RegistrationStart.Value.ToString("d MMM") + " - "
                     + _window.AddDropEnd.Value.ToString("d MMM yyyy");
            }
        }

        /// <summary>"1 - 14 Sep 2026" add/drop date range, or "" if unset.</summary>
        protected string AddDropDateRange
        {
            get
            {
                if (_window == null || !_window.AddDropStart.HasValue || !_window.AddDropEnd.HasValue)
                    return "";
                return _window.AddDropStart.Value.ToString("d MMM") + " - "
                     + _window.AddDropEnd.Value.ToString("d MMM yyyy");
            }
        }

        // --- Stats ------------------------------------------------------------

        /// <summary>Courses the student is already registered for in the registration term.</summary>
        protected int AlreadyRegisteredCount
        {
            get { return _alreadyRegisteredCount; }
        }

        /// <summary>Minimum credits the student must register for this term.</summary>
        protected int MinCredits
        {
            get { return _regSemester != null ? _regSemester.MinCredits : 12; }
        }

        /// <summary>Maximum credits the student may register for this term.</summary>
        protected int MaxCredits
        {
            get { return _regSemester != null ? _regSemester.MaxCredits : 21; }
        }

        /// <summary>Flat fee-per-credit rate, echoed into JS for live fee totals.</summary>
        protected decimal FeePerCredit
        {
            get
            {
                if (_offerings != null && _offerings.Count > 0) return _offerings[0].FeePerCredit;
                return 150m;
            }
        }

        // --- Row helpers ------------------------------------------------------

        /// <summary>Course accent color from the DB, validated to a 6-digit hex; slate fallback.</summary>
        protected string AccentColor(string color)
        {
            if (string.IsNullOrEmpty(color)) return "#64748b";
            return System.Text.RegularExpressions.Regex.IsMatch(color, @"^#[0-9A-Fa-f]{6}$")
                ? color : "#64748b";
        }

        protected bool RowRegistered(object myStatus)
        {
            if (IsAddDropPhase) return false;
            var s = myStatus as string;
            return s == "ENROLLED" || s == "PENDING";
        }

        protected bool RowFull(object myStatus, object enrolled, object capacity)
        {
            var s = myStatus as string;
            if (s == "ENROLLED" || s == "PENDING") return false;
            int en = Convert.ToInt32(enrolled);
            int cap = Convert.ToInt32(capacity);
            return cap > 0 && en >= cap;
        }

        protected bool RowOpen(object myStatus, object enrolled, object capacity, object prerequisiteMet)
        {
            return ActivePhase == 1
                && RegistrationOpen
                && string.IsNullOrEmpty(myStatus as string)
                && !RowFull(myStatus, enrolled, capacity)
                && Convert.ToBoolean(prerequisiteMet);
        }

        protected bool RowDroppable(object myStatus)
        {
            return IsAddDropPhase && (myStatus as string) == "ENROLLED";
        }

        /// <summary>
        /// Request Add is offered whenever the student holds no active claim on the
        /// course: never requested, or a past request was rejected or dropped — all
        /// of these are free to re-request during the same Add/Drop window.
        /// </summary>
        protected bool RowAddable(object myStatus, object enrolled, object capacity, object prerequisiteMet)
        {
            var s = myStatus as string;
            bool eligible = string.IsNullOrEmpty(s) || s == "REJECTED" || s == "DROPPED";
            return IsAddDropPhase && eligible && !RowFull(myStatus, enrolled, capacity) && Convert.ToBoolean(prerequisiteMet);
        }

        /// <summary>
        /// True when the row would otherwise show the enroll checkbox / Request Add button,
        /// but the student hasn't passed the course's prerequisite yet.
        /// </summary>
        protected bool RowLockedByPrerequisite(object myStatus, object enrolled, object capacity, object prerequisiteMet)
        {
            if (Convert.ToBoolean(prerequisiteMet)) return false;
            if (RowFull(myStatus, enrolled, capacity)) return false;

            var s = myStatus as string;
            if (ActivePhase == 1 && RegistrationOpen && string.IsNullOrEmpty(s)) return true;
            if (IsAddDropPhase && (string.IsNullOrEmpty(s) || s == "REJECTED" || s == "DROPPED")) return true;
            return false;
        }

        protected bool RowPending(object myStatus)
        {
            return (myStatus as string) == "PENDING";
        }

        /// <summary>Rejected add requests show this badge alongside a fresh Request Add button.</summary>
        protected bool RowRejected(object myStatus)
        {
            return (myStatus as string) == "REJECTED";
        }

        /// <summary>Green seat dot when seats remain, red when full.</summary>
        protected string SeatDotColor(object enrolled, object capacity)
        {
            int en = Convert.ToInt32(enrolled);
            int cap = Convert.ToInt32(capacity);
            return (cap > 0 && en >= cap) ? "#fecaca" : "#bbf7d0";
        }

        protected decimal RowFee(object credits)
        {
            return Convert.ToInt32(credits) * FeePerCredit;
        }

        // --- Persistence ------------------------------------------------------

        [WebMethod(EnableSession = true)]
        public static object Enrol(int[] offeringIds)
        {
            var ctx = HttpContext.Current;
            if (ctx.Session["user_id"] == null)
            {
                ctx.Response.StatusCode = 401;
                ctx.Response.SuppressContent = true;
                return null;
            }

            var user = UserContextFactory.FromSession(ctx.Session);
            int inserted = StudentPortalService.Enrol(user, offeringIds ?? new int[0]);
            return new { ok = true, inserted = inserted };
        }

        [WebMethod(EnableSession = true)]
        public static object RequestAdd(int offeringId)
        {
            var ctx = HttpContext.Current;
            if (ctx.Session["user_id"] == null)
            {
                ctx.Response.StatusCode = 401;
                ctx.Response.SuppressContent = true;
                return null;
            }
            try
            {
                var user = UserContextFactory.FromSession(ctx.Session);
                int id = StudentPortalService.RequestAdd(user, offeringId);
                return new { ok = id > 0 };
            }
            catch
            {
                return new { ok = false };
            }
        }

        [WebMethod(EnableSession = true)]
        public static object RequestDrop(int offeringId)
        {
            var ctx = HttpContext.Current;
            if (ctx.Session["user_id"] == null)
            {
                ctx.Response.StatusCode = 401;
                ctx.Response.SuppressContent = true;
                return null;
            }
            try
            {
                var user = UserContextFactory.FromSession(ctx.Session);
                bool ok = StudentPortalService.RequestDrop(user, offeringId);
                return new { ok = ok };
            }
            catch
            {
                return new { ok = false };
            }
        }
    }
}
