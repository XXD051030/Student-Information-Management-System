# Enrollment Page From DB Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `student/enrollment.aspx` fully database-driven — every displayed value comes from SQL Server, and selecting courses + "Proceed to Payment" persists `ENROLMENTS` rows.

**Architecture:** A new idempotent SQL script adds `capacity`/`fee_per_credit` columns and seeds an upcoming registration semester (`2026-S3`) with offerings, lecturers, timetables, and a registration window. `EnrolmentService` gains read methods (registration semester, registration window, offerings-for-registration, student semester number) and one write method (`Enrol`). The page gets the standard auth gate, server-binds an `asp:Repeater` of offering cards, exposes a `[WebMethod] Enrol`, and a new `enrollment.js` computes live selection totals and posts the chosen offerings.

**Tech Stack:** ASP.NET Web Forms (.NET Framework 4.7.2, C#), SQL Server LocalDB, raw `SqlCommand` via `src.db.Db.OpenConnection()`, Tailwind CDN, Lucide icons, plain-IIFE JavaScript.

**Note on testing:** This project has no unit-test framework. Verification is done by (a) building with MSBuild and (b) running `sqlcmd` queries / loading the page. Each task's verification step reflects that.

**Shared commands (used throughout):**

- Build:
  ```powershell
  & "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src\src.csproj" /t:Build /p:Configuration=Debug /v:minimal
  ```
- Run a SQL script:
  ```powershell
  sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -i "db\enrollment.sql"
  ```
- Ad-hoc query:
  ```powershell
  sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "<sql>"
  ```

Run all commands from the project directory `...\src\src`. (Per memory: use PowerShell for MSBuild — Git Bash mangles the switches.)

---

## File Structure

- **Create** `db/enrollment.sql` — schema patch + seed for the registration term.
- **Modify** `services/EnrolmentService.cs` — new models + read methods + `Enrol` write method.
- **Modify** `student/enrollment.aspx.designer.cs` — declare `offeringsRepeater`.
- **Modify** `student/enrollment.aspx.cs` — auth gate, data load, helpers, `Enrol` WebMethod.
- **Modify** `student/enrollment.aspx` — replace hardcoded markup with bound output.
- **Create** `js/enrollment/enrollment.js` — selection totals + submit.
- **Modify** `src.csproj` — add the new JS and SQL files as `Content`.
- **Modify** `doc/project-context.md` — document the now-DB-driven page.

---

## Task 1: Schema patch + seed script

**Files:**
- Create: `db/enrollment.sql`

- [ ] **Step 1: Write the script**

Create `db/enrollment.sql` with exactly this content:

```sql
/* ============================================================================
   db/enrollment.sql
   Idempotent patch + seed for the course-enrollment page.
   Run order: AFTER db/course_detail.sql.
   Safe to re-run.
   ========================================================================= */
USE StudentInformationManagementSystem;
GO

/* -- 1. Seat capacity on each offering ------------------------------------- */
IF COL_LENGTH('dbo.COURSE_OFFERINGS', 'capacity') IS NULL
    ALTER TABLE dbo.COURSE_OFFERINGS ADD capacity INT NULL;
GO

/* -- 2. Fee per credit on each course -------------------------------------- */
IF COL_LENGTH('dbo.COURSES', 'fee_per_credit') IS NULL
    ALTER TABLE dbo.COURSES ADD fee_per_credit DECIMAL(10,2) NULL;
GO
UPDATE dbo.COURSES SET fee_per_credit = 150 WHERE fee_per_credit IS NULL;
GO

/* -- 3. New courses for registration variety ------------------------------- */
INSERT INTO dbo.COURSES (course_name, course_code, programme_id, credit_hours, color, prerequisites)
SELECT v.course_name, v.course_code, v.programme_id, v.credit_hours, v.color, v.prerequisites
FROM (VALUES
    ('Human-Computer Interaction',      'CSC2204', 1, 3, '#10b981', NULL),
    ('Probability and Statistics',      'MTH2102', 1, 3, '#f59e0b', 'MTH1002'),
    ('Entrepreneurship and Innovation', 'BUS2001', 2, 2, '#0f766e', NULL),
    ('Mobile App Development',          'CSC2205', 3, 3, '#e0162b', NULL)
) v(course_name, course_code, programme_id, credit_hours, color, prerequisites)
WHERE NOT EXISTS (SELECT 1 FROM dbo.COURSES c WHERE c.course_code = v.course_code);
GO
UPDATE dbo.COURSES SET fee_per_credit = 150 WHERE fee_per_credit IS NULL;
GO

/* -- 4. Upcoming registration semester ------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM dbo.SEMESTERS WHERE name = '2026-S3')
    INSERT INTO dbo.SEMESTERS (name, start_date, end_date, is_current)
    VALUES ('2026-S3', '2026-08-03', '2026-12-11', 0);
GO

/* -- 5. Registration + add/drop windows (drive the phase banner) ----------- */
DECLARE @sem3 INT = (SELECT semester_id FROM dbo.SEMESTERS WHERE name = '2026-S3');

IF NOT EXISTS (SELECT 1 FROM dbo.ACADEMIC_CALENDAR WHERE semester_id = @sem3 AND event_type = 'REGISTRATION')
    INSERT INTO dbo.ACADEMIC_CALENDAR (semester_id, event_type, event_name, start_date, end_date)
    VALUES (@sem3, 'REGISTRATION', 'Course Registration', '2026-05-01', '2026-06-15');

IF NOT EXISTS (SELECT 1 FROM dbo.ACADEMIC_CALENDAR WHERE semester_id = @sem3 AND event_type = 'ADD_DROP')
    INSERT INTO dbo.ACADEMIC_CALENDAR (semester_id, event_type, event_name, start_date, end_date)
    VALUES (@sem3, 'ADD_DROP', 'Add / Drop Period', '2026-08-04', '2026-08-18');
GO

/* -- 6. Offerings for the registration semester (+ capacity) --------------- */
DECLARE @sem3 INT = (SELECT semester_id FROM dbo.SEMESTERS WHERE name = '2026-S3');

INSERT INTO dbo.COURSE_OFFERINGS (course_id, semester_id, capacity)
SELECT c.course_id, @sem3, v.capacity
FROM (VALUES
    ('CS101', 40), ('CS201', 40), ('BA101', 60), ('IT102', 40),
    ('CSC2204', 40), ('MTH2102', 50), ('BUS2001', 60), ('CSC2205', 2)
) v(course_code, capacity)
JOIN dbo.COURSES c ON c.course_code = v.course_code
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.COURSE_OFFERINGS o
    WHERE o.course_id = c.course_id AND o.semester_id = @sem3);

-- Backfill capacity for any 2026-S3 offering still null.
UPDATE o SET o.capacity = 40
FROM dbo.COURSE_OFFERINGS o
WHERE o.semester_id = @sem3 AND o.capacity IS NULL;
GO

/* -- 7. Lecturers for the new offerings ------------------------------------ */
DECLARE @sem3 INT = (SELECT semester_id FROM dbo.SEMESTERS WHERE name = '2026-S3');

INSERT INTO dbo.TEACHINGS (lecturer_id, offering_id)
SELECT v.lecturer_id, o.offering_id
FROM (VALUES
    ('CS101', 1), ('CS201', 1), ('BA101', 2), ('IT102', 3),
    ('CSC2204', 3), ('MTH2102', 1), ('BUS2001', 2), ('CSC2205', 3)
) v(course_code, lecturer_id)
JOIN dbo.COURSES c ON c.course_code = v.course_code
JOIN dbo.COURSE_OFFERINGS o ON o.course_id = c.course_id AND o.semester_id = @sem3
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.TEACHINGS t
    WHERE t.offering_id = o.offering_id AND t.lecturer_id = v.lecturer_id);
GO

/* -- 8. Timetable rows for the new offerings ------------------------------- */
DECLARE @sem3 INT = (SELECT semester_id FROM dbo.SEMESTERS WHERE name = '2026-S3');

INSERT INTO dbo.TIMETABLES (offering_id, venue, day_of_week, start_time, end_time)
SELECT o.offering_id, v.venue, v.day_of_week, v.start_time, v.end_time
FROM (VALUES
    ('CS101',   'Block A-101', 'Monday',    '09:00', '10:30'),
    ('CS201',   'Block A-102', 'Wednesday', '11:00', '12:30'),
    ('BA101',   'Block B-201', 'Tuesday',   '10:00', '11:30'),
    ('IT102',   'Lab C-301',   'Thursday',  '14:00', '15:30'),
    ('CSC2204', 'Block A-103', 'Wednesday', '14:00', '16:00'),
    ('MTH2102', 'Block A-104', 'Tuesday',   '14:00', '15:30'),
    ('BUS2001', 'Block B-202', 'Friday',    '15:00', '17:00'),
    ('CSC2205', 'Lab C-302',   'Thursday',  '09:00', '11:00')
) v(course_code, venue, day_of_week, start_time, end_time)
JOIN dbo.COURSES c ON c.course_code = v.course_code
JOIN dbo.COURSE_OFFERINGS o ON o.course_id = c.course_id AND o.semester_id = @sem3
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.TIMETABLES t WHERE t.offering_id = o.offering_id);
GO

/* -- 9. Seed enrolments in the registration semester ----------------------- */
/*  - Student 1 (Ong Zhi Bo) already registered for CS101 & CS201  -> "Registered"
    - Fill CSC2205 (capacity 2) with students 2 & 3                -> "Full"        */
DECLARE @sem3 INT = (SELECT semester_id FROM dbo.SEMESTERS WHERE name = '2026-S3');

INSERT INTO dbo.ENROLMENTS (student_id, offering_id, status)
SELECT v.student_id, o.offering_id, 'ENROLLED'
FROM (VALUES
    (1, 'CS101'), (1, 'CS201'),
    (2, 'CSC2205'), (3, 'CSC2205')
) v(student_id, course_code)
JOIN dbo.COURSES c ON c.course_code = v.course_code
JOIN dbo.COURSE_OFFERINGS o ON o.course_id = c.course_id AND o.semester_id = @sem3
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.ENROLMENTS e
    WHERE e.student_id = v.student_id AND e.offering_id = o.offering_id);
GO
```

- [ ] **Step 2: Run the script**

Run:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -i "db\enrollment.sql"
```
Expected: completes with no errors (row-count messages only).

- [ ] **Step 3: Run it again to confirm idempotency**

Run the same command a second time. Expected: still no errors; no duplicate-key failures.

- [ ] **Step 4: Verify the seeded data**

Run:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SET NOCOUNT ON; DECLARE @s INT=(SELECT semester_id FROM SEMESTERS WHERE name='2026-S3'); SELECT c.course_code, o.capacity, c.fee_per_credit, (SELECT COUNT(*) FROM ENROLMENTS e WHERE e.offering_id=o.offering_id) AS enrolled FROM COURSE_OFFERINGS o JOIN COURSES c ON o.course_id=c.course_id WHERE o.semester_id=@s ORDER BY c.course_code;"
```
Expected: 8 rows. Every row has `capacity` and `fee_per_credit = 150.00`. `CSC2205` shows `capacity 2` and `enrolled 2`. `CS101`/`CS201` show `enrolled 1`.

- [ ] **Step 5: Commit**

```powershell
git add "db/enrollment.sql"
git commit -m "feat(db): add enrollment schema patch and registration-term seed"
```

---

## Task 2: EnrolmentService read methods

**Files:**
- Modify: `services/EnrolmentService.cs`

- [ ] **Step 1: Add the `using` for DateTime**

At the top of `services/EnrolmentService.cs`, ensure the using block reads:

```csharp
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;
```

- [ ] **Step 2: Add the new models**

Inside `namespace src.services`, above the `EnrolmentService` class (after the existing `EnrolledCourse` class), add:

```csharp
    /// <summary>
    /// One course offering shown on the enrollment page, with everything the
    /// card needs and the current student's own enrolment status (null when the
    /// student has no enrolment row for this offering).
    /// </summary>
    public class OfferingForRegistration
    {
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string Color { get; set; }
        public string Description { get; set; }
        public string LecturerName { get; set; }
        public string Schedule { get; set; }
        public int EnrolledCount { get; set; }
        public int Capacity { get; set; }
        public decimal FeePerCredit { get; set; }
        public string Prerequisites { get; set; }
        public string MyStatus { get; set; }
    }

    /// <summary>
    /// Registration / add-drop windows for a semester, plus the phase that is
    /// active today. <see cref="IsOpen"/> is true only during the registration
    /// window, when new enrolments are accepted.
    /// </summary>
    public class RegistrationWindow
    {
        public DateTime? RegistrationStart { get; set; }
        public DateTime? RegistrationEnd { get; set; }
        public DateTime? AddDropStart { get; set; }
        public DateTime? AddDropEnd { get; set; }

        public bool IsOpen
        {
            get
            {
                var today = DateTime.Today;
                return RegistrationStart.HasValue && RegistrationEnd.HasValue
                    && today >= RegistrationStart.Value && today <= RegistrationEnd.Value;
            }
        }

        /// <summary>1 = registration, 2 = add/drop, 3 = locked.</summary>
        public int ActivePhase
        {
            get
            {
                var today = DateTime.Today;
                if (RegistrationStart.HasValue && RegistrationEnd.HasValue
                    && today >= RegistrationStart.Value && today <= RegistrationEnd.Value)
                    return 1;
                if (AddDropStart.HasValue && AddDropEnd.HasValue
                    && today >= AddDropStart.Value && today <= AddDropEnd.Value)
                    return 2;
                if (AddDropEnd.HasValue && today > AddDropEnd.Value)
                    return 3;
                return 1; // before registration opens, still show phase 1
            }
        }
    }
```

- [ ] **Step 3: Add the read methods**

Inside the `EnrolmentService` class, after `GetCurrentCourses`, add:

```csharp
        // The upcoming term open for registration: the next semester whose start
        // date is after the current semester's start date.
        public static Semester GetRegistrationSemester()
        {
            const string sql =
                "SELECT TOP 1 semester_id, name, start_date, end_date " +
                "FROM SEMESTERS " +
                "WHERE start_date > (SELECT MAX(start_date) FROM SEMESTERS WHERE is_current = 1) " +
                "ORDER BY start_date";
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            using (var reader = cmd.ExecuteReader())
            {
                if (!reader.Read()) return null;
                return new Semester
                {
                    SemesterId = (int)reader["semester_id"],
                    Name = reader["name"].ToString(),
                    StartDate = (DateTime)reader["start_date"],
                    EndDate = (DateTime)reader["end_date"]
                };
            }
        }

        // Registration + add/drop windows for the given semester.
        public static RegistrationWindow GetRegistrationWindow(int semesterId)
        {
            const string sql =
                "SELECT event_type, start_date, end_date FROM ACADEMIC_CALENDAR " +
                "WHERE semester_id = @sem AND event_type IN ('REGISTRATION', 'ADD_DROP')";
            var window = new RegistrationWindow();
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@sem", semesterId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var type = reader["event_type"].ToString();
                        var start = (DateTime)reader["start_date"];
                        var end = (DateTime)reader["end_date"];
                        if (type == "REGISTRATION")
                        {
                            window.RegistrationStart = start;
                            window.RegistrationEnd = end;
                        }
                        else if (type == "ADD_DROP")
                        {
                            window.AddDropStart = start;
                            window.AddDropEnd = end;
                        }
                    }
                }
            }
            return window;
        }

        // The student's current semester number (e.g. 3) from vw_student_semester,
        // used to label the registration term's year of study. Returns 0 when the
        // student has no row in the view.
        public static int GetStudentSemesterNo(int userId)
        {
            const string sql =
                "SELECT v.current_semester_no FROM vw_student_semester v " +
                "JOIN STUDENTS s ON v.student_id = s.student_id " +
                "WHERE s.user_id = @userId";
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var result = cmd.ExecuteScalar();
                return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
            }
        }

        // Every offering in the given semester, with the current student's own
        // enrolment status (null when not enrolled) and the live enrolled count.
        private const string SelectOfferingsForRegistration =
            "SELECT o.offering_id, c.course_code, c.course_name, c.credit_hours, " +
            "ISNULL(c.color, '') AS color, ISNULL(c.description, '') AS description, " +
            "ISNULL(c.prerequisites, '') AS prerequisites, " +
            "ISNULL(c.fee_per_credit, 150) AS fee_per_credit, " +
            "ISNULL(o.capacity, 0) AS capacity, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, " +
            "(SELECT COUNT(*) FROM ENROLMENTS en WHERE en.offering_id = o.offering_id " +
            "AND en.status IN ('ENROLLED', 'PENDING')) AS enrolled_count, " +
            "(SELECT TOP 1 e.status FROM ENROLMENTS e " +
            "JOIN STUDENTS s ON e.student_id = s.student_id " +
            "WHERE s.user_id = @userId AND e.offering_id = o.offering_id) AS my_status, " +
            "(SELECT STUFF((SELECT ' / ' + tt.day_of_week + ' ' " +
            "+ CONVERT(varchar(5), tt.start_time, 108) + '-' + CONVERT(varchar(5), tt.end_time, 108) " +
            "FROM TIMETABLES tt WHERE tt.offering_id = o.offering_id " +
            "ORDER BY tt.start_time FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 3, '')) AS schedule " +
            "FROM COURSE_OFFERINGS o " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "OUTER APPLY (SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE o.semester_id = @semesterId " +
            "ORDER BY c.course_code";

        public static List<OfferingForRegistration> GetOfferingsForRegistration(int userId, int semesterId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectOfferingsForRegistration, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                cmd.Parameters.AddWithValue("@semesterId", semesterId);
                var list = new List<OfferingForRegistration>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new OfferingForRegistration
                        {
                            OfferingId = (int)reader["offering_id"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            Color = reader["color"].ToString(),
                            Description = reader["description"].ToString(),
                            LecturerName = reader["lecturer_name"].ToString(),
                            Schedule = reader["schedule"] == DBNull.Value ? "" : reader["schedule"].ToString(),
                            EnrolledCount = Convert.ToInt32(reader["enrolled_count"]),
                            Capacity = Convert.ToInt32(reader["capacity"]),
                            FeePerCredit = Convert.ToDecimal(reader["fee_per_credit"]),
                            Prerequisites = reader["prerequisites"].ToString(),
                            MyStatus = reader["my_status"] == DBNull.Value ? null : reader["my_status"].ToString()
                        });
                    }
                }
                return list;
            }
        }
```

- [ ] **Step 4: Build**

Run the build command. Expected: `Build succeeded`, 0 errors.

- [ ] **Step 5: Commit**

```powershell
git add "services/EnrolmentService.cs"
git commit -m "feat(services): add enrollment-catalog read methods to EnrolmentService"
```

---

## Task 3: EnrolmentService `Enrol` write method

**Files:**
- Modify: `services/EnrolmentService.cs`

- [ ] **Step 1: Add the write method**

Inside the `EnrolmentService` class, after `GetOfferingsForRegistration`, add:

```csharp
        // Enrols the student (by user id) into the given offerings for the
        // registration semester. Skips offerings that are not in that semester,
        // already enrolled, or full. New rows use status 'PENDING' (payment
        // pending). Returns the number of rows inserted.
        public static int Enrol(int userId, IEnumerable<int> offeringIds)
        {
            if (offeringIds == null) return 0;

            var regSemester = GetRegistrationSemester();
            if (regSemester == null) return 0;

            const string insertSql =
                "INSERT INTO ENROLMENTS (student_id, offering_id, status) " +
                "SELECT s.student_id, o.offering_id, 'PENDING' " +
                "FROM COURSE_OFFERINGS o " +
                "JOIN STUDENTS s ON s.user_id = @userId " +
                "WHERE o.offering_id = @offeringId AND o.semester_id = @semesterId " +
                "AND NOT EXISTS (SELECT 1 FROM ENROLMENTS e " +
                "WHERE e.student_id = s.student_id AND e.offering_id = o.offering_id) " +
                "AND (SELECT COUNT(*) FROM ENROLMENTS e2 WHERE e2.offering_id = o.offering_id " +
                "AND e2.status IN ('ENROLLED', 'PENDING')) < ISNULL(o.capacity, 0)";

            int inserted = 0;
            using (var conn = Db.OpenConnection())
            {
                foreach (var offeringId in offeringIds)
                {
                    using (var cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        cmd.Parameters.AddWithValue("@offeringId", offeringId);
                        cmd.Parameters.AddWithValue("@semesterId", regSemester.SemesterId);
                        inserted += cmd.ExecuteNonQuery();
                    }
                }
            }
            return inserted;
        }
```

- [ ] **Step 2: Build**

Run the build command. Expected: `Build succeeded`, 0 errors.

- [ ] **Step 3: Commit**

```powershell
git add "services/EnrolmentService.cs"
git commit -m "feat(services): add Enrol write method to EnrolmentService"
```

---

## Task 4: Designer — declare the repeater

**Files:**
- Modify: `student/enrollment.aspx.designer.cs`

- [ ] **Step 1: Add the control field**

Replace the body of the `enrollment` partial class in `student/enrollment.aspx.designer.cs` so the file reads:

```csharp
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated. 
// </auto-generated>
//------------------------------------------------------------------------------

namespace src.student
{


    public partial class enrollment
    {

        /// <summary>
        /// offeringsRepeater control.
        /// </summary>
        protected global::System.Web.UI.WebControls.Repeater offeringsRepeater;
    }
}
```

- [ ] **Step 2: Build**

Run the build command. Expected: `Build succeeded`, 0 errors. (The control is declared but not yet referenced — this just confirms the file compiles.)

- [ ] **Step 3: Commit**

```powershell
git add "student/enrollment.aspx.designer.cs"
git commit -m "chore(enrollment): declare offeringsRepeater in designer"
```

---

## Task 5: Code-behind — auth gate, data load, helpers, WebMethod

**Files:**
- Modify: `student/enrollment.aspx.cs`

- [ ] **Step 1: Replace the file**

Replace the entire contents of `student/enrollment.aspx.cs` with:

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class enrollment : System.Web.UI.Page
    {
        private Semester _regSemester;
        private RegistrationWindow _window;
        private List<OfferingForRegistration> _offerings;
        private int _semesterNo;

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
            _regSemester = EnrolmentService.GetRegistrationSemester();

            if (_regSemester == null)
            {
                _offerings = new List<OfferingForRegistration>();
                _window = new RegistrationWindow();
                return;
            }

            _window = EnrolmentService.GetRegistrationWindow(_regSemester.SemesterId);
            _offerings = EnrolmentService.GetOfferingsForRegistration(userId, _regSemester.SemesterId);
            _semesterNo = EnrolmentService.GetStudentSemesterNo(userId);

            offeringsRepeater.DataSource = _offerings;
            offeringsRepeater.DataBind();
        }

        // --- Header -----------------------------------------------------------

        /// <summary>"Academic Year 2026 / 2027" from the registration term start year.</summary>
        protected string AcademicYearLabel
        {
            get
            {
                if (_regSemester == null) return "";
                int y = _regSemester.StartDate.Year;
                return "Academic Year " + y + " / " + (y + 1);
            }
        }

        /// <summary>Registration term name + month, e.g. "2026-S3 (Aug 2026)".</summary>
        protected string TermLabel
        {
            get
            {
                if (_regSemester == null) return "the upcoming semester";
                return _regSemester.Name + " (" + _regSemester.StartDate.ToString("MMM yyyy") + ")";
            }
        }

        /// <summary>
        /// "Y2 &middot; Trimester 1" for the registration term. The registration
        /// term is one semester after the student's current semester number; three
        /// trimesters make a year of study. Falls back to empty when unknown.
        /// </summary>
        protected string YearAndTrimesterLabel
        {
            get
            {
                if (_semesterNo <= 0) return TermLabel;
                int regNo = _semesterNo + 1;
                int year = ((regNo - 1) / 3) + 1;
                int trimester = ((regNo - 1) % 3) + 1;
                return "Y" + year + " · Trimester " + trimester;
            }
        }

        // --- Registration window ---------------------------------------------

        protected bool RegistrationOpen { get { return _window != null && _window.IsOpen; } }

        protected int ActivePhase { get { return _window != null ? _window.ActivePhase : 1; } }

        /// <summary>"1 May - 15 Jun 2026" registration date range, or "" if unset.</summary>
        protected string RegistrationDateRange
        {
            get
            {
                if (_window == null || !_window.RegistrationStart.HasValue || !_window.RegistrationEnd.HasValue)
                    return "";
                return _window.RegistrationStart.Value.ToString("d MMM") + " - "
                     + _window.RegistrationEnd.Value.ToString("d MMM yyyy");
            }
        }

        /// <summary>"1 - 14 Sep 2026" add/drop date range, or "" if unset.</summary>
        protected string AddDropDateRange
        {
            get
            {
                if (_window == null || !_window.AddDropStart.HasValue || !_window.AddDropEnd.HasValue)
                    return "";
                return _window.AddDropStart.Value.ToString("d MMM") + " - "
                     + _window.AddDropEnd.Value.ToString("d MMM yyyy");
            }
        }

        // --- Stats ------------------------------------------------------------

        /// <summary>Courses the student is already registered for in the registration term.</summary>
        protected int AlreadyRegisteredCount
        {
            get
            {
                if (_offerings == null) return 0;
                return _offerings.Count(o => o.MyStatus == "ENROLLED" || o.MyStatus == "PENDING");
            }
        }

        /// <summary>Flat fee-per-credit rate, echoed into JS for live fee totals.</summary>
        protected decimal FeePerCredit
        {
            get
            {
                if (_offerings != null && _offerings.Count > 0) return _offerings[0].FeePerCredit;
                return 150m;
            }
        }

        // --- Row helpers ------------------------------------------------------

        /// <summary>Course accent color from the DB, validated to a 6-digit hex; slate fallback.</summary>
        protected string AccentColor(string color)
        {
            if (string.IsNullOrEmpty(color)) return "#64748b";
            return System.Text.RegularExpressions.Regex.IsMatch(color, @"^#[0-9A-Fa-f]{6}$")
                ? color : "#64748b";
        }

        protected bool RowRegistered(object myStatus)
        {
            var s = myStatus as string;
            return s == "ENROLLED" || s == "PENDING";
        }

        protected bool RowFull(object myStatus, object enrolled, object capacity)
        {
            if (RowRegistered(myStatus)) return false;
            int en = Convert.ToInt32(enrolled);
            int cap = Convert.ToInt32(capacity);
            return cap > 0 && en >= cap;
        }

        protected bool RowOpen(object myStatus, object enrolled, object capacity)
        {
            return RegistrationOpen
                && !RowRegistered(myStatus)
                && !RowFull(myStatus, enrolled, capacity);
        }

        /// <summary>Green seat dot when seats remain, red when full.</summary>
        protected string SeatDotColor(object enrolled, object capacity)
        {
            int en = Convert.ToInt32(enrolled);
            int cap = Convert.ToInt32(capacity);
            return (cap > 0 && en >= cap) ? "#fecaca" : "#bbf7d0";
        }

        protected decimal RowFee(object credits)
        {
            return Convert.ToInt32(credits) * FeePerCredit;
        }

        // --- Persistence ------------------------------------------------------

        [WebMethod(EnableSession = true)]
        public static object Enrol(int[] offeringIds)
        {
            var ctx = HttpContext.Current;
            if (ctx.Session["user_id"] == null)
            {
                ctx.Response.StatusCode = 401;
                ctx.Response.SuppressContent = true;
                return null;
            }

            int userId = (int)ctx.Session["user_id"];
            int inserted = EnrolmentService.Enrol(userId, offeringIds ?? new int[0]);
            return new { ok = true, inserted = inserted };
        }
    }
}
```

- [ ] **Step 2: Build**

Run the build command. Expected: `Build succeeded`, 0 errors.

- [ ] **Step 3: Commit**

```powershell
git add "student/enrollment.aspx.cs"
git commit -m "feat(enrollment): auth gate, DB data load, helpers, Enrol WebMethod"
```

---

## Task 6: Markup — bind everything

**Files:**
- Modify: `student/enrollment.aspx`

- [ ] **Step 1: Replace the file**

Replace the entire contents of `student/enrollment.aspx` with:

```aspx
<%@ Page Language="C#" MasterPageFile="~/shared/DashboardLayout.master" AutoEventWireup="true" CodeBehind="enrollment.aspx.cs" Inherits="src.student.enrollment" Title="Course Enrollment - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500"><%= Server.HtmlEncode(AcademicYearLabel) %></p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Course Enrollment</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">
                Register for courses for <span class="text-slate-900 font-semibold"><%= Server.HtmlEncode(YearAndTrimesterLabel) %> &middot; <%= Server.HtmlEncode(TermLabel) %></span>.
            </p>
        </div>
    </div>

    <%-- Phase banner --%>
    <section class="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50/60 p-5 lg:p-6">
        <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex items-center gap-3">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-600 text-white">
                    <i data-lucide="check-circle-2" class="h-5 w-5"></i>
                </div>
                <div>
                    <p class="text-emerald-700" style="font-size:11.5px;font-weight:700;letter-spacing:0.04em"><%= RegistrationOpen ? "ENROLLMENT OPEN" : "ENROLLMENT CLOSED" %></p>
                    <p class="mt-0.5 text-slate-900" style="font-size:15px;font-weight:600">Registration period &middot; <%= Server.HtmlEncode(RegistrationDateRange) %></p>
                </div>
            </div>

            <%-- Phase timeline --%>
            <ol class="flex items-center gap-2">
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full <%= ActivePhase >= 1 ? "bg-emerald-600 text-white" : "bg-white text-slate-400 ring-1 ring-slate-200" %>" style="font-size:11px;font-weight:700">1</span>
                    <span class="hidden sm:inline text-slate-900" style="font-size:12px;font-weight:600">Registration period</span>
                    <span class="hidden sm:inline w-6 h-px bg-slate-300"></span>
                </li>
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full <%= ActivePhase >= 2 ? "bg-emerald-600 text-white" : "bg-white text-slate-400 ring-1 ring-slate-200" %>" style="font-size:11px;font-weight:700">2</span>
                    <span class="hidden sm:inline text-slate-500" style="font-size:12px;font-weight:500">Add / Drop period</span>
                    <span class="hidden sm:inline w-6 h-px bg-slate-300"></span>
                </li>
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full <%= ActivePhase >= 3 ? "bg-emerald-600 text-white" : "bg-white text-slate-400 ring-1 ring-slate-200" %>" style="font-size:11px;font-weight:700">3</span>
                    <span class="hidden sm:inline text-slate-500" style="font-size:12px;font-weight:500">Enrollment locked</span>
                </li>
            </ol>
        </div>
    </section>

    <%-- Stats --%>
    <section class="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Courses Selected</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><span id="enroll-count">0</span></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">courses in basket</p>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Credits Selected</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="shield-check" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><span id="enroll-credits">0</span></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">Limit: 12&#8211;21</p>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Estimated Fee</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="wallet" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">RM <span id="enroll-total">0</span></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">RM <%= ((int)FeePerCredit) %> / credit</p>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Already Registered</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="check-circle-2" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-emerald-600" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= AlreadyRegisteredCount %></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">courses confirmed</p>
        </div>
    </section>

    <%-- Course list --%>
    <section class="mt-6 grid gap-3">
        <asp:Repeater ID="offeringsRepeater" runat="server">
            <ItemTemplate>
                <article data-course-row data-code='<%# Server.HtmlEncode(Eval("CourseCode").ToString()) %>'
                         data-credits='<%# Eval("CreditHours") %>' data-fee='<%# RowFee(Eval("CreditHours")) %>'
                         class="rounded-2xl border border-slate-200 bg-white p-5">
                    <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                        <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style='background-color:<%# AccentColor(Eval("Color") as string) %>15;color:<%# AccentColor(Eval("Color") as string) %>'>
                            <i data-lucide="book-open" class="h-5 w-5"></i>
                        </div>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode(Eval("CourseCode").ToString()) %></span>
                                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Eval("CreditHours") %> credits</span>
                                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">RM <%# ((int)RowFee(Eval("CreditHours"))) %></span>
                                <asp:Panel runat="server" Visible='<%# RowRegistered(Eval("MyStatus")) %>' CssClass="inline-flex items-center gap-1 rounded-md bg-emerald-50 px-1.5 py-0.5 text-emerald-700" style="font-size:10.5px;font-weight:600">
                                    <i data-lucide="check-circle-2" class="h-3 w-3"></i> Registered
                                </asp:Panel>
                            </div>
                            <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3"><%# Server.HtmlEncode(Eval("CourseName").ToString()) %></h3>
                            <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55"><%# Server.HtmlEncode(Eval("Description").ToString()) %></p>
                            <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                                <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i><%# Server.HtmlEncode(Eval("LecturerName").ToString()) %></span>
                                <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i><%# Server.HtmlEncode(Eval("Schedule").ToString()) %></span>
                                <span class="inline-flex items-center gap-1.5">
                                    <span class="h-3.5 w-3.5 rounded-full" style='background-color:<%# SeatDotColor(Eval("EnrolledCount"), Eval("Capacity")) %>'></span>
                                    Seats: <%# Eval("EnrolledCount") %>/<%# Eval("Capacity") %>
                                </span>
                            </div>
                            <asp:Panel runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("Prerequisites") as string) %>' CssClass="mt-2 text-slate-500" style="font-size:12px">
                                <span class="text-slate-400">Prerequisites:</span>
                                <span class="ml-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode((Eval("Prerequisites") as string) ?? "") %></span>
                            </asp:Panel>
                        </div>
                        <div class="flex shrink-0 items-center gap-2">
                            <asp:Panel runat="server" Visible='<%# RowRegistered(Eval("MyStatus")) %>' CssClass="inline-flex items-center gap-1.5 rounded-xl bg-emerald-50 border border-emerald-200 px-3.5 h-10 text-emerald-700" style="font-size:13px;font-weight:600">
                                <i data-lucide="check-circle-2" class="h-4 w-4"></i> Registered
                            </asp:Panel>
                            <asp:Panel runat="server" Visible='<%# RowFull(Eval("MyStatus"), Eval("EnrolledCount"), Eval("Capacity")) %>'>
                                <button disabled class="inline-flex items-center gap-1.5 rounded-xl px-3.5 h-10 bg-slate-100 text-slate-400 cursor-not-allowed" style="font-size:13px;font-weight:600">
                                    <i data-lucide="alert-circle" class="h-4 w-4"></i> Full
                                </button>
                            </asp:Panel>
                            <asp:Panel runat="server" Visible='<%# RowOpen(Eval("MyStatus"), Eval("EnrolledCount"), Eval("Capacity")) %>'>
                                <input type="checkbox" data-action="toggle-enroll" data-code='<%# Server.HtmlEncode(Eval("CourseCode").ToString()) %>' data-offering='<%# Eval("OfferingId") %>'
                                       class="h-5 w-5 rounded border-slate-300 text-[#e0162b] accent-[#e0162b] cursor-pointer" />
                            </asp:Panel>
                        </div>
                    </div>
                </article>
            </ItemTemplate>
        </asp:Repeater>
    </section>

    <%-- Submit / confirm enrollment --%>
    <section class="mt-6 flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 lg:flex-row lg:items-center lg:justify-between">
        <div>
            <p class="text-slate-900" style="font-size:14.5px;font-weight:600">Confirm enrollment</p>
            <p class="mt-0.5 text-slate-500" style="font-size:12.5px">
                You may add or drop courses during the Add/Drop period (<%= Server.HtmlEncode(AddDropDateRange) %>).
            </p>
            <p class="mt-1 text-slate-500" style="font-size:12.5px">
                Selected: <span class="text-slate-900 font-semibold"><span id="enroll-count-footer">0</span> course(s)</span>
                &middot; <span class="text-slate-900 font-semibold"><span id="enroll-credits-footer">0</span> credits</span>
                &middot; <span class="text-slate-900 font-semibold">RM <span id="enroll-total-footer">0.00</span></span>
            </p>
        </div>
        <div class="flex items-center gap-2">
            <button data-action="proceed-to-payment" disabled id="enroll-submit"
                    class="inline-flex items-center gap-2 rounded-xl px-5 h-11 bg-slate-100 text-slate-400 cursor-not-allowed transition-all"
                    style="font-size:13.5px;font-weight:600">
                <i data-lucide="check-circle-2" class="h-4 w-4"></i>
                Proceed to Payment
            </button>
        </div>
    </section>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/enrollment/enrollment.js") %>"></script>
