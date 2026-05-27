# Course Detail page — driven from the database — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `student/course_detail.aspx` show a real, DB-backed course for the offering the student clicked, with the header, sidebar, Modules, Announcements, Assignments, and Grades all populated from the database.

**Architecture:** Extend the existing schema with new columns/tables (sidebar fields, learning outcomes, weekly modules, material file metadata, announcement pinning, assignment weight/type, and a gradebook). Add four read-only services that follow the existing `services/*.cs` pattern, then convert the static `.aspx` into `<asp:Repeater>`-bound markup driven by a thin code-behind that validates the student's enrolment.

**Tech Stack:** ASP.NET WebForms (C#, .NET Framework), ADO.NET (`System.Data.SqlClient`), SQL Server LocalDB, Tailwind (Play CDN) markup. No unit-test framework — verification is **msbuild build + `sqlcmd` checks + manual browser check**, per project convention.

---

## Conventions used in every task

**Build** (PowerShell tool — Git Bash mangles `/t:` `/p:` switches):

```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```

Run from `C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src`. Expected: `Build succeeded` with 0 errors.

**SQL / DB checks** (`sqlcmd` is not on PATH):

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "<query>"
```

Connection string `SimsDb` in `Web.config` points at this same DB.

**Live DB diverges from `seed_data.sql`** — the live LocalDB has student 1 (`user_id` 1) enrolled in offerings 1–4 (not just 1–2). Always confirm real data with `sqlcmd` rather than trusting the seed file. Sample data in this plan targets offerings **1 (CS101)** and **2 (CS201)**, which exist and are enrolled in both seed and live DBs.

**Models & service signatures** (defined once here; tasks must match these names exactly):

```csharp
// CourseDetailService
public class CourseHeader {
    public int CourseId; public string CourseCode; public string CourseName;
    public int CreditHours; public string Color; public string Description;
    public string LevelLabel; public string LecturerName; public string SemesterName;
    public int ModuleCount; public string Mode; public string ContactHours;
    public string Prerequisites; public string Textbook; public string OfficeHours;
}
public class LearningOutcome { public string Text; }
CourseHeader GetHeader(int offeringId, int userId);          // null if student not enrolled
List<LearningOutcome> GetLearningOutcomes(int courseId);

// ModuleService
public class Module { public int Week; public string Title; public string Description;
                      public List<MaterialItem> Items; }
public class MaterialItem { public string Title; public string FileType;
                            public int? FileSizeBytes; public string FileUrl; }
List<Module> GetModules(int offeringId);

// AnnouncementService (extend existing file)
public class CourseAnnouncement { public string AuthorName; public string AuthorRole;
    public DateTime CreatedAt; public bool IsPinned; public string Title;
    public string Content; public bool HasAttachment; }
List<CourseAnnouncement> GetByOffering(int offeringId);

// AssignmentService (extend existing file)
public class CourseAssignment { public string Title; public decimal? Weight;
    public string AssignmentType; public string GroupSize; public string Description;
    public DateTime DueDate; public string SubmissionStatus; public decimal? Marks; }
List<CourseAssignment> GetByOffering(int offeringId, int userId);

// AssessmentService
public class AssessmentRow { public string Name; public string Type; public decimal Weight;
    public int MaxMarks; public decimal? Marks; public decimal? Contribution; public bool IsGraded; }
public class Gradebook { public List<AssessmentRow> Items; public decimal? OverallAverage;
    public decimal EarnedWeighted; public decimal CompletedPercent; }
Gradebook GetGradebook(int offeringId, int userId);
```

Note: `SubmissionStatus` values are `"OPEN"` (no submission row), `"SUBMITTED"`, or `"MARKED"` (mirrors `SUBMISSIONS.status`). `Contribution = Marks / MaxMarks * Weight` (null when not graded).

---

## Task 1: Fix the broken navigation links

**Files:**
- Modify: `student/courses.aspx:70`
- Modify: `student/course_detail.aspx:7`

- [ ] **Step 1: Point "Open course" at the real page, keyed by offering id**

In `student/courses.aspx`, replace the `<a href=...>` on line 70:

```aspx
<a href='<%# ResolveUrl("~/student/course_detail.aspx?offering=" + Eval("OfferingId")) %>'
    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
    style="font-size:12.5px;font-weight:600">
    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
</a>
```

- [ ] **Step 2: Fix the "Back to My Courses" link**

In `student/course_detail.aspx`, replace line 7's `href`:

```aspx
<a href="<%= ResolveUrl("~/student/courses.aspx") %>" class="inline-flex items-center gap-1.5 text-slate-500 hover:text-slate-900 transition-colors" style="font-size:13px;font-weight:500">
    <i data-lucide="arrow-left" class="h-3.5 w-3.5"></i> Back to My Courses
</a>
```

- [ ] **Step 3: Build**

Run the build command. Expected: `Build succeeded`, 0 errors.

- [ ] **Step 4: Commit**

```
git add "5026CMD Software Engineer/src/src/student/courses.aspx" "5026CMD Software Engineer/src/src/student/course_detail.aspx"
git commit -m "fix(courses): point Open course link at course_detail.aspx by offering id"
```

---

## Task 2: DB migration — schema additions

**Files:**
- Create: `db/course_detail.sql`

This is an idempotent migration (the single source of truth for these extra columns/tables, run against the live DB), matching the style of `db/user_contact_info.sql`.

- [ ] **Step 1: Create the schema portion of the migration script**

Create `db/course_detail.sql`:

```sql
/******************************************************************************
 Course Detail feature: sidebar columns + learning outcomes + weekly modules +
 material file metadata + announcement pinning + assignment weight/type + a
 gradebook (assessments). Idempotent — safe to run more than once.

 Run order (fresh rebuild): full schema dump -> student_intake_semester.sql ->
 user_contact_info.sql -> user_icon_path.sql -> seed_data.sql -> THIS script.
 (Runs AFTER seed_data so its sample rows can reference seeded courses/offerings.)
******************************************************************************/
USE [StudentInformationManagementSystem];
GO

/* 1. COURSES sidebar columns (all nullable) */
IF COL_LENGTH('dbo.COURSES','description')   IS NULL ALTER TABLE dbo.COURSES ADD description VARCHAR(500) NULL;
IF COL_LENGTH('dbo.COURSES','level_label')   IS NULL ALTER TABLE dbo.COURSES ADD level_label VARCHAR(50) NULL;
IF COL_LENGTH('dbo.COURSES','mode')          IS NULL ALTER TABLE dbo.COURSES ADD mode VARCHAR(50) NULL;
IF COL_LENGTH('dbo.COURSES','contact_hours') IS NULL ALTER TABLE dbo.COURSES ADD contact_hours VARCHAR(50) NULL;
IF COL_LENGTH('dbo.COURSES','prerequisites') IS NULL ALTER TABLE dbo.COURSES ADD prerequisites VARCHAR(100) NULL;
IF COL_LENGTH('dbo.COURSES','textbook')      IS NULL ALTER TABLE dbo.COURSES ADD textbook VARCHAR(150) NULL;
IF COL_LENGTH('dbo.COURSES','office_hours')  IS NULL ALTER TABLE dbo.COURSES ADD office_hours VARCHAR(100) NULL;
GO

/* 2. LEARNING_OUTCOMES */
IF OBJECT_ID('dbo.LEARNING_OUTCOMES','U') IS NULL
CREATE TABLE dbo.LEARNING_OUTCOMES (
    outcome_id   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    course_id    INT NOT NULL,
    outcome_text VARCHAR(255) NOT NULL,
    sort_order   INT NOT NULL
);
GO

/* 3. MODULES (weekly accordion headers) */
IF OBJECT_ID('dbo.MODULES','U') IS NULL
CREATE TABLE dbo.MODULES (
    module_id   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    offering_id INT NOT NULL,
    week        INT NOT NULL,
    title       VARCHAR(255) NOT NULL,
    description VARCHAR(500) NULL
);
GO

/* 4. COURSE_MATERIALS item metadata */
IF COL_LENGTH('dbo.COURSE_MATERIALS','module_id')       IS NULL ALTER TABLE dbo.COURSE_MATERIALS ADD module_id INT NULL;
IF COL_LENGTH('dbo.COURSE_MATERIALS','file_type')       IS NULL ALTER TABLE dbo.COURSE_MATERIALS ADD file_type VARCHAR(20) NULL;
IF COL_LENGTH('dbo.COURSE_MATERIALS','file_size_bytes') IS NULL ALTER TABLE dbo.COURSE_MATERIALS ADD file_size_bytes INT NULL;
GO

/* 5. ANNOUNCEMENTS pinning */
IF COL_LENGTH('dbo.ANNOUNCEMENTS','is_pinned') IS NULL
    ALTER TABLE dbo.ANNOUNCEMENTS ADD is_pinned BIT NOT NULL CONSTRAINT DF_ANN_is_pinned DEFAULT 0;
GO

/* 6. ASSIGNMENTS weight/type */
IF COL_LENGTH('dbo.ASSIGNMENTS','weight')          IS NULL ALTER TABLE dbo.ASSIGNMENTS ADD weight DECIMAL(5,2) NULL;
IF COL_LENGTH('dbo.ASSIGNMENTS','assignment_type') IS NULL ALTER TABLE dbo.ASSIGNMENTS ADD assignment_type VARCHAR(20) NULL;
IF COL_LENGTH('dbo.ASSIGNMENTS','group_size')      IS NULL ALTER TABLE dbo.ASSIGNMENTS ADD group_size VARCHAR(20) NULL;
GO

/* 7. ASSESSMENTS (gradebook line items) */
IF OBJECT_ID('dbo.ASSESSMENTS','U') IS NULL
CREATE TABLE dbo.ASSESSMENTS (
    assessment_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    offering_id   INT NOT NULL,
    name          VARCHAR(255) NOT NULL,
    type          VARCHAR(20) NOT NULL,
    weight        DECIMAL(5,2) NOT NULL,
    max_marks     INT NOT NULL CONSTRAINT DF_ASSESS_max DEFAULT 100,
    sort_order    INT NOT NULL
);
GO

/* 8. STUDENT_ASSESSMENTS (per-student score; NULL marks = pending) */
IF OBJECT_ID('dbo.STUDENT_ASSESSMENTS','U') IS NULL
CREATE TABLE dbo.STUDENT_ASSESSMENTS (
    student_assessment_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    assessment_id INT NOT NULL,
    student_id    INT NOT NULL,
    marks         DECIMAL(5,2) NULL
);
GO
```

- [ ] **Step 2: Apply the script to the live DB**

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -i "db\course_detail.sql"
```

Expected: completes with no errors.

- [ ] **Step 3: Verify the schema landed**

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT COL_LENGTH('dbo.COURSES','textbook') AS textbook, COL_LENGTH('dbo.ASSIGNMENTS','weight') AS weight, COL_LENGTH('dbo.ANNOUNCEMENTS','is_pinned') AS pinned, OBJECT_ID('dbo.MODULES') AS modules, OBJECT_ID('dbo.ASSESSMENTS') AS assessments, OBJECT_ID('dbo.STUDENT_ASSESSMENTS') AS student_assessments, OBJECT_ID('dbo.LEARNING_OUTCOMES') AS outcomes;"
```

Expected: every column is non-NULL (all objects exist).

- [ ] **Step 4: Re-run the script to confirm idempotency**

Re-run the Step 2 command. Expected: no errors (all guards skip).

- [ ] **Step 5: Commit**

```
git add "5026CMD Software Engineer/src/src/db/course_detail.sql"
git commit -m "feat(db): add course-detail schema (sidebar, modules, assessments, pinning)"
```

---

## Task 3: DB migration — sample data

**Files:**
- Modify: `db/course_detail.sql` (append)

Guarded inserts (idempotent via natural-key `NOT EXISTS`) so the page has content for offerings 1 (CS101) and 2 (CS201) and student 1.

- [ ] **Step 1: Append the sample-data section**

Append to `db/course_detail.sql`:

```sql
/* ============================ SAMPLE DATA ============================ */

/* COURSES sidebar backfill (only where still NULL) */
UPDATE dbo.COURSES SET
    description   = N'Core programming concepts: variables, control flow, functions, and problem solving.',
    level_label   = N'Y1 · Trimester 1', mode = N'On-campus + LMS',
    contact_hours = N'3h lecture · 2h lab', prerequisites = N'None',
    textbook      = N'Savitch, Absolute C++ 6th ed.', office_hours = N'Tue 14:00 – 16:00'
WHERE course_id = 1 AND description IS NULL;

UPDATE dbo.COURSES SET
    description   = N'Relational modelling, SQL, normalization, and transaction basics.',
    level_label   = N'Y2 · Trimester 1', mode = N'On-campus + LMS',
    contact_hours = N'3h lecture · 1h lab', prerequisites = N'CS101 Programming Fundamentals',
    textbook      = N'Elmasri, Fundamentals of Database Systems 7th ed.', office_hours = N'Wed 10:00 – 12:00'
WHERE course_id = 2 AND description IS NULL;
GO

/* LEARNING_OUTCOMES */
INSERT INTO dbo.LEARNING_OUTCOMES (course_id, outcome_text, sort_order)
SELECT v.course_id, v.outcome_text, v.sort_order FROM (VALUES
    (1, N'Write and debug structured programs using core language constructs.', 1),
    (1, N'Decompose problems into functions and reusable components.', 2),
    (1, N'Apply basic data structures to practical tasks.', 3),
    (2, N'Design normalized relational schemas from requirements.', 1),
    (2, N'Write correct SQL queries across multiple tables.', 2),
    (2, N'Reason about transactions and data integrity.', 3)
) AS v(course_id, outcome_text, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM dbo.LEARNING_OUTCOMES lo
                  WHERE lo.course_id = v.course_id AND lo.sort_order = v.sort_order);
GO

/* MODULES (offering 1: weeks 1-3; offering 2: weeks 1-2) */
INSERT INTO dbo.MODULES (offering_id, week, title, description)
SELECT v.offering_id, v.week, v.title, v.description FROM (VALUES
    (1, 1, N'Introduction & Setup',        N'Course logistics, toolchain, first program.'),
    (1, 2, N'Variables & Control Flow',    N'Types, operators, conditionals, loops.'),
    (1, 3, N'Functions & Arrays',          N'Defining functions, parameters, arrays.'),
    (2, 1, N'Relational Model',            N'Entities, relations, keys.'),
    (2, 2, N'SQL Fundamentals',            N'SELECT, JOIN, filtering, grouping.')
) AS v(offering_id, week, title, description)
WHERE NOT EXISTS (SELECT 1 FROM dbo.MODULES m
                  WHERE m.offering_id = v.offering_id AND m.week = v.week);
GO

/* COURSE_MATERIALS items linked to the modules above.
   lecturer_id 1 teaches offerings 1 & 2 (seed TEACHINGS). */
INSERT INTO dbo.COURSE_MATERIALS (offering_id, lecturer_id, title, description, week, file_url, uploaded_at, module_id, file_type, file_size_bytes)
SELECT m.offering_id, 1, v.title, NULL, m.week, NULL, SYSDATETIME(), m.module_id, v.file_type, v.file_size_bytes
FROM (VALUES
    (1, 1, N'01-introduction.pptx', N'pptx',  3565158),
    (1, 1, N'Welcome video',        N'video', NULL),
    (1, 2, N'02-control-flow.pptx', N'pptx',  5347737),
    (1, 3, N'03-functions.pptx',    N'pptx',  4194304),
    (2, 1, N'01-relational.pptx',   N'pptx',  3984588),
    (2, 2, N'02-sql-basics.pptx',   N'pptx',  6081740)
) AS v(offering_id, week, title, file_type, file_size_bytes)
JOIN dbo.MODULES m ON m.offering_id = v.offering_id AND m.week = v.week
WHERE NOT EXISTS (SELECT 1 FROM dbo.COURSE_MATERIALS cm
                  WHERE cm.module_id = m.module_id AND cm.title = v.title);
GO

/* ASSIGNMENTS weight/type backfill for existing seeded rows
   (assignment 1 -> offering 1; assignment 2 -> offering 2). */
UPDATE dbo.ASSIGNMENTS SET weight = 10.00, assignment_type = N'Individual', group_size = NULL
WHERE assignment_id = 1 AND weight IS NULL;
UPDATE dbo.ASSIGNMENTS SET weight = 15.00, assignment_type = N'Group', group_size = N'3–4'
WHERE assignment_id = 2 AND weight IS NULL;
GO

/* ANNOUNCEMENTS: pin announcement 2 (targets offerings 1 & 2 in seed) */
UPDATE dbo.ANNOUNCEMENTS SET is_pinned = 1 WHERE announcement_id = 2;
GO

/* ASSESSMENTS (gradebook) for offering 1 */
INSERT INTO dbo.ASSESSMENTS (offering_id, name, type, weight, max_marks, sort_order)
SELECT v.offering_id, v.name, v.type, v.weight, 100, v.sort_order FROM (VALUES
    (1, N'Quiz 1 — Basics',        N'Quiz',       5.00,  1),
    (1, N'Quiz 2 — Control Flow',  N'Quiz',       5.00,  2),
    (1, N'Lab Assignment',         N'Assignment', 10.00, 3),
    (1, N'Mid-term Test',          N'Test',       25.00, 4),
    (1, N'Final Project',          N'Project',    30.00, 5)
) AS v(offering_id, name, type, weight, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM dbo.ASSESSMENTS a
                  WHERE a.offering_id = v.offering_id AND a.name = v.name);
GO

/* STUDENT_ASSESSMENTS for student 1: first three graded, last two pending */
INSERT INTO dbo.STUDENT_ASSESSMENTS (assessment_id, student_id, marks)
SELECT a.assessment_id, 1, v.marks
FROM (VALUES
    (N'Quiz 1 — Basics',       CAST(92.00 AS DECIMAL(5,2))),
    (N'Quiz 2 — Control Flow', CAST(85.00 AS DECIMAL(5,2))),
    (N'Lab Assignment',        CAST(88.00 AS DECIMAL(5,2)))
) AS v(name, marks)
JOIN dbo.ASSESSMENTS a ON a.offering_id = 1 AND a.name = v.name
WHERE NOT EXISTS (SELECT 1 FROM dbo.STUDENT_ASSESSMENTS sa
                  WHERE sa.assessment_id = a.assessment_id AND sa.student_id = 1);
GO
```

- [ ] **Step 2: Apply and verify**

Apply (Task 2 Step 2 command). Then verify counts for offering 1:

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT (SELECT COUNT(*) FROM MODULES WHERE offering_id=1) AS modules, (SELECT COUNT(*) FROM ASSESSMENTS WHERE offering_id=1) AS assessments, (SELECT COUNT(*) FROM STUDENT_ASSESSMENTS WHERE student_id=1) AS scored, (SELECT COUNT(*) FROM LEARNING_OUTCOMES WHERE course_id=1) AS outcomes;"
```

Expected: modules=3, assessments=5, scored=3, outcomes=3.

- [ ] **Step 3: Confirm idempotency** — re-run apply; expect no errors and the Step 2 counts unchanged.

- [ ] **Step 4: Commit**

```
git add "5026CMD Software Engineer/src/src/db/course_detail.sql"
git commit -m "feat(db): sample data for course-detail (CS101, CS201)"
```

---

## Task 4: ModuleService

**Files:**
- Create: `services/ModuleService.cs`
- Modify: `src.csproj` (add `<Compile>` entry)

- [ ] **Step 1: Create the service**

Create `services/ModuleService.cs`:

```csharp
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>One weekly module (accordion header) and its material items.</summary>
    public class Module
    {
        public int Week { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public List<MaterialItem> Items { get; set; } = new List<MaterialItem>();
    }

    /// <summary>One downloadable material under a module.</summary>
    public class MaterialItem
    {
        public string Title { get; set; }
        public string FileType { get; set; }
        public int? FileSizeBytes { get; set; }
        public string FileUrl { get; set; }
    }

    /// <summary>
    /// Read-only access to an offering's weekly modules with their materials.
    /// Returns an empty list when the offering has no modules. SQL exceptions
    /// propagate to the caller.
    /// </summary>
    public static class ModuleService
    {
        // Modules left-joined to their materials, ordered so a single pass in C#
        // groups items under each module in display order.
        private const string SelectModules =
            "SELECT m.module_id, m.week, m.title, m.description, " +
            "cm.title AS item_title, cm.file_type, cm.file_size_bytes, cm.file_url " +
            "FROM MODULES m " +
            "LEFT JOIN COURSE_MATERIALS cm ON cm.module_id = m.module_id " +
            "WHERE m.offering_id = @offeringId " +
            "ORDER BY m.week, cm.material_id";

        public static List<Module> GetModules(int offeringId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectModules, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                var modules = new List<Module>();
                Module current = null;
                int currentWeek = int.MinValue;
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int week = (int)reader["week"];
                        if (current == null || week != currentWeek)
                        {
                            current = new Module
                            {
                                Week = week,
                                Title = reader["title"].ToString(),
                                Description = reader["description"] == System.DBNull.Value
                                    ? "" : reader["description"].ToString()
                            };
                            modules.Add(current);
                            currentWeek = week;
                        }
                        if (reader["item_title"] != System.DBNull.Value)
                        {
                            current.Items.Add(new MaterialItem
                            {
                                Title = reader["item_title"].ToString(),
                                FileType = reader["file_type"] == System.DBNull.Value
                                    ? "" : reader["file_type"].ToString(),
                                FileSizeBytes = reader["file_size_bytes"] == System.DBNull.Value
                                    ? (int?)null : (int)reader["file_size_bytes"],
                                FileUrl = reader["file_url"] == System.DBNull.Value
                                    ? null : reader["file_url"].ToString()
                            });
                        }
                    }
                }
                return modules;
            }
        }
    }
}
```

- [ ] **Step 2: Register in the project**

In `src.csproj`, add after the `EnrolmentService.cs` compile line (around line 108):

```xml
    <Compile Include="services\ModuleService.cs" />
```

- [ ] **Step 3: Build** — expected `Build succeeded`, 0 errors.

- [ ] **Step 4: Verify the query against the live DB** — confirm the service SQL returns the seeded rows:

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT m.week, m.title, cm.title AS item, cm.file_type FROM MODULES m LEFT JOIN COURSE_MATERIALS cm ON cm.module_id=m.module_id WHERE m.offering_id=1 ORDER BY m.week, cm.material_id;"
```

Expected: weeks 1–3 with their material items (week 1 has 2 items incl. the video).

- [ ] **Step 5: Commit**

```
git add "5026CMD Software Engineer/src/src/services/ModuleService.cs" "5026CMD Software Engineer/src/src/src.csproj"
git commit -m "feat(services): ModuleService — weekly modules with materials"
```

---

## Task 5: AssessmentService (gradebook)

**Files:**
- Create: `services/AssessmentService.cs`
- Modify: `src.csproj`

- [ ] **Step 1: Create the service**

Create `services/AssessmentService.cs`:

```csharp
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>One gradebook line item with the student's score, if any.</summary>
    public class AssessmentRow
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public decimal Weight { get; set; }
        public int MaxMarks { get; set; }
        public decimal? Marks { get; set; }
        public bool IsGraded { get { return Marks.HasValue; } }
        /// <summary>Weighted contribution to the final grade; null when not graded.</summary>
        public decimal? Contribution
        {
            get { return Marks.HasValue ? (decimal?)Math.Round(Marks.Value / MaxMarks * Weight, 1) : null; }
        }
    }

    /// <summary>An offering's gradebook for one student, plus computed totals.</summary>
    public class Gradebook
    {
        public List<AssessmentRow> Items { get; set; } = new List<AssessmentRow>();
        /// <summary>Weighted average over graded items (0-100); null when none graded.</summary>
        public decimal? OverallAverage { get; set; }
        /// <summary>Sum of contributions of graded items.</summary>
        public decimal EarnedWeighted { get; set; }
        /// <summary>Sum of weights of graded items (the % of the course completed).</summary>
        public decimal CompletedPercent { get; set; }
    }

    /// <summary>
    /// Read-only gradebook for an offering and the student behind a user id.
    /// Assessments with no student score are returned as pending (null marks)
    /// and excluded from the totals. SQL exceptions propagate to the caller.
    /// </summary>
    public static class AssessmentService
    {
        private const string SelectGradebook =
            "SELECT a.name, a.type, a.weight, a.max_marks, sa.marks " +
            "FROM ASSESSMENTS a " +
            "JOIN COURSE_OFFERINGS o ON a.offering_id = o.offering_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id AND s.user_id = @userId " +
            "LEFT JOIN STUDENT_ASSESSMENTS sa ON sa.assessment_id = a.assessment_id " +
            "AND sa.student_id = s.student_id " +
            "WHERE a.offering_id = @offeringId " +
            "ORDER BY a.sort_order";

        public static Gradebook GetGradebook(int offeringId, int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectGradebook, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                cmd.Parameters.AddWithValue("@userId", userId);
                var book = new Gradebook();
                decimal weightedMarkSum = 0m;   // Σ (marks/max * weight)
                decimal gradedWeight = 0m;       // Σ weight of graded
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var row = new AssessmentRow
                        {
                            Name = reader["name"].ToString(),
                            Type = reader["type"].ToString(),
                            Weight = (decimal)reader["weight"],
                            MaxMarks = (int)reader["max_marks"],
                            Marks = reader["marks"] == DBNull.Value
                                ? (decimal?)null : (decimal)reader["marks"]
                        };
                        book.Items.Add(row);
                        if (row.IsGraded)
                        {
                            weightedMarkSum += row.Marks.Value / row.MaxMarks * row.Weight;
                            gradedWeight += row.Weight;
                        }
                    }
                }
                book.CompletedPercent = gradedWeight;
                book.EarnedWeighted = Math.Round(weightedMarkSum, 1);
                book.OverallAverage = gradedWeight > 0
                    ? (decimal?)Math.Round(weightedMarkSum / gradedWeight * 100, 0)
                    : null;
                return book;
            }
        }
    }
}
```

- [ ] **Step 2: Register** — add to `src.csproj`:

```xml
    <Compile Include="services\AssessmentService.cs" />
