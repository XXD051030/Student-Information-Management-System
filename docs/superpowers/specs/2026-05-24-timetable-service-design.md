# TimetableService (student timetable reads) — Design

**Date:** 2026-05-24
**Status:** Approved for planning

## Purpose

Provide read access to a student's class schedule. `StudentService` is
deliberately scoped to profile data only; timetable data is academic data and
gets its own boundary. `TimetableService` returns the scheduled classes for a
student's current-semester enrolments, supporting two views:

- the dashboard's "Today's Schedule" list, and
- a full weekly timetable page ("View timetable").

Scope: **read-only**, **current semester only**, **enrolled classes only**. No
writes, no attendance, no grades, no lecturer details.

## Architecture

One self-contained file, `services/TimetableService.cs`, namespace
`src.services`, holding a `ClassSession` model and a static `TimetableService`.
Mirrors the established `StudentService` / `Db` pattern (ADO.NET via
`Db.OpenConnection()`, parameterized `SqlCommand`, `using` blocks).

### `ClassSession` (POCO)

One scheduled class meeting:

| Property      | Type       | Source                          |
|---------------|------------|---------------------------------|
| `OfferingId`  | `int`      | `COURSE_OFFERINGS.offering_id`  |
| `CourseCode`  | `string`   | `COURSES.course_code`           |
| `CourseName`  | `string`   | `COURSES.course_name`           |
| `Venue`       | `string`   | `TIMETABLES.venue`              |
| `DayOfWeek`   | `string`   | `TIMETABLES.day_of_week`        |
| `StartTime`   | `TimeSpan` | `TIMETABLES.start_time` (`time`)|
| `EndTime`     | `TimeSpan` | `TIMETABLES.end_time` (`time`)  |

### `TimetableService` (static class)

- `List<ClassSession> GetWeeklyTimetable(int userId)`
  All current-semester enrolled classes for the student, ordered Monday→Sunday
  then by start time. Returns an empty list if none.

- `List<ClassSession> GetTodayClasses(int userId)`
  Same set, filtered to rows where `day_of_week` equals today's name
  (`DateTime.Now.DayOfWeek.ToString()`, e.g. `"Monday"`), ordered by start time.
  Returns an empty list if none.

A private `MapSession(SqlDataReader)` helper builds the POCO; both methods share
it and the shared FROM/WHERE.

## Data flow

```
Page code-behind -> TimetableService.GetTodayClasses(userId)
                       |
                       v
                Db.OpenConnection()
                       |
                       v
                parameterized SqlCommand (SELECT ... JOINs)
                       |
                       v
                SqlDataReader -> MapSession() per row -> List<ClassSession>
```

### Shared query

```sql
SELECT o.offering_id, c.course_code, c.course_name,
       t.venue, t.day_of_week, t.start_time, t.end_time
FROM TIMETABLES t
JOIN COURSE_OFFERINGS o ON t.offering_id = o.offering_id
JOIN COURSES c          ON o.course_id   = c.course_id
JOIN SEMESTERS sem      ON o.semester_id = sem.semester_id
JOIN ENROLMENTS e       ON e.offering_id = o.offering_id
JOIN STUDENTS s         ON e.student_id  = s.student_id
WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED'
```

- **Weekly** appends:
  `ORDER BY CASE t.day_of_week WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3 WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 WHEN 'Sunday' THEN 7 ELSE 8 END, t.start_time`
  (string day names don't sort chronologically, so an explicit CASE order is required.)
- **Today** appends:
  `AND t.day_of_week = @today  ORDER BY t.start_time`

## Data access conventions

Follows `StudentService` / `shared/login.aspx.cs`:

- `Db.OpenConnection()`; connection, command, reader each in `using` blocks.
- Every value parameterized via `cmd.Parameters.AddWithValue` (`@userId`, `@today`).
- `start_time`/`end_time` read as `TimeSpan` via `(TimeSpan)reader[...]` (SQL
  `time` maps to `TimeSpan`); both are `NOT NULL` so no DBNull guard needed.

## Error handling

- **No rows** is represented by an **empty list** (not null) — natural for a
  collection return type. (Contrast: `StudentService` returns `null` for a single
  record.)
- SQL/connection exceptions are **not** caught; they propagate to the caller.

## Testing

No test project exists. Verification:

1. **Compiles** as part of the `src` project (must be registered in `src.csproj`).
2. **Manual smoke check**: `TimetableService.GetWeeklyTimetable(1)` for seed user 1
   (student, enrolled in offerings 1 and 2 which have timetable rows on Monday and
   Tuesday) returns 2 sessions ordered Monday then Tuesday; `GetTodayClasses(1)`
   returns the subset matching the current day (possibly empty).

## Seed data reference (for verification)

- User 1 (student) enrolments: offerings 1 and 2, both `status = 'ENROLLED'`.
- TIMETABLES: offering 1 → Monday 09:00–11:00 (Room A1-01); offering 2 → Tuesday
  14:00–16:00 (Room B2-03).
- `day_of_week` values are full English day names.

## Out of scope

- Writes / schedule editing.
- Attendance, grades, assignments.
- Lecturer name/details (joining `TEACHINGS` risks row duplication when an
  offering has multiple teachers; add later only if a page needs it).
- Past/future semesters (current semester only).
