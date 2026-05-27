# Student Academic Metrics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add CGPA, attendance rate, credits earned, and an all-time course list to the student profile, and bind them into the dashboard, replacing the hardcoded mock values.

**Architecture:** Two new read-only static services (`GradeService`, `AttendanceService`) plus an `EnrolmentService`, each owning one SQL query and following the existing `TimetableService`/`AssignmentService` pattern (self-sufficient SQL, `null`/empty/`0` for missing data, exceptions propagate). `StudentService.MapStudent` aggregates them onto the `Student` object exactly as it already does for `TodayClasses` and `AssignmentsDueThisWeek`. The dashboard code-behind exposes formatted display properties; the markup binds to them.

**Tech Stack:** C# (.NET Framework, ASP.NET WebForms), `System.Data.SqlClient`, SQL Server LocalDB.

**Spec:** `docs/superpowers/specs/2026-05-24-student-academic-metrics-design.md`

---

## Prerequisites & conventions

- **Database:** All SQL checks assume the schema (`db/student_information_management_system.sql`) and seed (`db/seed_data.sql`) are loaded into the `StudentInformationManagementSystem` database on `(localdb)\MSSQLLocalDB` (the connection named `SimsDb` in `Web.config`).
- **Running SQL checks** (PowerShell):
  ```powershell
  sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "<query>"
  ```
- **Building:** From a Developer PowerShell (or VS Developer Command Prompt) in the `src\src` project folder:
  ```powershell
  msbuild src.csproj /t:Build /p:Configuration=Debug /nologo
  ```
  Expected on success: `Build succeeded.` with `0 Error(s)`. (Or build in Visual Studio with Ctrl+Shift+B.)
- **New `.cs` files must be registered** in `src.csproj` under the `<ItemGroup>` that contains the existing `<Compile Include="services\...">` lines (around lines 100–103), or the build will ignore them.
- **Seed reference for verification:** student `user_id = 1` (Ong Zhi Bo) is the happy path; `user_id = 6` (Raj Kumar) has no enrolments and is the empty-data case.

---

## Task 1: GradeService (CGPA + credits earned)

**Files:**
- Create: `services/GradeService.cs`
- Modify: `src.csproj` (add `<Compile Include="services\GradeService.cs" />`)

- [ ] **Step 1: Verify the SQL logic against the seed data**

Run:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT SUM(g.gpa * c.credit_hours) AS weighted_points, SUM(c.credit_hours) AS total_credits FROM STUDENTS s JOIN ENROLMENTS e ON e.student_id = s.student_id JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id JOIN COURSES c ON o.course_id = c.course_id JOIN GRADES g ON g.enrolment_id = e.enrolment_id WHERE s.user_id = 1 AND g.published = 1;"
```
Expected: `weighted_points = 24.70`, `total_credits = 7` (CGPA = 24.70 / 7 = 3.53).

Run the same query with `s.user_id = 6`. Expected: one row of `NULL  NULL` (no published grades), which the service treats as CGPA `null`, credits `0`.

- [ ] **Step 2: Write `services/GradeService.cs`**

```csharp
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// A student's cumulative academic summary, computed over all published
    /// grades across all semesters.
    /// </summary>
    public class GradeSummary
    {
        /// <summary>Credit-weighted cumulative GPA; null when no published grades.</summary>
        public decimal? Cgpa { get; set; }

        /// <summary>Total credit hours from all published grades (pass and fail); 0 when none.</summary>
        public int CreditsEarned { get; set; }
    }

    /// <summary>
    /// Read-only access to a student's grade-derived metrics. Returns a
    /// GradeSummary with a null Cgpa and 0 CreditsEarned when the student has
    /// no published grades. SQL exceptions are not caught here; they propagate
    /// to the caller.
    /// </summary>
    public static class GradeService
    {
        // Credit-weighted CGPA numerator/denominator over all published grades,
        // for the student behind the given user. Division is done in C# so an
        // empty set yields null instead of a divide-by-zero.
        private const string SelectSummary =
            "SELECT SUM(g.gpa * c.credit_hours) AS weighted_points, " +
            "SUM(c.credit_hours) AS total_credits " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN GRADES g ON g.enrolment_id = e.enrolment_id " +
            "WHERE s.user_id = @userId AND g.published = 1";

        public static GradeSummary GetSummary(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectSummary, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read() || reader["total_credits"] == System.DBNull.Value)
                    {
                        return new GradeSummary { Cgpa = null, CreditsEarned = 0 };
                    }

                    int totalCredits = (int)reader["total_credits"];
                    decimal weightedPoints = (decimal)reader["weighted_points"];

                    return new GradeSummary
                    {
                        Cgpa = totalCredits > 0
                            ? (decimal?)System.Math.Round(weightedPoints / totalCredits, 2)
                            : null,
                        CreditsEarned = totalCredits
                    };
                }
            }
        }
    }
}
```

- [ ] **Step 3: Register the file in `src.csproj`**

Add this line alongside the other service `<Compile>` entries (after `<Compile Include="services\AssignmentService.cs" />`):
```xml
    <Compile Include="services\GradeService.cs" />