```

- [ ] **Step 3: Build** — expected `Build succeeded`, 0 errors.

- [ ] **Step 4: Verify the query** — confirm the gradebook SQL returns 5 rows (3 with marks) for user 1, offering 1:

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT a.name, a.weight, a.max_marks, sa.marks FROM ASSESSMENTS a JOIN COURSE_OFFERINGS o ON a.offering_id=o.offering_id JOIN ENROLMENTS e ON e.offering_id=o.offering_id JOIN STUDENTS s ON e.student_id=s.student_id AND s.user_id=1 LEFT JOIN STUDENT_ASSESSMENTS sa ON sa.assessment_id=a.assessment_id AND sa.student_id=s.student_id WHERE a.offering_id=1 ORDER BY a.sort_order;"
```

Expected: 5 rows; Quiz 1/Quiz 2/Lab have marks 92/85/88, Mid-term & Final NULL.

- [ ] **Step 5: Commit**

```
git add "5026CMD Software Engineer/src/src/services/AssessmentService.cs" "5026CMD Software Engineer/src/src/src.csproj"
git commit -m "feat(services): AssessmentService — gradebook with computed totals"
```

---

## Task 6: CourseDetailService (header + outcomes + enrolment guard)

**Files:**
- Create: `services/CourseDetailService.cs`
- Modify: `src.csproj`

