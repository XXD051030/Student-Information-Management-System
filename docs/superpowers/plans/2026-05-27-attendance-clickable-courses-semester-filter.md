# Attendance: clickable course cards + semester filter — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the "By course" cards on `student/attendance.aspx` clickable so the detail panel switches courses instantly, and add a semester filter (listing only semesters with attendance, defaulting to current) that drives the cards, detail, and hero summary.

**Architecture:** Progressive enhancement. `AttendanceService` loads all of the student's semesters (keeping only semesters that have attendance). The server renders all course cards plus the current-semester hero and the first current-semester course's detail (no flash, no-JS baseline). A new `js/attendance/attendance.js` reads a serialized `window.attendanceData` payload and owns interaction: semester filtering, card clicks, hero recompute, and detail repaint — matching the `notifications.js` (client-painted detail) and `timetable.js` (server payload via a `window.*` global) conventions.

**Tech Stack:** ASP.NET WebForms (C#, .NET Framework 4.7.2), SQL Server LocalDB, Tailwind Play CDN, vanilla JS, Lucide icons, `System.Web.Script.Serialization.JavaScriptSerializer`.

**Verification note:** No unit-test harness exists in this project. Each task is verified by a successful `msbuild` compile and/or a described manual check, per project conventions. Build command (PowerShell — Git Bash mangles msbuild switches):

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src\src.csproj" /t:Build /p:Configuration=Debug /v:minimal
```

(If the MSBuild path differs, locate it with `& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -find MSBuild\**\Bin\MSBuild.exe`.)

---

## File Structure

- **Modify** `services/AttendanceService.cs` — load all semesters, add `SemesterId`/`SemesterName`/`IsCurrent` to `AttendanceCourse`, drop semesters that have no attendance.
- **Modify** `student/attendance.aspx.cs` — current-semester-scoped hero, default-course selection, `SemesterOptionsHtml` + `AttendancePayloadJson` builders; remove the now-unused semester-chip helpers and the placeholder-visibility logic.
- **Modify** `student/attendance.aspx.designer.cs` — remove the four placeholder fields that become plain HTML (`emptyCoursesPanel`, `detailPanel`, `emptySessionsPanel`, `emptyDetailPanel`); keep `courseRepeater` and `sessionsRepeater`.
- **Modify** `student/attendance.aspx` — semester `<select>`, hero/detail JS hooks (ids), card `data-*` attributes, convert placeholders to plain `id`'d divs, add the `ScriptsPlaceholder` block with the payload + script tag.
- **Create** `js/attendance/attendance.js` — filter, card click, hero recompute, detail repaint, empty-state toggles.
- **Modify** `src.csproj` — register `js\attendance\attendance.js` as Content.
- **Modify** `doc/project-context.md` — update attendance page/service/JS sections (mandatory maintenance rule).

---

## Task 1: Data layer — load all semesters, add semester fields, drop empty semesters

**Files:**
- Modify: `services/AttendanceService.cs`

- [ ] **Step 1: Add semester fields to `AttendanceCourse`**

In `services/AttendanceService.cs`, add three properties to the `AttendanceCourse` class, right after `OfferingId`:

```csharp
    public class AttendanceCourse
    {
        public int OfferingId { get; set; }
        public int SemesterId { get; set; }
        public string SemesterName { get; set; }
        public bool IsCurrent { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public string LecturerName { get; set; }
        public string Color { get; set; }
        public List<AttendanceSession> Sessions { get; set; }
```

(Leave the rest of `AttendanceCourse` — the `Sessions` initializer and the count/rate properties — unchanged.)

- [ ] **Step 2: Broaden the rows query to all semesters and select semester columns**

Replace the entire `SelectAttendanceRows` constant with:

```csharp
        private const string SelectAttendanceRows =
            "SELECT e.offering_id, sem.semester_id, sem.name AS semester_name, sem.is_current, " +
            "c.course_code, c.course_name, ISNULL(c.color, '') AS color, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, " +
            "a.attendance_id, a.attendance_date, a.status, " +
            "tt.venue, tt.start_time, tt.end_time " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "LEFT JOIN ATTENDANCE a ON a.enrolment_id = e.enrolment_id " +
            "OUTER APPLY (" +
            "SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "OUTER APPLY (" +
            "SELECT TOP 1 venue, start_time, end_time FROM TIMETABLES t " +
            "WHERE t.offering_id = o.offering_id " +
            "AND (a.attendance_date IS NULL OR t.day_of_week = DATENAME(WEEKDAY, a.attendance_date)) " +
            "ORDER BY t.start_time) tt " +
            "WHERE s.user_id = @userId AND e.status IN ('ENROLLED', 'COMPLETED') " +
            "ORDER BY sem.start_date DESC, c.course_code, a.attendance_date DESC, a.attendance_id DESC";
```

(The change vs. the original: added `sem.semester_id, sem.name AS semester_name, sem.is_current` to the SELECT, removed `sem.is_current = 1` from the WHERE, broadened `e.status` to `IN ('ENROLLED', 'COMPLETED')`, and ordered by `sem.start_date DESC` first.)

- [ ] **Step 3: Map the new semester fields when creating each course**

In `GetCourses`, inside the `if (!coursesByOffering.TryGetValue(...))` block, set the three new fields when constructing the `AttendanceCourse`:

```csharp
                        if (!coursesByOffering.TryGetValue(offeringId, out course))
                        {
                            course = new AttendanceCourse
                            {
                                OfferingId = offeringId,
                                SemesterId = (int)reader["semester_id"],
                                SemesterName = reader["semester_name"].ToString(),
                                IsCurrent = Convert.ToBoolean(reader["is_current"]),
                                CourseCode = reader["course_code"].ToString(),
                                CourseName = reader["course_name"].ToString(),
                                LecturerName = reader["lecturer_name"].ToString(),
                                Color = reader["color"].ToString()
                            };
                            coursesByOffering.Add(offeringId, course);
                        }
```

- [ ] **Step 4: Drop semesters with no attendance in `GetAttendancePage`**

Replace the body of `GetAttendancePage` so it filters out whole semesters that have zero attendance records (this excludes the empty future semester while keeping every course of any semester that does have records):

```csharp
        public static AttendancePageData GetAttendancePage(int userId)
        {
            var header = GetHeader(userId);
            if (header == null) return null;

            var courses = GetCourses(userId);

            // Keep only semesters that actually have attendance records.
            var semestersWithAttendance = new HashSet<int>(
                courses.Where(c => c.TotalCount > 0).Select(c => c.SemesterId));
            courses = courses
                .Where(c => semestersWithAttendance.Contains(c.SemesterId))
                .ToList();

            return new AttendancePageData
            {
                SemesterName = header.SemesterName,
                SemesterStartDate = header.SemesterStartDate,
                SemesterEndDate = header.SemesterEndDate,
                CurrentSemesterNo = header.CurrentSemesterNo,
                Courses = courses
            };
        }
```

(`System.Collections.Generic` and `System.Linq` are already imported at the top of the file, so `HashSet<int>` and the LINQ calls compile.)

- [ ] **Step 5: Build to verify it compiles**

Run the build command from the header.
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 6: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/services/AttendanceService.cs"
git commit -m "feat(attendance): load all semesters with semester context, drop empty semesters"
```

---

## Task 2: Code-behind — current-semester hero, default course, payload + semester options

**Files:**
- Modify: `student/attendance.aspx.cs`

- [ ] **Step 1: Replace the whole file**

Replace the entire contents of `student/attendance.aspx.cs` with:

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class attendance : System.Web.UI.Page
    {
        private int _selectedOfferingId;

        protected string OverallRateDisplay { get; private set; }
        protected string OverallSubtext { get; private set; }
        protected string PresentCountDisplay { get; private set; }
        protected string LateCountDisplay { get; private set; }
        protected string AbsentCountDisplay { get; private set; }
        protected string DetailCourseCode { get; private set; }
        protected string DetailCourseName { get; private set; }
        protected string DetailLecturerName { get; private set; }
        protected string DetailCourseColorStyle { get; private set; }
        protected string DetailPresentDisplay { get; private set; }
        protected string DetailLateDisplay { get; private set; }
        protected string DetailAbsentDisplay { get; private set; }
        protected string SessionsFooterDisplay { get; private set; }
        protected string SemesterOptionsHtml { get; private set; }
        protected string AttendancePayloadJson { get; private set; }

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

            BindAttendancePage((int)Session["user_id"]);
        }

        protected string CourseCardClass(object dataItem)
        {
            var course = dataItem as AttendanceCourse;
            bool selected = course != null && course.OfferingId == _selectedOfferingId;
            return selected
                ? "text-left rounded-lg border bg-white p-5 border-[#e0162b]/40 shadow-[0_8px_24px_-12px_rgba(224,22,43,0.35)] ring-1 ring-[#e0162b]/20 cursor-pointer"
                : "text-left rounded-lg border bg-white p-5 border-slate-200 cursor-pointer";
        }

        protected string CourseColorStyle(object color)
        {
            return "background-color:" + SafeColor(color);
        }

        protected string CourseRateDisplay(object dataItem)
        {
            var course = dataItem as AttendanceCourse;
            return course == null ? "N/A" : FormatRate(course.AttendanceRate);
        }

        protected string CourseRatioDisplay(object dataItem)
        {
            var course = dataItem as AttendanceCourse;
            if (course == null) return "0 / 0";
            return course.PresentCount + " / " + course.TotalCount;
        }

        protected string CourseBarStyle(object dataItem)
        {
            var course = dataItem as AttendanceCourse;
            decimal width = course == null || !course.AttendanceRate.HasValue
                ? 0m
                : course.AttendanceRate.Value * 100m;
            return "width:" + Math.Max(0m, Math.Min(100m, width)).ToString("0.#") + "%;background-color:#e0162b";
        }

        protected string SessionDateDisplay(object dataItem)
        {
            var session = dataItem as AttendanceSession;
            return session == null ? "" : session.AttendanceDate.ToString("d MMM yyyy");
        }

        protected string SessionDayDisplay(object dataItem)
        {
            var session = dataItem as AttendanceSession;
            return session == null ? "" : session.AttendanceDate.ToString("ddd");
        }

        protected string SessionTimeDisplay(object dataItem)
        {
            var session = dataItem as AttendanceSession;
            if (session == null || !session.StartTime.HasValue || !session.EndTime.HasValue)
            {
                return "TBA";
            }

            return FormatTime(session.StartTime.Value) + " - " + FormatTime(session.EndTime.Value);
        }

        protected string SessionTypeDisplay(object dataItem)
        {
            var session = dataItem as AttendanceSession;
            return session == null || string.IsNullOrWhiteSpace(session.SessionType)
                ? "Class"
                : session.SessionType;
        }

        protected string SessionVenueDisplay(object dataItem)
        {
            var session = dataItem as AttendanceSession;
            return session == null || string.IsNullOrWhiteSpace(session.Venue)
                ? "TBA"
                : session.Venue;
        }

        protected string StatusBadgeClass(object statusValue)
        {
            string status = (statusValue == null ? "" : statusValue.ToString()).ToUpperInvariant();
            switch (status)
            {
                case "PRESENT":
                    return "inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5";
                case "LATE":
                    return "inline-flex items-center gap-1 rounded border bg-sky-50 text-sky-700 border-sky-100 px-1.5 py-0.5";
                case "ABSENT":
                    return "inline-flex items-center gap-1 rounded border bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20 px-1.5 py-0.5";
                default:
                    return "inline-flex items-center gap-1 rounded border bg-slate-50 text-slate-700 border-slate-200 px-1.5 py-0.5";
            }
        }

        protected string StatusIcon(object statusValue)
        {
            string status = (statusValue == null ? "" : statusValue.ToString()).ToUpperInvariant();
            switch (status)
            {
                case "PRESENT": return "check-circle-2";
                case "LATE": return "clock";
                case "ABSENT": return "x-circle";
                default: return "circle";
            }
        }

        protected string StatusDisplay(object statusValue)
        {
            string status = statusValue == null ? "" : statusValue.ToString();
            return string.IsNullOrWhiteSpace(status) ? "N/A" : status.ToUpperInvariant();
        }

        protected string LecturerDisplay(object lecturer)
        {
            string name = lecturer == null ? "" : lecturer.ToString();
            return string.IsNullOrWhiteSpace(name) ? "Lecturer not assigned" : name;
        }

        private void BindAttendancePage(int userId)
        {
            var attendance = AttendanceService.GetAttendancePage(userId);
            if (attendance == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }

            // Cards: every kept semester. JS filters to the current semester on load.
            courseRepeater.DataSource = attendance.Courses;
            courseRepeater.DataBind();

            // Hero: current-semester subset only (the initial, pre-filter view).
            var currentCourses = attendance.Courses.Where(c => c.IsCurrent).ToList();
            int hPresent = currentCourses.Sum(c => c.PresentCount);
            int hLate = currentCourses.Sum(c => c.LateCount);
            int hAbsent = currentCourses.Sum(c => c.AbsentCount);
            int hTotal = currentCourses.Sum(c => c.TotalCount);
            decimal? hRate = hTotal == 0 ? (decimal?)null : Math.Round((decimal)hPresent / hTotal, 4);

            OverallRateDisplay = FormatRate(hRate);
            PresentCountDisplay = hPresent.ToString();
            LateCountDisplay = hLate.ToString();
            AbsentCountDisplay = hAbsent.ToString();
            OverallSubtext = hTotal == 0
                ? "No attendance records yet"
                : hPresent + " present / " + hTotal + " recorded across " + currentCourses.Count + " " + Pluralize("course", currentCourses.Count);

            // Default selected course: first current-semester course, else first overall.
            var selectedCourse = currentCourses.FirstOrDefault() ?? attendance.Courses.FirstOrDefault();
            _selectedOfferingId = selectedCourse == null ? 0 : selectedCourse.OfferingId;

            if (selectedCourse != null)
            {
                DetailCourseCode = selectedCourse.CourseCode;
                DetailCourseName = selectedCourse.CourseName;
                DetailLecturerName = LecturerDisplay(selectedCourse.LecturerName);
                DetailCourseColorStyle = CourseColorStyle(selectedCourse.Color);
                DetailPresentDisplay = selectedCourse.PresentCount.ToString();
                DetailLateDisplay = selectedCourse.LateCount.ToString();
                DetailAbsentDisplay = selectedCourse.AbsentCount.ToString();
                SessionsFooterDisplay = "Showing " + selectedCourse.Sessions.Count + " of " + selectedCourse.Sessions.Count + " recorded sessions";

                sessionsRepeater.DataSource = selectedCourse.Sessions;
                sessionsRepeater.DataBind();
            }

            SemesterOptionsHtml = BuildSemesterOptions(attendance.Courses);
            AttendancePayloadJson = BuildPayloadJson(attendance.Courses, _selectedOfferingId, currentCourses);
        }

        private static string BuildSemesterOptions(List<AttendanceCourse> courses)
        {
            var semesters = courses
                .GroupBy(c => c.SemesterId)
                .Select(g => new { Id = g.Key, Name = g.First().SemesterName, IsCurrent = g.First().IsCurrent })
                .ToList();

            var sb = new StringBuilder();
            foreach (var sem in semesters)
            {
                sb.Append("<option value=\"")
                  .Append(sem.Id)
                  .Append("\"")
                  .Append(sem.IsCurrent ? " selected" : "")
                  .Append(">")
                  .Append(HttpUtility.HtmlEncode(sem.Name))
                  .Append("</option>");
            }
            sb.Append("<option value=\"all\">All semesters</option>");
            return sb.ToString();
        }

        private string BuildPayloadJson(List<AttendanceCourse> courses, int defaultOfferingId, List<AttendanceCourse> currentCourses)
        {
            int currentSemesterId = currentCourses.Select(c => c.SemesterId).FirstOrDefault();

            var payload = new
            {
                defaultOfferingId = defaultOfferingId,
                currentSemesterId = currentSemesterId,
                courses = courses.Select(c => new
                {
                    offeringId = c.OfferingId,
                    semesterId = c.SemesterId,
                    semesterName = c.SemesterName,
                    isCurrent = c.IsCurrent,
                    code = c.CourseCode,
                    name = c.CourseName,
                    lecturer = LecturerDisplay(c.LecturerName),
                    color = SafeColor(c.Color),
                    present = c.PresentCount,
                    late = c.LateCount,
                    absent = c.AbsentCount,
                    total = c.TotalCount,
                    sessions = c.Sessions.Select(s => new
                    {
                        date = SessionDateDisplay(s),
                        day = SessionDayDisplay(s),
                        time = SessionTimeDisplay(s),
                        type = SessionTypeDisplay(s),
                        venue = SessionVenueDisplay(s),
                        status = (s.Status ?? "").ToUpperInvariant()
                    }).ToList()
                }).ToList()
            };

            string json = new JavaScriptSerializer().Serialize(payload);
            // Defensive: never let a value close the inline <script> early.
            return json.Replace("</", "<\\/");
        }

        private static string FormatRate(decimal? rate)
        {
            return rate.HasValue ? (rate.Value * 100m).ToString("0.#") + "%" : "N/A";
        }

        private static string FormatTime(TimeSpan time)
        {
            return DateTime.Today.Add(time).ToString("HH:mm");
        }

        private static string SafeColor(object color)
        {
            string value = color == null ? "" : color.ToString();
            if (value.Length == 7 && value[0] == '#' && value.Skip(1).All(Uri.IsHexDigit))
            {
                return value;
            }
            return "#e0162b";
        }

        private static string Pluralize(string word, int count)
        {
            return count == 1 ? word : word + "s";
        }
    }
}
```

> What changed vs. the original: removed `SemesterDisplay` and its helpers (`FormatSemester`, `YearNo`, `TrimesterNo`) — the header chip is replaced by the dropdown; removed all `*.Visible = ...` placeholder toggling (those placeholders become plain JS-controlled divs in Task 3); added `SemesterOptionsHtml`, `AttendancePayloadJson`, `BuildSemesterOptions`, `BuildPayloadJson`; hero now sums only `IsCurrent` courses.

- [ ] **Step 2: Do not build yet** — the markup still has the old placeholders/chip and no `ScriptsPlaceholder`; the page compiles only after Task 3 aligns markup + designer. (The code-behind itself is valid C#, but build verification happens at the end of Task 3.)

- [ ] **Step 3: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/student/attendance.aspx.cs"
git commit -m "feat(attendance): current-semester hero, default course, payload and semester options"
```

---

## Task 3: Markup + designer — dropdown, JS hooks, plain-div panels, scripts

**Files:**
- Modify: `student/attendance.aspx`
- Modify: `student/attendance.aspx.designer.cs`

- [ ] **Step 1: Replace the semester chip with the dropdown**

In `student/attendance.aspx`, replace the semester chip span in the header (the `<span ...>` containing `<i data-lucide="calendar-days" ...>` and `<%: SemesterDisplay %>`):

```aspx
            <span class="inline-flex items-center gap-2 rounded-full bg-slate-100 px-3 py-1 text-slate-700" style="font-size:12px;font-weight:600">
                <i data-lucide="calendar-days" class="h-3.5 w-3.5"></i>
                <%: SemesterDisplay %>
            </span>
```

with:

```aspx
            <div class="inline-flex items-center gap-2 rounded-full bg-slate-100 px-3 py-1 text-slate-700" style="font-size:12px;font-weight:600">
                <i data-lucide="calendar-days" class="h-3.5 w-3.5"></i>
                <select id="semester-filter" class="bg-transparent text-slate-700 focus:outline-none cursor-pointer" style="font-size:12px;font-weight:600">
                    <%= SemesterOptionsHtml %>
                </select>
            </div>
```

- [ ] **Step 2: Add ids to the hero values**

In the hero summary section, wrap the four dynamic values so JS can update them. Replace:

```aspx
                    <p class="mt-2" style="font-size:56px;font-weight:800;letter-spacing:-0.02em;line-height:1"><%: OverallRateDisplay %></p>
                    <p class="mt-2 text-white/80" style="font-size:13px"><%: OverallSubtext %></p>
```

with:

```aspx
                    <p class="mt-2" style="font-size:56px;font-weight:800;letter-spacing:-0.02em;line-height:1"><span id="hero-rate"><%: OverallRateDisplay %></span></p>
                    <p id="hero-subtext" class="mt-2 text-white/80" style="font-size:13px"><%: OverallSubtext %></p>
```

Then, in the present/late/absent grid just below, wrap each count. Replace:

```aspx
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700"><%: PresentCountDisplay %></p>
```
with
```aspx
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700"><span id="hero-present"><%: PresentCountDisplay %></span></p>
```

Replace:
```aspx
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700"><%: LateCountDisplay %></p>
```
with
```aspx
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700"><span id="hero-late"><%: LateCountDisplay %></span></p>
```

Replace:
```aspx
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700"><%: AbsentCountDisplay %></p>
```
with
```aspx
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700"><span id="hero-absent"><%: AbsentCountDisplay %></span></p>
```

- [ ] **Step 3: Add `data-*` attributes to the course card root**

In the `courseRepeater` `ItemTemplate`, replace the opening card `<div>`:

```aspx
                    <div class='<%# CourseCardClass(Container.DataItem) %>'>
```

with:

```aspx
                    <div class='<%# CourseCardClass(Container.DataItem) %>' data-offering='<%# Eval("OfferingId") %>' data-semester-id='<%# Eval("SemesterId") %>'>
```

- [ ] **Step 4: Convert the empty-courses placeholder to a plain div**

Replace:

```aspx
        <asp:PlaceHolder ID="emptyCoursesPanel" runat="server" Visible="false">
            <div class="mt-3 rounded-lg border border-dashed border-slate-200 bg-white px-6 py-8 text-center">
                <p class="text-slate-900" style="font-size:15px;font-weight:600">No current-semester courses</p>
                <p class="mt-1 text-slate-500" style="font-size:13px">Attendance appears after you are enrolled in current-semester courses.</p>
            </div>
        </asp:PlaceHolder>
```

with:

```aspx
        <div id="empty-courses" class="mt-3 rounded-lg border border-dashed border-slate-200 bg-white px-6 py-8 text-center" style="display:none">
            <p class="text-slate-900" style="font-size:15px;font-weight:600">No courses for this semester</p>
            <p class="mt-1 text-slate-500" style="font-size:13px">Attendance appears after you are enrolled in courses for the selected semester.</p>
        </div>
```

- [ ] **Step 5: Convert the detail panel placeholder to a plain section and add JS hooks**

Replace the opening of the detail placeholder:

```aspx
    <asp:PlaceHolder ID="detailPanel" runat="server">
        <%-- Detail sessions --%>
        <section class="mt-6 rounded-lg border border-slate-200 bg-white">
```

with:

```aspx
    <%-- Detail sessions --%>
    <section id="detail-panel" class="mt-6 rounded-lg border border-slate-200 bg-white">
```

Then, inside that header, add ids to the accent bar, code, name, and lecturer. Replace:

```aspx
                    <span class="h-10 w-1.5 rounded-full" style="<%= DetailCourseColorStyle %>"></span>
                    <div class="min-w-0">
                        <p class="text-slate-500" style="font-size:11.5px;font-weight:700;letter-spacing:0.06em"><%: DetailCourseCode %></p>
                        <h3 class="text-slate-900 truncate" style="font-size:18px;font-weight:700;letter-spacing:-0.01em"><%: DetailCourseName %></h3>
                        <p class="text-slate-500 truncate" style="font-size:12.5px"><%: DetailLecturerName %></p>
                    </div>
```

with:

```aspx
                    <span id="detail-accent" class="h-10 w-1.5 rounded-full" style="<%= DetailCourseColorStyle %>"></span>
                    <div class="min-w-0">
                        <p id="detail-code" class="text-slate-500" style="font-size:11.5px;font-weight:700;letter-spacing:0.06em"><%: DetailCourseCode %></p>
                        <h3 id="detail-name" class="text-slate-900 truncate" style="font-size:18px;font-weight:700;letter-spacing:-0.01em"><%: DetailCourseName %></h3>
                        <p id="detail-lecturer" class="text-slate-500 truncate" style="font-size:12.5px"><%: DetailLecturerName %></p>
                    </div>
```

- [ ] **Step 6: Add ids to the detail KPI strip**

Replace the three KPI value paragraphs. Replace:

```aspx
                    <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700"><%: DetailPresentDisplay %></p>
```
with
```aspx
                    <p id="detail-present" class="mt-1 text-slate-900" style="font-size:22px;font-weight:700"><%: DetailPresentDisplay %></p>
```

Replace:
```aspx
                    <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700"><%: DetailLateDisplay %></p>
```
with
```aspx
                    <p id="detail-late" class="mt-1 text-slate-900" style="font-size:22px;font-weight:700"><%: DetailLateDisplay %></p>
```

Replace:
```aspx
                    <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700"><%: DetailAbsentDisplay %></p>
```
with
```aspx
                    <p id="detail-absent" class="mt-1 text-slate-900" style="font-size:22px;font-weight:700"><%: DetailAbsentDisplay %></p>
```

- [ ] **Step 7: Add an id to the sessions `<tbody>`**

Replace:

```aspx
                    <tbody class="divide-y divide-slate-100">
                        <asp:Repeater ID="sessionsRepeater" runat="server">
```

with:

```aspx
                    <tbody id="sessions-body" class="divide-y divide-slate-100">
                        <asp:Repeater ID="sessionsRepeater" runat="server">
```

- [ ] **Step 8: Convert the empty-sessions placeholder to a plain div**

Replace:

```aspx
            <asp:PlaceHolder ID="emptySessionsPanel" runat="server" Visible="false">
                <div class="border-t border-slate-100 px-6 py-8 text-center">
                    <p class="text-slate-900" style="font-size:15px;font-weight:600">No sessions recorded for this course</p>
                    <p class="mt-1 text-slate-500" style="font-size:13px">Attendance rows will appear after records are entered.</p>
                </div>
            </asp:PlaceHolder>
```

with:

```aspx
            <div id="empty-sessions" class="border-t border-slate-100 px-6 py-8 text-center" style="display:none">
                <p class="text-slate-900" style="font-size:15px;font-weight:600">No sessions recorded for this course</p>
                <p class="mt-1 text-slate-500" style="font-size:13px">Attendance rows will appear after records are entered.</p>
            </div>
```

- [ ] **Step 9: Add an id to the footer text and close the section**

Replace:

```aspx
            <footer class="flex items-center justify-between border-t border-slate-100 px-6 py-3">
                <p class="text-slate-500" style="font-size:12px"><%: SessionsFooterDisplay %></p>
            </footer>
        </section>
    </asp:PlaceHolder>
```

with:

```aspx
            <footer class="flex items-center justify-between border-t border-slate-100 px-6 py-3">
                <p id="sessions-footer" class="text-slate-500" style="font-size:12px"><%: SessionsFooterDisplay %></p>
            </footer>
        </section>
```

- [ ] **Step 10: Convert the empty-detail placeholder to a plain div**

Replace:

```aspx
    <asp:PlaceHolder ID="emptyDetailPanel" runat="server" Visible="false">
        <section class="mt-6 rounded-lg border border-dashed border-slate-200 bg-white px-6 py-10 text-center">
            <p class="text-slate-900" style="font-size:15px;font-weight:600">No attendance details yet</p>
            <p class="mt-1 text-slate-500" style="font-size:13px">Course attendance details will appear after current-semester enrolments are available.</p>
        </section>
    </asp:PlaceHolder>
```

with:

```aspx
    <section id="empty-detail" class="mt-6 rounded-lg border border-dashed border-slate-200 bg-white px-6 py-10 text-center" style="display:none">
        <p class="text-slate-900" style="font-size:15px;font-weight:600">No attendance details yet</p>
        <p class="mt-1 text-slate-500" style="font-size:13px">Course attendance details will appear after enrolments with attendance are available.</p>
    </section>
```

- [ ] **Step 11: Add the `ScriptsPlaceholder` content block**

Immediately after the page's closing `</asp:Content>` (the very last line of the file), add a second content block:

```aspx
<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script type="text/javascript">
        window.attendanceData = <%= AttendancePayloadJson %>;
    </script>
    <script src='<%= ResolveUrl("~/js/attendance/attendance.js") %>'></script>
</asp:Content>
```

- [ ] **Step 12: Remove the four placeholder fields from the designer**

In `student/attendance.aspx.designer.cs`, delete the field declarations for `emptyCoursesPanel`, `detailPanel`, `emptySessionsPanel`, and `emptyDetailPanel` (and their doc-comment blocks). The file body should keep only `courseRepeater` and `sessionsRepeater`:

```csharp
namespace src.student
{


    public partial class attendance
    {
        /// <summary>
        /// courseRepeater control.
        /// </summary>
        /// <remarks>
        /// Auto-generated field.
        /// To modify move field declaration from designer file to code-behind file.
        /// </remarks>
        protected global::System.Web.UI.WebControls.Repeater courseRepeater;

        /// <summary>
        /// sessionsRepeater control.
        /// </summary>
        /// <remarks>
        /// Auto-generated field.
        /// To modify move field declaration from designer file to code-behind file.
        /// </remarks>
        protected global::System.Web.UI.WebControls.Repeater sessionsRepeater;
    }
}
```

- [ ] **Step 13: Build to verify markup + code-behind + designer compile together**

Run the build command from the header.
Expected: `Build succeeded`, 0 errors.

> If the build reports that `ScriptsPlaceholder` does not exist, confirm `DashboardLayout.master` re-exposes a `ContentPlaceHolder` named `ScriptsPlaceholder` (project-context records that it does). It is the same placeholder `timetable.aspx` and `account.aspx` use for their scripts.

- [ ] **Step 14: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/student/attendance.aspx" "5026CMD Software Engineer/src/src/student/attendance.aspx.designer.cs"
git commit -m "feat(attendance): semester dropdown, JS hooks, client-controlled panels"
```

---

## Task 4: Client-side interactivity (`attendance.js`)

**Files:**
- Create: `js/attendance/attendance.js`
- Modify: `src.csproj`

- [ ] **Step 1: Create `js/attendance/attendance.js`**

```javascript
// Attendance page: clickable course cards + semester filter.
// The server renders every course card (all kept semesters) and serializes the
// full per-course data to window.attendanceData. This script filters cards by
// semester, recomputes the hero summary from the visible courses, and repaints
// the detail panel (header, KPI strip, sessions table, footer) on card click.
(function () {
    "use strict";

    var data = window.attendanceData || { courses: [], defaultOfferingId: 0 };

    // Index courses by offeringId. Object keys are strings, and the card
    // data-offering attribute is a string, so lookups stay consistent.
    var byOffering = {};
    data.courses.forEach(function (c) { byOffering[String(c.offeringId)] = c; });

    var selectedOfferingId = String(data.defaultOfferingId || "");

    // Mirror of attendance.aspx.cs CourseCardClass (both selection states).
    var SELECTED_CARD =
        "text-left rounded-lg border bg-white p-5 border-[#e0162b]/40 shadow-[0_8px_24px_-12px_rgba(224,22,43,0.35)] ring-1 ring-[#e0162b]/20 cursor-pointer";
    var UNSELECTED_CARD =
        "text-left rounded-lg border bg-white p-5 border-slate-200 cursor-pointer";

    // Mirror of attendance.aspx.cs StatusBadgeClass / StatusIcon.
    function badge(status) {
        switch (status) {
            case "PRESENT":
                return { cls: "inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5", icon: "check-circle-2" };
            case "LATE":
                return { cls: "inline-flex items-center gap-1 rounded border bg-sky-50 text-sky-700 border-sky-100 px-1.5 py-0.5", icon: "clock" };
            case "ABSENT":
                return { cls: "inline-flex items-center gap-1 rounded border bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20 px-1.5 py-0.5", icon: "x-circle" };
            default:
                return { cls: "inline-flex items-center gap-1 rounded border bg-slate-50 text-slate-700 border-slate-200 px-1.5 py-0.5", icon: "circle" };
        }
    }

    function esc(s) {
        var d = document.createElement("div");
        d.textContent = s == null ? "" : String(s);
        return d.innerHTML;
    }

    function cards() {
        return Array.prototype.slice.call(
            document.querySelectorAll("#course-grid [data-offering]"));
    }

    function setText(id, txt) {
        var el = document.getElementById(id);
        if (el) { el.textContent = txt; }
    }

    function show(id, on) {
        var el = document.getElementById(id);
        if (el) { el.style.display = on ? "" : "none"; }
    }

    // Mirror of attendance.aspx.cs FormatRate: one optional decimal, "N/A" when empty.
    function formatRate(present, total) {
        if (total === 0) { return "N/A"; }
        var r = Math.round((present / total) * 1000) / 10;
        var str = (r % 1 === 0) ? String(r) : r.toFixed(1);
        return str + "%";
    }

    function rowHtml(s) {
        var b = badge(s.status);
        return '<tr class="hover:bg-slate-50/60">' +
            '<td class="px-6 py-3.5">' +
                '<div class="text-slate-900" style="font-size:13px;font-weight:600">' + esc(s.date) + '</div>' +
                '<div class="text-slate-500" style="font-size:11px">' + esc(s.day) + '</div>' +
            '</td>' +
            '<td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">' + esc(s.time) + '</td>' +
            '<td class="px-4 py-3.5">' +
                '<span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">' + esc(s.type) + '</span>' +
            '</td>' +
            '<td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">' + esc(s.venue) + '</td>' +
            '<td class="px-6 py-3.5">' +
                '<span class="' + b.cls + '" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">' +
                    '<i data-lucide="' + b.icon + '" class="h-3 w-3"></i> ' + esc(s.status) +
                '</span>' +
            '</td>' +
        '</tr>';
    }

    function selectCourse(offeringId) {
        offeringId = String(offeringId);
        selectedOfferingId = offeringId;

        cards().forEach(function (card) {
            var on = card.getAttribute("data-offering") === offeringId;
            card.className = on ? SELECTED_CARD : UNSELECTED_CARD;
        });

        var c = byOffering[offeringId];
        if (!c) { return; }

        var accent = document.getElementById("detail-accent");
        if (accent) { accent.style.backgroundColor = c.color; }
        setText("detail-code", c.code);
        setText("detail-name", c.name);
        setText("detail-lecturer", c.lecturer);
        setText("detail-present", String(c.present));
        setText("detail-late", String(c.late));
        setText("detail-absent", String(c.absent));

        var body = document.getElementById("sessions-body");
        if (body) { body.innerHTML = c.sessions.map(rowHtml).join(""); }
        show("empty-sessions", c.sessions.length === 0);
        setText("sessions-footer",
            "Showing " + c.sessions.length + " of " + c.sessions.length + " recorded sessions");

        if (window.lucide && typeof window.lucide.createIcons === "function") {
            window.lucide.createIcons();
        }
    }

    function applyFilter(value) {
        var visible = [];
        cards().forEach(function (card) {
            var sid = card.getAttribute("data-semester-id");
            var on = value === "all" || sid === value;
            card.style.display = on ? "" : "none";
            if (on) { visible.push(card); }
        });

        // Hero recompute from the visible courses.
        var present = 0, late = 0, absent = 0, total = 0;
        visible.forEach(function (card) {
            var c = byOffering[card.getAttribute("data-offering")];
            if (!c) { return; }
            present += c.present; late += c.late; absent += c.absent; total += c.total;
        });
        setText("hero-rate", formatRate(present, total));
        setText("hero-present", String(present));
        setText("hero-late", String(late));
        setText("hero-absent", String(absent));
        setText("hero-subtext", total === 0
            ? "No attendance records yet"
            : present + " present / " + total + " recorded across " +
              visible.length + " " + (visible.length === 1 ? "course" : "courses"));

        show("empty-courses", visible.length === 0);

        // Keep the current selection if it is still visible, else pick the first.
        var keep = visible.filter(function (card) {
            return card.getAttribute("data-offering") === selectedOfferingId;
        })[0];
        var target = keep || visible[0];

        if (target) {
            show("detail-panel", true);
            show("empty-detail", false);
            selectCourse(target.getAttribute("data-offering"));
        } else {
            show("detail-panel", false);
            show("empty-detail", true);
        }
    }

    function init() {
        cards().forEach(function (card) {
            card.addEventListener("click", function () {
                selectCourse(card.getAttribute("data-offering"));
            });
        });

        var sel = document.getElementById("semester-filter");
        if (sel) {
            sel.addEventListener("change", function () { applyFilter(sel.value); });
            applyFilter(sel.value);
        } else {
            applyFilter("all");
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
```

- [ ] **Step 2: Register the file in `src.csproj`**

Find an existing JS `<Content Include="js\... .js" />` line in `src.csproj` (e.g. `js\account\account.js`) and add a sibling entry in the same `<ItemGroup>`:

```xml
    <Content Include="js\attendance\attendance.js" />
```

> Match the exact backslash path style already used for the other JS entries. The project-context notes `js\course-detail\course-detail.js` was previously left out of `src.csproj`; make sure this entry is actually present.

- [ ] **Step 3: Build to verify the project still compiles**

Run the build command from the header.
Expected: `Build succeeded`, 0 errors. (A `.js` file does not affect compilation; this confirms the `.csproj` edit is well-formed XML.)

- [ ] **Step 4: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/js/attendance/attendance.js" "5026CMD Software Engineer/src/src/src.csproj"
git commit -m "feat(attendance): client-side card switching, semester filter and hero recompute"
```

---

## Task 5: Update project-context documentation

**Files:**
- Modify: `doc/project-context.md`

- [ ] **Step 1: Update the `student/attendance.aspx` section**

In `doc/project-context.md`, in the `### student/attendance.aspx` section, change the connections and data lines to reflect the new behavior. Replace:

```markdown
- No page-specific JS.
```

with:

```markdown
- Script: `~/js/attendance/attendance.js`.
```

And under the page's data description, add these bullets after the existing "Displayed data" list:

```markdown
- Now loads attendance across **all** of the student's semesters (`AttendanceService` keeps only semesters that have attendance records); a semester `<select>` (`#semester-filter`) filters cards, detail, and the hero client-side, defaulting to the current semester (plus an "All semesters" option).
- The "By course" cards are clickable; clicking one repaints the detail panel client-side from `window.attendanceData`. The hero recomputes to match the selected semester.
- The detail panel, empty-courses, empty-sessions, and empty-detail regions are plain `id`'d HTML (`#detail-panel`, `#empty-courses`, `#empty-sessions`, `#empty-detail`) toggled by JS — they are no longer `asp:PlaceHolder` controls.
```

- [ ] **Step 2: Update the `student/attendance.aspx.cs` section**

In the `### student/attendance.aspx.cs` section, add to the helper-members description:

```markdown
- Hero counts are scoped to the current-semester subset for the initial render; `SemesterOptionsHtml` builds the dropdown options; `AttendancePayloadJson` serializes per-course data (counts + pre-formatted sessions) to `window.attendanceData` via `JavaScriptSerializer`. The default selected course is the first current-semester course.
```

- [ ] **Step 3: Add a `js/attendance/attendance.js` subsection**

Add a new subsection under the JavaScript area (e.g. after the timetable JS section or near the other student-page JS docs):

```markdown
### `js/attendance/attendance.js`

Client interactivity for `student/attendance.aspx`.

Responsibilities:

- Reads `window.attendanceData` (per-course counts + pre-formatted sessions).
- Semester filter (`#semester-filter`): shows/hides cards by `data-semester-id`, recomputes the hero (present/late/absent/rate/subtext) from visible courses, and toggles `#empty-courses` / `#detail-panel` / `#empty-detail`.
- Card click (`[data-offering]`): repaints the detail header (`#detail-accent`, `#detail-code`, `#detail-name`, `#detail-lecturer`), KPI strip (`#detail-present`, `#detail-late`, `#detail-absent`), sessions `<tbody>` (`#sessions-body`), footer (`#sessions-footer`), and toggles `#empty-sessions`.
- Re-runs `lucide.createIcons()` after injecting status-icon markup.
- Mirrors the server's card-class, status-badge/icon, and rate-format logic so client and server renders match.
```

- [ ] **Step 4: Update the `AttendanceService` section**

In the `### services/AttendanceService.cs` section, update the "Important behavior" bullets to note the multi-semester load:

```markdown
- `GetAttendancePage` loads the student's courses across **all** semesters (`e.status IN ('ENROLLED','COMPLETED')`), then drops any semester that has zero attendance records. `AttendanceCourse` carries `SemesterId`, `SemesterName`, and `IsCurrent`.
- `GetCurrentSemesterRate` still scopes to the current semester only (used by the dashboard).
```

- [ ] **Step 5: Note the `src.csproj` JS entry**

In the `### src.csproj` "Current project-file mismatch" area (or nearby), add:

```markdown
- `js\attendance\attendance.js` is included as `Content` (added with the attendance clickable-cards/semester-filter feature).
```

- [ ] **Step 6: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/doc/project-context.md"
git commit -m "docs(context): attendance multi-semester filter and clickable cards"
```

---

## Task 6: Manual verification

**Files:** none (manual run)

- [ ] **Step 1: Run the app and sign in**

Launch the site (IIS Express / Visual Studio, `https://localhost:44368/`) and log in as a seeded student who has current-semester attendance (e.g. the user mapped to `STUDENTS.student_id = 1`, who has CS101/CS201 attendance in `2026-S2`).

- [ ] **Step 2: Confirm the default view**

Navigate to `student/attendance.aspx`. Expected:
- The semester dropdown shows `2026-S2` selected (current), plus "All semesters". The empty future `2026-S3` is **not** listed.
- Only current-semester course cards are visible; the hero shows the current-semester totals/rate.
- The detail panel shows the first current-semester course's sessions; empty-state panels are hidden.

- [ ] **Step 3: Confirm clickable cards**

Click a different course card. Expected:
- The clicked card gets the selected (red ring) styling; the previous one reverts.
- The detail header, KPI strip, sessions table, and footer update to the clicked course, instantly, with no page reload.
- A course with no sessions shows the "No sessions recorded" message and an empty table.

- [ ] **Step 4: Confirm the semester filter and hero recompute**

Change the dropdown to "All semesters". Expected:
- All cards (all kept semesters) appear; the hero recomputes to the summed totals across visible courses; the first visible course's detail shows.
Change back to `2026-S2`. Expected:
- Cards narrow to the current semester and the hero returns to current-semester totals.

- [ ] **Step 5: Confirm the no-JS baseline (optional)**

With scripting disabled, the page still renders the current-semester hero and the first course's detail server-side (all cards visible, empty-state panels hidden). No errors.

- [ ] **Step 6: Final commit (only if verification needed tweaks)**

```powershell
git add -A "5026CMD Software Engineer/src/src/student" "5026CMD Software Engineer/src/src/js/attendance"
git commit -m "fix(attendance): manual-verification adjustments"
```

> Skip this commit if no changes were needed.

---

## Self-Review (completed)

- **Spec coverage:** clickable cards (Task 3 `data-offering` + Task 4 `selectCourse`); semester filter listing only semesters-with-attendance (Task 1 drop-empty + Task 2 `BuildSemesterOptions` + Task 4 `applyFilter`); hero matches selected semester (Task 4 recompute); all-semester load, no seed data (Task 1); progressive-enhancement initial render (Task 2 + Task 3); JS registered in `src.csproj` (Task 4); project-context updated (Task 5); manual verification incl. no-JS baseline (Task 6). All spec sections map to a task.
- **Placeholder scan:** none — every code/markup step contains full content.
- **Type consistency:** `AttendanceCourse.SemesterId/SemesterName/IsCurrent` (Task 1) are read by `BuildSemesterOptions`/`BuildPayloadJson`/hero (Task 2) and surfaced as `Eval("OfferingId")`/`Eval("SemesterId")` (Task 3) and `data-offering`/`data-semester-id` (Task 4). Payload field names (`offeringId`, `semesterId`, `code`, `name`, `lecturer`, `color`, `present`, `late`, `absent`, `total`, `sessions[].date/day/time/type/venue/status`, `defaultOfferingId`) defined in `BuildPayloadJson` (Task 2) match exactly the reads in `attendance.js` (Task 4). DOM ids set in markup (Task 3 — `#semester-filter`, `#hero-rate/present/late/absent`, `#hero-subtext`, `#detail-accent/code/name/lecturer/present/late/absent`, `#sessions-body`, `#sessions-footer`, `#empty-courses/sessions/detail`, `#detail-panel`) match every `getElementById`/`querySelector` in `attendance.js` (Task 4). Card-class strings and status-badge/icon maps are duplicated verbatim between `attendance.aspx.cs` (Task 2) and `attendance.js` (Task 4).
```