```

- [ ] **Step 4: Build**

Run: `msbuild src.csproj /t:Build /p:Configuration=Debug /nologo`
Expected: `Build succeeded.` `0 Error(s)`.

- [ ] **Step 5: Commit**

```powershell
git add services/GradeService.cs src.csproj
git commit -m "feat(services): add GradeService for CGPA and credits earned"
```

---

## Task 2: AttendanceService (current-semester rate)

**Files:**
- Create: `services/AttendanceService.cs`
- Modify: `src.csproj` (add `<Compile Include="services\AttendanceService.cs" />`)

- [ ] **Step 1: Verify the SQL logic against the seed data**

Run:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END) AS present_count, COUNT(*) AS total_count FROM STUDENTS s JOIN ENROLMENTS e ON e.student_id = s.student_id JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id JOIN SEMESTERS sem ON o.semester_id = sem.semester_id JOIN ATTENDANCE a ON a.enrolment_id = e.enrolment_id WHERE s.user_id = 1 AND sem.is_current = 1;"
```
Expected: `present_count = 2`, `total_count = 3` (rate = 2/3 = 0.67 → 67%). LATE is not counted as present.

Run the same query with `s.user_id = 6`. Expected: `NULL  0` (no records) → service returns `null`.

- [ ] **Step 2: Write `services/AttendanceService.cs`**

```csharp
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// Read-only access to a student's attendance rate for the current
    /// semester. Returns null when the student has no attendance records this
    /// semester (distinct from a real 0). SQL exceptions are not caught here;
    /// they propagate to the caller.
    /// </summary>
    public static class AttendanceService
    {
        // Present-vs-total counts over the current semester's enrolments only.
        // Only PRESENT is credited; LATE and ABSENT count against the rate.
        private const string SelectCounts =
            "SELECT SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END) AS present_count, " +
            "COUNT(*) AS total_count " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ATTENDANCE a ON a.enrolment_id = e.enrolment_id " +
            "WHERE s.user_id = @userId AND sem.is_current = 1";

        /// <summary>
        /// Fraction (0..1) of current-semester attendance records marked PRESENT,
        /// or null when there are no records.
        /// </summary>
        public static decimal? GetCurrentSemesterRate(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectCounts, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;

                    int total = (int)reader["total_count"];
                    if (total == 0) return null;

                    int present = (int)reader["present_count"];
                    return System.Math.Round((decimal)present / total, 4);
                }
            }
        }
    }
}
```

- [ ] **Step 3: Register the file in `src.csproj`**

```xml
    <Compile Include="services\AttendanceService.cs" />
```

- [ ] **Step 4: Build**

Run: `msbuild src.csproj /t:Build /p:Configuration=Debug /nologo`
Expected: `Build succeeded.` `0 Error(s)`.

- [ ] **Step 5: Commit**

```powershell
git add services/AttendanceService.cs src.csproj
git commit -m "feat(services): add AttendanceService for current-semester rate"
```

---

## Task 3: EnrolmentService (all-time course list)

**Files:**
- Create: `services/EnrolmentService.cs`
- Modify: `src.csproj` (add `<Compile Include="services\EnrolmentService.cs" />`)

- [ ] **Step 1: Verify the SQL logic against the seed data**