- [ ] **Step 1: Create the service**

Create `services/CourseDetailService.cs`:

```csharp
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>Course header + sidebar fields for one offering.</summary>
    public class CourseHeader
    {
        public int CourseId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string Color { get; set; }
        public string Description { get; set; }
        public string LevelLabel { get; set; }
        public string LecturerName { get; set; }
        public string SemesterName { get; set; }
        public int ModuleCount { get; set; }
        public string Mode { get; set; }
        public string ContactHours { get; set; }
        public string Prerequisites { get; set; }
        public string Textbook { get; set; }
        public string OfficeHours { get; set; }
    }

    /// <summary>One learning-outcome bullet.</summary>
    public class LearningOutcome { public string Text { get; set; } }

    /// <summary>
    /// Read-only course-detail header for an offering, scoped to a student. Returns
    /// null when the student behind <paramref name="userId"/> is not enrolled in the
    /// offering (callers redirect). SQL exceptions propagate to the caller.
    /// </summary>
    public static class CourseDetailService
    {
        // Header for an offering the student is enrolled in. OUTER APPLY TOP 1
        // picks one lecturer; the module count is a correlated subquery.
        private const string SelectHeader =
            "SELECT c.course_id, c.course_code, c.course_name, c.credit_hours, c.color, " +
            "c.description, c.level_label, c.mode, c.contact_hours, c.prerequisites, " +
            "c.textbook, c.office_hours, sem.name AS semester_name, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, " +
            "(SELECT COUNT(*) FROM MODULES m WHERE m.offering_id = o.offering_id) AS module_count " +
            "FROM COURSE_OFFERINGS o " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id AND s.user_id = @userId " +
            "OUTER APPLY (SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE o.offering_id = @offeringId";

        public static CourseHeader GetHeader(int offeringId, int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectHeader, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;   // not enrolled / no such offering
                    return new CourseHeader
                    {
                        CourseId = (int)reader["course_id"],
                        CourseCode = reader["course_code"].ToString(),
                        CourseName = reader["course_name"].ToString(),
                        CreditHours = (int)reader["credit_hours"],
                        Color = reader["color"] == System.DBNull.Value ? "" : reader["color"].ToString(),
                        Description = Str(reader["description"]),
                        LevelLabel = Str(reader["level_label"]),
                        LecturerName = reader["lecturer_name"].ToString(),
                        SemesterName = reader["semester_name"].ToString(),
                        ModuleCount = (int)reader["module_count"],
                        Mode = Str(reader["mode"]),
                        ContactHours = Str(reader["contact_hours"]),
                        Prerequisites = Str(reader["prerequisites"]),
                        Textbook = Str(reader["textbook"]),
                        OfficeHours = Str(reader["office_hours"])
                    };
                }
            }
        }

        private const string SelectOutcomes =
            "SELECT outcome_text FROM LEARNING_OUTCOMES " +
            "WHERE course_id = @courseId ORDER BY sort_order";

        public static List<LearningOutcome> GetLearningOutcomes(int courseId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectOutcomes, conn))
            {
                cmd.Parameters.AddWithValue("@courseId", courseId);
                var list = new List<LearningOutcome>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                        list.Add(new LearningOutcome { Text = reader["outcome_text"].ToString() });
                }
                return list;
            }
        }

        private static string Str(object value)
        {
            return value == System.DBNull.Value ? "" : value.ToString();
        }
    }
}
```

