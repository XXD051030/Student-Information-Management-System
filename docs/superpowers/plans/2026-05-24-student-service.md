# StudentService (read-only profile) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a read-only `StudentService` to the empty `services/` folder that fetches a student's joined profile by user id or student id.

**Architecture:** One self-contained file, `services/StudentService.cs` (namespace `src.services`), holding a `Student` POCO and a static `StudentService`. Data access reuses the existing `Db.OpenConnection()` helper with parameterized `SqlCommand`s, mirroring `shared/login.aspx.cs`. Returns the populated `Student` or `null` when not found; SQL exceptions propagate to callers.

**Tech Stack:** ASP.NET Web Forms, .NET Framework 4.7.2, classic (non-SDK) csproj, ADO.NET (`System.Data.SqlClient`), SQL Server.

---

## Important context for the engineer

- **The project does NOT auto-include source files.** `src.csproj` is a classic MSBuild project: every compiled file is listed explicitly under a `<Compile Include="...">` item (see `db\Db.cs` at line 99). A new `.cs` file will be silently ignored by the build until it is registered in the csproj. **Both** creating the file **and** editing the csproj are required.
- There is **no test project / test framework** in this solution. Verification is: (1) the solution compiles, and (2) a manual smoke check against seed data. The plan reflects this instead of forcing a unit-test harness that doesn't exist.
- Existing data-access reference: `shared/login.aspx.cs` (uses `Db.OpenConnection()`, `using` blocks, `cmd.Parameters.AddWithValue`).
- Relevant schema columns:
  - `STUDENTS`: `student_id`, `user_id`, `programme_id`, `full_name`, `date_of_birth` (nullable `date`), `status`
  - `USERS`: `user_id`, `username`, `email`
  - `PROGRAMMES`: `programme_id`, `programme_name`, `programme_code`
- Seed data: user_id `1` is a `STUDENT` (`p26017888`). Use it for the smoke check.
- All paths below are relative to the project directory:
  `C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src`

---

## Task 1: Create the StudentService source file

**Files:**
- Create: `services\StudentService.cs`

- [ ] **Step 1: Create `services\StudentService.cs` with the full contents below**

```csharp
using System;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// Read-only view of a student's profile, joined across
    /// STUDENTS, USERS and PROGRAMMES.
    /// </summary>
    public class Student
    {
        public int StudentId { get; set; }
        public int UserId { get; set; }
        public int ProgrammeId { get; set; }
        public string FullName { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string Status { get; set; }
        public string Email { get; set; }
        public string Username { get; set; }
        public string ProgrammeName { get; set; }
        public string ProgrammeCode { get; set; }
    }

    /// <summary>
    /// Read-only data access for student profiles. Returns null when no
    /// matching student exists. SQL exceptions are not caught here; they
    /// propagate to the caller.
    /// </summary>
    public static class StudentService
    {
        private const string SelectProfile =
            "SELECT s.student_id, s.user_id, s.programme_id, s.full_name, " +
            "s.date_of_birth, s.status, u.email, u.username, " +
            "p.programme_name, p.programme_code " +
            "FROM STUDENTS s " +
            "JOIN USERS u ON s.user_id = u.user_id " +
            "JOIN PROGRAMMES p ON s.programme_id = p.programme_id ";

        public static Student GetByUserId(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectProfile + "WHERE s.user_id = @userId", conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    return reader.Read() ? MapStudent(reader) : null;
                }
            }
        }

        public static Student GetByStudentId(int studentId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectProfile + "WHERE s.student_id = @studentId", conn))
            {
                cmd.Parameters.AddWithValue("@studentId", studentId);
                using (var reader = cmd.ExecuteReader())
                {
                    return reader.Read() ? MapStudent(reader) : null;
                }
            }
        }

        private static Student MapStudent(SqlDataReader reader)
        {
            return new Student
            {
                StudentId = (int)reader["student_id"],
                UserId = (int)reader["user_id"],
                ProgrammeId = (int)reader["programme_id"],
                FullName = reader["full_name"].ToString(),
                DateOfBirth = reader["date_of_birth"] == DBNull.Value
                    ? (DateTime?)null
                    : (DateTime)reader["date_of_birth"],
                Status = reader["status"].ToString(),
                Email = reader["email"].ToString(),
                Username = reader["username"].ToString(),
                ProgrammeName = reader["programme_name"].ToString(),
                ProgrammeCode = reader["programme_code"].ToString()
            };
        }
    }
}
```