Run:
```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT e.offering_id, c.course_code, c.course_name, c.credit_hours, ISNULL(lec.full_name, '') AS lecturer_name, sem.name AS semester_name, e.status FROM STUDENTS s JOIN ENROLMENTS e ON e.student_id = s.student_id JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id JOIN COURSES c ON o.course_id = c.course_id JOIN SEMESTERS sem ON o.semester_id = sem.semester_id OUTER APPLY (SELECT TOP 1 l.full_name FROM TEACHINGS t JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec WHERE s.user_id = 1 ORDER BY sem.name, c.course_code;"
```
Expected: 2 rows, both semester `2026-S1`, lecturer `Dr. Sarah Tan`:
| course_code | course_name | credit_hours | lecturer_name | semester_name | status |
|---|---|---|---|---|---|
| CS101 | Programming Fundamentals | 3 | Dr. Sarah Tan | 2026-S1 | ENROLLED |
| CS201 | Database Systems | 4 | Dr. Sarah Tan | 2026-S1 | ENROLLED |

Run the same query with `s.user_id = 6`. Expected: 0 rows.

- [ ] **Step 2: Write `services/EnrolmentService.cs`**

```csharp
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>
    /// One course the student is (or was) enrolled in, across any semester.
    /// </summary>
    public class EnrolledCourse
    {
        public int OfferingId { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string LecturerName { get; set; }
        public string SemesterName { get; set; }
        public string Status { get; set; }
    }

    /// <summary>
    /// Read-only access to a student's complete enrolment history. Returns an
    /// empty list when the student has no enrolments. SQL exceptions are not
    /// caught here; they propagate to the caller.
    /// </summary>
    public static class EnrolmentService
    {
        // Every enrolment for the student, all statuses and semesters, one row
        // each. OUTER APPLY TOP 1 picks a single lecturer per offering so an
        // offering with multiple lecturers does not duplicate the course row.
        private const string SelectCourses =
            "SELECT e.offering_id, c.course_code, c.course_name, c.credit_hours, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, sem.name AS semester_name, e.status " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "OUTER APPLY (" +
            "SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "WHERE s.user_id = @userId " +
            "ORDER BY sem.name, c.course_code";

        public static List<EnrolledCourse> GetCourses(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectCourses, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                var courses = new List<EnrolledCourse>();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        courses.Add(new EnrolledCourse
                        {
                            OfferingId = (int)reader["offering_id"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            LecturerName = reader["lecturer_name"].ToString(),
                            SemesterName = reader["semester_name"].ToString(),
                            Status = reader["status"].ToString()
                        });
                    }
                }
                return courses;
            }
        }
    }
}
```

- [ ] **Step 3: Register the file in `src.csproj`**

```xml
    <Compile Include="services\EnrolmentService.cs" />
```

- [ ] **Step 4: Build**

Run: `msbuild src.csproj /t:Build /p:Configuration=Debug /nologo`
Expected: `Build succeeded.` `0 Error(s)`.

- [ ] **Step 5: Commit**

```powershell
git add services/EnrolmentService.cs src.csproj
git commit -m "feat(services): add EnrolmentService for all-time course list"
```

---

## Task 4: Aggregate metrics onto the Student profile

**Files:**
- Modify: `services/StudentService.cs`

- [ ] **Step 1: Add the four new properties to the `Student` class**

In `services/StudentService.cs`, find the existing `AssignmentsDueThisWeek` property (around line 29) and add these properties immediately after it, inside the `Student` class:

```csharp
        /// <summary>Credit-weighted cumulative GPA; null when no published grades.</summary>
        public decimal? Cgpa { get; set; }

        /// <summary>Total credit hours from all published grades (pass and fail).</summary>
        public int CreditsEarned { get; set; }

        /// <summary>Current-semester attendance rate (0..1); null when no records.</summary>
        public decimal? AttendanceRate { get; set; }

        /// <summary>Every course the student is or was enrolled in, all semesters.</summary>
        public List<EnrolledCourse> Courses { get; set; }
```

- [ ] **Step 2: Populate them in `MapStudent`**

Replace the entire existing `MapStudent` method (currently lines 73–92) with this version, which captures `userId` once and calls the three services:

