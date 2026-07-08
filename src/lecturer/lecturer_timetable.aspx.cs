using System;
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;
using src.services;

namespace src.lecturer
{
    public partial class lecturer_timetable : src.security.LecturerPage
    {
        protected int SlotCount { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindOptions();
                ResetForm();
            }
            BindSlots();
        }

        protected void Save_Click(object sender, EventArgs e)
        {
            int timetableId;
            int offerId;
            TimeSpan start;
            TimeSpan end;

            if (!int.TryParse(timetableIdField.Value, out timetableId)) timetableId = 0;
            if (!int.TryParse(offeringList.SelectedValue, out offerId) ||
                !TimeSpan.TryParse(startTimeText.Text, out start) ||
                !TimeSpan.TryParse(endTimeText.Text, out end))
            {
                ShowMessage("Select a course and enter valid start and end times.", false);
                return;
            }

            try
            {
                LecturerPortalService.SaveClassSession(
                    UserContextFactory.FromSession(Session), timetableId, offerId,
                    dayList.SelectedValue, start, end, roomText.Text);
                ResetForm();
                BindSlots();
                ShowMessage("Timetable slot saved.", true);
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message, false);
            }
        }

        protected void Cancel_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        protected void Slots_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out id)) return;
            var user = UserContextFactory.FromSession(Session);

            if (e.CommandName == "DeleteSlot")
            {
                ShowMessage(LecturerPortalService.DeleteClassSession(user, id)
                    ? "Timetable slot deleted."
                    : "The timetable slot could not be deleted.", true);
                ResetForm();
                BindSlots();
                return;
            }

            if (e.CommandName == "EditSlot")
            {
                var slot = LecturerPortalService.GetManageableClassSessions(user)
                    .FirstOrDefault(x => x.TimetableId == id);
                if (slot == null) return;
                timetableIdField.Value = slot.TimetableId.ToString(CultureInfo.InvariantCulture);
                offeringList.SelectedValue = slot.OfferingId.ToString(CultureInfo.InvariantCulture);
                dayList.SelectedValue = slot.DayOfWeek;
                startTimeText.Text = slot.StartTime.ToString(@"hh\:mm");
                endTimeText.Text = slot.EndTime.ToString(@"hh\:mm");
                roomText.Text = slot.Venue == "TBA" ? "" : slot.Venue;
                formTitleLiteral.Text = "Edit timetable slot";
                saveButton.Text = "Update slot";
                cancelButton.Visible = true;
            }
        }

        protected string FormatTime(object value)
        {
            return value is TimeSpan ? ((TimeSpan)value).ToString(@"hh\:mm") : "";
        }

        private void BindOptions()
        {
            var user = UserContextFactory.FromSession(Session);
            offeringList.DataSource = LecturerPortalService.GetCourses(user)
                .OrderByDescending(x => x.AcademicYear)
                .ThenBy(x => x.Semester)
                .ThenBy(x => x.CourseCode)
                .Select(x => new
                {
                    Value = x.OfferingId,
                    Text = x.CourseCode + " - " + x.CourseName + " (" + x.SemesterName + ")"
                }).ToList();
            offeringList.DataValueField = "Value";
            offeringList.DataTextField = "Text";
            offeringList.DataBind();

            dayList.Items.Clear();
            foreach (var day in new[] { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" })
                dayList.Items.Add(new ListItem(day, day));
        }

        private void BindSlots()
        {
            var slots = LecturerPortalService.GetManageableClassSessions(UserContextFactory.FromSession(Session));
            SlotCount = slots.Count;
            slotsRepeater.DataSource = slots;
            slotsRepeater.DataBind();
            emptySlotsPanel.Visible = slots.Count == 0;
        }

        private void ResetForm()
        {
            timetableIdField.Value = "0";
            if (offeringList.Items.Count > 0) offeringList.SelectedIndex = 0;
            if (dayList.Items.Count > 0) dayList.SelectedValue = "Monday";
            startTimeText.Text = "09:00";
            endTimeText.Text = "11:00";
            roomText.Text = "";
            formTitleLiteral.Text = "Add timetable slot";
            saveButton.Text = "Save slot";
            cancelButton.Visible = false;
        }

        private void ShowMessage(string message, bool success)
        {
            messagePanel.Visible = true;
            messagePanel.CssClass = success
                ? "mt-5 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-emerald-700"
                : "mt-5 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-red-700";
            messageLiteral.Text = Server.HtmlEncode(message);
        }
    }
}