</asp:Content>
```

- [ ] **Step 2: Build**

Run the build command. Expected: `Build succeeded`, 0 errors.

- [ ] **Step 3: Commit**

```powershell
git add "student/enrollment.aspx"
git commit -m "feat(enrollment): bind page markup to DB offerings"
```

---

## Task 7: JavaScript — selection totals + submit

**Files:**
- Create: `js/enrollment/enrollment.js`

- [ ] **Step 1: Write the script**

Create `js/enrollment/enrollment.js` with exactly this content:

```javascript
// Course enrollment page: live selection totals + persist on "Proceed to Payment".
// Each enrollable <article data-course-row> carries:
//   data-credits   – integer credit hours
//   data-fee       – fee for this course (credits * rate)
// and contains a checkbox [data-action="toggle-enroll"][data-offering="<id>"].
(function () {
    "use strict";

    function rows() {
        return Array.prototype.slice.call(document.querySelectorAll("[data-course-row]"));
    }

    function checkbox(row) {
        return row.querySelector('[data-action="toggle-enroll"]');
    }

    function selectedRows() {
        return rows().filter(function (row) {
            var cb = checkbox(row);
            return cb && cb.checked;
        });
    }

    function setText(id, value) {
        var el = document.getElementById(id);
        if (el) el.textContent = value;
    }

    function recompute() {
        var selected = selectedRows();
        var count = selected.length;
        var credits = 0;
        var fee = 0;
        selected.forEach(function (row) {
            credits += parseInt(row.getAttribute("data-credits"), 10) || 0;
            fee += parseFloat(row.getAttribute("data-fee")) || 0;
        });

        setText("enroll-count", count);
        setText("enroll-credits", credits);
        setText("enroll-total", fee);
        setText("enroll-count-footer", count);
        setText("enroll-credits-footer", credits);
        setText("enroll-total-footer", fee.toFixed(2));

        var submit = document.getElementById("enroll-submit");
        if (submit) {
            var enabled = count > 0;
            submit.disabled = !enabled;
            submit.classList.toggle("bg-slate-100", !enabled);
            submit.classList.toggle("text-slate-400", !enabled);
            submit.classList.toggle("cursor-not-allowed", !enabled);
            submit.classList.toggle("bg-[#e0162b]", enabled);
            submit.classList.toggle("text-white", enabled);
            submit.classList.toggle("hover:bg-[#a01020]", enabled);
        }
    }

    function selectedOfferingIds() {
        return selectedRows().map(function (row) {
            return parseInt(checkbox(row).getAttribute("data-offering"), 10);
        }).filter(function (n) { return !isNaN(n); });
    }

    function proceed() {
        var ids = selectedOfferingIds();
        if (ids.length === 0) return;

        var submit = document.getElementById("enroll-submit");
        if (submit) submit.disabled = true;

        fetch("/student/enrollment.aspx/Enrol", {
            method: "POST",
            headers: { "Content-Type": "application/json; charset=utf-8" },
            body: JSON.stringify({ offeringIds: ids })
        }).then(function (res) {
            if (!res.ok) throw new Error("enrol failed");
            // Reload so newly enrolled courses render as Registered.
            window.location.reload();
        }).catch(function () {
            if (submit) submit.disabled = false;
            alert("Enrollment could not be completed. Please try again.");
        });
    }

    document.addEventListener("change", function (e) {
        if (e.target && e.target.matches('[data-action="toggle-enroll"]')) {
            recompute();
        }
    });

    document.addEventListener("click", function (e) {
        var btn = e.target.closest ? e.target.closest('[data-action="proceed-to-payment"]') : null;
        if (btn) {
            e.preventDefault();
            proceed();
        }
    });

    recompute();
})();
```

- [ ] **Step 2: Verify the file is well-formed**

Run:
```powershell
node --check "js\enrollment\enrollment.js"
```
Expected: no output (exit 0). If `node` is unavailable, skip this step and rely on the browser check in Task 10.

- [ ] **Step 3: Commit**

```powershell
git add "js/enrollment/enrollment.js"
git commit -m "feat(enrollment): add selection-totals and submit script"
```

---

## Task 8: Project file — include new content

**Files:**
- Modify: `src.csproj`

- [ ] **Step 1: Find the JS content entries**

Open `src.csproj` and locate the `<Content Include="js\...\*.js" />` lines (e.g. `js\courses\courses.js`, `js\account\account.js`).

- [ ] **Step 2: Add the new JS entry**

Next to the other `js\...` content entries, add:

```xml
    <Content Include="js\enrollment\enrollment.js" />
