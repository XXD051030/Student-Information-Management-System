# Course Detail page — driven from the database

**Date:** 2026-05-26
**Status:** Approved (design)

## Problem

`student/course_detail.aspx` is entirely hardcoded: it shows a fixed "CSC2104
Software Engineering" course with fabricated modules, announcements,
assignments, and grades. Its code-behind (`course_detail.aspx.cs`) is empty —
nothing reads the database, so every "Open course" click would show the same
fake page.

The "Open course" link on `student/courses.aspx` is also broken: it points to
`~/student/academic/course-detail.aspx?code=…`, but there is no `academic`
folder, no URL routing (`Global.asax.cs` registers no routes), and the real
file is `student/course_detail.aspx` (underscore). The "Back to My Courses"
link inside the detail page is wrong the same way.

The mockup is richer than the current schema. Per the agreed scope, the
database is **extended** so the entire mockup is real data — no section is
dropped or left static.

## Goal

- Clicking "Open course" navigates to the correct page for the **specific
  offering** the student clicked, and the page renders that offering's real
  data from the database.
- All four sections — Modules, Announcements, Assignments, Grades — plus the
  course header and the "Course Details" sidebar are DB-driven.
- The page verifies the logged-in student is enrolled in the requested
  offering before rendering.

## Non-goals

- Serving real file downloads (materials/announcement `file_url` may be NULL or
  placeholders; the download buttons stay as-is).
- Persisting the "Pin course" button in the DB — it stays client-side
  (`localStorage`), same as the courses page today.
- A separate multi-attachment table for announcements (see Simplifications).
- Changing the dashboard or other pages that already use
  `AnnouncementService` / `AssignmentService`.

## Identifier & navigation

- Use **`offering_id`** as the page key, not `course_code`. Materials,
  announcements, assignments, and grades all hang off the offering (a course in
  a specific semester), and each course card already carries
  `EnrolledCourse.OfferingId`. `course_code` would be ambiguous across
  semesters.
- `student/courses.aspx` "Open course" link →
  `~/student/course_detail.aspx?offering=<OfferingId>`.
- `student/course_detail.aspx` "Back to My Courses" link →
  `~/student/courses.aspx`.

## Database changes

All changes must be applied to the **live LocalDB**, not only `seed_data.sql`
(per project memory: the live DB diverges from the seed). Provide an idempotent
migration script plus updated seed rows.

### Course header + sidebar — extend `COURSES`

Add nullable columns:

- `description` VARCHAR(500) — the blurb under the title.
- `level_label` VARCHAR(50) — e.g. "Y2 · Trimester 1".
- `mode` VARCHAR(50) — e.g. "On-campus + LMS".
- `contact_hours` VARCHAR(50) — e.g. "3h lecture · 2h lab".
- `prerequisites` VARCHAR(100) — e.g. "CSC1102 OOP".
- `textbook` VARCHAR(150) — e.g. "Sommerville, 11th ed.".
- `office_hours` VARCHAR(100) — e.g. "Wed 14:00 – 16:00".

### Learning outcomes — new table `LEARNING_OUTCOMES`

- `outcome_id` INT IDENTITY PK
- `course_id` INT NOT NULL (FK → COURSES)
- `outcome_text` VARCHAR(255) NOT NULL
- `sort_order` INT NOT NULL

### Modules — new table `MODULES`

The weekly accordion headers.

- `module_id` INT IDENTITY PK
- `offering_id` INT NOT NULL (FK → COURSE_OFFERINGS)
- `week` INT NOT NULL
- `title` VARCHAR(255) NOT NULL
- `description` VARCHAR(500) NULL

### Module items — extend `COURSE_MATERIALS`

Each material row is one downloadable item under a module. Add:

- `module_id` INT NULL (FK → MODULES) — links the item to its week.
- `file_type` VARCHAR(20) NULL — `'pptx'` / `'video'` / `'pdf'` / `'docx'`;
  drives the item icon.
- `file_size_bytes` INT NULL — formatted to "3.4 MB" in C#; NULL for videos
  (no size shown).

(The existing `week`, `title`, `description`, `file_url` columns are retained.
`COURSE_MATERIALS` is not currently read by any service, so this restructure is
safe.)

