# Attendance: clickable course cards + semester filter — design

Date: 2026-05-27
Page: `student/attendance.aspx` (+ code-behind, `AttendanceService`, new `js/attendance/attendance.js`)

## Goal

On the student attendance page:

1. Make the "By course" cards **clickable**. Clicking a card switches the detail panel (header, KPI strip, sessions table, footer) to that course's attendance records, instantly, with no page reload.
2. Add a **semester filter** so the student can view attendance for a specific semester. The filter lists only semesters that actually have attendance records, defaults to the current semester, and drives the cards, the detail panel, and the hero summary.

## Current behavior (baseline)

- `AttendanceService.GetAttendancePage(userId)` loads **only current-semester** courses (`sem.is_current = 1`, `e.status = 'ENROLLED'`), each with all its `ATTENDANCE` sessions.
- The page is fully server-rendered with **no page-specific JS**.
- `courseRepeater` renders one card per current-semester course.
- The detail panel always shows `Courses.FirstOrDefault()` — cards are not clickable. `CourseCardClass` only styles the (fixed) first course as selected.
- A static "All sessions" badge sits in the detail header and does nothing.
- The hero ("Overall attendance") sums all loaded courses — which works today only because all loaded courses are current-semester.

## Data reality (verified against live LocalDB, 2026-05-27)

- Semesters: `2025-S3`, `2026-S1`, `2026-S2` (current), `2026-S3` (future).
- All enrolments are status `ENROLLED`; none `COMPLETED`. Enrolments exist only in `2026-S2` and `2026-S3`.
- `ATTENDANCE` rows exist only for `2026-S2`. `2026-S3` is enrolled but has zero attendance.

Consequence: with current data the filter will show only `2026-S2`. The future semester `2026-S3` is excluded because it has no attendance rows. This is expected and acceptable — no seed data will be added; the feature is built to work correctly as more data appears.

## Design decisions (confirmed with user)

- **Card switching:** client-side JS, instant (no reload).
- **Semester scope:** load all the student's semesters; dropdown filters to one, defaulting to current.
- **Hero scope:** the hero recomputes to match the selected semester.
- **Seed data:** none added; build the feature only.
- **Empty semesters:** the filter lists only semesters that have at least one attendance record (excludes the empty future semester).

## Architecture: progressive enhancement