```

(If the build/deploy of `course-detail.js` was also fixed previously, leave that as-is; this task only adds the enrollment JS.)

- [ ] **Step 3: Add the SQL entry**

Locate the `db\*.sql` content entries (e.g. `db\seed_data.sql`, `db\course_detail.sql`) and add next to them:

```xml
    <Content Include="db\enrollment.sql" />
```

- [ ] **Step 4: Build**

Run the build command. Expected: `Build succeeded`, 0 errors.

- [ ] **Step 5: Commit**

```powershell
git add "src.csproj"
git commit -m "chore: include enrollment.js and enrollment.sql in project"
```

---

## Task 9: Update project context doc

**Files:**
- Modify: `doc/project-context.md`

- [ ] **Step 1: Update the enrollment page section**

In `doc/project-context.md`, find the `### student/enrollment.aspx` section and replace its "Current state" / "Important DOM hooks" / "If finishing this page" notes with an accurate description: the page is now DB-driven, auth-gated, binds `offeringsRepeater` from `EnrolmentService.GetOfferingsForRegistration`, shows the registration window from `ACADEMIC_CALENDAR`, and persists via the `Enrol` WebMethod → `EnrolmentService.Enrol`. Note `js/enrollment/enrollment.js` now exists.

- [ ] **Step 2: Update the EnrolmentService section**