- [ ] **Step 2: Register** — add to `src.csproj`:

```xml
    <Compile Include="services\CourseDetailService.cs" />
```

- [ ] **Step 3: Build** — expected `Build succeeded`, 0 errors.

- [ ] **Step 4: Verify the guard** — confirm offering 1 returns a row for user 1, and an offering the student is NOT enrolled in returns none:

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT c.course_code, c.textbook, (SELECT COUNT(*) FROM MODULES m WHERE m.offering_id=o.offering_id) AS modules FROM COURSE_OFFERINGS o JOIN COURSES c ON o.course_id=c.course_id JOIN ENROLMENTS e ON e.offering_id=o.offering_id JOIN STUDENTS s ON e.student_id=s.student_id AND s.user_id=1 WHERE o.offering_id=1;"
```

Expected: one row (CS101, its textbook, modules=3).

- [ ] **Step 5: Commit**

```
git add "5026CMD Software Engineer/src/src/services/CourseDetailService.cs" "5026CMD Software Engineer/src/src/src.csproj"
git commit -m "feat(services): CourseDetailService — header, outcomes, enrolment guard"
```

---

## Task 7: AnnouncementService.GetByOffering

**Files:**
- Modify: `services/AnnouncementService.cs`

- [ ] **Step 1: Add the model and method**

In `services/AnnouncementService.cs`, add the `CourseAnnouncement` class after the existing `Announcement` class (inside the namespace), and add the `GetByOffering` method inside the `AnnouncementService` class (after `GetForStudent`):

```csharp
    /// <summary>One announcement on a course-detail page, with author display info.</summary>
    public class CourseAnnouncement
    {
        public string AuthorName { get; set; }
        public string AuthorRole { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsPinned { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public bool HasAttachment { get; set; }
    }
```

```csharp
        // Announcements targeting one offering, pinned first then newest first.
        // Author name comes from LECTURERS when the creator is a lecturer; role
        // from USERS. file_url presence drives the attachment flag.
        private const string SelectByOffering =
            "SELECT DISTINCT an.announcement_id, an.title, " +
            "CAST(an.content AS varchar(max)) AS content, an.created_at, an.is_pinned, " +
            "CASE WHEN an.file_url IS NULL THEN 0 ELSE 1 END AS has_attachment, " +
            "u.role, ISNULL(l.full_name, u.username) AS author_name " +
            "FROM ANNOUNCEMENTS an " +
            "JOIN ANNOUNCEMENT_TARGETS at ON at.announcement_id = an.announcement_id " +
            "JOIN USERS u ON u.user_id = an.created_by " +
            "LEFT JOIN LECTURERS l ON l.user_id = u.user_id " +
            "WHERE at.offering_id = @offeringId " +
            "ORDER BY an.is_pinned DESC, an.created_at DESC";

        public static List<CourseAnnouncement> GetByOffering(int offeringId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectByOffering, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                var list = new List<CourseAnnouncement>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new CourseAnnouncement
                        {
                            Title = reader["title"].ToString(),
                            Content = reader["content"].ToString(),
                            CreatedAt = (DateTime)reader["created_at"],
                            IsPinned = (bool)reader["is_pinned"],
                            HasAttachment = (int)reader["has_attachment"] == 1,
                            AuthorName = reader["author_name"].ToString(),
                            AuthorRole = reader["role"].ToString()
                        });
                    }
                }
                return list;
            }
        }