The server renders the initial state (current semester, first course's detail) so there is no flash and a sensible no-JS baseline. A new `js/attendance/attendance.js` owns all **interaction** (semester filtering, card clicks, hero recompute, detail rebuild). This mirrors existing conventions:

- `notifications.js` paints a detail panel client-side from data carried on the list.
- `timetable.js` reads a server-serialized payload from a `window.*` global.

### Data flow

1. `AttendanceService` loads all of the student's courses across all semesters (with sessions), then keeps only semesters that have ≥1 attendance record.
2. Code-behind:
   - Renders `courseRepeater` for **all** kept courses; each card carries `data-offering` and `data-semester-id`.
   - Computes the hero (`PresentCount`/`LateCount`/`AbsentCount`/rate) from the **current-semester subset** for the initial render.
   - Renders the detail panel for the default course (first current-semester course) via the existing `sessionsRepeater`.
   - Renders the semester `<select>` options (distinct kept semesters, ordered, current pre-selected). An "All semesters" option is included since the summed hero is meaningful across semesters.
   - Serializes `AttendancePayloadJson` to `window.attendanceData`.
3. `attendance.js` reads `window.attendanceData` and wires interaction.

### `window.attendanceData` payload shape

```js
{
  defaultOfferingId: 12,            // first current-semester course
  currentSemesterId: 3,
  courses: [
    {
      offeringId: 12,
      semesterId: 3,
      semesterName: "2026-S2",
      isCurrent: true,
      code: "CS101",
      name: "Introduction to Programming",
      lecturer: "Dr. ...",          // already defaulted to "Lecturer not assigned" if blank
      color: "#e0162b",             // already validated server-side
      present: 1, late: 1, absent: 0, total: 2,
      sessions: [
        { date: "12 May 2026", day: "Mon", time: "09:00 - 11:00",
          type: "Class", venue: "Lab A", status: "PRESENT" }
      ]
    }
  ]
}
```

All display strings (date, day, time, type, venue) are pre-formatted in C# so date/culture logic stays server-side and matches the no-JS render. JS only maps `status` → badge class/icon (the same PRESENT/LATE/ABSENT mapping the code-behind uses, reimplemented in JS like `notifications.js` does for categories).

## Components and changes

### 1. `services/AttendanceService.cs`

- `SelectAttendanceRows`: remove `sem.is_current = 1`; broaden `e.status = 'ENROLLED'` to `e.status IN ('ENROLLED','COMPLETED')`; select `sem.semester_id`, `sem.name AS semester_name`, `sem.is_current`, and order by `sem.start_date DESC, c.course_code, a.attendance_date DESC, a.attendance_id DESC`.
- `AttendanceCourse`: add `SemesterId` (int), `SemesterName` (string), `IsCurrent` (bool).
- `GetCourses`: populate the new fields when first creating each course.
- `GetAttendancePage`: after building courses, **drop courses whose semester has no attendance at all** (group by `SemesterId`, keep semesters where any course has `TotalCount > 0`). Keep current header for defaults.
- `AttendancePageData`: the hero aggregate properties (`PresentCount`, etc.) must now be scoped to current-semester courses, OR the code-behind computes the hero from the current-semester subset directly. **Chosen:** keep `AttendancePageData` aggregates as-is (sum of all courses for the "All semesters" semantics the JS also uses) and have the **code-behind** compute the initial hero from `Courses.Where(c => c.IsCurrent)`. This avoids changing the meaning of existing properties and keeps "All semesters" summing trivial.
- `GetCurrentSemesterRate` is unchanged (still current-semester only; used by dashboard).

### 2. `student/attendance.aspx.cs`

- `BindAttendancePage`:
  - Bind `courseRepeater` to all kept courses.
  - Default selected course = first current-semester course (fallback: first kept course if current semester somehow has none).
  - Compute hero displays from the current-semester subset.
  - Render detail for the default course via `sessionsRepeater` (unchanged logic, just sourced from the default course).
  - Build the semester `<select>` option list (distinct kept semesters by `SemesterId`/`SemesterName`, ordered newest-first, current marked `selected`; plus an "All semesters" option) — exposed as a bound control or a generated-markup property.
  - Build `AttendancePayloadJson` via `System.Web.Script.Serialization.JavaScriptSerializer` (same approach as `timetable.aspx.cs`), pre-formatting session display strings with the existing `SessionDateDisplay`/`SessionTimeDisplay`/etc. helpers.
- Card markup: add `data-offering='<%# Eval("OfferingId") %>'` and `data-semester-id='<%# Eval("SemesterId") %>'` to the card root; keep `CourseCardClass` for the initial selected styling.

### 3. `student/attendance.aspx`

- Replace the static semester chip in the header with the semester `<select>` (id e.g. `#semester-filter`), styled to match existing controls. Keep the Export button.
- Give the detail panel stable ids/hooks for JS to repaint: detail course accent bar, code, name, lecturer, KPI present/late/absent values, sessions `<tbody>`, footer text, and the empty-sessions placeholder. Keep server-rendered initial content inside them.
- Add `data-offering` / `data-semester-id` to each card (above).
- Register the script for the page (ScriptsPlaceholder) pointing at `~/js/attendance/attendance.js`.

### 4. `js/attendance/attendance.js` (new)

Responsibilities:

- Read `window.attendanceData`; index courses by `offeringId`.
- **Semester filter** (`#semester-filter` change): show/hide cards by `data-semester-id` (or show all when "all"); recompute the hero present/late/absent/rate from the visible courses' counts; auto-select the first visible course and repaint the detail.
- **Card click** (`[data-offering]`): set selected styling on the clicked card, clear it from others, repaint the detail panel from that course's payload.
- **Detail repaint:** fill the accent bar color, code, name, lecturer, KPI numbers, footer ("Showing N of N recorded sessions"); rebuild the sessions `<tbody>` rows from `sessions[]`, applying the status → badge class/icon map; toggle the empty-sessions placeholder when a course has zero sessions.
- **Empty states:** when a semester filter yields no cards, show the empty-courses placeholder and hide the detail; otherwise hide it.
- Re-run `lucide.createIcons()` after injecting icon markup (status icons), consistent with the global icon init.

DOM hooks (final names settled during implementation): `#semester-filter`, `[data-offering]`, `#detail-*` (accent, code, name, lecturer, present, late, absent, footer), `#sessions-body`, `emptySessionsPanel`, `emptyCoursesPanel`, and the hero count nodes.

### 5. `src.csproj`

- Add `<Content Include="js\attendance\attendance.js" />` near the other JS content entries. (The project-context records that `course-detail.js` was previously left out of the project file — this avoids repeating that mistake.)

### 6. `doc/project-context.md`

Update per the mandatory maintenance rule:
- `student/attendance.aspx`: now multi-semester, clickable cards, semester filter, page-specific JS.
- `student/attendance.aspx.cs`: payload serialization + semester options + current-semester-scoped hero.
- Add `js/attendance/attendance.js` section.
- `AttendanceService`: all-semester load, semester fields, drop-empty-semesters rule.
- Note the new `js\attendance\attendance.js` `src.csproj` entry.

## Error handling / edge cases

- No attendance anywhere → existing `emptyDetailPanel` / `emptyCoursesPanel` behavior; dropdown would be empty/disabled.
- Current semester has courses but no attendance, while a past semester does → current is excluded from the dropdown (only semesters-with-attendance are listed); default falls back to the first listed semester.
- A course in a listed semester with zero sessions → still shown as a card (0/0); selecting it shows the empty-sessions placeholder.
- Color/lecturer already sanitized server-side before entering the payload.

## Testing

- Build with msbuild (PowerShell), per project memory.
- Manual: load attendance page as a logged-in student; verify current semester shows by default, cards are clickable and swap the detail, the dropdown lists only `2026-S2` (current data), the hero matches the selection, and "All semesters" sums correctly.
- Verify no-JS baseline still renders current semester + first course detail.

## Out of scope

- Seed data for past semesters.
- The Export report button (remains a static placeholder).
- Any change to attendance status semantics (PRESENT/LATE/ABSENT only).
