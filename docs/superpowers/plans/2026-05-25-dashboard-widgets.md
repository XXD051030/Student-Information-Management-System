# Dashboard Widgets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the five dashboard widgets on `shared/dashboard.aspx` (Today's Schedule, My Courses, Pending Tasks, Upcoming Assignments, Announcements) to real data from the database.

**Architecture:** Add three read-only data accessors following the existing service house style (parameterized SQL, `Db.OpenConnection()`, empty list / zero on no rows). Surface them as new `Student` properties populated in `StudentService.MapStudent`. In the markup, replace hardcoded `<li>` blocks with `<asp:Repeater>` controls bound in `Page_Load`, formatted by protected helper methods on the page (matching the existing `coursesRepeater` pattern).

**Tech Stack:** ASP.NET WebForms (C#, .NET Framework), `System.Data.SqlClient`, SQL Server LocalDB, Tailwind-style utility CSS in markup.

---

## Conventions for this codebase

There is **no unit-test project**. Per project convention, data accessors are verified by running their SQL against the live LocalDB, then confirming the build, then loading the page. Each task's "verify" steps reflect that.

**Build command** (PowerShell — Git Bash mangles the `/t:` `/p:` switches):

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

**SQL check command** (PowerShell — sqlcmd is not on PATH):

```powershell
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "<query>"
```

**Test login:** `user_id = 1` (Ong Zhi Bo) has 4 current-semester enrolments, 2 announcements, and 3 pending tasks — used as the expected-output baseline below.

All commands run from the project directory `5026CMD Software Engineer/src/src`.

---

## File Structure

- `services/EnrolmentService.cs` — **modify**: add `GetCurrentCourses`.
- `services/AssignmentService.cs` — **modify**: add `GetPendingTaskCount`.
- `services/AnnouncementService.cs` — **create**: `Announcement` model + `AnnouncementService`.
- `services/StudentService.cs` — **modify**: add `CurrentCourses`, `PendingTaskCount`, `Announcements` to the `Student` model and populate them in `MapStudent`.
- `src.csproj` — **modify**: register the new `AnnouncementService.cs`.
- `shared/dashboard.aspx` — **modify**: replace hardcoded schedule / assignments / announcements markup with repeaters; rebind courses; bind pending count.
- `shared/dashboard.aspx.cs` — **modify**: add binding in `Page_Load` and the formatting helper methods.
- `shared/dashboard.aspx.designer.cs` — **modify**: add the three new repeater fields.

---

## Task 1: Current-semester courses (My Courses)

**Files:**
- Modify: `services/EnrolmentService.cs`
- Modify: `services/StudentService.cs`
- Modify: `shared/dashboard.aspx.cs:62`

- [ ] **Step 1: Verify the query returns the expected current-semester courses**

Run:

```powershell
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT c.course_code FROM STUDENTS s JOIN ENROLMENTS e ON e.student_id=s.student_id JOIN COURSE_OFFERINGS o ON e.offering_id=o.offering_id JOIN COURSES c ON o.course_id=c.course_id JOIN SEMESTERS sem ON o.semester_id=sem.semester_id WHERE s.user_id=1 AND sem.is_current=1 AND e.status='ENROLLED' ORDER BY c.course_code;"
```

Expected: 4 rows — `BA101`, `CS101`, `CS201`, `IT102`.

- [ ] **Step 2: Add `GetCurrentCourses` to `EnrolmentService`**

In `services/EnrolmentService.cs`, add this method to the `EnrolmentService` class, immediately after the existing `GetCourses` method (it reuses the same `MapEnrolledCourse` shape inline, scoped to the current semester and active enrolment):

```csharp
        // Current-semester enrolled courses only, for the dashboard "My Courses"
        // widget. Same projection as GetCourses, filtered to is_current + ENROLLED.
        private const string SelectCurrentCourses =
            "SELECT e.offering_id, c.course_code, c.course_name, c.credit_hours, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, sem.name AS semester_name, e.status " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "OUTER APPLY (" +
            "SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' " +
            "ORDER BY c.course_code";

        public static List<EnrolledCourse> GetCurrentCourses(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectCurrentCourses, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var courses = new List<EnrolledCourse>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        courses.Add(new EnrolledCourse
                        {
                            OfferingId = (int)reader["offering_id"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            LecturerName = reader["lecturer_name"].ToString(),
                            SemesterName = reader["semester_name"].ToString(),
                            Status = reader["status"].ToString()
                        });
                    }
                }
                return courses;
            }
        }
```

- [ ] **Step 3: Add the `CurrentCourses` property and populate it**

In `services/StudentService.cs`, add this property to the `Student` class, immediately after the existing `Courses` property (around line 41):

```csharp
        /// <summary>Courses the student is enrolled in for the current semester only.</summary>
        public List<EnrolledCourse> CurrentCourses { get; set; }
```

Then in `MapStudent`, add the population line after `Courses = EnrolmentService.GetCourses(userId)` (turn the existing line's trailing context into a comma-separated continuation):

```csharp
                Courses = EnrolmentService.GetCourses(userId),
                CurrentCourses = EnrolmentService.GetCurrentCourses(userId)
```

- [ ] **Step 4: Rebind the courses repeater to the current semester**

In `shared/dashboard.aspx.cs`, in `Page_Load`, change the bind line (currently line 62):

```csharp
                coursesRepeater.DataSource = _student.Courses;
```

to:

```csharp
                coursesRepeater.DataSource = _student.CurrentCourses;
```

- [ ] **Step 5: Build**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

Expected: `Build succeeded.` with 0 errors.

- [ ] **Step 6: Commit**

```powershell
git add "services/EnrolmentService.cs" "services/StudentService.cs" "shared/dashboard.aspx.cs"
git commit -m "feat(dashboard): scope My Courses to the current semester"
```

---

## Task 2: Pending Tasks count

**Files:**
- Modify: `services/AssignmentService.cs`
- Modify: `services/StudentService.cs`
- Modify: `shared/dashboard.aspx.cs`
- Modify: `shared/dashboard.aspx:72`

- [ ] **Step 1: Verify the pending-count query**

Run:

```powershell
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT COUNT(*) AS pending FROM ASSIGNMENTS a JOIN COURSE_OFFERINGS o ON a.offering_id=o.offering_id JOIN SEMESTERS sem ON o.semester_id=sem.semester_id JOIN ENROLMENTS e ON e.offering_id=o.offering_id JOIN STUDENTS s ON e.student_id=s.student_id WHERE s.user_id=1 AND sem.is_current=1 AND e.status='ENROLLED' AND NOT EXISTS (SELECT 1 FROM SUBMISSIONS sub WHERE sub.assignment_id=a.assignment_id AND sub.student_id=s.student_id);"
```

Expected: `pending = 3`.

- [ ] **Step 2: Add `GetPendingTaskCount` to `AssignmentService`**

In `services/AssignmentService.cs`, add this method to the `AssignmentService` class, after `GetDueThisWeek`:

```csharp
        /// <summary>
        /// Count of current-semester assignments on the student's enrolled courses
        /// that the student has not yet submitted.
        /// </summary>
        public static int GetPendingTaskCount(int userId)
        {
            const string sql =
                "SELECT COUNT(*) " +
                "FROM ASSIGNMENTS a " +
                "JOIN COURSE_OFFERINGS o ON a.offering_id = o.offering_id " +
                "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
                "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
                "JOIN STUDENTS s ON e.student_id = s.student_id " +
                "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' " +
                "AND NOT EXISTS (SELECT 1 FROM SUBMISSIONS sub " +
                "WHERE sub.assignment_id = a.assignment_id AND sub.student_id = s.student_id)";

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                return (int)cmd.ExecuteScalar();
            }
        }
```

- [ ] **Step 3: Add the `PendingTaskCount` property and populate it**

In `services/StudentService.cs`, add to the `Student` class (after the `AssignmentsDueThisWeek` property, around line 29):

```csharp
        /// <summary>Current-semester assignments the student has not yet submitted.</summary>
        public int PendingTaskCount { get; set; }
```

Then in `MapStudent`, add to the object initializer after `AssignmentsDueThisWeek = AssignmentService.GetDueThisWeek(userId),`:

```csharp
                PendingTaskCount = AssignmentService.GetPendingTaskCount(userId),
```

- [ ] **Step 4: Expose the value on the page**

In `shared/dashboard.aspx.cs`, add this property after `AssignmentDueCount` (around line 99):

```csharp
        protected int PendingTaskCount
        {
            // Current-semester assignments the student has not yet submitted.
            get { return _student != null ? _student.PendingTaskCount : 0; }
        }
```

- [ ] **Step 5: Bind the Pending Tasks card**

In `shared/dashboard.aspx`, replace the hardcoded value (line 72):

```aspx
                    <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">3</p>
```

with:

```aspx
                    <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= PendingTaskCount %></p>
```

- [ ] **Step 6: Build**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

Expected: `Build succeeded.` with 0 errors.

- [ ] **Step 7: Commit**

```powershell
git add "services/AssignmentService.cs" "services/StudentService.cs" "shared/dashboard.aspx.cs" "shared/dashboard.aspx"
git commit -m "feat(dashboard): bind Pending Tasks to unsubmitted assignment count"
```

---

## Task 3: Announcements data layer

**Files:**
- Create: `services/AnnouncementService.cs`
- Modify: `src.csproj`
- Modify: `services/StudentService.cs`

- [ ] **Step 1: Verify the announcements query**

Run:

```powershell
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT DISTINCT TOP 5 an.announcement_id, an.title FROM ANNOUNCEMENTS an JOIN ANNOUNCEMENT_TARGETS at ON at.announcement_id=an.announcement_id JOIN COURSE_OFFERINGS o ON at.offering_id=o.offering_id JOIN SEMESTERS sem ON o.semester_id=sem.semester_id JOIN ENROLMENTS e ON e.offering_id=o.offering_id JOIN STUDENTS s ON e.student_id=s.student_id WHERE s.user_id=1 AND sem.is_current=1 AND e.status='ENROLLED' ORDER BY an.announcement_id DESC;"
```

Expected: 2 rows — `Campus Maintenance Notice`, `Assignment 1 Released`.

- [ ] **Step 2: Create `services/AnnouncementService.cs`**

```csharp
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// One announcement shown to a student.
    /// </summary>
    public class Announcement
    {
        public int AnnouncementId { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    /// <summary>
    /// Read-only access to announcements targeting a student's current-semester
    /// enrolled course offerings. Returns an empty list when there are none. SQL
    /// exceptions are not caught here; they propagate to the caller.
    /// </summary>
    public static class AnnouncementService
    {
        // DISTINCT guards against an announcement targeting several of the
        // student's offerings producing duplicate rows. TOP 5 keeps the
        // dashboard widget concise; newest first.
        private const string SelectAnnouncements =
            "SELECT DISTINCT TOP 5 an.announcement_id, an.title, " +
            "CAST(an.content AS varchar(max)) AS content, an.created_at " +
            "FROM ANNOUNCEMENTS an " +
            "JOIN ANNOUNCEMENT_TARGETS at ON at.announcement_id = an.announcement_id " +
            "JOIN COURSE_OFFERINGS o ON at.offering_id = o.offering_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id " +
            "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' " +
            "ORDER BY an.created_at DESC";

        public static List<Announcement> GetForStudent(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectAnnouncements, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var announcements = new List<Announcement>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        announcements.Add(new Announcement
                        {
                            AnnouncementId = (int)reader["announcement_id"],
                            Title = reader["title"].ToString(),
                            Content = reader["content"].ToString(),
                            CreatedAt = (DateTime)reader["created_at"]
                        });
                    }
                }
                return announcements;
            }
        }
    }
}
```

Note: `content` is a SQL `text` column; `DISTINCT` cannot be applied to `text`, so it is cast to `varchar(max)`.

- [ ] **Step 3: Register the new file in the project**

In `src.csproj`, add this line to the `<ItemGroup>` of `<Compile>` entries, immediately after the `AssignmentService.cs` line (keeping alphabetical order):

```xml
    <Compile Include="services\AnnouncementService.cs" />
```

The surrounding context becomes:

```xml
    <Compile Include="db\Db.cs" />
    <Compile Include="services\AnnouncementService.cs" />
    <Compile Include="services\AssignmentService.cs" />
```

- [ ] **Step 4: Add the `Announcements` property and populate it**

In `services/StudentService.cs`, add to the `Student` class (after the `CurrentCourses` property added in Task 1):

```csharp
        /// <summary>Recent announcements targeting the student's current courses.</summary>
        public List<Announcement> Announcements { get; set; }
```

Then in `MapStudent`, add to the object initializer after the `CurrentCourses = ...` line:

```csharp
                Announcements = AnnouncementService.GetForStudent(userId)
```

(Ensure the line before it ends with a comma and this final line does not.)

- [ ] **Step 5: Build**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

Expected: `Build succeeded.` with 0 errors.

- [ ] **Step 6: Commit**

```powershell
git add "services/AnnouncementService.cs" "src.csproj" "services/StudentService.cs"
git commit -m "feat(services): add AnnouncementService for a student's current courses"
```

---

## Task 4: Today's Schedule widget

**Files:**
- Modify: `shared/dashboard.aspx.designer.cs`
- Modify: `shared/dashboard.aspx.cs`
- Modify: `shared/dashboard.aspx:86-168`

- [ ] **Step 1: Add the repeater field to the designer**

In `shared/dashboard.aspx.designer.cs`, add inside the `dashboard` class, after the `coursesRepeater` field:

```csharp
        /// <summary>scheduleRepeater control.</summary>
        protected global::System.Web.UI.WebControls.Repeater scheduleRepeater;
```

- [ ] **Step 2: Add the schedule helper methods**

In `shared/dashboard.aspx.cs`, add these members to the `dashboard` class (place them after the `CreditsEarnedValue` property, before the closing brace):

```csharp
        private static readonly string[] ClassAccentPalette =
            { "#e0162b", "#3b82f6", "#f59e0b", "#10b981" };

        protected string ClassAccentColor(int index)
        {
            return ClassAccentPalette[index % ClassAccentPalette.Length];
        }

        protected string FormatTimeRange(TimeSpan start, TimeSpan end)
        {
            // en dash (–) between the two HH:mm times, matching the markup.
            return start.ToString(@"hh\:mm") + " – " + end.ToString(@"hh\:mm");
        }

        protected bool IsLiveNow(TimeSpan start, TimeSpan end)
        {
            TimeSpan now = DateTime.Now.TimeOfDay;
            return now >= start && now < end;
        }

        protected string TodayScheduleSubtitle
        {
            // e.g. "4 classes · 6h 30m total", or a friendly note when empty.
            get
            {
                if (_student == null || _student.TodayClasses == null || _student.TodayClasses.Count == 0)
                {
                    return "No classes today";
                }

                int count = _student.TodayClasses.Count;
                TimeSpan total = TimeSpan.Zero;
                foreach (var session in _student.TodayClasses)
                {
                    total += session.EndTime - session.StartTime;
                }

                string duration = (int)total.TotalHours + "h " + total.Minutes + "m";
                return count + (count == 1 ? " class" : " classes") + " · " + duration + " total";
            }
        }
```

- [ ] **Step 3: Bind the repeater in `Page_Load`**

In `shared/dashboard.aspx.cs`, inside the `if (_student != null)` block in `Page_Load`, add after the existing `coursesRepeater.DataBind();`:

```csharp
                scheduleRepeater.DataSource = _student.TodayClasses;
                scheduleRepeater.DataBind();
```

- [ ] **Step 4: Replace the Today's Schedule markup**

In `shared/dashboard.aspx`, replace the entire Today's Schedule block (the `<div class="lg:col-span-2 rounded-2xl border border-slate-200 bg-white">` starting at line 87 through its closing `</div>` at line 168) with:

```aspx
        <%-- Today's Schedule --%>
        <div class="lg:col-span-2 rounded-2xl border border-slate-200 bg-white">
            <header class="flex items-center justify-between p-6 pb-4">
                <div>
                    <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Today's Schedule</h2>
                    <p class="text-slate-500 mt-0.5" style="font-size:13px"><%= TodayScheduleSubtitle %></p>
                </div>
                <a href="#" class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors" style="font-size:13px;font-weight:600">
                    Full week <i data-lucide="arrow-up-right" class="h-3.5 w-3.5"></i>
                </a>
            </header>
            <asp:Repeater ID="scheduleRepeater" runat="server">
                <HeaderTemplate><ul class="divide-y divide-slate-100"></HeaderTemplate>
                <ItemTemplate>
                    <li class="flex items-center gap-4 px-6 py-4 hover:bg-slate-50/60 transition-colors">
                        <div class="w-1.5 h-12 rounded-full" style="background-color:<%# ClassAccentColor(Container.ItemIndex) %>"></div>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="text-slate-900 truncate" style="font-size:14px;font-weight:600"><%# Server.HtmlEncode(Eval("CourseName").ToString()) %></span>
                                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode(Eval("CourseCode").ToString()) %></span>
                                <asp:Literal runat="server" Visible='<%# IsLiveNow((TimeSpan)Eval("StartTime"), (TimeSpan)Eval("EndTime")) %>'
                                    Text='<span class="inline-flex items-center gap-1 rounded-md bg-[#e0162b]/10 px-1.5 py-0.5 text-[#a01020]" style="font-size:10.5px;font-weight:600"><span class="h-1.5 w-1.5 rounded-full bg-[#e0162b] animate-pulse"></span>LIVE</span>' />
                            </div>
                            <div class="mt-1 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:12.5px">
                                <span class="inline-flex items-center gap-1"><i data-lucide="clock" class="h-3.5 w-3.5"></i><%# FormatTimeRange((TimeSpan)Eval("StartTime"), (TimeSpan)Eval("EndTime")) %></span>
                                <span class="inline-flex items-center gap-1"><i data-lucide="map-pin" class="h-3.5 w-3.5"></i><%# Server.HtmlEncode(Eval("Venue").ToString()) %></span>
                            </div>
                        </div>
                        <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300"></i>
                    </li>
                </ItemTemplate>
                <FooterTemplate></ul></FooterTemplate>
            </asp:Repeater>
            <% if (TodayClassCount == 0) { %>
                <p class="px-6 py-8 text-center text-slate-400" style="font-size:13px">No classes scheduled today.</p>
            <% } %>
        </div>
```

Note: the `LIVE` badge uses an `<asp:Literal>` whose `Visible` is bound to `IsLiveNow`; when false the literal renders nothing. The empty-state paragraph renders only when `TodayClassCount == 0` — an empty repeater renders nothing of its own.

- [ ] **Step 5: Build**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

Expected: `Build succeeded.` with 0 errors.

- [ ] **Step 6: Manual verification**

Run the site (IIS Express / Visual Studio), log in as the seeded student, and open `shared/dashboard.aspx`. Confirm Today's Schedule lists the student's classes for the current weekday with correct times and venues, that a class currently in progress shows the LIVE badge, and that the subtitle reads "N classes · Xh Ym total". If today has no classes, confirm "No classes scheduled today." appears.

- [ ] **Step 7: Commit**

```powershell
git add "shared/dashboard.aspx" "shared/dashboard.aspx.cs" "shared/dashboard.aspx.designer.cs"
git commit -m "feat(dashboard): bind Today's Schedule to the student's timetable"
```

---

## Task 5: Upcoming Assignments widget

**Files:**
- Modify: `shared/dashboard.aspx.designer.cs`
- Modify: `shared/dashboard.aspx.cs`
- Modify: `shared/dashboard.aspx:170-225`

- [ ] **Step 1: Add the repeater field to the designer**

In `shared/dashboard.aspx.designer.cs`, add after `scheduleRepeater`:

```csharp
        /// <summary>assignmentsRepeater control.</summary>
        protected global::System.Web.UI.WebControls.Repeater assignmentsRepeater;
```

- [ ] **Step 2: Add the assignment helper methods**

In `shared/dashboard.aspx.cs`, add these members to the `dashboard` class (after the schedule helpers from Task 4):

```csharp
        protected string FormatRelativeDue(DateTime due)
        {
            int days = (due.Date - DateTime.Today).Days;
            if (days < 0) return "Overdue";
            if (days == 0) return "Due today";
            if (days == 1) return "Tomorrow";
            return "In " + days + " days";
        }

        protected string DueIcon(DateTime due)
        {
            int days = (due.Date - DateTime.Today).Days;
            return days <= 1 ? "alert-circle" : "check-circle-2";
        }

        protected string DueBadgeClass(DateTime due)
        {
            int days = (due.Date - DateTime.Today).Days;
            if (days <= 1) return "bg-[#e0162b]/10 text-[#e0162b]";
            if (days <= 3) return "bg-amber-50 text-amber-600";
            return "bg-emerald-50 text-emerald-600";
        }

        protected string DueTextClass(DateTime due)
        {
            int days = (due.Date - DateTime.Today).Days;
            return days <= 1 ? "text-[#e0162b] font-semibold" : "text-slate-500";
        }
```

- [ ] **Step 3: Bind the repeater in `Page_Load`**

In `shared/dashboard.aspx.cs`, inside the `if (_student != null)` block in `Page_Load`, add after the `scheduleRepeater.DataBind();` lines from Task 4:

```csharp
                assignmentsRepeater.DataSource = _student.AssignmentsDueThisWeek;
                assignmentsRepeater.DataBind();
```

- [ ] **Step 4: Replace the Upcoming Assignments markup**

In `shared/dashboard.aspx`, replace the entire Upcoming Assignments block (the `<div class="rounded-2xl border border-slate-200 bg-white">` starting at line 171 through its closing `</div>` at line 225) with:

```aspx
        <%-- Upcoming Assignments --%>
        <div class="rounded-2xl border border-slate-200 bg-white">
            <header class="flex items-center justify-between p-6 pb-4">
                <div>
                    <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Upcoming Assignments</h2>
                    <p class="text-slate-500 mt-0.5" style="font-size:13px"><%= AssignmentDueCount %> due this week</p>
                </div>
            </header>
            <asp:Repeater ID="assignmentsRepeater" runat="server">
                <HeaderTemplate><ul class="space-y-2 px-3 pb-4"></HeaderTemplate>
                <ItemTemplate>
                    <li class="flex items-start gap-3 rounded-xl px-3 py-3 hover:bg-slate-50 transition-colors">
                        <span class='mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg <%# DueBadgeClass((DateTime)Eval("DueDate")) %>'>
                            <i data-lucide='<%# DueIcon((DateTime)Eval("DueDate")) %>' class="h-4 w-4"></i>
                        </span>
                        <div class="min-w-0 flex-1">
                            <p class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600"><%# Server.HtmlEncode(Eval("Title").ToString()) %></p>
                            <p class="mt-0.5" style="font-size:12px">
                                <span class="text-slate-500"><%# Server.HtmlEncode(Eval("CourseCode").ToString()) %></span>
                                <span class="text-slate-400"> &middot; </span>
                                <span class='<%# DueTextClass((DateTime)Eval("DueDate")) %>'><%# FormatRelativeDue((DateTime)Eval("DueDate")) %></span>
                            </p>
                        </div>
                    </li>
                </ItemTemplate>
                <FooterTemplate></ul></FooterTemplate>
            </asp:Repeater>
            <% if (AssignmentDueCount == 0) { %>
                <p class="px-6 py-8 text-center text-slate-400" style="font-size:13px">Nothing due this week.</p>
            <% } %>
            <div class="border-t border-slate-100 p-3">
                <button class="w-full rounded-xl py-2.5 text-slate-700 hover:bg-slate-50 transition-colors" style="font-size:13px;font-weight:600">
                    View all assignments
                </button>
            </div>
        </div>
```

- [ ] **Step 5: Build**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

Expected: `Build succeeded.` with 0 errors.

- [ ] **Step 6: Manual verification**

Reload `shared/dashboard.aspx` as the seeded student. Confirm Upcoming Assignments lists assignments due within 7 days with title, course code, and a relative due label ("Tomorrow", "In 3 days", etc.), that near-due items show the red alert icon and red due text, and that the header count matches. If nothing is due, confirm "Nothing due this week." appears.

- [ ] **Step 7: Commit**

```powershell
git add "shared/dashboard.aspx" "shared/dashboard.aspx.cs" "shared/dashboard.aspx.designer.cs"
git commit -m "feat(dashboard): bind Upcoming Assignments to assignments due this week"
```

---

## Task 6: Announcements widget

**Files:**
- Modify: `shared/dashboard.aspx.designer.cs`
- Modify: `shared/dashboard.aspx.cs`
- Modify: `shared/dashboard.aspx:261-304`

- [ ] **Step 1: Add the repeater field to the designer**

In `shared/dashboard.aspx.designer.cs`, add after `assignmentsRepeater`:

```csharp
        /// <summary>announcementsRepeater control.</summary>
        protected global::System.Web.UI.WebControls.Repeater announcementsRepeater;
```

- [ ] **Step 2: Add the relative-time helper and announcement count property**

In `shared/dashboard.aspx.cs`, add to the `dashboard` class (after the assignment helpers from Task 5):

```csharp
        protected int AnnouncementCount
        {
            get { return _student != null && _student.Announcements != null ? _student.Announcements.Count : 0; }
        }

        protected string FormatRelativeTime(DateTime when)
        {
            TimeSpan ago = DateTime.Now - when;
            if (ago.TotalMinutes < 1) return "Just now";
            if (ago.TotalMinutes < 60) return (int)ago.TotalMinutes + "m ago";
            if (ago.TotalHours < 24) return (int)ago.TotalHours + "h ago";

            int days = (int)ago.TotalDays;
            if (days == 1) return "Yesterday";
            if (days < 7) return days + " days ago";
            return when.ToString("d MMM yyyy", System.Globalization.CultureInfo.InvariantCulture);
        }
```

- [ ] **Step 3: Bind the repeater in `Page_Load`**

In `shared/dashboard.aspx.cs`, inside the `if (_student != null)` block in `Page_Load`, add after the `assignmentsRepeater.DataBind();` lines from Task 5:

```csharp
                announcementsRepeater.DataSource = _student.Announcements;
                announcementsRepeater.DataBind();
```

- [ ] **Step 4: Replace the Announcements markup**

In `shared/dashboard.aspx`, replace the entire Announcements block (the `<div class="rounded-2xl border border-slate-200 bg-white p-6">` starting at line 262 through its closing `</div>` at line 304) with:

```aspx
        <%-- Announcements --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-6">
            <header class="flex items-center justify-between mb-4">
                <div class="flex items-center gap-2">
                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-[#e0162b]/10 text-[#e0162b]">
                        <i data-lucide="megaphone" class="h-4 w-4"></i>
                    </span>
                    <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Announcements</h2>
                </div>
            </header>
            <asp:Repeater ID="announcementsRepeater" runat="server">
                <HeaderTemplate><ul class="space-y-4"></HeaderTemplate>
                <ItemTemplate>
                    <li class="border-b border-slate-100 pb-4 last:border-b-0 last:pb-0">
                        <div class="flex items-center gap-2">
                            <span class="text-slate-400" style="font-size:11.5px"><%# Server.HtmlEncode(FormatRelativeTime((DateTime)Eval("CreatedAt"))) %></span>
                        </div>
                        <p class="mt-2 text-slate-900" style="font-size:13.5px;font-weight:600;line-height:1.45"><%# Server.HtmlEncode(Eval("Title").ToString()) %></p>
                        <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55"><%# Server.HtmlEncode(Eval("Content").ToString()) %></p>
                    </li>
                </ItemTemplate>
                <FooterTemplate></ul></FooterTemplate>
            </asp:Repeater>
            <% if (AnnouncementCount == 0) { %>
                <p class="py-8 text-center text-slate-400" style="font-size:13px">No announcements.</p>
            <% } %>
        </div>
```

- [ ] **Step 5: Build**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

Expected: `Build succeeded.` with 0 errors.

- [ ] **Step 6: Manual verification**

Reload `shared/dashboard.aspx` as the seeded student (`user_id = 1`). Confirm Announcements shows the two seeded items ("Campus Maintenance Notice", "Assignment 1 Released") newest first, each with title, a two-line content preview, and a relative timestamp. Confirm no category tag appears. For a student with no targeted announcements, confirm "No announcements." appears.

- [ ] **Step 7: Commit**

```powershell
git add "shared/dashboard.aspx" "shared/dashboard.aspx.cs" "shared/dashboard.aspx.designer.cs"
git commit -m "feat(dashboard): bind Announcements to the student's current courses"
```

---

## Final verification

- [ ] **Full build is clean**

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

Expected: `Build succeeded.` with 0 errors, 0 new warnings.

- [ ] **Whole-page smoke test**

Load `shared/dashboard.aspx` as `user_id = 1` and confirm all five widgets show real data simultaneously: 4 current courses, pending-task count of 3, 2 announcements, plus the day's schedule and any assignments due this week. Then confirm the welcome-banner counts ("N classes today", "N assignments due this week") still match the widgets.
