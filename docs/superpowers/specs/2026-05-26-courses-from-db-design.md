# My Courses page — driven from the database

**Date:** 2026-05-26
**Status:** Approved (design)

## Problem

`student/courses.aspx` currently renders 18 hardcoded course cards. It does not
reflect the logged-in student's actual enrolments, and its filter row offers
seven per-trimester buttons (All semesters, Y1·T1 … Y3·T2). The JS file it
references (`~/js/courses/courses.js`) does not exist, so the search, pin, and
filter interactions do not work at all.

## Goal

- Every card comes from the database.
- Show **only the courses the logged-in student is enrolled in** — not the full
  course catalogue.
- Replace the seven semester buttons with **two**: **Current semester**
  (default) and **All semesters**.

## Non-goals

- Building the `course-detail.aspx` page that the "Open course" link targets.
- Persisting pins in the database (pins remain cosmetic / `localStorage`).
- Changing `GetCurrentCourses` or the dashboard, which already work.

## Data source

Use the existing `EnrolmentService.GetCourses(userId)`, which already returns
every course the student is or was enrolled in (all semesters), joined to
course code/name/credits, lecturer, and semester name. The "Current semester"
view is a **client-side filter** over this same list, so toggling is instant and
needs no postback.

### Service changes (`services/EnrolmentService.cs`)

- Add `public string Color { get; set; }` to `EnrolledCourse`.
- In the `GetCourses` SELECT, add `c.color` and map it in the reader loop
  (`reader["color"]`, treating `DBNull` as empty/null).
- `GetCurrentCourses` is left unchanged.

## Code-behind (`student/courses.aspx.cs`)

Mirrors `shared/dashboard.aspx.cs`:

- Add the no-cache headers and the `Session["user_id"] == null` →
  redirect-to-login guard.
- Load `_courses = EnrolmentService.GetCourses(userId)` and
  `_currentSemesterName = SemesterService.GetCurrent()?.Name`.
- Bind an `<asp:Repeater ID="coursesRepeater">` to `_courses`.
- Helpers exposed to the markup:
  - `bool IsCurrent(string semesterName)` — compares to `_currentSemesterName`
    (ordinal, case-insensitive); used to stamp each card.
  - `string AccentColor(string color)` — returns the color or a neutral slate
    fallback when null/empty (same idea as the dashboard's `ClassColor`).
  - `int EnrolledCount` — `_courses.Count`, for the header "Pinned X / Y" total.

## Markup (`student/courses.aspx`)

- Replace the 18 `<article>` blocks with **one Repeater `ItemTemplate`** that
  produces the same card layout, bound with `Eval`:
  - `CourseCode`, `CourseName`, `LecturerName`, `CreditHours`, `SemesterName`.
  - Accent strip + icon tint use `AccentColor(Eval("Color"))`.
  - Each card root carries `data-current='<%# IsCurrent(...) %>'` and
    `data-search='<%# code + name + lecturer, lowercased %>'` for the JS.
  - Keep the **pin button**. **Remove the status badge.**
- **Filter row:** exactly two buttons — `data-semester="current"` (active by
  default) and `data-semester="all"`. Keep the **search box on the right**.
- Header "Pinned" tile: the total (`Y`) is server-rendered from `EnrolledCount`;
  the pinned number (`X`) stays JS-driven.
- Keep the existing `#no-results` empty-state block.
- The designer file must declare the new `coursesRepeater` control.

## New file: `js/courses/courses.js`

Creates the interactivity the page already references but lacks:

- **Semester toggle** — clicking a `data-semester` button shows/hides cards by
  their `data-current` value; "Current semester" is active on load (cards with
  `data-current="false"` hidden).
- **Search** — filters the currently-visible cards by `data-search`
  (case-insensitive substring of code/name/lecturer).
- **Pin** — toggles a pin in `localStorage` keyed by course code, updates the
  pin icon state and the "Pinned X" number.
- **Empty state** — shows `#no-results` when the active filter + search leave no
  visible cards, hides it otherwise.

## Edge cases

- Student with no enrolments → repeater renders nothing; the empty state shows.
- Current semester with no enrolled courses → default view is empty and the
  empty state shows; switching to "All semesters" reveals past courses.
- `color` is null in the DB → neutral slate fallback.
- No current semester configured (`GetCurrent()` null) → no card is marked
  current; default view is empty until the user switches to "All semesters".

## Verification

- Build with msbuild (PowerShell), per project memory.
- Log in as a seeded student and confirm only their enrolled courses appear,
  defaulting to the current semester, with the two-button toggle, search, and
  pin all working.
