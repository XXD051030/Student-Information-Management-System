# Dashboard Widgets — Design

**Date:** 2026-05-25
**Status:** Approved (pending spec review)

## Goal

Wire the five dashboard widgets on `shared/dashboard.aspx` to real data. Today's
Schedule, Upcoming Assignments, and Announcements are currently hardcoded HTML;
My Courses is bound but shows every semester; Pending Tasks is a hardcoded "3".

## Scope

In scope:

- Today's Schedule — bind to current data, show LIVE status and real counts.
- My Courses — scope to the current semester only.
- Pending Tasks — count of unsubmitted assignments this semester.
- Upcoming Assignments — bind to assignments due this week.
- Announcements — announcements targeting the student's enrolled offerings.

Out of scope:

- The "View timetable" / "Full week" / "See all" / "View all assignments"
  navigation buttons remain visual only (no target pages yet).
- No new visual design — existing markup is preserved; only data is wired in.
- Announcement category tags (Academic/Event/System) are dropped — the
  `ANNOUNCEMENTS` table has no category column, so the tags had no data behind
  them.

## Data layer

All new access is read-only and follows the existing house style: parameterized
SQL, `Db.OpenConnection()`, returns an empty list (or zero) when there are no
rows, and lets SQL exceptions propagate to the caller.

### New: `AnnouncementService` + `Announcement`

`Announcement` model: `AnnouncementId`, `Title`, `Content`, `CreatedAt`.

`GetForStudent(int userId)` returns the student's most recent announcements:

```
SELECT DISTINCT TOP 5 an.announcement_id, an.title, an.content, an.created_at
FROM ANNOUNCEMENTS an
JOIN ANNOUNCEMENT_TARGETS at ON at.announcement_id = an.announcement_id
JOIN COURSE_OFFERINGS o      ON at.offering_id = o.offering_id
JOIN SEMESTERS sem           ON o.semester_id = sem.semester_id
JOIN ENROLMENTS e            ON e.offering_id = o.offering_id
JOIN STUDENTS s              ON e.student_id = s.student_id
WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED'
ORDER BY an.created_at DESC
```

`DISTINCT` guards against an announcement targeting several of the student's
offerings producing duplicate rows.

### New: `AssignmentService.GetPendingTaskCount(int userId)`

Count of current-semester assignments on the student's enrolled courses that the
student has not yet submitted:

```
SELECT COUNT(*)
FROM ASSIGNMENTS a
JOIN COURSE_OFFERINGS o ON a.offering_id = o.offering_id
JOIN SEMESTERS sem      ON o.semester_id = sem.semester_id
JOIN ENROLMENTS e       ON e.offering_id = o.offering_id
JOIN STUDENTS s         ON e.student_id = s.student_id
WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED'
  AND NOT EXISTS (
      SELECT 1 FROM SUBMISSIONS sub
      WHERE sub.assignment_id = a.assignment_id
        AND sub.student_id = s.student_id)
```

Reuses the `SelectAssignments` join shape already in `AssignmentService`.

### New: `EnrolmentService.GetCurrentCourses(int userId)`

Same projection and lecturer `OUTER APPLY` as the existing `GetCourses`, but
filtered to the current semester and active enrolment:
`... WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED'`.
`GetCourses` (all-time) is kept unchanged.

### `Student` model + `StudentService.MapStudent`

Add three properties, populated alongside the existing ones in `MapStudent`:

- `List<EnrolledCourse> CurrentCourses` ← `EnrolmentService.GetCurrentCourses`
- `int PendingTaskCount` ← `AssignmentService.GetPendingTaskCount`
- `List<Announcement> Announcements` ← `AnnouncementService.GetForStudent`

## Presentation layer

Approach: `<asp:Repeater>` controls bound in `Page_Load`, with **protected helper
methods on the page** called inline from item templates — matching the existing
`coursesRepeater` pattern. No `OnItemDataBound` handlers, no view-model DTOs.

### dashboard.aspx.cs

New protected helpers:

- `FormatTimeRange(TimeSpan start, TimeSpan end)` → `"09:00 – 10:30"`.
- `IsLiveNow(TimeSpan start, TimeSpan end)` → true when `DateTime.Now.TimeOfDay`
  is within the range (drives the LIVE badge).
- `ClassAccentColor(int index)` → cycles a 4-color palette (`#e0162b`, `#3b82f6`,
  `#f59e0b`, `#10b981`) for the left bar.
- `FormatRelativeDue(DateTime due)` → "Today", "Tomorrow", "In N days", else the
  date; plus a helper for the urgency icon/color bucket (overdue/today/tomorrow,
  soon, ok).
- `FormatRelativeTime(DateTime when)` → "Nh ago", "Yesterday", "N days ago".
- `TodayClassesTotalLabel` → "N classes · Xh Ym total" computed from
  `TodayClasses` durations.

New designer fields: `scheduleRepeater`, `assignmentsRepeater`,
`announcementsRepeater` (in addition to existing `coursesRepeater`).

`Page_Load` binds each repeater from the loaded `_student` lists; `coursesRepeater`
is rebound from `CurrentCourses` instead of `Courses`. The Pending Tasks card and
header counts read from the new/existing `Student` fields.

### dashboard.aspx

- **Today's Schedule** — replace the four hardcoded `<li>`s with a Repeater over
  `TodayClasses`. Each item: accent bar color by index, course name + code, LIVE
  badge when `IsLiveNow`, time range, venue. Header subtitle uses
  `TodayClassesTotalLabel`. Empty state: "No classes scheduled today."
- **Upcoming Assignments** — Repeater over `AssignmentsDueThisWeek`: title, course
  code, relative due text, urgency icon. Header shows real "N due this week".
  Empty state: "Nothing due this week."
- **My Courses** — `coursesRepeater` unchanged in markup; bound to `CurrentCourses`.
  Empty state for no current enrolments.
- **Pending Tasks** card — value bound to `PendingTaskCount`.
- **Announcements** — Repeater over `Announcements`: title, content, relative time.
  Empty state: "No announcements."

All text from the database is HTML-encoded via `Server.HtmlEncode`, consistent
with the existing `coursesRepeater` template.

## Error handling

Each widget degrades to its empty state when its list is empty or count is zero.
Existing `—` / zero display conventions for GPA, attendance, and credits are kept.
SQL exceptions propagate as in the current services (no new catch blocks).

## Testing

- Verify against the live LocalDB (per project memory the live DB diverges from
  `seed_data.sql`): confirm `ANNOUNCEMENT_TARGETS`, `SUBMISSIONS`, and current-
  semester enrolments actually return rows for the test login, so widgets render
  populated rather than empty.
- Build with msbuild (PowerShell, not Git Bash — it mangles msbuild switches).
- Manually load the dashboard for a seeded student and confirm each widget shows
  real data and that empty states render when data is absent.
