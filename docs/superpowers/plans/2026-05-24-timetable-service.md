# TimetableService (student timetable reads) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a read-only `TimetableService` that returns a student's current-semester enrolled classes, both as a full week and filtered to today.

**Architecture:** One self-contained file, `services/TimetableService.cs` (namespace `src.services`), holding a `ClassSession` POCO and a static `TimetableService`. Reuses `Db.OpenConnection()` + parameterized `SqlCommand`, mirroring `services/StudentService.cs`. Returns `List<ClassSession>` (empty when no rows); SQL exceptions propagate.

**Tech Stack:** ASP.NET Web Forms, .NET Framework 4.7.2, classic (non-SDK) csproj, ADO.NET (`System.Data.SqlClient`), SQL Server.

---

## Important context for the engineer

- **The project does NOT auto-include source files.** `src.csproj` is a classic MSBuild project; every compiled `.cs` is listed explicitly under `<Compile Include="...">`. The existing `services/StudentService.cs` is registered at `src.csproj` line 100. A new file must be registered too or it is silently excluded from the build.
- **Reference implementation:** `services/StudentService.cs` — copy its structure (shared SELECT const, `using` blocks, `AddWithValue`, private mapper). This is the same pattern, applied to a list-returning query.
- **No test project exists.** Verification = compiles + manual smoke check.
- **Schema (verified):**
  - `TIMETABLES`: `timetable_id`, `offering_id`, `venue` (varchar), `day_of_week` (varchar, full English names like `'Monday'`), `start_time` (`time`), `end_time` (`time`)
  - `COURSE_OFFERINGS`: `offering_id`, `course_id`, `semester_id`
  - `COURSES`: `course_id`, `course_name`, `course_code`
  - `SEMESTERS`: `semester_id`, `is_current` (bit)
  - `ENROLMENTS`: `enrolment_id`, `student_id`, `offering_id`, `status` (seed value for active = `'ENROLLED'`)
  - `STUDENTS`: `student_id`, `user_id`
- SQL `time` columns map to .NET `TimeSpan`. `DateTime.Now.DayOfWeek.ToString()` yields `"Monday"` etc., matching `day_of_week`.
- All paths below are relative to: `C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src`

---

## Task 1: Create the TimetableService source file

**Files:**
- Create: `services\TimetableService.cs`

- [ ] **Step 1: Create `services\TimetableService.cs` with EXACTLY these contents**

```csharp
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// One scheduled class meeting on a student's timetable.
    /// </summary>
    public class ClassSession
    {
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public string Venue { get; set; }
        public string DayOfWeek { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }

    /// <summary>
    /// Read-only access to a student's current-semester class schedule.
    /// Returns an empty list when there are no matching classes. SQL
    /// exceptions are not caught here; they propagate to the caller.
    /// </summary>
    public static class TimetableService
    {
        private const string SelectSchedule =
            "SELECT o.offering_id, c.course_code, c.course_name, " +
            "t.venue, t.day_of_week, t.start_time, t.end_time " +
            "FROM TIMETABLES t " +
            "JOIN COURSE_OFFERINGS o ON t.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id " +
            "WHERE s.user_id = @userId AND sem.is_current = 1 AND e.status = 'ENROLLED' ";

        private const string DayOrder =
            "CASE t.day_of_week " +
            "WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3 " +
            "WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 " +
            "WHEN 'Sunday' THEN 7 ELSE 8 END";

        public static List<ClassSession> GetWeeklyTimetable(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                SelectSchedule + "ORDER BY " + DayOrder + ", t.start_time", conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                return ReadSessions(cmd);
            }
        }

        public static List<ClassSession> GetTodayClasses(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(
                SelectSchedule + "AND t.day_of_week = @today ORDER BY t.start_time", conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@today", DateTime.Now.DayOfWeek.ToString());
                return ReadSessions(cmd);
            }
        }

        private static List<ClassSession> ReadSessions(SqlCommand cmd)
        {
            var sessions = new List<ClassSession>();
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    sessions.Add(MapSession(reader));
                }
            }
            return sessions;
        }

        private static ClassSession MapSession(SqlDataReader reader)
        {
            return new ClassSession
            {
                OfferingId = (int)reader["offering_id"],
                CourseCode = reader["course_code"].ToString(),
                CourseName = reader["course_name"].ToString(),
                Venue = reader["venue"].ToString(),
                DayOfWeek = reader["day_of_week"].ToString(),
                StartTime = (TimeSpan)reader["start_time"],
                EndTime = (TimeSpan)reader["end_time"]
            };
        }
    }
}
```

