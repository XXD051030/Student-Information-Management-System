# Per-Student Semester Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give each student their own current semester number, derived from the term they enrolled in (intake), and display it on the dashboard instead of the calendar trimester digit.

**Architecture:** Add `intake_semester_id` to `STUDENTS` (FK → `SEMESTERS`). A view `vw_student_semester` computes `current_semester_no` as the chronological distance from the student's intake term to the current term. `StudentService` reads that number via a join; the dashboard's `SemesterNumber` returns it. The shared calendar (`SEMESTERS` / `is_current`) is unchanged.

**Tech Stack:** SQL Server (LocalDB), ASP.NET WebForms (C#, .NET Framework), ADO.NET (`System.Data.SqlClient`). No unit-test project exists in this repo — DB behaviour is verified with `sqlcmd` queries and C# changes are verified by building with MSBuild plus a `sqlcmd` cross-check (per project convention).

---

## Tooling reference (used throughout)

**Build** (PowerShell tool — NOT Git Bash, which mangles `/t:` `/p:` switches):
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```
Run from `5026CMD Software Engineer/src/src`.

**SQL checks** (sqlcmd is not on PATH):
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "<query>"
```

**Live data this plan assumes** (verified 2026-05-25): `SEMESTERS` has `2025-S3` (id 1), `2026-S1` (id 2), `2026-S2` (id 3, `is_current = 1`). `STUDENTS` has ids 1–4 (Ong, Lee, Nurul, Raj).

## File structure

- **Create** `db/student_intake_semester.sql` — idempotent migration: add column, backfill, enforce NOT NULL, add FK, create the view. This is the dev source of truth, like the old `db/auth_tokens.sql` before it was folded into the dump.
- **Modify** `db/seed_data.sql` — include `intake_semester_id` in the `STUDENTS` insert so a fresh rebuild seeds intakes.
- **Modify** `services/StudentService.cs` — add `CurrentSemesterNo` to `Student`; join the view into the profile query and map it.
- **Modify** `shared/dashboard.aspx.cs` — `SemesterNumber` returns the student's number.
- **Modify** `services/SemesterService.cs` — remove the now-unused `Semester.Number` property.

> **Out of scope:** Regenerating the full SSMS dump `db/student_information_management_system.sql` to include the new column/FK/view is a follow-up the user performs in SSMS (matching how `auth_tokens.sql` was folded in). Nothing in this plan depends on it.

---

## Task 1: DB migration — intake column, backfill, FK, and the view

**Files:**
- Create: `db/student_intake_semester.sql`

- [ ] **Step 1: Confirm the view does not exist yet (failing check)**

Run:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT student_id, current_semester_no FROM dbo.vw_student_semester ORDER BY student_id;"
```
Expected: FAIL — `Invalid object name 'dbo.vw_student_semester'.`

- [ ] **Step 2: Create the migration script**

Create `db/student_intake_semester.sql` with exactly this content:

```sql
/******************************************************************************
 Per-student semester: intake term column + derivation view.
 Idempotent — safe to run more than once against the live DB.
******************************************************************************/
USE [StudentInformationManagementSystem];
GO

/* 1. Add intake_semester_id, nullable first so existing rows can be backfilled */
IF COL_LENGTH('dbo.STUDENTS', 'intake_semester_id') IS NULL
    ALTER TABLE dbo.STUDENTS ADD intake_semester_id INT NULL;
GO

/* 2. Backfill existing students (only rows still NULL).
      Term ids: 1 = 2025-S3, 2 = 2026-S1, 3 = 2026-S2 (current).
      Intended current semester numbers: Ong 3, Lee 2, Nurul 1, Raj 3. */
UPDATE dbo.STUDENTS SET intake_semester_id = 1 WHERE student_id = 1 AND intake_semester_id IS NULL;
UPDATE dbo.STUDENTS SET intake_semester_id = 2 WHERE student_id = 2 AND intake_semester_id IS NULL;
UPDATE dbo.STUDENTS SET intake_semester_id = 3 WHERE student_id = 3 AND intake_semester_id IS NULL;
UPDATE dbo.STUDENTS SET intake_semester_id = 1 WHERE student_id = 4 AND intake_semester_id IS NULL;

/* Safety net: any student not listed above gets the current term as intake */
UPDATE dbo.STUDENTS
SET intake_semester_id = (SELECT semester_id FROM dbo.SEMESTERS WHERE is_current = 1)
WHERE intake_semester_id IS NULL;
GO

/* 3. Enforce NOT NULL now that every row has a value */
ALTER TABLE dbo.STUDENTS ALTER COLUMN intake_semester_id INT NOT NULL;
GO

/* 4. Foreign key to SEMESTERS */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'fk_student_intake_semester')
    ALTER TABLE dbo.STUDENTS WITH CHECK
        ADD CONSTRAINT fk_student_intake_semester
        FOREIGN KEY (intake_semester_id) REFERENCES dbo.SEMESTERS (semester_id);