In the `### services/EnrolmentService.cs` section, add the new methods (`GetRegistrationSemester`, `GetRegistrationWindow`, `GetStudentSemesterNo`, `GetOfferingsForRegistration`, `Enrol`) and the new models (`OfferingForRegistration`, `RegistrationWindow`). Note the service is no longer read-only — `Enrol` writes `ENROLMENTS` rows (status `PENDING`). Add `ACADEMIC_CALENDAR` to its DB dependencies.

- [ ] **Step 3: Update supporting sections**

- Add `db/enrollment.sql` to the "Database Scripts" section and to the "Fresh Rebuild Order" as step 7 (after `course_detail.sql`): adds `COURSE_OFFERINGS.capacity`, `COURSES.fee_per_credit`, the `2026-S3` registration semester, its `ACADEMIC_CALENDAR` windows, offerings/teachings/timetables, and seed enrolments.
- Update the "Page/File Connection Table" Enrollment row: JS is now `js/enrollment/enrollment.js`; services `EnrolmentService`.
- Update the "Enrollment" entry in the Data Flow Summary to reflect the real flow.
- Remove the now-resolved entries from "Known Issues And Gotchas": "Missing Enrollment JavaScript" and "Enrollment Page Not Auth-Gated".
- Add `ACADEMIC_CALENDAR` to the "Database Table Usage By Code" table (used by `EnrolmentService`).

