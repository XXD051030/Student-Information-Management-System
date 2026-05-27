# Enrollment Page From DB — Design

Date: 2026-05-27
Status: Approved

## Goal

Convert `student/enrollment.aspx` from fully hardcoded markup into a
database-driven page. Every value shown — header term info, registration
window banner, the "Already Registered" stat, and every course card (code,
name, credits, lecturer, schedule, seats, fee, prerequisites, status) — comes
from the database. Selecting courses and clicking "Proceed to Payment"
persists the student's choices to `ENROLMENTS`.

## Decisions (from brainstorming)

- **Persistence:** the page writes. "Proceed to Payment" inserts `ENROLMENTS`
  rows for the logged-in student.
- **Seats & fees:** add real DB columns (`COURSE_OFFERINGS.capacity`,
  `COURSES.fee_per_credit`) and seed them, rather than dropping the UI.
- **Course list:** show offerings for a **new upcoming registration semester**
  (`2026-S3`), not the current active term.
- **Prerequisites:** display the `COURSES.prerequisites` text as a badge only.
  No automatic met / not-met logic, no prerequisite-based blocking.
- **New-enrollment status:** newly enrolled rows use status `PENDING` (payment
  pending). The enrollment page treats both `PENDING` and `ENROLLED` as
  "registered". Dashboard/courses pages filter on `ENROLLED` and are
  unaffected.

## Current State

- `student/enrollment.aspx` is static markup ported from a TSX mockup: 8 course
  cards, seat counts, fees, a 3-step phase timeline, "Academic Year 2026/2027",
  "Y2 · Trimester 2 (Sep 2026)".
- `student/enrollment.aspx.cs` has an empty `Page_Load` (no auth gate).
- `js/enrollment/enrollment.js` is referenced by the page but does not exist.
- Live DB (verified): semesters 1–3 (`2026-S2` is current, ends 2026-07-17),
  4 course offerings all in the current semester, 4 courses. `COURSES` already
  has the `course_detail.sql` columns including `prerequisites varchar`. There
  is **no** `capacity` column on `COURSE_OFFERINGS` and **no** fee column on
  `COURSES`.

## Schema Changes — new script `db/enrollment.sql`

Idempotent patch + seed script. Added to the fresh-rebuild order **after**
`db/course_detail.sql`. Every statement guarded (`IF NOT EXISTS` /
`IF COL_LENGTH(...) IS NULL`) so it is safe to re-run.

1. `ALTER TABLE COURSE_OFFERINGS ADD capacity INT NULL` — max seats.
2. `ALTER TABLE COURSES ADD fee_per_credit DECIMAL(10,2) NULL` — backfilled to
   `150`. Per-course fee = `credit_hours * fee_per_credit`. The "RM x / credit"
   label is derived from this rate.
3. Insert upcoming registration semester `2026-S3` (`is_current = 0`,
   start ~2026-08-03, end ~2026-12-11) if absent.
4. Insert `ACADEMIC_CALENDAR` rows for `2026-S3`:
   - `REGISTRATION` event with a window that **includes today (2026-05-27)** so
     the banner reads "ENROLLMENT OPEN".
   - `ADD_DROP` event after registration.
   These drive the phase banner and the 3-step timeline.
5. Insert `COURSE_OFFERINGS` for `2026-S3`: reuse the 4 existing courses and add
   a small number of new `COURSES` for variety, so the list resembles the
   mockup's breadth. Add matching `TEACHINGS` and `TIMETABLES` so each card has
   a lecturer and a schedule.
6. Backfill `capacity` and `fee_per_credit` for all offerings/courses.
7. Seed one or two `ENROLMENTS` for student "Ong Zhi Bo" (student_id 1) in the
   new semester so the "Registered" badge and "Already Registered" stat render
   with real data.

## Service Layer — extend `services/EnrolmentService.cs`

This makes `EnrolmentService` no longer read-only (a `Enrol` write method is
added). The project context note is updated accordingly.

New model `OfferingForRegistration`:
- `OfferingId, CourseCode, CourseName, CreditHours, Color, Description,
  LecturerName, Schedule, EnrolledCount, Capacity, FeePerCredit,
  Prerequisites, MyStatus` (null / PENDING / ENROLLED).

