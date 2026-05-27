# StudentService (read-only profile) — Design

**Date:** 2026-05-24
**Status:** Approved for planning

## Purpose

Introduce the first class in the empty `services/` folder: a `StudentService`
that reads a student's profile data. Today, data access lives inline in page
code-behind (e.g. `shared/login.aspx.cs` runs SQL directly). This service moves
student-profile reads behind a reusable, testable boundary so pages (account,
dashboard) can fetch a student's details without embedding SQL or column-name
strings.

Scope is deliberately narrow: **read-only profile data**. No updates, no admin
CRUD, no academic aggregation (enrolments/grades/attendance). Those can be added
later as separate methods or services.

## Architecture

One self-contained file, `services/StudentService.cs`, namespace `src.services`.
It contains both the data model and the service, mirroring the lightweight style
of the existing `db/Db.cs` (no separate Models folder is introduced — YAGNI for a
single read-only draft; trivially splittable later).

### `Student` (POCO)

Plain data object representing a joined student profile:

| Property        | Type       | Source                          |
|-----------------|------------|---------------------------------|
| `StudentId`     | `int`      | `STUDENTS.student_id`           |
| `UserId`        | `int`      | `STUDENTS.user_id`              |
| `ProgrammeId`   | `int`      | `STUDENTS.programme_id`         |
| `FullName`      | `string`   | `STUDENTS.full_name`            |
| `DateOfBirth`   | `DateTime?`| `STUDENTS.date_of_birth` (null) |
| `Status`        | `string`   | `STUDENTS.status`               |
| `Email`         | `string`   | `USERS.email`                   |
| `Username`      | `string`   | `USERS.username`                |
| `ProgrammeName` | `string`   | `PROGRAMMES.programme_name`     |
| `ProgrammeCode` | `string`   | `PROGRAMMES.programme_code`     |

### `StudentService` (static class)

Static, matching the `Db` pattern. Two read methods:

- `Student GetByUserId(int userId)`
  Joins `STUDENTS` → `USERS` → `PROGRAMMES`, filtered on `STUDENTS.user_id`.
  Returns the populated `Student`, or `null` if no matching student row exists.
  (`STUDENTS.user_id` is unique, so at most one row.)

- `Student GetByStudentId(int studentId)`
  Same join, filtered on `STUDENTS.student_id`. Returns `Student` or `null`.

A private `MapStudent(SqlDataReader reader)` helper builds the POCO from a reader
row, so both methods share one mapping definition.

## Data flow

```
Page code-behind  ->  StudentService.GetByUserId(userId)
                          |
                          v
                   Db.OpenConnection()  (existing helper)
                          |
                          v
                   parameterized SqlCommand (SELECT ... JOIN)
                          |
                          v
                   SqlDataReader -> MapStudent() -> Student  (or null)
```

The SELECT joins on:
`STUDENTS s JOIN USERS u ON s.user_id = u.user_id JOIN PROGRAMMES p ON s.programme_id = p.programme_id`.

## Data access conventions

Follows the established pattern in `shared/login.aspx.cs`:

- Acquire connection via `Db.OpenConnection()`.
- Wrap connection, command, and reader in `using` blocks.
- Parameterize every value with `cmd.Parameters.AddWithValue` — no string
  concatenation of inputs (prevents SQL injection).
- Read `date_of_birth` defensively: it is nullable, so check `IsDBNull` before
  casting to `DateTime`.

## Error handling

- **Not found** is represented by returning `null`, not by throwing.
- SQL/connection exceptions are **not** caught inside the service; they propagate
  to the caller, which decides how to surface the failure (the service has no UI
  context). This keeps the service a pure data boundary.

## Testing

The codebase has no test project today, so verification for this draft is:

1. **Compiles** as part of the `src` project (added to `src.csproj` if the project
   does not auto-include files).
2. **Manual smoke check**: call `StudentService.GetByUserId(1)` (seed user `1` is a
   STUDENT) from a page or scratch handler and confirm a populated `Student` comes
   back, and that an unknown id returns `null`.

A dedicated test project is out of scope for this draft and can be added when the
service layer grows.

## Out of scope

- Profile updates / writes.
- Admin student CRUD (list all, create, deactivate).
- Academic data (enrolments, grades, GPA, attendance).
- A shared Models folder / separate model file.