```csharp
        private static Student MapStudent(SqlDataReader reader)
        {
            int userId = (int)reader["user_id"];
            var gradeSummary = GradeService.GetSummary(userId);

            return new Student
            {
                StudentId = (int)reader["student_id"],
                UserId = userId,
                ProgrammeId = (int)reader["programme_id"],
                FullName = reader["full_name"].ToString(),
                DateOfBirth = reader["date_of_birth"] == DBNull.Value
                    ? (DateTime?)null
                    : (DateTime)reader["date_of_birth"],
                Status = reader["status"].ToString(),
                Email = reader["email"].ToString(),
                Username = reader["username"].ToString(),
                ProgrammeName = reader["programme_name"].ToString(),
                ProgrammeCode = reader["programme_code"].ToString(),
                TodayClasses = TimetableService.GetTodayClasses(userId),
                AssignmentsDueThisWeek = AssignmentService.GetDueThisWeek(userId),
                Cgpa = gradeSummary.Cgpa,
                CreditsEarned = gradeSummary.CreditsEarned,
                AttendanceRate = AttendanceService.GetCurrentSemesterRate(userId),
                Courses = EnrolmentService.GetCourses(userId)
            };
        }
```

- [ ] **Step 3: Build**

Run: `msbuild src.csproj /t:Build /p:Configuration=Debug /nologo`
Expected: `Build succeeded.` `0 Error(s)`.

- [ ] **Step 4: Commit**

```powershell
git add services/StudentService.cs
git commit -m "feat(services): aggregate academic metrics onto Student profile"
```

---

## Task 5: Bind the metrics into the dashboard

**Files:**
- Modify: `shared/dashboard.aspx.cs`
- Modify: `shared/dashboard.aspx`

- [ ] **Step 1: Add display properties to the code-behind**

In `shared/dashboard.aspx.cs`, add these properties inside the `dashboard` class, next to the existing `AssignmentDueCount` property:

```csharp
        protected string CgpaDisplay
        {
            // 2-decimal CGPA, or an em dash when the student has no published grades.
            get
            {
                return _student != null && _student.Cgpa.HasValue
                    ? _student.Cgpa.Value.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture)
                    : "—";
            }
        }

        protected string AttendanceDisplay
        {
            // Whole-percent attendance, or an em dash when there are no records.
            get
            {
                return _student != null && _student.AttendanceRate.HasValue
                    ? System.Math.Round(_student.AttendanceRate.Value * 100).ToString("0", System.Globalization.CultureInfo.InvariantCulture) + "%"
                    : "—";
            }
        }

        protected int CreditsEarnedValue
        {
            get { return _student != null ? _student.CreditsEarned : 0; }
        }
```

- [ ] **Step 2: Bind the courses repeater in `Page_Load`**

In `shared/dashboard.aspx.cs`, in `Page_Load`, immediately after the existing line
`_semester = SemesterService.GetCurrent();`
add:

```csharp
            if (_student != null)
            {
                coursesRepeater.DataSource = _student.Courses;
                coursesRepeater.DataBind();
            }
```

- [ ] **Step 3: Bind the three stat cards in the markup**

In `shared/dashboard.aspx`:

Replace the GPA value line (currently):
```aspx
                    <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">3.78</p>
```
with:
```aspx
                    <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= CgpaDisplay %></p>
```

Replace the Attendance value line (currently):
```aspx
                    <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">94%</p>
```
with:
```aspx
                    <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= AttendanceDisplay %></p>
```

Replace the Credits Earned value line (currently):
```aspx
                    <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">78</p>
```
with:
```aspx
                    <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= CreditsEarnedValue %></p>
```

- [ ] **Step 4: Remove the fabricated trend/target badges**

These show invented deltas we cannot compute. In the GPA card, delete the trend badge block:
```aspx
                <span class="inline-flex items-center gap-1 rounded-full px-2 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:11px;font-weight:600">
                    <i data-lucide="trending-up" class="h-3 w-3"></i>
                    +0.12
                </span>
```
and change the GPA sublabel `vs last semester` to `cumulative`.