```

- [ ] **Step 2: Build** — expected `Build succeeded`, 0 errors.

- [ ] **Step 3: Verify** — confirm pinned announcement 2 sorts first for offering 1:

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT DISTINCT an.title, an.is_pinned, ISNULL(l.full_name,u.username) AS author, u.role FROM ANNOUNCEMENTS an JOIN ANNOUNCEMENT_TARGETS at ON at.announcement_id=an.announcement_id JOIN USERS u ON u.user_id=an.created_by LEFT JOIN LECTURERS l ON l.user_id=u.user_id WHERE at.offering_id=1 ORDER BY an.is_pinned DESC, an.created_at DESC;"
```

Expected: announcement 2 ("Assignment 1 Released") first with is_pinned=1.

- [ ] **Step 4: Commit**

```
git add "5026CMD Software Engineer/src/src/services/AnnouncementService.cs"
git commit -m "feat(services): AnnouncementService.GetByOffering — pinned-first per offering"
```

---

## Task 8: AssignmentService.GetByOffering

**Files:**
- Modify: `services/AssignmentService.cs`

- [ ] **Step 1: Add the model and method**

In `services/AssignmentService.cs`, add the `CourseAssignment` class after the existing `Assignment` class, and add `GetByOffering` + its reader inside `AssignmentService`:

```csharp
    /// <summary>One assignment on a course-detail page, with the student's submission state.</summary>
    public class CourseAssignment
    {
        public string Title { get; set; }
        public decimal? Weight { get; set; }
        public string AssignmentType { get; set; }
        public string GroupSize { get; set; }
        public string Description { get; set; }
        public DateTime DueDate { get; set; }
        /// <summary>"OPEN" (no submission), "SUBMITTED", or "MARKED".</summary>
        public string SubmissionStatus { get; set; }
        public decimal? Marks { get; set; }
    }
```

```csharp
        // Assignments for one offering with the student's submission status/marks.
        // No submission row -> status defaults to OPEN.
        private const string SelectByOffering =
            "SELECT a.title, a.description, a.due_date, a.weight, a.assignment_type, a.group_size, " +
            "ISNULL(sub.status, 'OPEN') AS sub_status, sub.marks " +
            "FROM ASSIGNMENTS a " +
            "JOIN COURSE_OFFERINGS o ON a.offering_id = o.offering_id " +
            "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
            "JOIN STUDENTS s ON e.student_id = s.student_id AND s.user_id = @userId " +
            "LEFT JOIN SUBMISSIONS sub ON sub.assignment_id = a.assignment_id " +
            "AND sub.student_id = s.student_id " +
            "WHERE a.offering_id = @offeringId " +
            "ORDER BY a.due_date";

        public static List<CourseAssignment> GetByOffering(int offeringId, int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectByOffering, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                cmd.Parameters.AddWithValue("@userId", userId);
                var list = new List<CourseAssignment>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new CourseAssignment
                        {
                            Title = reader["title"].ToString(),
                            Description = reader["description"] == DBNull.Value ? "" : reader["description"].ToString(),
                            DueDate = (DateTime)reader["due_date"],
                            Weight = reader["weight"] == DBNull.Value ? (decimal?)null : (decimal)reader["weight"],
                            AssignmentType = reader["assignment_type"] == DBNull.Value ? "" : reader["assignment_type"].ToString(),
                            GroupSize = reader["group_size"] == DBNull.Value ? "" : reader["group_size"].ToString(),
                            SubmissionStatus = reader["sub_status"].ToString(),
                            Marks = reader["marks"] == DBNull.Value ? (decimal?)null : (decimal)reader["marks"]
                        });
                    }
                }
                return list;
            }
        }
```

- [ ] **Step 2: Build** — expected `Build succeeded`, 0 errors.