### Announcements — extend `ANNOUNCEMENTS`

- `is_pinned` BIT NOT NULL DEFAULT 0 — pinned announcements sort first and show
  the "Pinned" badge.

Author name, initials, and role are derived by joining `created_by` (a
`user_id`) → `USERS.role` and → `LECTURERS.full_name` (initials computed in C#).

### Assignments — extend `ASSIGNMENTS`

- `weight` DECIMAL(5,2) NULL — assessment weight %, e.g. 10.00.
- `assignment_type` VARCHAR(20) NULL — `'Individual'` / `'Group'`.
- `group_size` VARCHAR(20) NULL — e.g. "3–4".

Status badge and score come from the existing `SUBMISSIONS` table for the
logged-in student: no submission → open; `SUBMITTED` → pending; `MARKED` →
graded with `marks`.

### Grades — new tables `ASSESSMENTS` + `STUDENT_ASSESSMENTS`

The gradebook for the Grades tab. Kept **separate** from `ASSIGNMENTS` so the
existing dashboard/assignment code is untouched. (A unified table for both tabs
would be cleaner in theory but would require rewriting working code — out of
scope.)

`ASSESSMENTS`:

- `assessment_id` INT IDENTITY PK
- `offering_id` INT NOT NULL (FK → COURSE_OFFERINGS)
- `name` VARCHAR(255) NOT NULL
- `type` VARCHAR(20) NOT NULL — `'Quiz'` / `'Test'` / `'Assignment'` /
  `'Project'`
- `weight` DECIMAL(5,2) NOT NULL — % contribution to the final grade
- `max_marks` INT NOT NULL DEFAULT 100
- `sort_order` INT NOT NULL

`STUDENT_ASSESSMENTS`:

- `student_assessment_id` INT IDENTITY PK
- `assessment_id` INT NOT NULL (FK → ASSESSMENTS)
- `student_id` INT NOT NULL (FK → STUDENTS)
- `marks` DECIMAL(5,2) NULL — NULL means **Pending** (not yet graded)

Derived in C# (not stored): per-assessment **contribution** =
`marks / max_marks * weight`; **overall average** (donut) = weighted average of
graded assessments = `Σ(marks/max_marks · weight) / Σ(weight)` over graded
rows; **earned (weighted)** = `Σ` contributions of graded rows; **completed %**
= `Σ(weight)` of graded rows. The bar chart plots each graded assessment's
`marks/max_marks`.

## New / extended services

Follow the existing service pattern in `services/` (static class, `Db.OpenConnection()`,
parameterised SQL, plain model classes, exceptions propagate to the caller).

### `CourseDetailService` (new)

- `CourseHeader GetHeader(int offeringId, int userId)` — joins
  COURSE_OFFERINGS → COURSES → SEMESTERS, lecturer via TEACHINGS/LECTURERS, and
  **filters by the student behind `userId` being enrolled** in the offering.
  Returns `null` when the student is not enrolled (caller redirects). Includes
  the sidebar columns and a module count.
- `List<LearningOutcome> GetLearningOutcomes(int courseId)` — ordered by
  `sort_order`.

`CourseHeader` carries: course code/name/credits/color, `description`,
`level_label`, lecturer name, semester name, module count, and the sidebar
fields (`mode`, `contact_hours`, `prerequisites`, `textbook`, `office_hours`).

### `ModuleService` (new)

- `List<Module> GetModules(int offeringId)` — modules ordered by `week`, each
  with its nested `List<MaterialItem>` (ordered, with `file_type`,
  `file_size_bytes`, `title`, `file_url`). A single query joining MODULES →
  COURSE_MATERIALS, grouped in C#.

### `AssessmentService` (new)

- `Gradebook GetGradebook(int offeringId, int userId)` — assessments for the
  offering left-joined to the student's `STUDENT_ASSESSMENTS` rows; returns the
  per-assessment list plus the computed totals described above.

### `AnnouncementService` (extend)

- `List<CourseAnnouncement> GetByOffering(int offeringId)` — announcements
  targeting the offering (via ANNOUNCEMENT_TARGETS), **pinned first** then
  newest first, with author name/role/initials and a flag for whether a
  `file_url` attachment is present. The existing `GetForStudent` is unchanged.

### `AssignmentService` (extend)

- `List<CourseAssignment> GetByOffering(int offeringId, int userId)` —
  assignments for the offering with `weight`, `assignment_type`, `group_size`,
  and the student's submission status + marks (LEFT JOIN SUBMISSIONS). The
  existing dashboard methods are unchanged.

## Code-behind (`student/course_detail.aspx.cs`)

Mirrors `student/courses.aspx.cs`:

- No-cache headers; `Session["user_id"] == null` → redirect to login.
- Parse `Request.QueryString["offering"]` as int; invalid → redirect to
  `~/student/courses.aspx`.
- `header = CourseDetailService.GetHeader(offeringId, userId)`; if `null`
  (not enrolled / no such offering) → redirect to `~/student/courses.aspx`.
- Load outcomes, modules, announcements, assignments, and gradebook; bind each
  to its Repeater.
- Expose markup helpers: `AccentColor(color)` (reuse the courses-page idea),
  initials, file-size formatting, due-date phrasing ("Tomorrow · 11:59 PM",
  "In 6 days", "Submitted · 28 Apr", "Graded · 15 Apr"), and grade colour
  thresholds (emerald/amber).

## Markup (`student/course_detail.aspx`)

Keep the existing visual style; replace static content with bound controls:

- **Header**: code, `level_label`, title, `description`, lecturer, credits,
  module count, accent gradient.
- **Sidebar**: the seven `COURSES` sidebar fields + a Repeater for learning
  outcomes.
- **Modules pane**: a Repeater of modules (week header: number/title/
  description/item count) each containing a nested Repeater of material items
  (icon by `file_type`, name, formatted size).
- **Announcements pane**: a Repeater (pinned first) — author/initials/role,
  timestamp, pinned badge when set, title, body, "1 attachment" when a file is
  present.
- **Assignments pane**: a Repeater — title, weight badge, type/group badge,
  description, due/status line, score badge when graded.
- **Grades pane**: bound donut (overall %), bar chart, and the assessments
  table with computed contribution and totals row.
- The designer file declares every new Repeater control.

## Seed data (`db/seed_data.sql`)

Add rows for the **already-seeded offerings** the seeded student (student 1,
user 1) is enrolled in (offerings 1 = CS101 and 2 = CS201) so the page has
content:

- `COURSES` sidebar columns + `LEARNING_OUTCOMES` for those courses.
- `MODULES` (a few weeks) + `COURSE_MATERIALS` items linked to them, with
  `file_type` / `file_size_bytes`.
- `ASSESSMENTS` (a mix of Quiz/Test/Assignment/Project with weights) +
  `STUDENT_ASSESSMENTS` for student 1 (some graded, some NULL/pending).
- `ASSIGNMENTS` weight/type/group on existing rows + at least one matching
  `SUBMISSIONS` status.
- At least one pinned `ANNOUNCEMENT` targeting an enrolled offering.

## Simplifications (confirmed)

- **Announcement attachments**: show "1 attachment" when `file_url` is present,
  rather than building a multi-attachment table for "2 attachments".
- **Pin course** button: client-side `localStorage` only, not DB-backed.

## Edge cases

- Offering with no modules / announcements / assignments / assessments → that
  pane renders empty (an empty Repeater), no error.
- Assessment with NULL `marks` → "Pending"; excluded from the donut/earned/
  completed totals and the bar chart.
- No published/graded assessments at all → donut shows 0% / empty totals.
- `color` NULL → neutral slate fallback (same as courses page).
- Student requests an `offering` they are not enrolled in, or a non-numeric/
  missing `offering` → redirect to `~/student/courses.aspx`.

## Verification

- Build with msbuild (PowerShell), per project memory.
- Apply the migration + seed to the live LocalDB; verify with sqlcmd.
- Log in as the seeded student, click "Open course" on an enrolled course, and
  confirm the header, sidebar, and all four tabs show that offering's real
  data; confirm a not-enrolled / bad `offering` id redirects back.