GO

/* 5. Derivation view.
      current_semester_no = (rank of current term) - (rank of intake term) + 1,
      ranked chronologically, floored at 1, CAST to INT so callers read Int32. */
CREATE OR ALTER VIEW dbo.vw_student_semester AS
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
       intake.seq      AS intake_seq,
       cur.current_seq,
       CAST(CASE WHEN cur.current_seq - intake.seq + 1 < 1 THEN 1
                 ELSE cur.current_seq - intake.seq + 1 END AS INT) AS current_semester_no
FROM dbo.STUDENTS s
JOIN ordered intake ON intake.semester_id = s.intake_semester_id
CROSS JOIN cur;
GO
```

- [ ] **Step 3: Apply the migration to the live DB**

Run:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -i "db\student_intake_semester.sql"
```
Expected: completes with no error messages (rows-affected notices are fine).

- [ ] **Step 4: Verify the derived numbers (passing check)**

Run:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT student_id, intake_semester_id, current_semester_no FROM dbo.vw_student_semester ORDER BY student_id;"
```
Expected rows:
```
student_id  intake_semester_id  current_semester_no
1           1                   3
2           2                   2
3           3                   1
4           1                   3
```

- [ ] **Step 5: Verify the FK rejects a bad intake (constraint check)**

Run:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "UPDATE dbo.STUDENTS SET intake_semester_id = 999 WHERE student_id = 1;"
```
Expected: FAIL — `The UPDATE statement conflicted with the FOREIGN KEY constraint "fk_student_intake_semester"`. (No row is changed; student 1 stays at intake 1.)

- [ ] **Step 6: Commit**

```
git add "db/student_intake_semester.sql"
git commit -m "feat(db): add per-student intake semester and derivation view"
```

---

## Task 2: Seed intakes for fresh rebuilds

**Files:**
- Modify: `db/seed_data.sql` (the `STUDENTS` insert block)

- [ ] **Step 1: Update the STUDENTS insert**

Find this block in `db/seed_data.sql`:
```sql
SET IDENTITY_INSERT [dbo].[STUDENTS] ON
INSERT [dbo].[STUDENTS] ([student_id],[user_id],[programme_id],[full_name],[date_of_birth],[status]) VALUES
 (1, 1, 1, N'Ong Zhi Bo',   '2003-04-15', N'ACTIVE'),
 (2, 4, 1, N'Lee Wei Ming', '2004-07-22', N'ACTIVE'),
 (3, 5, 2, N'Nurul Huda',   '2003-11-03', N'ACTIVE'),
 (4, 6, 3, N'Raj Kumar',    '2005-02-28', N'ACTIVE')
SET IDENTITY_INSERT [dbo].[STUDENTS] OFF
GO
```

Replace it with (adds `intake_semester_id` as the last column):
```sql
SET IDENTITY_INSERT [dbo].[STUDENTS] ON
INSERT [dbo].[STUDENTS] ([student_id],[user_id],[programme_id],[full_name],[date_of_birth],[status],[intake_semester_id]) VALUES
 (1, 1, 1, N'Ong Zhi Bo',   '2003-04-15', N'ACTIVE', 1),
 (2, 4, 1, N'Lee Wei Ming', '2004-07-22', N'ACTIVE', 2),
 (3, 5, 2, N'Nurul Huda',   '2003-11-03', N'ACTIVE', 3),
 (4, 6, 3, N'Raj Kumar',    '2005-02-28', N'ACTIVE', 1)
SET IDENTITY_INSERT [dbo].[STUDENTS] OFF
GO
```

- [ ] **Step 2: Sanity-check the edit**

Run:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT 1;"
```
(No DB change here — the live DB was already migrated in Task 1. This edit only affects future fresh rebuilds, which run `student_intake_semester.sql` before `seed_data.sql`.) Confirm by eye that the four rows each end with a valid term id (1, 2, or 3).

- [ ] **Step 3: Commit**

```
git add "db/seed_data.sql"
git commit -m "chore(db): seed student intake semesters"
```

---

## Task 3: Expose CurrentSemesterNo from StudentService

**Files:**
- Modify: `services/StudentService.cs`

- [ ] **Step 1: Add the property to the Student class**

In `services/StudentService.cs`, after this line (currently line 23):
```csharp
        public string ProgrammeCode { get; set; }
