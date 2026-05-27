# Account Profile — Bind to Database

**Date:** 2026-05-25
**Status:** Approved

## Problem

The Profile card in `shared/account.aspx` is entirely hard-coded ("Aisyah Yusoff",
"I22023456", "May 2024", etc.). It should render the logged-in student's real profile
from the database. Two of the displayed fields — phone and mailing address — have no
home in the schema yet.

## Scope

**In scope:** the **Profile** card only — load every value from the DB for the
session's current student.

**Out of scope:** the Change Password, Preferences, and Active Sessions cards. No
write-back/persistence of any field — the "Save changes" button stays as-is
(client-side only, non-functional server-side).

## Approach

Reuse the existing `StudentService` (the same read-only profile loader the dashboard
uses) rather than introducing a new service or inline query. `account.aspx.cs` mirrors
`dashboard.aspx.cs`: a session guard, one `GetByUserId` call, and `protected` display
properties consumed by `<%= %>` bindings in the markup.

## Changes

### 1. Database — `db/user_contact_info.sql` (new, idempotent)

Follows the same pattern as `db/student_intake_semester.sql`:

- Add columns, guarded so re-runs are safe:
  - `phone VARCHAR(20) NULL`
  - `mailing_address VARCHAR(255) NULL`
  - on `dbo.USERS`, each wrapped in a `COL_LENGTH(...) IS NULL` check.
- Backfill sample values for existing users so seeded students display real data.
- Columns remain **nullable** — not every user is a student.
- The main schema dump (`student_information_management_system.sql`) is **not** edited,
  consistent with how `intake_semester_id` is handled. Fresh-rebuild order: full dump →
  `student_intake_semester.sql` → `user_contact_info.sql` → `seed_data.sql`.

### 2. `services/StudentService.cs`

Add three properties to the `Student` class:

- `string Phone`
- `string MailingAddress`
- `DateTime? IntakeDate`

Extend the `SelectProfile` query:

- Select `u.phone`, `u.mailing_address`.
- `LEFT JOIN SEMESTERS si ON si.semester_id = s.intake_semester_id`, selecting
  `si.start_date AS intake_date`.

Map the three new fields in `MapStudent`, null-safe (`DBNull` → null / empty string).
The existing related-data loads (timetable, assignments, grades, etc.) are left
unchanged; the account page simply does not read them.

### 3. `shared/account.aspx.cs`

Mirror `dashboard.aspx.cs`:

- `Page_Load`: no-cache headers; if `Session["user_id"]` is null → redirect to
  `~/shared/login.aspx`. Load `_student = StudentService.GetByUserId(...)`. If
  `_student` is null (e.g. an admin/lecturer with no student row) → redirect to login.
- `protected` display properties:

| Property          | Source              | Format / rule                                              |
|-------------------|---------------------|------------------------------------------------------------|
| `FullName`        | `s.FullName`        | as-is                                                      |
| `Initials`        | `s.FullName`        | first letters of the first two words, upper-cased ("AY")   |
| `ProgrammeName`   | `s.ProgrammeName`   | used for both the subtitle and the MAJOR field             |
| `StudentIdLabel`  | `s.Username`        | e.g. `p26017888`                                           |
| `Email`           | `s.Email`           | as-is                                                      |
| `StatusBadge`     | `s.Status`          | upper-cased (e.g. "ACTIVE")                                |
| `IntakeLabel`     | `s.IntakeDate`      | `"MMM yyyy"` invariant (e.g. "Aug 2025"); "—" when null    |
| `StandingLabel`   | `s.CurrentSemesterNo` | `"Year {ceil(n/3)} · Trimester {((n-1)%3)+1}"`           |
| `Phone`           | `s.Phone`           | input `value`; empty string when null                      |
| `MailingAddress`  | `s.MailingAddress`  | input `value`; empty string when null                      |

### 4. `shared/account.aspx`

Replace only the hard-coded strings inside the **Profile card** with `<%= %>`
bindings to the properties above. Layout, CSS classes, the other three cards, and the
"Save changes" / "Cancel" buttons stay exactly as they are.

## Edge cases

- No session / non-student user → redirect to login.
- Null phone, mailing address, or intake date → empty string ("—" for intake).
- Single-word full name → initials use just the first letter.

## Testing

Manual verification (per project convention — WebForms, no automated suite):

1. Run `db/user_contact_info.sql` against the live LocalDB; confirm the columns exist
   and seeded students have phone/address values.
2. Build via PowerShell `msbuild`.
3. Log in as a seeded student and open `account.aspx`; confirm every Profile field
   matches the DB row (name, initials, username, email, programme, status, intake
   month/year, Year·Trimester standing, phone, address).
4. Confirm the other three cards are visually unchanged.
