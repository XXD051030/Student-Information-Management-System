# Per-Student Semester — Design

**Date:** 2026-05-25
**Status:** Approved for planning

## Problem

The schema tracks the institution's **calendar term** (`SEMESTERS` with a single
global `is_current` flag) but has no notion of **which semester of their
programme each individual student is in**. At INTI, three intakes a year means
two students can sit in the same calendar term (`2026-S2`) while one is in their
Semester 1 and the other in their Semester 4.

The dashboard exposes this gap as a visible bug: `Semester.Number`
(`services/SemesterService.cs`) parses the digit out of the calendar term *name*
— `"2026-S2"` → `"2"` — so the "Semester" label shows the trimester of the
calendar year, identical for every student regardless of how far into their
degree they are.

## Goal

Give each student their own current semester number, derived automatically, and
fix the dashboard to display it. Keep the shared calendar (`SEMESTERS` /
`is_current`) exactly as-is, since offerings, timetables, the academic calendar,
and the "current teaching week" all depend on it.

## Approach: intake-derived semester number

Record the calendar term each student **started** in, and compute their current
semester number as their position relative to that intake. Chosen over a stored
counter (goes stale) and over counting enrolled terms (Semester 0 for new
students, depends on complete enrolment data).

### 1. Schema change — one column, no new tables

Add to `STUDENTS`:

- `intake_semester_id INT NOT NULL`, foreign key → `SEMESTERS(semester_id)`.

Constraint decision: a student's intake **must** be a term that already exists
in `SEMESTERS`. The FK enforces this. If older students are ever needed, the
older terms get added to `SEMESTERS` first. This keeps the derivation math
trivial and correctness guaranteed by the FK.

`SEMESTERS`, `is_current`, and every table hanging off them are unchanged.

### 2. Derivation — a view does the math

New view `vw_student_semester`. Terms are ranked chronologically; the current
semester number is the distance from the student's intake to today's current
term, 1-based:

```
current_semester_no = (rank of current term) − (rank of intake term) + 1
```

```sql
CREATE VIEW dbo.vw_student_semester AS
WITH ordered AS (
    SELECT semester_id,
           is_current,
           ROW_NUMBER() OVER (ORDER BY start_date, semester_id) AS seq
    FROM dbo.SEMESTERS
),
cur AS (
    SELECT seq AS current_seq FROM ordered WHERE is_current = 1
)
SELECT s.student_id,
       s.intake_semester_id,
       intake.seq                                          AS intake_seq,
       cur.current_seq,
       CASE WHEN cur.current_seq - intake.seq + 1 < 1 THEN 1
            ELSE cur.current_seq - intake.seq + 1 END       AS current_semester_no
FROM dbo.STUDENTS s
JOIN ordered intake ON intake.semester_id = s.intake_semester_id
CROSS JOIN cur;
```

- Ranking by `start_date` (tie-broken by `semester_id`) avoids depending on
  identity-insert order.
- The `CASE` floors the result at 1 so a future-dated intake never shows a zero
  or negative semester.
- Assumes exactly one `is_current = 1` row, which the existing data guarantees.

**Worked example.** Terms ordered `2025-S3 (1) → 2026-S1 (2) → 2026-S2 (3)`,
current = `2026-S2`. A student with intake `2025-S3` → Semester 3; a student
with intake `2026-S2` → Semester 1.

### 3. Migration + seed

- Add the column as nullable, backfill `intake_semester_id` for existing
  `STUDENTS` rows, then alter to `NOT NULL` and add the FK. The live LocalDB has
  more rows than `seed_data.sql`, so the backfill is verified against the live
  DB before tightening to `NOT NULL`.
- Seed intakes so the demo reads sensibly: Ong (`student_id` 1) → `2025-S3`
  (Semester 3); the other seeded students spread across terms.

### 4. Application impact — two files

- `services/StudentService.cs`: `Student` gains `CurrentSemesterNo`, populated
  from `vw_student_semester` keyed by `student_id` (folded into the existing
  by-user lookup).
- `shared/dashboard.aspx.cs`: `SemesterNumber` returns the student's
  `CurrentSemesterNo` instead of `_semester.Number`.
- `services/SemesterService.cs`: `GetCurrent()`, `CurrentWeek`, and `TotalWeeks`
  are untouched — they remain the shared calendar and week counter. The unused
  `Semester.Number` property is removed once nothing references it.

### Display

Dashboard shows the bare number — "Semester 3" — matching the current
single-number layout. No programme label, no UI restructuring.

## Out of scope

Programme curriculum / study plan, prerequisites, course sections, study-break
gap handling, and moving `full_name` onto `USERS`. These were noted during
brainstorming but are deliberately deferred.

## Testing

- View math: with `2026-S2` current, assert intake `2025-S3` → 3, `2026-S1` → 2,
  `2026-S2` → 1, and a future intake → 1 (floor).
- FK rejects an intake `semester_id` not present in `SEMESTERS`.
- Dashboard renders the logged-in student's own number, and two students with
  different intakes in the same term show different numbers.