```
add:
```csharp

        /// <summary>The student's current semester of study, derived from their intake term.</summary>
        public int CurrentSemesterNo { get; set; }
```

- [ ] **Step 2: Join the view into the profile query**

Replace the `SelectProfile` constant:
```csharp
        private const string SelectProfile =
            "SELECT s.student_id, s.user_id, s.programme_id, s.full_name, " +
            "s.date_of_birth, s.status, u.email, u.username, " +
            "p.programme_name, p.programme_code " +
            "FROM STUDENTS s " +
            "JOIN USERS u ON s.user_id = u.user_id " +
            "JOIN PROGRAMMES p ON s.programme_id = p.programme_id ";
```
with:
```csharp
        private const string SelectProfile =
            "SELECT s.student_id, s.user_id, s.programme_id, s.full_name, " +
            "s.date_of_birth, s.status, u.email, u.username, " +
            "p.programme_name, p.programme_code, vs.current_semester_no " +
            "FROM STUDENTS s " +
            "JOIN USERS u ON s.user_id = u.user_id " +
            "JOIN PROGRAMMES p ON s.programme_id = p.programme_id " +
            "JOIN vw_student_semester vs ON vs.student_id = s.student_id ";
```

- [ ] **Step 3: Map the new column**

In `MapStudent`, after this line:
```csharp
                ProgrammeCode = reader["programme_code"].ToString(),
```
add:
```csharp
                CurrentSemesterNo = (int)reader["current_semester_no"],
```

- [ ] **Step 4: Build**

Run (from `5026CMD Software Engineer/src/src`):
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 5: Commit**

```
git add "services/StudentService.cs"
git commit -m "feat(services): read current semester number from vw_student_semester"
```

---

## Task 4: Dashboard shows the student's semester

**Files:**
- Modify: `shared/dashboard.aspx.cs` (the `SemesterNumber` property, currently lines 84-87)

- [ ] **Step 1: Point SemesterNumber at the student's number**

Replace:
```csharp
        protected string SemesterNumber
        {
            get { return _semester != null ? _semester.Number : ""; }
        }
```
with:
```csharp
        protected string SemesterNumber
        {
            get { return _student != null ? _student.CurrentSemesterNo.ToString(System.Globalization.CultureInfo.InvariantCulture) : ""; }
        }
```

(`_semester` is still used by `SemesterWeek`, so leave the field and `SemesterService.GetCurrent()` call alone.)

- [ ] **Step 2: Build**

Run (from `5026CMD Software Engineer/src/src`):
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 3: Cross-check the value the page will render for Ong (user_id 1)**

Run:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT vs.current_semester_no FROM STUDENTS s JOIN vw_student_semester vs ON vs.student_id = s.student_id WHERE s.user_id = 1;"
```
Expected: `3` — the number the dashboard will display when Ong is logged in (previously it showed `2`, the `2026-S2` trimester digit).

- [ ] **Step 4: Commit**

```
git add "shared/dashboard.aspx.cs"
git commit -m "feat(dashboard): show student's own semester instead of calendar trimester"
```

---

## Task 5: Remove the now-unused Semester.Number

**Files:**
- Modify: `services/SemesterService.cs` (remove the `Number` property, currently lines 17-25)

- [ ] **Step 1: Confirm nothing else references `.Number`**

Run:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -E -Q "SELECT 1;"
```
(That is just a no-op connectivity check.) Then search the source:
```
git grep -n "\.Number" -- "*.cs" "*.aspx"
```
Expected: no matches for `_semester.Number` or any `Semester` instance's `.Number`. (Task 4 already removed the only caller.) If any match remains, stop and resolve it before deleting the property.

- [ ] **Step 2: Delete the property**

In `services/SemesterService.cs`, remove this block (currently lines 17-25):
```csharp

        /// <summary>Semester number parsed from the name (e.g. "2026-S1" -> "1").</summary>
        public string Number
        {
            get
            {
                int idx = Name != null ? Name.IndexOf('S') : -1;
                return idx >= 0 && idx + 1 < Name.Length ? Name.Substring(idx + 1) : Name;
            }
        }
```

- [ ] **Step 3: Build**

Run (from `5026CMD Software Engineer/src/src`):
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 4: Commit**

```
git add "services/SemesterService.cs"
git commit -m "refactor(services): drop unused Semester.Number trimester parser"
```

---

## Final verification

- [ ] All five commits made.
- [ ] `vw_student_semester` returns 3/2/1/3 for students 1/2/3/4.
- [ ] Project builds with 0 errors.
- [ ] Dashboard cross-check query returns 3 for user_id 1.
- [ ] `git grep "\.Number"` finds no `Semester.Number` references.