- [ ] **Step 4: Commit**

```powershell
git add "doc/project-context.md"
git commit -m "docs(context): enrollment page is now DB-driven"
```

---

## Task 10: Full build + manual verification

**Files:** none (verification only)

- [ ] **Step 1: Clean build**

Run the build command. Expected: `Build succeeded`, 0 errors, 0 warnings related to the enrollment files.

- [ ] **Step 2: Confirm the data query the page uses**

Run:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SET NOCOUNT ON; DECLARE @s INT=(SELECT semester_id FROM SEMESTERS WHERE name='2026-S3'); SELECT c.course_code, c.fee_per_credit, o.capacity, (SELECT COUNT(*) FROM ENROLMENTS e WHERE e.offering_id=o.offering_id AND e.status IN ('ENROLLED','PENDING')) AS enrolled FROM COURSE_OFFERINGS o JOIN COURSES c ON o.course_id=c.course_id WHERE o.semester_id=@s ORDER BY c.course_code;"
```
Expected: 8 offerings; `CSC2205` enrolled == capacity (Full); `CS101`/`CS201` enrolled >= 1 (student 1 Registered).

- [ ] **Step 3: Load the page (manual)**

Start the app in Visual Studio / IIS Express, log in as student "Ong Zhi Bo" (user_id 1), and open `https://localhost:44368/student/enrollment.aspx`. Confirm:
- Header shows "Academic Year 2026 / 2027" and the `2026-S3` term.
- Banner reads "ENROLLMENT OPEN" with the registration date range; timeline step 1 is highlighted.
- "Already Registered" stat shows the count of student 1's `2026-S3` enrolments.
- `CS101`/`CS201` cards show the "Registered" badge (no checkbox).
- `CSC2205` shows a disabled "Full" button with a red seat dot and `2/2` seats.
- Other cards show a checkbox; `MTH2102` shows its prerequisites text.