- [ ] **Step 3: Verify** — confirm offering 1 assignment shows weight/type and the student's submission status:

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT a.title, a.weight, a.assignment_type, ISNULL(sub.status,'OPEN') AS st, sub.marks FROM ASSIGNMENTS a JOIN COURSE_OFFERINGS o ON a.offering_id=o.offering_id JOIN ENROLMENTS e ON e.offering_id=o.offering_id JOIN STUDENTS s ON e.student_id=s.student_id AND s.user_id=1 LEFT JOIN SUBMISSIONS sub ON sub.assignment_id=a.assignment_id AND sub.student_id=s.student_id WHERE a.offering_id=1 ORDER BY a.due_date;"
```

Expected: "Assignment 1: Variables & Loops", weight 10.00, Individual, status SUBMITTED.

- [ ] **Step 4: Commit**

```
git add "5026CMD Software Engineer/src/src/services/AssignmentService.cs"
git commit -m "feat(services): AssignmentService.GetByOffering — weight/type + submission state"
```

---

## Task 9: Code-behind + header/sidebar binding

**Files:**
- Modify: `student/course_detail.aspx.cs`
- Modify: `student/course_detail.aspx.designer.cs`
- Modify: `student/course_detail.aspx` (header + sidebar sections only)

- [ ] **Step 1: Write the code-behind**

Replace the entire body of `student/course_detail.aspx.cs` with:

```csharp
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class course_detail : System.Web.UI.Page
    {
        protected CourseHeader Header;

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
            Response.Cache.SetNoStore();

            if (Session["user_id"] == null)
            {
                Response.Redirect("~/shared/login.aspx");
                return;
            }
            int userId = (int)Session["user_id"];

            int offeringId;
            if (!int.TryParse(Request.QueryString["offering"], out offeringId))
            {
                Response.Redirect("~/student/courses.aspx");
                return;
            }

            Header = CourseDetailService.GetHeader(offeringId, userId);
            if (Header == null)   // not enrolled / no such offering
            {
                Response.Redirect("~/student/courses.aspx");
                return;
            }

            outcomesRepeater.DataSource = CourseDetailService.GetLearningOutcomes(Header.CourseId);
            outcomesRepeater.DataBind();

            modulesRepeater.DataSource = ModuleService.GetModules(offeringId);
            modulesRepeater.DataBind();

            announcementsRepeater.DataSource = AnnouncementService.GetByOffering(offeringId);
            announcementsRepeater.DataBind();

            assignmentsRepeater.DataSource = AssignmentService.GetByOffering(offeringId, userId);
            assignmentsRepeater.DataBind();

            _gradebook = AssessmentService.GetGradebook(offeringId, userId);
            assessmentsRepeater.DataSource = _gradebook.Items;
            assessmentsRepeater.DataBind();
        }

        private Gradebook _gradebook;

        /// <summary>Course accent color, or a neutral slate fallback for null/malformed values.</summary>
        protected string AccentColor(string color)
        {
            if (string.IsNullOrEmpty(color)) return "#64748b";
            return System.Text.RegularExpressions.Regex.IsMatch(color, @"^#[0-9A-Fa-f]{6}$")
                ? color : "#64748b";
        }

        /// <summary>Up to two uppercase initials from a full name (e.g. "Dr. Sarah Tan" -> "ST").</summary>
        protected string Initials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "?";
            var parts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            string letters = "";
            for (int i = parts.Length - 1; i >= 0 && letters.Length < 2; i--)
            {
                char c = parts[i][0];
                if (char.IsLetter(c)) letters = char.ToUpperInvariant(c) + letters;
            }
            return letters.Length == 0 ? "?" : letters;
        }

        /// <summary>Human file size ("3.4 MB"); empty for null (e.g. videos).</summary>
        protected string FileSize(object bytes)
        {
            if (bytes == null) return "";
            int b = (int)bytes;
            if (b >= 1048576) return Math.Round(b / 1048576.0, 1) + " MB";
            if (b >= 1024) return Math.Round(b / 1024.0, 0) + " KB";
            return b + " B";
        }

        /// <summary>lucide icon name for a material file type.</summary>
        protected string FileIcon(string fileType)
        {
            switch ((fileType ?? "").ToLowerInvariant())
            {
                case "video": return "play-circle";
                case "pdf": return "file-text";
                case "docx": return "file-text";
                default: return "paperclip";
            }
        }

        /// <summary>Due/status line for an assignment card.</summary>
        protected string DueLabel(string status, DateTime due)
        {
            if (status == "MARKED") return "Graded · " + due.ToString("d MMM");
            if (status == "SUBMITTED") return "Submitted · " + due.ToString("d MMM");
            int days = (int)(due.Date - DateTime.Today).TotalDays;
            if (days < 0) return "Overdue · " + due.ToString("d MMM");
            if (days == 0) return "Today · 11:59 PM";
            if (days == 1) return "Tomorrow · 11:59 PM";
            return "In " + days + " days";
        }

        protected Gradebook Book { get { return _gradebook; } }

        /// <summary>Donut stroke-dashoffset for a 0-100 percentage over circumference 301.6.</summary>
        protected string DonutOffset(decimal? pct)
        {
            decimal p = pct ?? 0m;
            return Math.Round(301.6m * (1 - p / 100m), 1).ToString(System.Globalization.CultureInfo.InvariantCulture);
        }
    }
}
```

- [ ] **Step 2: Declare the repeater controls in the designer**

Replace the body of `student/course_detail.aspx.designer.cs` with:

```csharp
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------

namespace src.student
{
    public partial class course_detail
    {
        protected global::System.Web.UI.WebControls.Repeater outcomesRepeater;
        protected global::System.Web.UI.WebControls.Repeater modulesRepeater;
        protected global::System.Web.UI.WebControls.Repeater announcementsRepeater;
        protected global::System.Web.UI.WebControls.Repeater assignmentsRepeater;
        protected global::System.Web.UI.WebControls.Repeater assessmentsRepeater;
    }
}
```

- [ ] **Step 3: Bind the header**

In `student/course_detail.aspx`, replace the `<section>` header block (lines 12–41 in the original, the red-gradient banner) with this server-bound version (drop the hardcoded "CSC2104 / Software Engineering / Dr. Lim" text):

```aspx
    <section class="relative mt-4 overflow-hidden rounded-3xl p-7 lg:p-9 text-white" style="background:linear-gradient(135deg,#e0162b 0%,#1e293b 100%)">
        <div class="pointer-events-none absolute -top-16 -right-10 h-64 w-64 rounded-full bg-white/10 blur-3xl"></div>
        <div class="relative flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
            <div class="max-w-2xl">
                <div class="flex items-center gap-2">
                    <span class="rounded-md bg-white/15 px-2 py-0.5 backdrop-blur" style="font-size:11px;font-weight:600;letter-spacing:0.04em"><%= Server.HtmlEncode(Header.CourseCode) %></span>
                    <span class="text-white/70" style="font-size:12px"><%= Server.HtmlEncode(Header.LevelLabel) %></span>
                </div>
                <h1 class="mt-3 text-white" style="font-size:30px;font-weight:700;letter-spacing:-0.015em;line-height:1.15">
                    <%= Server.HtmlEncode(Header.CourseName) %>
                </h1>
                <p class="mt-2 text-white/80 max-w-xl" style="font-size:14.5px;line-height:1.6">
                    <%= Server.HtmlEncode(Header.Description) %>
                </p>
                <div class="mt-4 flex flex-wrap gap-x-5 gap-y-1 text-white/80" style="font-size:13px">
                    <span>&#128100; <%= Server.HtmlEncode(Header.LecturerName) %></span>
                    <span>&#127891; <%= Header.CreditHours %> credits</span>
                    <span>&#128218; <%= Header.ModuleCount %> modules</span>
                </div>
            </div>
            <div class="shrink-0">
                <button data-action="toggle-pin" data-code="<%= Server.HtmlEncode(Header.CourseCode) %>"
                    class="inline-flex items-center gap-2 rounded-2xl border border-white/25 bg-white/10 px-5 py-2.5 text-white backdrop-blur hover:bg-white/20 transition-colors"
                    style="font-size:13px;font-weight:600" aria-label="Toggle pin">
                    <i data-lucide="pin" class="h-4 w-4"></i>
                    Pin course
                </button>
            </div>
        </div>
    </section>
```

- [ ] **Step 4: Bind the sidebar**

In `student/course_detail.aspx`, replace the `<aside>` "Course Details" block (lines 327–359 in the original) with:

```aspx
                <aside class="rounded-2xl border border-slate-200 bg-white p-6">
                    <h3 class="text-slate-900" style="font-size:15px;font-weight:600">Course Details</h3>
                    <dl class="mt-4 space-y-3">
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Mode</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500"><%= Server.HtmlEncode(Header.Mode) %></dd>
                        </div>
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Contact hours</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500"><%= Server.HtmlEncode(Header.ContactHours) %></dd>
                        </div>
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Prerequisites</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500"><%= Server.HtmlEncode(Header.Prerequisites) %></dd>
                        </div>
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Textbook</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500"><%= Server.HtmlEncode(Header.Textbook) %></dd>
                        </div>
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Office hours</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500"><%= Server.HtmlEncode(Header.OfficeHours) %></dd>
                        </div>
                    </dl>
                    <div class="mt-5 rounded-xl bg-slate-50 p-4">
                        <p class="text-slate-500" style="font-size:11.5px;font-weight:600;letter-spacing:0.04em">LEARNING OUTCOMES</p>
                        <ul class="mt-2 space-y-2 text-slate-700" style="font-size:12.5px;line-height:1.55">
                            <asp:Repeater ID="outcomesRepeater" runat="server">
                                <ItemTemplate>
                                    <li>&bull; <%# Server.HtmlEncode(Eval("Text").ToString()) %></li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                    </div>
                </aside>