New methods:
- `Semester GetRegistrationSemester()` — the next semester after the current
  one by `start_date` (the upcoming term open for registration).
- `RegistrationWindow GetRegistrationWindow(int semesterId)` — registration and
  add/drop dates from `ACADEMIC_CALENDAR`, plus which phase is active today
  (Registration / Add-Drop / Locked).
- `List<OfferingForRegistration> GetOfferingsForRegistration(int userId, int semesterId)`
  — one row per offering in the semester. Lecturer via `OUTER APPLY TOP 1`;
  schedule concatenated from `TIMETABLES`; `EnrolledCount` from `ENROLMENTS`
  (statuses `ENROLLED` + `PENDING`); the student's own `MyStatus` via a join on
  `STUDENTS`/`ENROLMENTS`.
- `int Enrol(int userId, IEnumerable<int> offeringIds)` — inserts `ENROLMENTS`
  rows (status `PENDING`) for the student's offerings that are in the
  registration semester, not already enrolled, and not full. Returns the count
  inserted. Parameterized; uses `Db.OpenConnection()`.

Status resolution (in code, from a row): `Registered` if `MyStatus` is
`PENDING`/`ENROLLED`; else `Full` if `EnrolledCount >= Capacity`; else
`Enrollable`.

## Page — `student/enrollment.aspx` (+ `.cs`, `.designer.cs`)

- **Code-behind:** add the standard cache-disable + `Session["user_id"]` auth
  gate (matching dashboard/account/courses). Load the registration semester,
  window, and offerings; expose helper members for the markup (academic-year
  label, term label, year-of-study, registration dates, already-registered
  count, fee-per-credit constant for JS). Add a `[WebMethod(EnableSession=true)]
  Enrol(int[] offeringIds)` that calls `EnrolmentService.Enrol` for the session
  user and returns `{ ok, inserted }`, or HTTP 401 if not logged in.
- **Markup:** replace hardcoded sections with bound output:
  - Header: academic year, term label, year-of-study.
  - Phase banner + timeline: from the registration window.
  - Stats: "Already Registered" is server-rendered; "Courses Selected",
    "Credits Selected", "Estimated Fee" stay client-computed (live selection).
  - Course list: `asp:Repeater` (`offeringsRepeater`) over offerings. Each item
    renders code/name/credits/color/description/lecturer/schedule/seats/fee and
    a prerequisites text badge when present. Status decides the control:
    checkbox (Enrollable), "Registered" badge (Registered), disabled "Full"
    button (Full).
- **Designer:** declare new server controls (`offeringsRepeater` and any
  `runat="server"` labels).

## JavaScript — create `js/enrollment/enrollment.js`

Plain IIFE (no bundler), matching project conventions. Uses the existing DOM
hooks (`#enroll-count`, `#enroll-credits`, `#enroll-total`, footers,
`#enroll-submit`, `[data-course-row]`, `[data-action="toggle-enroll"]`,
`[data-action="proceed-to-payment"]`):
- Recompute selected count / credits / fee from ticked rows (credits and fee per
  row come from `data-credits` / `data-fee` rendered by the server). Mirror
  values into header and footer counters.
- Enable/disable the submit button based on selection count.
- On "Proceed to Payment": POST selected `offeringIds` to
  `/student/enrollment.aspx/Enrol`, then reload so newly enrolled courses show
  as Registered.
- Re-run `lucide.createIcons()` if icons are touched.

## Bookkeeping

- `src.csproj`: add `<Content Include="js\enrollment\enrollment.js" />` and
  `<Content Include="db\enrollment.sql" />`.
- `doc/project-context.md`: enrollment page is now DB-driven; document new
  `EnrolmentService` methods + write capability, `db/enrollment.sql`, new
  schema columns, updated rebuild order, and the enrollment data-flow.

## Out Of Scope

- A real payment page / `PAYMENTS` write flow (button persists enrollment as
  `PENDING` only).
- Structured prerequisite enforcement.
- Drop/withdraw flow.
