using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;
using src.services;

namespace src.lecturer
{
    public partial class lecturer_attendance_history : src.security.LecturerPage
    {
        private List<LecturerAttendanceHistoryRow> _history = new List<LecturerAttendanceHistoryRow>();

        protected void Page_Load(object sender, EventArgs e)
        {
            _history = LecturerPortalService.GetAttendanceHistory(UserContextFactory.FromSession(Session));
            historyRepeater.DataSource = _history;
            historyRepeater.DataBind();
            courseFilterSelect.Items.Clear();
            courseFilterSelect.Items.Add(new ListItem("All courses", "all"));
            foreach (string courseCode in _history.Select(row => row.CourseCode).Distinct().OrderBy(code => code))
                courseFilterSelect.Items.Add(new ListItem(courseCode, courseCode));
            emptyPanel.Visible = _history.Count == 0;
        }

        protected int SessionCount { get { return _history.Count; } }

        protected string DateLabel(object value)
        {
            return Convert.ToDateTime(value).ToString("ddd, d MMM yyyy", CultureInfo.InvariantCulture);
        }

        protected string TimeLabel(object start, object end)
        {
            return FormatTime((TimeSpan)start) + " - " + FormatTime((TimeSpan)end);
        }

        protected string SearchText(object dataItem)
        {
            var row = dataItem as LecturerAttendanceHistoryRow;
            return row == null
                ? ""
                : HttpUtility.HtmlAttributeEncode(
                    row.CourseCode + " " + row.CourseName + " " +
                    row.SessionDate.ToString("d MMM yyyy", CultureInfo.InvariantCulture));
        }

        protected string ViewUrl(object dataItem)
        {
            var row = dataItem as LecturerAttendanceHistoryRow;
            if (row == null) return "#";
            return ResolveUrl(
                "~/lecturer/lecturer_take_attendance.aspx?offering=" + row.OfferingId.ToString(CultureInfo.InvariantCulture) +
                "&date=" + row.SessionDate.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) +
                "&start=" + row.StartTime.ToString(@"hh\:mm") +
                "&end=" + row.EndTime.ToString(@"hh\:mm") +
                "&mode=view");
        }

        private static string FormatTime(TimeSpan value)
        {
            return DateTime.Today.Add(value).ToString("h:mm tt", CultureInfo.InvariantCulture);
        }
    }
}