```

- [ ] **Step 5: Build** — expected `Build succeeded`, 0 errors. (The other four repeaters are declared in the designer but not yet placed in markup — they're bound in code-behind; their markup is added in Tasks 10–13. A `Repeater` with no markup counterpart will throw at run time, so do NOT browse the page until Task 13 is done. Build-only check here.)

- [ ] **Step 6: Commit**

```
git add "5026CMD Software Engineer/src/src/student/course_detail.aspx.cs" "5026CMD Software Engineer/src/src/student/course_detail.aspx.designer.cs" "5026CMD Software Engineer/src/src/student/course_detail.aspx"
git commit -m "feat(course-detail): code-behind + header/sidebar bound to DB"
```

---

## Task 10: Bind the Modules pane

**Files:**
- Modify: `student/course_detail.aspx` (Modules pane)

- [ ] **Step 1: Replace the static module accordion with a Repeater**

In `student/course_detail.aspx`, replace the whole `<ul ... id="module-accordion">…</ul>` block (the five hardcoded `<li>` week items, original lines 100–323) with:

```aspx
                    <ul class="divide-y divide-slate-100" id="module-accordion">
                        <asp:Repeater ID="modulesRepeater" runat="server">
                            <ItemTemplate>
                                <li>
                                    <button data-action="toggle-module" data-week='<%# Eval("Week") %>'
                                        class="flex w-full items-center gap-4 px-6 py-4 hover:bg-slate-50/60 transition-colors text-left">
                                        <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#e0162b15;color:#e0162b;font-size:12px;font-weight:700"><%# Eval("Week") %></span>
                                        <div class="min-w-0 flex-1">
                                            <p class="text-slate-900 truncate" style="font-size:14px;font-weight:600"><%# Server.HtmlEncode(Eval("Title").ToString()) %></p>
                                            <p class="text-slate-500 mt-0.5 truncate" style="font-size:12.5px"><%# Server.HtmlEncode(Eval("Description").ToString()) %></p>
                                        </div>
                                        <span class="text-slate-400" style="font-size:11.5px;font-weight:600"><%# ((System.Collections.ICollection)Eval("Items")).Count %> items</span>
                                        <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 transition-transform module-chevron"></i>
                                    </button>
                                    <ul class="bg-slate-50/50 px-6 pb-4 module-items hidden" data-week='<%# Eval("Week") %>'>
                                        <asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'>
                                            <ItemTemplate>
                                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                                                        <i data-lucide='<%# FileIcon(Eval("FileType").ToString()) %>' class="h-4 w-4"></i>
                                                    </span>
                                                    <div class="min-w-0 flex-1">
                                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500"><%# Server.HtmlEncode(Eval("Title").ToString()) %></p>
                                                        <p class="text-slate-400" style="font-size:11px"><%# FileSize(Eval("FileSizeBytes")) %></p>
                                                    </div>
                                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                                        <i data-lucide="download" class="h-4 w-4"></i>
                                                    </button>
                                                </li>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </ul>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>
```

Also update the panel sub-header (original line 97) to reflect real counts — replace the hardcoded "12 weekly modules…" paragraph with:

```aspx
                            <p class="text-slate-500 mt-0.5" style="font-size:13px"><%= Header.ModuleCount %> weekly modules</p>
