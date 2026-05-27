# DB-driven My Courses page — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `student/courses.aspx` show only the logged-in student's enrolled courses from the database, with a two-button semester filter (Current / All), search, and pinning.

**Architecture:** Reuse `EnrolmentService.GetCourses(userId)` (all enrolled courses, all semesters) as the single data source. An `<asp:Repeater>` renders the cards server-side; a new `js/courses/courses.js` does client-side semester toggle, search, pin, and empty-state. The "current semester" set is derived by comparing each course's semester name to `SemesterService.GetCurrent().Name` and stamping each card with `data-current`.

**Tech Stack:** ASP.NET WebForms (C#, .NET Framework), SQL Server (LocalDB), Tailwind Play CDN, vanilla JS, Lucide icons.

**Verification note:** No unit-test harness exists in this project. Each task is verified by a successful `msbuild` compile and/or a described manual check, per project conventions. Build command (PowerShell — Git Bash mangles msbuild switches):

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src\src.csproj" /t:Build /p:Configuration=Debug /v:minimal
```

(If the MSBuild path differs, locate it with `& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -find MSBuild\**\Bin\MSBuild.exe`.)

---

## File Structure

- **Modify** `services/EnrolmentService.cs` — add `Color` to `EnrolledCourse`; select/map `c.color` in `GetCourses`.
- **Modify** `student/courses.aspx.cs` — auth guard, load courses + current semester, bind repeater, expose helper methods.
- **Modify** `student/courses.aspx.designer.cs` — declare the `coursesRepeater` control.
- **Modify** `student/courses.aspx` — replace hardcoded cards with a repeater; reduce filter buttons to two; server-render the enrolled total.
- **Create** `js/courses/courses.js` — semester toggle, search, pin, empty-state.
- **Modify** `src.csproj` — register the new `.js` file as Content (match how other js files are listed).

---

## Task 1: Add `Color` to the enrolment data layer

**Files:**
- Modify: `services/EnrolmentService.cs`

- [ ] **Step 1: Add the `Color` property to `EnrolledCourse`**

In `services/EnrolmentService.cs`, add the property after `Status`:

```csharp
    public class EnrolledCourse
    {
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string LecturerName { get; set; }
        public string SemesterName { get; set; }
        public string Status { get; set; }
        public string Color { get; set; }
    }
```

- [ ] **Step 2: Select `c.color` in the `GetCourses` query**

Change the `SelectCourses` constant's SELECT list to add `c.color`:

```csharp
        private const string SelectCourses =
            "SELECT e.offering_id, c.course_code, c.course_name, c.credit_hours, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, sem.name AS semester_name, e.status, c.color " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "OUTER APPLY (" +
            "SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE s.user_id = @userId " +
            "ORDER BY sem.name, c.course_code";
```

- [ ] **Step 3: Map `color` in the `GetCourses` reader loop**

In `GetCourses`, add the `Color` assignment inside the `new EnrolledCourse { ... }`:

```csharp
                        courses.Add(new EnrolledCourse
                        {
                            OfferingId = (int)reader["offering_id"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            LecturerName = reader["lecturer_name"].ToString(),
                            SemesterName = reader["semester_name"].ToString(),
                            Status = reader["status"].ToString(),
                            Color = reader["color"] == System.DBNull.Value ? "" : reader["color"].ToString()
                        });
```

> Leave `GetCurrentCourses` unchanged. The dashboard binds it and does not read `Color`, so adding the column there is unnecessary (YAGNI).

- [ ] **Step 4: Build to verify it compiles**

Run the build command from the header.
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 5: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/services/EnrolmentService.cs"
git commit -m "feat(services): expose course color on EnrolledCourse"
```

---

## Task 2: Declare the repeater control in the designer file

**Files:**
- Modify: `student/courses.aspx.designer.cs`

- [ ] **Step 1: Add the `coursesRepeater` field**

Replace the body of the partial class in `student/courses.aspx.designer.cs`:

```csharp
namespace src.student
{


    public partial class courses
    {

        /// <summary>
        /// coursesRepeater control.
        /// </summary>
        /// <remarks>
        /// Auto-generated field.
        /// To modify move field declaration from designer file to code-behind file.
        /// </remarks>
        protected global::System.Web.UI.WebControls.Repeater coursesRepeater;
    }
}
```

- [ ] **Step 2: Commit** (compiles only after Task 4 wires up the markup/code-behind; commit anyway as a small, coherent change)

```powershell
git add "5026CMD Software Engineer/src/src/student/courses.aspx.designer.cs"
git commit -m "chore(courses): declare coursesRepeater control"
```

---

## Task 3: Code-behind — auth guard, data load, helpers

**Files:**
- Modify: `student/courses.aspx.cs`

- [ ] **Step 1: Replace the file contents**

Replace the whole of `student/courses.aspx.cs` with:

```csharp
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class courses : System.Web.UI.Page
    {
        private List<EnrolledCourse> _courses;
        private string _currentSemesterName;

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

            int userId = (int)Session["user_id"];
            _courses = EnrolmentService.GetCourses(userId);

            var current = SemesterService.GetCurrent();
            _currentSemesterName = current != null ? current.Name : null;

            coursesRepeater.DataSource = _courses;
            coursesRepeater.DataBind();
        }

        /// <summary>Total number of courses the student is enrolled in (all semesters).</summary>
        protected int EnrolledCount
        {
            get { return _courses != null ? _courses.Count : 0; }
        }

        /// <summary>True when the given semester name matches the current semester.</summary>
        protected bool IsCurrent(string semesterName)
        {
            return _currentSemesterName != null
                && string.Equals(semesterName, _currentSemesterName, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>Course accent color from the DB, or a neutral slate fallback when unset.</summary>
        protected string AccentColor(string color)
        {
            return string.IsNullOrEmpty(color) ? "#64748b" : color;
        }

        /// <summary>Lowercased "code name lecturer" string used by the client-side search filter.</summary>
        protected string SearchKey(string code, string name, string lecturer)
        {
            return ((code ?? "") + " " + (name ?? "") + " " + (lecturer ?? "")).ToLowerInvariant();
        }
    }
}
```

- [ ] **Step 2: Do not build yet** — the markup still references the old hardcoded cards but no longer matches; build verification happens after Task 4.

- [ ] **Step 3: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/student/courses.aspx.cs"
git commit -m "feat(courses): load enrolled courses and current semester in code-behind"
```

---

## Task 4: Markup — repeater, two filter buttons, dynamic total

**Files:**
- Modify: `student/courses.aspx`

- [ ] **Step 1: Replace the filter buttons (the `#semester-filters` block)**

Replace the `<div class="flex flex-wrap gap-2" id="semester-filters"> ... </div>` block (the seven buttons) with exactly two buttons:

```aspx
        <div class="flex flex-wrap gap-2" id="semester-filters">
            <button data-action="filter-semester" data-semester="current"
                class="rounded-full px-3.5 py-1.5 bg-slate-900 text-white transition-all"
                style="font-size:12.5px;font-weight:600">Current semester</button>
            <button data-action="filter-semester" data-semester="all"
                class="rounded-full px-3.5 py-1.5 border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:text-slate-900 transition-all"
                style="font-size:12.5px;font-weight:600">All semesters</button>
        </div>
```

> The search box `<div class="relative w-full lg:w-72"> ... </div>` immediately after this block stays exactly as-is (already on the right).

- [ ] **Step 2: Make the "Pinned X / Y" total dynamic**

In the header tile, replace the hardcoded total. Change:

```aspx
                    <span id="pinned-count">4</span><span class="text-slate-400"> / 18</span>
```

to:

```aspx
                    <span id="pinned-count">0</span><span class="text-slate-400"> / <%= EnrolledCount %></span>
```

- [ ] **Step 3: Replace the entire course grid with a repeater**

Replace the whole `<div class="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3" id="course-grid"> ... </div>` block (all 18 `<article>` cards) with:

```aspx
    <%-- Course grid --%>
    <div class="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3" id="course-grid">
        <asp:Repeater ID="coursesRepeater" runat="server">
            <ItemTemplate>
                <article data-course-code='<%# Server.HtmlEncode(Eval("CourseCode").ToString()) %>'
                    data-current='<%# IsCurrent(Eval("SemesterName").ToString()) ? "true" : "false" %>'
                    data-search='<%# Server.HtmlEncode(SearchKey(Eval("CourseCode").ToString(), Eval("CourseName").ToString(), Eval("LecturerName").ToString())) %>'
                    class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
                    <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style='background-color:<%# AccentColor(Eval("Color") as string) %>'></span>
                    <div class="flex items-start justify-between">
                        <div class="flex h-10 w-10 items-center justify-center rounded-xl" style='background-color:<%# AccentColor(Eval("Color") as string) %>15;color:<%# AccentColor(Eval("Color") as string) %>'>
                            <i data-lucide="book-open" class="h-4 w-4"></i>
                        </div>
                        <button type="button" data-action="toggle-pin" data-code='<%# Server.HtmlEncode(Eval("CourseCode").ToString()) %>' aria-label="Toggle pin"
                            class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                            <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                        </button>
                    </div>
                    <div class="mt-4 flex items-center gap-2">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode(Eval("CourseCode").ToString()) %></span>
                    </div>
                    <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3"><%# Server.HtmlEncode(Eval("CourseName").ToString()) %></h3>
                    <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                        <span><%# Server.HtmlEncode(Eval("LecturerName").ToString()) %></span>
                        <span><%# Eval("CreditHours") %> credits</span>
                    </div>
                    <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                        <span class="text-slate-500" style="font-size:11.5px;font-weight:500"><%# Server.HtmlEncode(Eval("SemesterName").ToString()) %></span>
                        <a href='<%# ResolveUrl("~/student/academic/course-detail.aspx?code=" + Server.UrlEncode(Eval("CourseCode").ToString())) %>'
                            class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                            style="font-size:12.5px;font-weight:600">
                            Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                        </a>
                    </div>
                </article>
            </ItemTemplate>
        </asp:Repeater>
    </div>
```

> The `#no-results` empty-state block and the `ScriptsPlaceholder` block below the grid stay unchanged.

- [ ] **Step 4: Build to verify markup + code-behind + designer compile together**

Run the build command from the header.
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 5: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/student/courses.aspx"
git commit -m "feat(courses): render enrolled courses from a repeater with two-semester filter"
```

---

## Task 5: Client-side interactivity (`courses.js`)

**Files:**
- Create: `js/courses/courses.js`
- Modify: `src.csproj`

- [ ] **Step 1: Create `js/courses/courses.js`**

```javascript
// My Courses page: semester toggle (current/all), search, pin, empty-state.
// Cards are rendered server-side; each <article> carries:
//   data-current="true|false"  – belongs to the current semester
//   data-search="..."          – lowercased code/name/lecturer for search
//   data-course-code="CODE"     – stable key for pinning
(function () {
    "use strict";

    var PIN_KEY = "courses.pinned";
    var state = { semester: "current", query: "" };

    function cards() {
        return Array.prototype.slice.call(document.querySelectorAll("#course-grid [data-course-code]"));
    }

    function loadPins() {
        try { return JSON.parse(localStorage.getItem(PIN_KEY)) || []; }
        catch (e) { return []; }
    }

    function savePins(pins) {
        localStorage.setItem(PIN_KEY, JSON.stringify(pins));
    }

    function isPinned(code) {
        return loadPins().indexOf(code) !== -1;
    }

    function applyFilters() {
        var q = state.query.trim().toLowerCase();
        var visible = 0;

        cards().forEach(function (card) {
            var matchesSemester = state.semester === "all" || card.getAttribute("data-current") === "true";
            var matchesQuery = q === "" || (card.getAttribute("data-search") || "").indexOf(q) !== -1;
            var show = matchesSemester && matchesQuery;
            card.style.display = show ? "" : "none";
            if (show) { visible++; }
        });

        var noResults = document.getElementById("no-results");
        if (noResults) { noResults.classList.toggle("hidden", visible !== 0); }
    }

    function updatePinnedCount() {
        var el = document.getElementById("pinned-count");
        if (el) { el.textContent = String(loadPins().length); }
    }

    function paintPin(card) {
        var code = card.getAttribute("data-course-code");
        var btn = card.querySelector('[data-action="toggle-pin"]');
        if (!btn) { return; }
        if (isPinned(code)) {
            btn.classList.add("text-[#e0162b]");
            btn.classList.remove("text-slate-400");
        } else {
            btn.classList.remove("text-[#e0162b]");
            btn.classList.add("text-slate-400");
        }
    }

    function togglePin(code) {
        var pins = loadPins();
        var i = pins.indexOf(code);
        if (i === -1) { pins.push(code); } else { pins.splice(i, 1); }
        savePins(pins);
    }

    function activateSemesterButton(clicked) {
        var buttons = document.querySelectorAll('[data-action="filter-semester"]');
        Array.prototype.forEach.call(buttons, function (b) {
            var active = b === clicked;
            b.classList.toggle("bg-slate-900", active);
            b.classList.toggle("text-white", active);
            b.classList.toggle("border", !active);
            b.classList.toggle("border-slate-200", !active);
            b.classList.toggle("bg-white", !active);
            b.classList.toggle("text-slate-600", !active);
        });
    }

    function init() {
        // Semester buttons
        Array.prototype.forEach.call(
            document.querySelectorAll('[data-action="filter-semester"]'),
            function (btn) {
                btn.addEventListener("click", function () {
                    state.semester = btn.getAttribute("data-semester") || "current";
                    activateSemesterButton(btn);
                    applyFilters();
                });
            }
        );

        // Search
        var search = document.getElementById("course-search");
        if (search) {
            search.addEventListener("input", function () {
                state.query = search.value || "";
                applyFilters();
            });
        }

        // Pin buttons
        cards().forEach(function (card) {
            paintPin(card);
            var btn = card.querySelector('[data-action="toggle-pin"]');
            if (btn) {
                btn.addEventListener("click", function () {
                    togglePin(card.getAttribute("data-course-code"));
                    paintPin(card);
                    updatePinnedCount();
                });
            }
        });

        updatePinnedCount();
        applyFilters();
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
```

- [ ] **Step 2: Register the file in `src.csproj`**

Find an existing JS `<Content Include="js\... .js" />` line (e.g. the account or login js) in `src.csproj` and add a sibling entry next to it:

```xml
    <Content Include="js\courses\courses.js" />
```

> Match the exact `<ItemGroup>` and backslash path style already used for `js\account\account.js`. If `js\courses\courses.js` is already auto-included, do not duplicate it.

- [ ] **Step 3: Build to verify the project still compiles**

Run the build command from the header.
Expected: `Build succeeded`, 0 errors. (A `.js` file does not affect compilation, but this confirms the `.csproj` edit is well-formed XML.)

- [ ] **Step 4: Commit**

```powershell
git add "5026CMD Software Engineer/src/src/js/courses/courses.js" "5026CMD Software Engineer/src/src/src.csproj"
git commit -m "feat(courses): add client-side semester toggle, search and pin"
```

---

## Task 6: Manual verification

**Files:** none (manual run)

- [ ] **Step 1: Run the app and sign in**

Launch the site (IIS Express / Visual Studio) and log in as a seeded student
(student with `user_id` matching `STUDENTS.student_id = 1`, who has enrolments
in the seed data).

- [ ] **Step 2: Confirm enrolled-only + current default**

Navigate to `student/courses.aspx`. Expected:
- Only the signed-in student's enrolled courses appear (not the whole catalogue).
- "Current semester" button is active by default; only current-semester courses
  are visible. The "Pinned 0 / N" total reflects the student's enrolled count.

- [ ] **Step 3: Confirm the toggle**

Click "All semesters" → past-semester enrolled courses also appear. Click
"Current semester" → list narrows back. Active button styling moves with it.

- [ ] **Step 4: Confirm search and pin**

Type a course code/name fragment → list filters; clearing the box restores it.
Searching for nonsense shows the "No courses match" empty state. Click a pin →
icon turns red and "Pinned" count increments; reload → pin persists
(localStorage).

- [ ] **Step 5: Final commit (if any markup tweaks were needed)**

```powershell
git add -A "5026CMD Software Engineer/src/src/student"
git commit -m "fix(courses): manual-verification adjustments"
```

> Skip this commit if no changes were needed during verification.

---

## Self-Review (completed)

- **Spec coverage:** DB-driven cards (Task 4), enrolled-only via `GetCourses` (Task 3), two-button filter (Task 4), client-side toggle/search/pin (Task 5), `Color` field (Task 1), dynamic total (Task 4), missing `courses.js` created (Task 5), empty-state retained (Task 4/5), no status badge (Task 4 omits it). All covered.
- **Placeholder scan:** none — every code step has full content.
- **Type consistency:** `EnrolledCourse.Color` (Task 1) is read via `Eval("Color")` (Task 4); helper signatures `IsCurrent`, `AccentColor`, `SearchKey`, `EnrolledCount` (Task 3) match their `<%# %>`/`<%= %>` uses (Task 4); `data-current` / `data-search` / `data-course-code` / `data-action` attributes (Task 4) match the selectors in `courses.js` (Task 5).
