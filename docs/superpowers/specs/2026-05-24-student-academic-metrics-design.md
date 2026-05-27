# Design: Academic metrics on StudentService

**Date:** 2026-05-24
**Status:** Approved

## Overview

Extend the student profile with four read-only academic metrics — **CGPA**,
**attendance rate**, **credits earned**, and **all-time enrolled courses** —
backed by the existing schema. This replaces the hardcoded mock values already
present in `shared/dashboard.aspx` (GPA `3.78`, Attendance `94%`, Credits `78`,
and the "My Courses" grid).

Tables involved: `GRADES`, `ATTENDANCE`, `ENROLMENTS`, `COURSES`,
`COURSE_OFFERINGS`, `TEACHINGS`, `LECTURERS`, `SEMESTERS`, `STUDENTS`.

## Architecture

Follows the established one-concern-per-service pattern used by
`TimetableService` and `AssignmentService`: small, static, read-only services
whose SQL is self-sufficient, that return `null`/empty/`0` for missing data and
let SQL exceptions propagate. `StudentService.MapStudent` aggregates them onto
the `Student` object exactly as it already does for `TodayClasses` and
`AssignmentsDueThisWeek`.

Two new services:

| Service | Method | Returns |
|---|---|---|
| `GradeService` | `GetSummary(int userId)` | `GradeSummary { decimal? Cgpa; int CreditsEarned; }` — one query yields both (shared join) |
| `AttendanceService` | `GetCurrentSemesterRate(int userId)` | `decimal?` — fraction 0–1, `null` when no records |
| `EnrolmentService` | `GetCourses(int userId)` | `List<EnrolledCourse>` |

New value types:

```csharp
public class GradeSummary
{
    public decimal? Cgpa { get; set; }      // null when no published grades
    public int CreditsEarned { get; set; }  // 0 when none
}

public class EnrolledCourse
{
    public int OfferingId { get; set; }
    public string CourseCode { get; set; }
    public string CourseName { get; set; }
    public int CreditHours { get; set; }
    public string LecturerName { get; set; } // "" when no lecturer assigned
    public string SemesterName { get; set; }
    public string Status { get; set; }       // ENROLLED, etc.
}
```

New `Student` members (populated in `MapStudent`):

```csharp
public decimal? Cgpa { get; set; }
public int CreditsEarned { get; set; }
public decimal? AttendanceRate { get; set; }   // fraction 0–1, null when no records
public List<EnrolledCourse> Courses { get; set; }
```

## Computation semantics

### CGPA — cumulative, credit-weighted

Over **all published grades across all semesters**:

```
CGPA = SUM(g.gpa * c.credit_hours) / SUM(c.credit_hours)   where g.published = 1
```

The query returns the two sums separately; the division is performed in C# so an
empty set yields `null` instead of a divide-by-zero. Failed courses (gpa `0.00`)
are included, as is standard for CGPA. Rounded to 2 decimals for display.

Join path: `STUDENTS s → ENROLMENTS e → COURSE_OFFERINGS o → COURSES c`,
`ENROLMENTS e → GRADES g`, filtered to `s.user_id = @userId AND g.published = 1`.

### Credits earned — all published grades

`SUM(c.credit_hours)` over the **same published-grade set** (`g.published = 1`),
counting both passed and failed courses. Returns `0` when there are none.
Computed in the same `GetSummary` query as CGPA.

### Attendance rate — current semester only

```
rate = COUNT(status = 'PRESENT') / COUNT(*)
```

over `ATTENDANCE` rows belonging to the student's **current-semester**
enrolments. `LATE` counts as absent (only `PRESENT` is credited). Returns `null`
when the student has no attendance records this semester (distinct from a real
`0`).

Join path: `STUDENTS s → ENROLMENTS e → COURSE_OFFERINGS o → SEMESTERS sem`
(`sem.is_current = 1`), `ENROLMENTS e → ATTENDANCE a`, filtered to
`s.user_id = @userId`. Numerator and denominator counts are returned and divided
in C#.

### Courses — all-time enrollment

**Every** enrolment the student has ever had (all statuses, all semesters), one
row per enrolment, ordered by `SEMESTERS.name` then `COURSES.course_code`.

An offering may be taught by more than one lecturer, which would otherwise
duplicate course rows. To get a single lecturer name without duplication, use:

```sql
OUTER APPLY (
    SELECT TOP 1 l.full_name
    FROM TEACHINGS t
    JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id
    WHERE t.offering_id = o.offering_id
    ORDER BY t.teaching_id
) lec
```

`LecturerName` is the empty string when no lecturer is assigned.

Join path: `STUDENTS s → ENROLMENTS e → COURSE_OFFERINGS o → COURSES c`,
`o → SEMESTERS sem`, plus the `OUTER APPLY` above; filtered to
`s.user_id = @userId`.

## Data flow

`dashboard.aspx.cs` already calls `StudentService.GetByUserId(...)` in
`Page_Load`. `MapStudent` will additionally call `GradeService.GetSummary`,
`AttendanceService.GetCurrentSemesterRate`, and `EnrolmentService.GetCourses`,
populating the four new `Student` members.

New code-behind display properties expose them with safe formatting:

- `Cgpa` → `"—"` when `null`, else 2-decimal string.
- `AttendanceRatePercent` → `"—"` when `null`, else rounded integer percent.
- `CreditsEarned` → integer.
- `Courses` → bound to the "My Courses" grid (code, name, lecturer).

The hardcoded mock markup in `dashboard.aspx` is replaced with bindings to these
properties. Each service keeps its SQL self-sufficient (current-semester scoping
via `SEMESTERS.is_current = 1`), matching commit `33d53cb`.

## Error handling

Identical to the existing services: SQL exceptions propagate to the caller;
missing data returns `null`/empty/`0` rather than throwing. Nullable returns
(`Cgpa`, `AttendanceRate`) distinguish "no data" from a genuine `0`.

## Testing / verification

No test project exists in this solution; these services are verified the same way
as `TimetableService` and `AssignmentService` — by running each query against the
seeded database (`db/seed_data.sql`) and confirming the dashboard renders the
computed values. The implementation plan will include concrete check queries and
their expected results derived from the seed data.