In the Attendance card, delete its trend badge block:
```aspx
                <span class="inline-flex items-center gap-1 rounded-full px-2 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:11px;font-weight:600">
                    <i data-lucide="trending-up" class="h-3 w-3"></i>
                    +2.4%
                </span>
```

In the Credits Earned card, delete the target badge block:
```aspx
                <span class="inline-flex items-center gap-1 rounded-full px-2 py-0.5 bg-slate-100 text-slate-600" style="font-size:11px;font-weight:600">
                    of 120
                </span>
```
and change its sublabel `65% completed` to `earned to date`.

- [ ] **Step 5: Replace the static My Courses list with a repeater**

In `shared/dashboard.aspx`, locate the My Courses card's `<ul class="grid gap-3 sm:grid-cols-2">`. Replace everything between that `<ul ...>` tag and its matching `</ul>` (all four hardcoded `<li>` course blocks) with this repeater:

```aspx
            <asp:Repeater ID="coursesRepeater" runat="server">
                <HeaderTemplate><ul class="grid gap-3 sm:grid-cols-2"></HeaderTemplate>
                <ItemTemplate>
                    <li class="group rounded-xl border border-slate-200 p-4 hover:border-slate-300 hover:shadow-sm transition-all cursor-pointer">
                        <div class="flex items-center justify-between">
                            <div class="flex h-9 w-9 items-center justify-center rounded-lg" style="background-color:#e0162b15;color:#e0162b">
                                <i data-lucide="book-open" class="h-4 w-4"></i>
                            </div>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode(Eval("CourseCode").ToString()) %></span>
                        </div>
                        <p class="mt-3 text-slate-900 line-clamp-1" style="font-size:14px;font-weight:600"><%# Server.HtmlEncode(Eval("CourseName").ToString()) %></p>
                        <p class="mt-0.5 text-slate-500" style="font-size:12px"><%# Server.HtmlEncode(Eval("LecturerName").ToString()) %></p>
                    </li>
                </ItemTemplate>
                <FooterTemplate></ul></FooterTemplate>
            </asp:Repeater>
```

Note: the opening `<ul ...>` and closing `</ul>` now live inside the repeater's `HeaderTemplate`/`FooterTemplate`, so remove the original standalone `<ul ...>`/`</ul>` tags when replacing.

- [ ] **Step 6: Build**

Run: `msbuild src.csproj /t:Build /p:Configuration=Debug /nologo`
Expected: `Build succeeded.` `0 Error(s)`.

- [ ] **Step 7: Run the app and verify against the seed data**

Launch the site (Visual Studio F5 / IIS Express) and sign in as the seeded student `p26017888` (`user_id = 1`). On the dashboard, confirm the stat cards and course list show:
- **Current GPA:** `3.53`
- **Attendance:** `67%`
- **Credits Earned:** `7`
- **My Courses:** two cards — `CS101 Programming Fundamentals — Dr. Sarah Tan` and `CS201 Database Systems — Dr. Sarah Tan`.

(If a student with no published grades / no attendance / no enrolments logs in, GPA and Attendance show `—`, Credits shows `0`, and My Courses is empty — no errors.)

- [ ] **Step 8: Commit**

```powershell
git add shared/dashboard.aspx shared/dashboard.aspx.cs
git commit -m "feat(dashboard): bind GPA, attendance, credits, and courses to StudentService"
```

---

## Self-review notes

- **Spec coverage:** CGPA (Task 1), credits earned (Task 1), attendance rate (Task 2), all-time courses with lecturer + semester (Task 3), Student aggregation (Task 4), dashboard binding (Task 5). All four spec metrics map to tasks.
- **Type consistency:** `GradeSummary { Cgpa, CreditsEarned }`, `EnrolledCourse { OfferingId, CourseCode, CourseName, CreditHours, LecturerName, SemesterName, Status }`, and the `Student` members (`Cgpa`, `CreditsEarned`, `AttendanceRate`, `Courses`) are used identically in Tasks 1–5. `AttendanceRate` is the 0..1 fraction throughout; the percent conversion happens only in `AttendanceDisplay`.
- **Edge cases:** divide-by-zero (no credits / no attendance) returns `null`; multi-lecturer offerings de-duplicated via `OUTER APPLY TOP 1`; missing lecturer → empty string.
