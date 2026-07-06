using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using src.services;

namespace student_information_management_system
{
    public partial class lecturer_announcements : src.security.LecturerPage
    {
        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".xls", ".xlsx", ".png", ".jpg", ".jpeg", ".gif", ".webp", ".txt", ".zip"
        };

        private LecturerProfile _lecturer;
        private List<LecturerAnnouncementRow> _announcements = new List<LecturerAnnouncementRow>();
        private LecturerAnnouncementRow _selectedAnnouncement;
        private int? _offeringFilter;
        private string _tabFilter = "all";
        private string _yearFilter = "all";
        private string _semesterFilter = "all";
        private bool _isCourseScoped;

        protected bool IsCourseScoped { get { return _isCourseScoped && _offeringFilter.HasValue; } }
        protected int SelectedOfferingId { get { return _offeringFilter.GetValueOrDefault(); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
                Page.Form.Action = Request.RawUrl;
            }

            var user = UserContextFactory.FromSession(Session);
            _lecturer = LecturerPortalService.GetProfile(user);
            if (_lecturer == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            int offeringId;
            if (int.TryParse(Request.QueryString["offering"], out offeringId) && offeringId > 0)
                _offeringFilter = offeringId;
            _isCourseScoped = string.Equals(Request.QueryString["context"], "course", StringComparison.OrdinalIgnoreCase);

            _yearFilter = string.IsNullOrWhiteSpace(Request.QueryString["year"]) ? "all" : Request.QueryString["year"];
            _semesterFilter = string.IsNullOrWhiteSpace(Request.QueryString["semester"]) ? "all" : Request.QueryString["semester"];
            if (_isCourseScoped)
            {
                _yearFilter = "all";
                _semesterFilter = "all";
            }

            _tabFilter = (ViewState["AnnouncementTab"] as string) ?? "all";

            if (!IsPostBack)
            {
                BindCourses();
                SetComposeVisible(false);
                int selectedId;
                if (int.TryParse(Request.QueryString["id"], out selectedId) && selectedId > 0)
                    ViewState["SelectedAnnouncementId"] = selectedId;
            }

            LoadRows();
        }

        protected void ShowComposeButton_Click(object sender, EventArgs e)
        {
            SetComposeVisible(true);
        }

        protected void CloseComposeButton_Click(object sender, EventArgs e)
        {
            SetComposeVisible(false);
        }

        protected void PostAnnouncement_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(titleInput.Text) || string.IsNullOrWhiteSpace(messageInput.Text))
            {
                ShowError("Add a title and message before posting.");
                SetComposeVisible(true);
                return;
            }

            int offeringId;
            int.TryParse(courseSelect.SelectedValue, out offeringId);

            string fileUrl = SaveAttachment();
            if (statusBanner.Visible && string.IsNullOrEmpty(fileUrl) && attachmentInput.HasFile)
            {
                SetComposeVisible(true);
                return;
            }

            var user = UserContextFactory.FromSession(Session);
            var targetOfferingIds = offeringId > 0
                ? new List<int> { offeringId }
                : LecturerPortalService.GetCourses(user).Select(c => c.OfferingId).Distinct().ToList();

            if (targetOfferingIds.Count == 0)
            {
                ShowError("No assigned courses are available.");
                SetComposeVisible(true);
                return;
            }

            int postedCount = 0;
            foreach (int targetOfferingId in targetOfferingIds)
            {
                int added = LecturerPortalService.AddAnnouncement(user, new LecturerAnnouncementInput
                {
                    OfferId = targetOfferingId,
                    Title = titleInput.Text,
                    Message = messageInput.Text,
                    FileUrl = fileUrl,
                    IsPinned = pinnedInput.Checked
                });
                if (added > 0) postedCount++;
            }

            if (postedCount == 0)
            {
                ShowError("The announcement could not be posted.");
                SetComposeVisible(true);
                return;
            }