```

- [ ] **Step 2: Build** — expected `Build succeeded`, 0 errors. (The nested `<asp:Repeater>` has no `ID`, which is valid for a template-bound child.)

- [ ] **Step 3: Commit**

```
git add "5026CMD Software Engineer/src/src/student/course_detail.aspx"
git commit -m "feat(course-detail): bind Modules pane to ModuleService"
```

---

## Task 11: Bind the Announcements pane

**Files:**
- Modify: `student/course_detail.aspx` (Announcements pane)

- [ ] **Step 1: Replace the static announcement list with a Repeater**

In `student/course_detail.aspx`, replace the whole `<ul class="divide-y divide-slate-100">…</ul>` inside the announcements pane (the three hardcoded `<li>` items, original lines 373–441) with:

```aspx
                <ul class="divide-y divide-slate-100">
                    <asp:Repeater ID="announcementsRepeater" runat="server">
                        <ItemTemplate>
                            <li>
                                <div class="flex w-full items-start gap-3 px-6 py-5">
                                    <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[#e0162b] text-white" style="font-size:12px;font-weight:600"><%# Server.HtmlEncode(Initials(Eval("AuthorName").ToString())) %></div>
                                    <div class="min-w-0 flex-1">
                                        <div class="flex items-center gap-2 flex-wrap">
                                            <span class="text-slate-900" style="font-size:13.5px;font-weight:600"><%# Server.HtmlEncode(Eval("AuthorName").ToString()) %></span>
                                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode(Eval("AuthorRole").ToString()) %></span>
                                            <span class="text-slate-400" style="font-size:11.5px">&middot; <%# ((System.DateTime)Eval("CreatedAt")).ToString("d MMM · HH:mm") %></span>
                                            <%# (bool)Eval("IsPinned") ? "<span class=\"inline-flex items-center gap-1 rounded-md bg-[#e0162b]/10 px-1.5 py-0.5 text-[#a01020]\" style=\"font-size:10.5px;font-weight:600\">Pinned</span>" : "" %>
                                        </div>
                                        <p class="mt-1.5 text-slate-900" style="font-size:14px;font-weight:600"><%# Server.HtmlEncode(Eval("Title").ToString()) %></p>
                                        <p class="mt-1 text-slate-600" style="font-size:13px;line-height:1.6"><%# Server.HtmlEncode(Eval("Content").ToString()) %></p>
                                        <%# (bool)Eval("HasAttachment") ? "<p class=\"mt-2 inline-flex items-center gap-1 text-slate-500\" style=\"font-size:11.5px\">1 attachment</p>" : "" %>
                                    </div>
                                </div>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
```

- [ ] **Step 2: Build** — expected `Build succeeded`, 0 errors.

- [ ] **Step 3: Commit**

```
git add "5026CMD Software Engineer/src/src/student/course_detail.aspx"
git commit -m "feat(course-detail): bind Announcements pane (pinned-first)"
```

---

## Task 12: Bind the Assignments pane

**Files:**
- Modify: `student/course_detail.aspx` (Assignments pane)

- [ ] **Step 1: Replace the static assignment cards with a Repeater**

In `student/course_detail.aspx`, replace the whole `<div class="grid gap-3">…</div>` inside the assignments pane (the four hardcoded `<button>` cards, original lines 447–541) with:

```aspx
            <div class="grid gap-3">
                <asp:Repeater ID="assignmentsRepeater" runat="server">
                    <ItemTemplate>
                        <div class="group flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 text-left sm:flex-row sm:items-center">
                            <span class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-[#e0162b]/10 text-[#e0162b]">
                                <i data-lucide="clipboard-list" class="h-5 w-5"></i>
                            </span>
                            <div class="min-w-0 flex-1">
                                <div class="flex items-center gap-2 flex-wrap">
                                    <h3 class="text-slate-900" style="font-size:14.5px;font-weight:600"><%# Server.HtmlEncode(Eval("Title").ToString()) %></h3>
                                    <%# Eval("Weight") != null ? "<span class=\"rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600\" style=\"font-size:10.5px;font-weight:600\">" + System.Convert.ToDecimal(Eval("Weight")).ToString("0.#") + "%</span>" : "" %>
                                    <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode(Eval("AssignmentType").ToString() + (string.IsNullOrEmpty(Eval("GroupSize").ToString()) ? "" : " (" + Eval("GroupSize") + ")")) %></span>
                                </div>
                                <p class="mt-1 text-slate-500" style="font-size:12.5px"><%# Server.HtmlEncode(Eval("Description").ToString()) %></p>
                                <p class="mt-1 inline-flex items-center gap-1 text-slate-500" style="font-size:12px">
                                    <span><%# Server.HtmlEncode(DueLabel(Eval("SubmissionStatus").ToString(), (System.DateTime)Eval("DueDate"))) %></span>
                                </p>
                            </div>
                            <div class="flex items-center gap-2">
                                <%# Eval("Marks") != null ? "<span class=\"rounded-lg bg-emerald-50 px-3 py-1.5 text-emerald-700\" style=\"font-size:12.5px;font-weight:700\">" + System.Convert.ToDecimal(Eval("Marks")).ToString("0.#") + " / 100</span>" : "" %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
```

- [ ] **Step 2: Build** — expected `Build succeeded`, 0 errors.

- [ ] **Step 3: Commit**

```
git add "5026CMD Software Engineer/src/src/student/course_detail.aspx"
git commit -m "feat(course-detail): bind Assignments pane (weight/type + status)"
```

---

## Task 13: Bind the Grades pane

**Files:**
- Modify: `student/course_detail.aspx` (Grades pane)

- [ ] **Step 1: Bind the donut + totals**

In `student/course_detail.aspx`, in the Grades pane "Overall Grade" card, replace the donut value circle and the two stat tiles (original lines 553–573). Set the second donut `<circle>`'s `stroke-dashoffset` and the center text dynamically:

```aspx
                    <div class="relative mx-auto mt-3 h-44 w-44 flex items-center justify-center">
                        <svg viewBox="0 0 120 120" class="w-full h-full -rotate-90">
                            <circle cx="60" cy="60" r="48" fill="none" stroke="#f1f5f9" stroke-width="12" />
                            <circle cx="60" cy="60" r="48" fill="none" stroke="#e0162b" stroke-width="12"
                                stroke-dasharray="301.6" stroke-dashoffset='<%= DonutOffset(Book.OverallAverage) %>' stroke-linecap="round" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <div class="text-slate-900" style="font-size:32px;font-weight:700;letter-spacing:-0.01em"><%= Book.OverallAverage.HasValue ? Book.OverallAverage.Value + "%" : "—" %></div>
                            <div class="text-slate-500" style="font-size:12px">Average</div>
                        </div>
                    </div>
                    <div class="mt-4 grid grid-cols-2 gap-3">
                        <div class="rounded-xl bg-slate-50 p-3">
                            <div class="text-slate-500" style="font-size:11.5px;font-weight:500">Earned (weighted)</div>
                            <div class="text-slate-900 mt-1" style="font-size:18px;font-weight:700"><%= Book.EarnedWeighted %><span class="text-slate-400" style="font-size:12px"> /100</span></div>
                        </div>
                        <div class="rounded-xl bg-slate-50 p-3">
                            <div class="text-slate-500" style="font-size:11.5px;font-weight:500">Completed</div>
                            <div class="text-slate-900 mt-1" style="font-size:18px;font-weight:700"><%= Book.CompletedPercent %><span class="text-slate-400" style="font-size:12px">%</span></div>
                        </div>
                    </div>
```

Also update the "Based on N graded items" line (original line 551):

```aspx
                    <p class="text-slate-500 mt-0.5" style="font-size:12.5px">Based on <%= Book.Items.FindAll(i => i.IsGraded).Count %> graded items</p>
```

- [ ] **Step 2: Replace the static bar chart with bound bars**

Replace the inner bars of the bar chart (original lines 598–617, the four hardcoded `<div class="flex-1 …">` bars) with a Repeater bound to the same gradebook items. Bar height is `marks/max * 56%` of the plot so graded items scale; pending items render no bar:

```aspx
                        <asp:Repeater ID="barsRepeater" runat="server">
                            <ItemTemplate>
                                <div class="flex-1 flex flex-col items-center gap-1 z-10">
                                    <div class="w-full rounded-t-md" style='height:<%# (bool)Eval("IsGraded") ? System.Math.Round(System.Convert.ToDecimal(Eval("Marks")) / System.Convert.ToInt32(Eval("MaxMarks")) * 72, 0) : 0 %>%;background-color:#e0162b'></div>
                                    <span class="text-slate-500 text-center" style="font-size:10px"><%# Server.HtmlEncode(Eval("Name").ToString()) %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
```

Add `barsRepeater` to the designer file (`student/course_detail.aspx.designer.cs`):

```csharp
        protected global::System.Web.UI.WebControls.Repeater barsRepeater;
```

And bind it in `Page_Load` (add after the `assessmentsRepeater.DataBind();` line). Because `barsRepeater` uses a `DataSource="<%# ... %>"` binding expression, bind it via `DataBind()` only after `Book` is set:

```csharp
            barsRepeater.DataSource = _gradebook.Items;
            barsRepeater.DataBind();
```

- [ ] **Step 3: Replace the static assessments table body with a Repeater**

Replace the `<tbody>…</tbody>` of the "All Assessments" table (original lines 640–690) with:

```aspx
                            <tbody class="divide-y divide-slate-100">
                                <asp:Repeater ID="assessmentsRepeater" runat="server">
                                    <ItemTemplate>
                                        <tr class="hover:bg-slate-50/60">
                                            <td class="px-6 py-3.5 text-slate-900" style="font-size:13px;font-weight:500"><%# Server.HtmlEncode(Eval("Name").ToString()) %></td>
                                            <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px"><%# Server.HtmlEncode(Eval("Type").ToString()) %></td>
                                            <td class="px-3 py-3.5 text-right text-slate-600" style="font-size:12.5px"><%# System.Convert.ToDecimal(Eval("Weight")).ToString("0.#") %>%</td>
                                            <td class="px-3 py-3.5 text-right" style="font-size:13px;font-weight:600">
                                                <%# (bool)Eval("IsGraded") ? "<span class=\"text-emerald-700\">" + System.Convert.ToDecimal(Eval("Marks")).ToString("0.#") + " / " + Eval("MaxMarks") + "</span>" : "<span class=\"text-slate-400\">Pending</span>" %>
                                            </td>
                                            <td class="px-6 py-3.5 text-right text-slate-700" style="font-size:12.5px;font-weight:600"><%# Eval("Contribution") != null ? System.Convert.ToDecimal(Eval("Contribution")).ToString("0.#") + " pts" : "—" %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
```

Update the table footer total (original lines 691–698) to use the computed earned-weighted value:

```aspx
                            <tfoot>
                                <tr class="bg-slate-50">
                                    <td class="px-6 py-3.5 text-slate-900" colspan="2" style="font-size:13px;font-weight:700">Total</td>
                                    <td class="px-3 py-3.5 text-right text-slate-900" style="font-size:13px;font-weight:700">100%</td>
                                    <td class="px-3 py-3.5 text-right text-slate-500" style="font-size:12.5px">&mdash;</td>
                                    <td class="px-6 py-3.5 text-right text-slate-900" style="font-size:13px;font-weight:700"><%= Book.EarnedWeighted %> pts</td>
                                </tr>
                            </tfoot>
```

- [ ] **Step 4: Build** — expected `Build succeeded`, 0 errors.

- [ ] **Step 5: Commit**

```
git add "5026CMD Software Engineer/src/src/student/course_detail.aspx" "5026CMD Software Engineer/src/src/student/course_detail.aspx.designer.cs" "5026CMD Software Engineer/src/src/student/course_detail.aspx.cs"
git commit -m "feat(course-detail): bind Grades pane (donut, bars, table) to AssessmentService"
```

---

## Task 14: End-to-end manual verification

**Files:** none (verification only)

- [ ] **Step 1: Build the whole project** — expected `Build succeeded`, 0 errors.

- [ ] **Step 2: Run the app and log in** as the seeded student (`p26017888`, user 1). On **My Courses**, click **Open course** on **Programming Fundamentals (CS101)**.

Verify the URL is `…/student/course_detail.aspx?offering=1` and the page shows:
- Header: "CS101", "Y1 · Trimester 1", "Programming Fundamentals", description, "Dr. Sarah Tan", "3 credits", "3 modules".
- Sidebar: mode/contact/prereq/textbook/office hours populated; 3 learning-outcome bullets.
- **Modules** tab: weeks 1–3; week 1 expands to 2 items (a `.pptx` with size + a video with no size).
- **Announcements** tab: the pinned "Assignment 1 Released" first with a Pinned badge, author "Dr. Sarah Tan" / role "LECTURER".
- **Assignments** tab: "Assignment 1: Variables & Loops", 10% / Individual, "Submitted · 15 Feb".
- **Grades** tab: donut shows the weighted average of the 3 graded items; table lists 5 rows (3 graded with contribution pts, Mid-term + Final "Pending"); bars only for graded items; "Based on 3 graded items".

- [ ] **Step 3: Verify the enrolment guard** — manually browse to `…/student/course_detail.aspx?offering=3` (BA101, which student 1 is **not** enrolled in per seed) and to `…/student/course_detail.aspx?offering=abc`. Both must **redirect to My Courses**.

- [ ] **Step 4: No commit** (verification only). If any check fails, fix in the owning task and re-verify.

---

## Notes for the implementer

- **Tailwind grid quirk** (project memory): the Play CDN's `grid-cols-*` utilities are unreliable here, but this plan reuses the existing layout's already-working grid markup — don't introduce new `grid-cols-*` classes. If a multi-column block misbehaves, use inline `style="display:grid"`.
- **No nested `<form>`** (project memory): `DashboardLayout.master` already wraps the body in a form; never add a `<form runat="server">` to this content page.
- All four panes share the same `data-action="switch-tab"` JS in `js/course-detail/course-detail.js`, which already exists and is unchanged.