- [ ] **Step 4: Exercise the enroll flow (manual)**

Tick one or two enrollable courses. Confirm the "Courses Selected", "Credits Selected", and "Estimated Fee" stats and footer update live, and "Proceed to Payment" becomes enabled. Click it. Confirm the page reloads and the chosen courses now render as "Registered" and the "Already Registered" count increased.

- [ ] **Step 5: Confirm persistence in the DB**

Run:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SET NOCOUNT ON; DECLARE @s INT=(SELECT semester_id FROM SEMESTERS WHERE name='2026-S3'); SELECT c.course_code, e.status FROM ENROLMENTS e JOIN STUDENTS st ON e.student_id=st.student_id JOIN COURSE_OFFERINGS o ON e.offering_id=o.offering_id JOIN COURSES c ON o.course_id=c.course_id WHERE st.user_id=1 AND o.semester_id=@s ORDER BY c.course_code;"
```
Expected: the newly selected courses appear with status `PENDING`.

- [ ] **Step 6: Verify no regressions on related pages (manual)**

Open `student/courses.aspx` and `shared/dashboard.aspx`. Confirm they still load and that the new `PENDING` enrolments do **not** appear as current `ENROLLED` courses there (those pages filter on `ENROLLED`).

---

## Notes for the implementer

- Run all commands from `...\src\src`. Use PowerShell for MSBuild (Git Bash mangles the `/p:` switches).
- The SQL script is idempotent; re-running it after a DB rebuild is expected and safe.
- `asp:Panel` renders a `<div>`. The extra wrapper inside the card's right-hand flex container is intentional and harmless.
- The `Enrol` WebMethod inserts `PENDING`, not `ENROLLED`, by design (payment is a future, out-of-scope flow). The enrollment page treats both as "registered".
- If `GetRegistrationSemester()` ever returns null (no future semester seeded), the page renders with an empty course list and a closed banner rather than erroring.
```