- [ ] **Step 2: Verify the file exists**

Run: `Get-ChildItem services\StudentService.cs`
Expected: the file is listed (non-zero length).

---

## Task 2: Register the file in the project

**Files:**
- Modify: `src.csproj` (the `<ItemGroup>` containing `<Compile Include="db\Db.cs" />`, around line 99)

- [ ] **Step 1: Add a Compile entry for the new file**

In `src.csproj`, find this line (inside the `<ItemGroup>` that lists the `<Compile>` items):

```xml
    <Compile Include="db\Db.cs" />
```

Add the following line immediately after it:

```xml
    <Compile Include="services\StudentService.cs" />
```

- [ ] **Step 2: Verify the entry was added**

Run: `Select-String -Path src.csproj -Pattern "services\\StudentService.cs"`
Expected: one match showing the new `<Compile Include="services\StudentService.cs" />` line.

---

## Task 3: Build the solution

**Files:** none (verification only)

- [ ] **Step 1: Build with MSBuild**

Run (from the project directory):
```
msbuild src.csproj /t:Build /p:Configuration=Debug /nologo /verbosity:minimal
```
Expected: `Build succeeded.` with `0 Error(s)`.

If `msbuild` is not on PATH, use the Developer Command Prompt for Visual Studio, or the full path, e.g.:
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /verbosity:minimal
```
As a last resort, open `src.sln` in Visual Studio and Build (Ctrl+Shift+B); confirm 0 errors.

- [ ] **Step 2: Confirm the new type compiled into the assembly**

The build emits `bin\src.dll`. The build succeeding with the new `<Compile>` entry present is sufficient confirmation that `src.services.StudentService` is included.

---

## Task 4: Manual smoke check (against seed data)

**Files:** none (verification only). This step requires the SQL Server database to be present and the `SimsDb` connection string in `Web.config` to be valid. If the DB is not available in this environment, record that and skip — the build in Task 3 is the gating check.

- [ ] **Step 1: Add a temporary verification call**

In `shared\login.aspx.cs`, inside `Page_Load`, temporarily add at the very top (after the cache lines):

```csharp
            // TEMP smoke check — remove after verifying
            var smokeStudent = src.services.StudentService.GetByUserId(1);
            System.Diagnostics.Debug.WriteLine(
                "SMOKE: " + (smokeStudent == null
                    ? "null"
                    : smokeStudent.FullName + " / " + smokeStudent.Email + " / " + smokeStudent.ProgrammeName));
            var smokeMissing = src.services.StudentService.GetByStudentId(999999);
            System.Diagnostics.Debug.WriteLine("SMOKE missing: " + (smokeMissing == null ? "null (expected)" : "UNEXPECTED ROW"));
```

- [ ] **Step 2: Run the app and load the login page**

Run the site (F5 in Visual Studio, or `dotnet` is not applicable here — use IIS Express via VS). Navigate to `/shared/login.aspx`.
Expected (in the Visual Studio Output / Debug window):
- `SMOKE: <a full name> / <an email> / <a programme name>` — a populated student for user 1.
- `SMOKE missing: null (expected)` — confirms not-found returns null.

- [ ] **Step 3: Remove the temporary smoke-check code**

Delete the two `// TEMP smoke check` blocks added in Step 1 from `shared\login.aspx.cs`. Re-build (Task 3 Step 1) to confirm it still compiles cleanly.

---

## Task 5: Commit

**Files:**
- `services\StudentService.cs` (new)
- `src.csproj` (modified)

- [ ] **Step 1: Stage only the StudentService changes**

```
git add services/StudentService.cs src.csproj
```

- [ ] **Step 2: Verify nothing unrelated is staged**

Run: `git status`
Expected: only `services/StudentService.cs` (new file) and `src.csproj` (modified) are staged. The many unrelated working-tree changes from the branch must remain unstaged.

- [ ] **Step 3: Commit**

```
git commit -m "feat(services): add read-only StudentService

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Notes

- **DRY:** the SELECT/JOIN is defined once in `SelectProfile`; both methods append only their WHERE clause. Mapping is centralized in `MapStudent`.
- **YAGNI:** no updates, admin CRUD, academic data, or separate Models folder — all explicitly out of scope per the design.
- **Security:** every input is parameterized; no string concatenation of user values.