- [ ] **Step 2: Verify the file exists**

Run: `Get-ChildItem services\TimetableService.cs`
Expected: the file is listed (non-zero length).

---

## Task 2: Register the file in the project

**Files:**
- Modify: `src.csproj` (the `<ItemGroup>` containing the `<Compile>` items)

- [ ] **Step 1: Add a Compile entry**

In `src.csproj`, find:

```xml
    <Compile Include="services\StudentService.cs" />
```

Add immediately after it:

```xml
    <Compile Include="services\TimetableService.cs" />
```

- [ ] **Step 2: Verify the entry was added**

Run: `Select-String -Path src.csproj -Pattern "services\\TimetableService.cs"`
Expected: one match.

---

## Task 3: Build the solution

**Files:** none (verification only)

- [ ] **Step 1: Build with MSBuild**

Run from the project directory:
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /verbosity:minimal
```
(If that path doesn't exist, use `msbuild` on PATH or the VS Developer prompt.)
Expected: `src -> ...\bin\src.dll` with 0 errors.

---

## Task 4: Manual smoke check (against seed data) — defer to human if DB unavailable

**Files:** none. Requires a live SQL Server DB + running the app. If the DB/app cannot run headlessly in this environment, record that Task 4 is deferred to the human and rely on Task 3 (build) as the gating check. **Do not leave temporary code committed.**

- [ ] **Step 1: Add a temporary verification call**

In `shared\dashboard.aspx.cs`, inside `Page_Load`, after `_student = ...`, temporarily add:

```csharp
            // TEMP smoke check — remove after verifying
            var week = src.services.TimetableService.GetWeeklyTimetable((int)Session["user_id"]);
            System.Diagnostics.Debug.WriteLine("SMOKE week count: " + week.Count);
            foreach (var cs in week)
                System.Diagnostics.Debug.WriteLine("  " + cs.DayOfWeek + " " + cs.StartTime + " " + cs.CourseCode + " " + cs.Venue);
            var today = src.services.TimetableService.GetTodayClasses((int)Session["user_id"]);
            System.Diagnostics.Debug.WriteLine("SMOKE today count: " + today.Count);
```

- [ ] **Step 2: Run the app, log in as the seed student, open the dashboard**

Run the site (VS / IIS Express), log in as user 1 (`p26017888`), load `/shared/dashboard.aspx`.
Expected in the Debug/Output window:
- `SMOKE week count: 2` with one Monday 09:00:00 (CSC… / Room A1-01) and one Tuesday 14:00:00 (Room B2-03) line, Monday listed before Tuesday.
- `SMOKE today count: N` — equals the number of the above whose day matches the actual current day (0 if today is neither Monday nor Tuesday).

- [ ] **Step 3: Remove the temporary smoke-check code**

Delete the `// TEMP smoke check` block from `shared\dashboard.aspx.cs` and re-build (Task 3) to confirm it still compiles.

---

## Task 5: Commit

**Files:**
- `services\TimetableService.cs` (new)
- `src.csproj` (modified)

- [ ] **Step 1: Stage only the TimetableService changes**

```
git add services/TimetableService.cs src.csproj
```

- [ ] **Step 2: Verify nothing unrelated is staged**

Run: `git status`
Expected: only `services/TimetableService.cs` (new) and `src.csproj` (modified) staged. The other working-tree changes on this branch remain unstaged.

- [ ] **Step 3: Commit**

```
git commit -m "feat(services): add read-only TimetableService

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Notes

- **DRY:** the SELECT/JOIN/WHERE lives once in `SelectSchedule`; the day-ordering `CASE` lives once in `DayOrder`; row reading is centralized in `ReadSessions` + `MapSession`.
- **YAGNI:** no lecturer join, no writes, no other-semester data — all out of scope per the design.
- **Security:** `@userId` and `@today` are parameterized; no concatenation of user-supplied values (the appended fragments are fixed string literals).
- **Return contract:** empty `List<ClassSession>` (never null) when there are no classes.