            titleInput.Text = "";
            messageInput.Text = "";
            pinnedInput.Checked = false;
            statusMessage.Text = postedCount == 1
                ? "Announcement posted to students."
                : "Announcement posted to all " + postedCount + " assigned courses.";
            statusBanner.CssClass = "mt-4 rounded-md border border-emerald-200 bg-emerald-50 px-4 py-3 text-emerald-800";
            statusBanner.Visible = true;
            SetComposeVisible(false);
            LoadRows();
        }

        protected void AnnouncementsRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SelectAnnouncement") return;

            int announcementId;
            if (int.TryParse(e.CommandArgument.ToString(), out announcementId))
            {
                ViewState["SelectedAnnouncementId"] = announcementId;
                LoadRows();
            }
        }

        protected void CourseFilterSelect_SelectedIndexChanged(object sender, EventArgs e)
        {
            int offeringId;
            if (int.TryParse(courseFilterSelect.SelectedValue, out offeringId) && offeringId > 0)
            {
                Response.Redirect(FilterUrl(offeringId, _yearFilter, _semesterFilter));
                return;
            }

            Response.Redirect(FilterUrl(null, _yearFilter, _semesterFilter));
        }

        protected void YearFilterSelect_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(FilterUrl(null, yearFilterSelect.SelectedValue, _semesterFilter));
        }

        protected void SemesterFilterSelect_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(FilterUrl(null, _yearFilter, semesterFilterSelect.SelectedValue));
        }

        protected void TabButton_Command(object sender, CommandEventArgs e)
        {
            string tab = e.CommandArgument == null ? "all" : e.CommandArgument.ToString();
            if (tab != "pinned" && tab != "files") tab = "all";

            _tabFilter = tab;
            ViewState["AnnouncementTab"] = tab;
            ViewState["SelectedAnnouncementId"] = null;
            LoadRows();
        }

        protected void PinButton_Click(object sender, EventArgs e)
        {
            if (_selectedAnnouncement == null) return;

            bool newState = !_selectedAnnouncement.IsPinned;
            bool updated = LecturerPortalService.SetAnnouncementPinned(
                UserContextFactory.FromSession(Session),
                _selectedAnnouncement.AnnouncementId,
                newState);

            if (!updated)
            {
                ShowError("The announcement pin could not be updated.");
                return;
            }

            statusMessage.Text = newState ? "Announcement pinned." : "Announcement unpinned.";
            statusBanner.CssClass = "mt-4 rounded-md border border-emerald-200 bg-emerald-50 px-4 py-3 text-emerald-800";
            statusBanner.Visible = true;
            Response.Redirect(AnnouncementUrl(_selectedAnnouncement.AnnouncementId), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void DeleteButton_Click(object sender, EventArgs e)
        {
            if (_selectedAnnouncement == null) return;

            var user = UserContextFactory.FromSession(Session);
            LecturerPortalService.DeleteAnnouncement(user, _selectedAnnouncement.AnnouncementId);
            ViewState["SelectedAnnouncementId"] = null;
            statusMessage.Text = "Announcement deleted.";
            statusBanner.CssClass = "mt-4 rounded-md border border-emerald-200 bg-emerald-50 px-4 py-3 text-emerald-800";
            statusBanner.Visible = true;
            LoadRows();
        }

        private void BindCourses()
        {
            var user = UserContextFactory.FromSession(Session);
            var courses = LecturerPortalService.GetCourses(user);
            var sessions = AcademicTermReader.GetSessionOptions();
            var courseOptions = courses.Select(c => new
            {
                c.OfferingId,
                Label = c.CourseCode + " - " + c.CourseName
            }).ToList();

            courseSelect.DataSource = courseOptions;
            courseSelect.DataTextField = "Label";
            courseSelect.DataValueField = "OfferingId";
            courseSelect.DataBind();
            courseSelect.Items.Insert(0, new ListItem("All assigned courses", "0"));
            var filteredCourseOptions = courses
                .Where(c => _yearFilter == "all" || string.Equals(c.AcademicYear, _yearFilter, StringComparison.OrdinalIgnoreCase))
                .Where(c => _semesterFilter == "all" || string.Equals(c.Semester, _semesterFilter, StringComparison.OrdinalIgnoreCase))
                .Select(c => new
                {
                    c.OfferingId,
                    Label = c.CourseCode + " - " + c.CourseName
                }).ToList();
            courseFilterSelect.DataSource = filteredCourseOptions;
            courseFilterSelect.DataTextField = "Label";
            courseFilterSelect.DataValueField = "OfferingId";
            courseFilterSelect.DataBind();
            courseFilterSelect.Items.Insert(0, new ListItem("All courses", "0"));

            yearFilterSelect.Items.Clear();
            yearFilterSelect.Items.Add(new ListItem("All years", "all"));
            foreach (string year in sessions.Select(s => s.AcademicYear)
                .Concat(courses.Select(c => c.AcademicYear))
                .Where(value => !string.IsNullOrWhiteSpace(value)).Distinct()
                .OrderBy(StudentPortalFormat.AcademicYearSortOrder)
                .ThenBy(value => value, StringComparer.OrdinalIgnoreCase))
                yearFilterSelect.Items.Add(new ListItem(StudentPortalFormat.AcademicYearLabel(year), year));

            semesterFilterSelect.Items.Clear();
            semesterFilterSelect.Items.Add(new ListItem("All semesters", "all"));
            foreach (string semester in sessions
                .Where(s => _yearFilter == "all" || s.AcademicYear == _yearFilter)
                .Select(s => s.Semester)
                .Concat(courses.Where(c => _yearFilter == "all" || c.AcademicYear == _yearFilter).Select(c => c.Semester))
                .Where(value => !string.IsNullOrWhiteSpace(value)).Distinct()
                .OrderBy(StudentPortalFormat.SemesterSortOrder)
                .ThenBy(value => value, StringComparer.OrdinalIgnoreCase))
                semesterFilterSelect.Items.Add(new ListItem(StudentPortalFormat.SemesterLabel(semester), semester));

            if (_offeringFilter.HasValue)
            {
                var value = _offeringFilter.Value.ToString(CultureInfo.InvariantCulture);
                if (courseSelect.Items.FindByValue(value) != null)
                    courseSelect.SelectedValue = value;
                if (courseFilterSelect.Items.FindByValue(value) != null)
                    courseFilterSelect.SelectedValue = value;
            }
            if (yearFilterSelect.Items.FindByValue(_yearFilter) != null)
                yearFilterSelect.SelectedValue = _yearFilter;
            if (semesterFilterSelect.Items.FindByValue(_semesterFilter) != null)
                semesterFilterSelect.SelectedValue = _semesterFilter;
        }

        private void LoadRows()
        {
            var user = UserContextFactory.FromSession(Session);
            _announcements = LecturerPortalService.GetAnnouncements(user, _offeringFilter);
            if (_yearFilter != "all")
                _announcements = _announcements.Where(a => string.Equals(a.AcademicYear, _yearFilter, StringComparison.OrdinalIgnoreCase)).ToList();
            if (_semesterFilter != "all")
                _announcements = _announcements.Where(a => string.Equals(a.Semester, _semesterFilter, StringComparison.OrdinalIgnoreCase)).ToList();
            if (_tabFilter == "pinned")
                _announcements = _announcements.Where(a => a.IsPinned).ToList();
            else if (_tabFilter == "files")
                _announcements = _announcements.Where(a => a.HasAttachment).ToList();

            int selectedId = SelectedAnnouncementId();
            if (selectedId == 0 && _announcements.Count > 0)
            {
                selectedId = _announcements[0].AnnouncementId;
                ViewState["SelectedAnnouncementId"] = selectedId;
            }

            _selectedAnnouncement = _announcements.FirstOrDefault(a => a.AnnouncementId == selectedId);
            announcementsRepeater.DataSource = _announcements;
            announcementsRepeater.DataBind();
            emptyPanel.Visible = _announcements.Count == 0;
            detailPanel.Visible = _selectedAnnouncement != null;
            pinButton.CssClass = _selectedAnnouncement != null && _selectedAnnouncement.IsPinned
                ? "inline-flex h-9 w-9 items-center justify-center rounded-md bg-amber-50 text-amber-500 hover:bg-amber-100"
                : "inline-flex h-9 w-9 items-center justify-center rounded-md text-slate-300 hover:bg-slate-100 hover:text-slate-500";
            pinButton.ToolTip = _selectedAnnouncement != null && _selectedAnnouncement.IsPinned
                ? "Unpin announcement"
                : "Pin announcement";
            ApplyTabStyles();
        }

        private int SelectedAnnouncementId()
        {
            object value = ViewState["SelectedAnnouncementId"];
            if (value == null) return 0;
            int id;
            return int.TryParse(value.ToString(), out id) ? id : 0;
        }

        private string AnnouncementUrl(int announcementId)
        {
            string url = ResolveUrl("~/lecturer/lecturer_announcement.aspx?id=" +
                announcementId.ToString(CultureInfo.InvariantCulture));
            if (_offeringFilter.HasValue)
                url += "&offering=" + _offeringFilter.Value.ToString(CultureInfo.InvariantCulture);
            if (_yearFilter != "all")
                url += (url.Contains("?") ? "&" : "?") + "year=" + HttpUtility.UrlEncode(_yearFilter);
            if (_semesterFilter != "all")
                url += (url.Contains("?") ? "&" : "?") + "semester=" + HttpUtility.UrlEncode(_semesterFilter);
            if (_isCourseScoped)
                url += (url.Contains("?") ? "&" : "?") + "context=course";
            return url;
        }

        private string FilterUrl(int? offeringId, string year, string semester)
        {
            var parts = new List<string>();
            if (offeringId.HasValue)
                parts.Add("offering=" + offeringId.Value.ToString(CultureInfo.InvariantCulture));
            if (!string.IsNullOrWhiteSpace(year) && year != "all")
                parts.Add("year=" + HttpUtility.UrlEncode(year));
            if (!string.IsNullOrWhiteSpace(semester) && semester != "all")
                parts.Add("semester=" + HttpUtility.UrlEncode(semester));
            if (_isCourseScoped)
                parts.Add("context=course");
            return ResolveUrl("~/lecturer/lecturer_announcement.aspx") + (parts.Count == 0 ? "" : "?" + string.Join("&", parts));
        }

        private string SaveAttachment()
        {
            if (!attachmentInput.HasFile) return null;

            string extension = Path.GetExtension(attachmentInput.FileName);
            if (!AllowedExtensions.Contains(extension))
            {
                ShowError("Attachment type is not supported.");
                return null;
            }

            const int maxBytes = 10 * 1024 * 1024;
            if (attachmentInput.PostedFile.ContentLength > maxBytes)
            {
                ShowError("Attachment must be 10 MB or smaller.");
                return null;
            }

            string folder = Server.MapPath("~/uploads/announcements");
            Directory.CreateDirectory(folder);
            string safeName = Path.GetFileNameWithoutExtension(attachmentInput.FileName);
            foreach (char invalid in Path.GetInvalidFileNameChars())
                safeName = safeName.Replace(invalid, '-');
            if (string.IsNullOrWhiteSpace(safeName)) safeName = "attachment";

            string fileName = DateTime.Now.ToString("yyyyMMddHHmmss", CultureInfo.InvariantCulture) + "-" + Guid.NewGuid().ToString("N").Substring(0, 8) + "-" + safeName + extension.ToLowerInvariant();
            string physicalPath = Path.Combine(folder, fileName);
            attachmentInput.SaveAs(physicalPath);
            return "~/uploads/announcements/" + fileName;
        }

        private void ShowError(string message)
        {
            statusMessage.Text = message;
            statusBanner.CssClass = "mt-4 rounded-md border border-rose-200 bg-rose-50 px-4 py-3 text-rose-800";
            statusBanner.Visible = true;
        }

        private void SetComposeVisible(bool visible)
        {
            const string hidden = " hidden";
            if (visible)
            {
                composePanel.CssClass = composePanel.CssClass.Replace(hidden, "");
                return;
            }

            if (!composePanel.CssClass.Contains("hidden"))
                composePanel.CssClass += hidden;
        }

        private void ApplyTabStyles()
        {
            SetTabStyle(allTabButton, _tabFilter == "all");
            SetTabStyle(pinnedTabButton, _tabFilter == "pinned");
            SetTabStyle(filesTabButton, _tabFilter == "files");
        }

        private static void SetTabStyle(LinkButton button, bool active)
        {
            button.CssClass = active
                ? "rounded px-2 py-1.5 text-center bg-white text-slate-900 shadow-sm"
                : "rounded px-2 py-1.5 text-center text-slate-500 hover:text-slate-900";
        }

        protected string Html(object value)
        {
            return HttpUtility.HtmlEncode(value == null ? "" : value.ToString());
        }

        protected string SelectedClass(object value)
        {
            int id;
            int.TryParse(value.ToString(), out id);
            string selected = id == SelectedAnnouncementId() ? " bg-rose-50/60" : "";
            return selected;
        }

        protected string RelativeTime(object value)
        {
            var when = (DateTime)value;
            TimeSpan ago = DateTime.Now - when;
            if (ago.TotalMinutes < 1) return "Now";
            if (ago.TotalHours < 1) return ((int)ago.TotalMinutes).ToString(CultureInfo.InvariantCulture) + "m";
            if (ago.TotalHours < 24) return ((int)ago.TotalHours).ToString(CultureInfo.InvariantCulture) + "h";
            if (ago.TotalDays < 2) return "Yesterday";
            return when.ToString("d MMM", CultureInfo.InvariantCulture);
        }

        protected string DetailPinnedLabel
        {
            get { return _selectedAnnouncement != null && _selectedAnnouncement.IsPinned ? "PINNED" : "ANNOUNCEMENT"; }
        }

        protected string DetailTargetCourses
        {
            get { return Html(_selectedAnnouncement == null ? "" : _selectedAnnouncement.TargetCourses); }
        }

        protected string DetailTitle
        {
            get { return Html(_selectedAnnouncement == null ? "Select an announcement" : _selectedAnnouncement.Title); }
        }

        protected string DetailCreatedAt
        {
            get
            {
                return _selectedAnnouncement == null
                    ? ""
                    : Html(_selectedAnnouncement.CreatedAt.ToString("d MMM yyyy - h:mm tt", CultureInfo.InvariantCulture));
            }
        }

        protected string DetailDateOnly
        {
            get
            {
                return _selectedAnnouncement == null
                    ? ""
                    : Html(_selectedAnnouncement.CreatedAt.ToString("d MMM yyyy", CultureInfo.InvariantCulture));
            }
        }

        protected string DetailContent
        {
            get { return Html(_selectedAnnouncement == null ? "" : _selectedAnnouncement.Content); }
        }

        protected bool DetailHasAttachment
        {
            get { return _selectedAnnouncement != null && _selectedAnnouncement.HasAttachment; }
        }

        protected string DetailAttachmentUrl
        {
            get
            {
                return DetailHasAttachment
                    ? ResolveUrl(_selectedAnnouncement.FileUrl)
                    : "#";
            }
        }

        protected string DetailAttachmentLabel
        {
            get
            {
                if (!DetailHasAttachment) return "None";
                return Html(Path.GetFileName(_selectedAnnouncement.FileUrl));
            }
        }
    }
}
