# Account Profile DB Binding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render the logged-in student's real profile in the `account.aspx` Profile card from the database, and add `phone` + `mailing_address` columns to the USERS table to back two of those fields.

**Architecture:** Reuse the existing read-only `StudentService.GetByUserId` (the same loader the dashboard uses). Extend its `Student` model and profile query with phone, mailing address, and intake date. `account.aspx.cs` mirrors `dashboard.aspx.cs`: a session guard plus `protected` display properties consumed by `<%= %>` bindings in the markup. Only the Profile card changes; the Password, Preferences, and Active Sessions cards and the (client-only) Save button are untouched.

**Tech Stack:** ASP.NET WebForms (C#, .NET Framework), SQL Server LocalDB, MSBuild.

**Verification note:** This project has no unit-test framework (confirmed in the spec and the build/DB memory). The TDD "write failing test" step is replaced with **build + SQL check + manual browser verification**, which is the established convention here.

**Reference commands (PowerShell — Git Bash mangles MSBuild switches):**

- **Build:**
  `& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal`
  (run from `5026CMD Software Engineer/src/src`)
- **SQL check:**
  `& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "<query>"`

**Expected values for the primary test login (username `p26017888`, user_id 1, student_id 1):**
Full name "Ong Zhi Bo" · Initials "OZ" · Student ID "p26017888" · Email "p26017888@student.newinti.edu.my" · Major "Bachelor of Computer Science" · Status "ACTIVE" · Intake "Aug 2025" (intake semester 2025-S3, start 2025-08-04) · Standing "Year 1 · Trimester 3" (current_semester_no = 3).

---

## File Structure

- `db/user_contact_info.sql` — **new** idempotent migration: adds `phone` + `mailing_address` to USERS and backfills sample values.
- `services/StudentService.cs` — **modify**: 3 new `Student` properties, extend `SelectProfile` query + join, map new fields in `MapStudent`.
- `shared/account.aspx.cs` — **modify**: `Page_Load` session guard + load student; `protected` display properties.
- `shared/account.aspx` — **modify**: replace hard-coded Profile-card strings with `<%= %>` bindings.

---

## Task 1: Database migration — add phone + mailing_address to USERS

**Files:**
- Create: `db/user_contact_info.sql`

- [ ] **Step 1: Create the migration script**

Create `db/user_contact_info.sql` with exactly this content:

```sql
/******************************************************************************
 USERS contact info: phone + mailing_address columns.
 Idempotent — safe to run more than once against the live DB.

 Fresh rebuild order: full schema dump (student_information_management_system.sql)
 -> student_intake_semester.sql -> THIS script -> seed_data.sql.
 (These columns are not folded into the dump.)
******************************************************************************/
USE [StudentInformationManagementSystem];
GO

/* 1. Add columns, nullable (not every user is a student) */
IF COL_LENGTH('dbo.USERS', 'phone') IS NULL
    ALTER TABLE dbo.USERS ADD phone VARCHAR(20) NULL;
GO

IF COL_LENGTH('dbo.USERS', 'mailing_address') IS NULL
    ALTER TABLE dbo.USERS ADD mailing_address VARCHAR(255) NULL;
GO

/* 2. Backfill sample values for existing student users (only rows still NULL).
      user_id 1 = Ong Zhi Bo, 4 = Lee Wei Ming, 5 = Nurul Huda, 6 = Raj Kumar. */
UPDATE dbo.USERS SET phone = N'+60 12-345 6789',
       mailing_address = N'INTI International College Penang, Bayan Lepas, Penang'
WHERE user_id = 1 AND phone IS NULL;

UPDATE dbo.USERS SET phone = N'+60 16-222 1188',
       mailing_address = N'12 Jalan Sungai Pinang, George Town, Penang'
WHERE user_id = 4 AND phone IS NULL;

UPDATE dbo.USERS SET phone = N'+60 13-987 6543',
       mailing_address = N'48 Lorong Bayan Indah, Bayan Lepas, Penang'
WHERE user_id = 5 AND phone IS NULL;

UPDATE dbo.USERS SET phone = N'+60 19-555 7321',
       mailing_address = N'7 Persiaran Gurney, George Town, Penang'
WHERE user_id = 6 AND phone IS NULL;
GO
```

- [ ] **Step 2: Run the migration against the live LocalDB**

Run (PowerShell):
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -i "db\user_contact_info.sql"
```
Expected: completes with no errors (Rows affected messages are fine).

- [ ] **Step 3: Verify columns exist and are backfilled**

Run:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT user_id, phone, mailing_address FROM USERS WHERE user_id = 1"
```
Expected: one row — user_id `1`, phone `+60 12-345 6789`, mailing_address `INTI International College Penang, Bayan Lepas, Penang`.

- [ ] **Step 4: Confirm re-running is safe (idempotency)**

Re-run the Step 2 command once more.
Expected: no errors, no `Invalid column` / `column already exists` failures (the `COL_LENGTH` guards skip the ALTERs; the `phone IS NULL` guards skip the UPDATEs).

- [ ] **Step 5: Commit**

```
git add "db/user_contact_info.sql"
git commit -m "feat(db): add phone and mailing_address to USERS"
```

---

## Task 2: Extend Student model + StudentService query

**Files:**
- Modify: `services/StudentService.cs`

- [ ] **Step 1: Add three properties to the `Student` class**

In `services/StudentService.cs`, add these properties to the `Student` class (place them after the `ProgrammeCode` property, before `CurrentSemesterNo`):

```csharp
        public string Phone { get; set; }
        public string MailingAddress { get; set; }

        /// <summary>Start date of the student's intake semester; null when unknown.</summary>
        public DateTime? IntakeDate { get; set; }
```

- [ ] **Step 2: Extend the `SelectProfile` query**

Replace the entire `SelectProfile` constant with:

```csharp
        private const string SelectProfile =
            "SELECT s.student_id, s.user_id, s.programme_id, s.full_name, " +
            "s.date_of_birth, s.status, u.email, u.username, " +
            "u.phone, u.mailing_address, " +
            "p.programme_name, p.programme_code, " +
            "ISNULL(vs.current_semester_no, 1) AS current_semester_no, " +
            "si.start_date AS intake_date " +
            "FROM STUDENTS s " +
            "JOIN USERS u ON s.user_id = u.user_id " +
            "JOIN PROGRAMMES p ON s.programme_id = p.programme_id " +
            "LEFT JOIN vw_student_semester vs ON vs.student_id = s.student_id " +
            "LEFT JOIN SEMESTERS si ON si.semester_id = s.intake_semester_id ";
```

- [ ] **Step 3: Map the new fields in `MapStudent`**

In `MapStudent`, add these three assignments to the `new Student { ... }` initializer (place them right after the `ProgrammeCode = ...` line):

```csharp
                Phone = reader["phone"] == DBNull.Value ? "" : reader["phone"].ToString(),
                MailingAddress = reader["mailing_address"] == DBNull.Value ? "" : reader["mailing_address"].ToString(),
                IntakeDate = reader["intake_date"] == DBNull.Value
                    ? (DateTime?)null
                    : (DateTime)reader["intake_date"],
```

- [ ] **Step 4: Build**

Run:
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 5: Verify the query returns the new columns**

Run the query the service now uses, for user 1:
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT u.phone, u.mailing_address, si.start_date AS intake_date FROM STUDENTS s JOIN USERS u ON s.user_id=u.user_id LEFT JOIN SEMESTERS si ON si.semester_id=s.intake_semester_id WHERE s.user_id=1"
```
Expected: phone `+60 12-345 6789`, mailing_address `INTI International College Penang...`, intake_date `2025-08-04`.

- [ ] **Step 6: Commit**

```
git add "services/StudentService.cs"
git commit -m "feat(services): load phone, mailing address, intake date in StudentService"
```

---

## Task 3: account.aspx.cs — load student and expose display properties

**Files:**
- Modify: `shared/account.aspx.cs`

- [ ] **Step 1: Replace the file contents**

Replace the entire contents of `shared/account.aspx.cs` with:

```csharp
using System;
using System.Globalization;
using System.Web;
using System.Web.UI;
using src.services;

namespace src.shared
{
    public partial class account : System.Web.UI.Page
    {
        private Student _student;

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

            _student = StudentService.GetByUserId((int)Session["user_id"]);
            if (_student == null)
            {
                // Session belongs to a non-student (e.g. admin/lecturer) — no profile to show.
                Response.Redirect("~/shared/login.aspx");
                return;
            }
        }

        protected string FullName
        {
            get { return _student != null ? _student.FullName : ""; }
        }

        // First letters of the first two words of the name, e.g. "Ong Zhi Bo" -> "OZ".
        protected string Initials
        {
            get
            {
                if (_student == null || string.IsNullOrEmpty(_student.FullName)) return "";
                var parts = _student.FullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                string initials = parts[0].Substring(0, 1);
                if (parts.Length > 1) initials += parts[1].Substring(0, 1);
                return initials.ToUpperInvariant();
            }
        }

        protected string ProgrammeName
        {
            get { return _student != null ? _student.ProgrammeName : ""; }
        }

        protected string StudentIdLabel
        {
            get { return _student != null ? _student.Username : ""; }
        }

        protected string Email
        {
            get { return _student != null ? _student.Email : ""; }
        }

        protected string StatusBadge
        {
            get
            {
                return _student != null && !string.IsNullOrEmpty(_student.Status)
                    ? _student.Status.ToUpperInvariant()
                    : "";
            }
        }

        // Intake month/year from the intake semester start date, e.g. "Aug 2025".
        protected string IntakeLabel
        {
            get
            {
                return _student != null && _student.IntakeDate.HasValue
                    ? _student.IntakeDate.Value.ToString("MMM yyyy", CultureInfo.InvariantCulture)
                    : "—";
            }
        }

        // "Year X · Trimester Y" from the 1-based current semester number.
        // 3 trimesters per academic year: year = ceil(n/3), trimester = ((n-1) mod 3) + 1.
        // "&middot;" is written raw because <%= %> does not HTML-encode.
        protected string StandingLabel
        {
            get
            {
                if (_student == null) return "";
                int n = _student.CurrentSemesterNo;
                int year = (n + 2) / 3;
                int trimester = ((n - 1) % 3) + 1;
                return "Year " + year + " &middot; Trimester " + trimester;
            }
        }

        protected string Phone
        {
            get { return _student != null ? _student.Phone : ""; }
        }

        protected string MailingAddress
        {
            get { return _student != null ? _student.MailingAddress : ""; }
        }
    }
}
```

- [ ] **Step 2: Build**

Run:
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 3: Commit**

```
git add "shared/account.aspx.cs"
git commit -m "feat(account): load student profile and expose display properties"
```

---

## Task 4: account.aspx — bind Profile card to the display properties

**Files:**
- Modify: `shared/account.aspx`

Replace each hard-coded value below with its binding. Only the Profile `<section>` changes; leave the password/preferences/sessions sections and the Cancel/Save buttons exactly as they are.

- [ ] **Step 1: Bind the avatar initials**

Find (around line 22):
```html
<div class="flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-[#e0162b] to-[#a01020] text-white" style="font-size:26px;font-weight:700">AY</div>
```
Replace `AY` with `<%= Initials %>` so the inner text reads `><%= Initials %></div>`.

- [ ] **Step 2: Bind the name and programme subtitle**

Find (around lines 28-29):
```html
<p class="text-slate-900 truncate" style="font-size:18px;font-weight:700;letter-spacing:-0.01em">Aisyah Yusoff</p>
<p class="text-slate-500" style="font-size:13px">BSc (Hons) Computer Science</p>
```
Replace `Aisyah Yusoff` with `<%= FullName %>` and `BSc (Hons) Computer Science` with `<%= ProgrammeName %>`.

- [ ] **Step 3: Bind the status badge**

Find (around line 31):
```html
<span class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span> ACTIVE
```
Replace `ACTIVE` with `<%= StatusBadge %>`.

- [ ] **Step 4: Bind the FULL NAME read-only field**

Find (around line 44):
```html
<span class="text-slate-700 truncate" style="font-size:13px">Aisyah Yusoff</span>
```
Replace `Aisyah Yusoff` with `<%= FullName %>`.

- [ ] **Step 5: Bind the STUDENT ID field**

Find (around line 54):
```html
<span class="text-slate-700 truncate" style="font-size:13px">I22023456</span>
```
Replace `I22023456` with `<%= StudentIdLabel %>`.

- [ ] **Step 6: Bind the EMAIL field**

Find (around line 64):
```html
<span class="text-slate-700 truncate" style="font-size:13px">aisyah.yusoff@student.newinti.edu.my</span>
```
Replace `aisyah.yusoff@student.newinti.edu.my` with `<%= Email %>`.

- [ ] **Step 7: Bind the MAJOR field**

Find (around line 74):
```html
<span class="text-slate-700 truncate" style="font-size:13px">BSc (Hons) Computer Science</span>
```
Replace `BSc (Hons) Computer Science` with `<%= ProgrammeName %>`.

- [ ] **Step 8: Bind the INTAKE field**

Find (around line 84):
```html
<span class="text-slate-700 truncate" style="font-size:13px">May 2024</span>
```
Replace `May 2024` with `<%= IntakeLabel %>`.

- [ ] **Step 9: Bind the CURRENT STANDING field**

Find (around line 94):
```html
<span class="text-slate-700 truncate" style="font-size:13px">Year 2 &middot; Trimester 2</span>
```
Replace `Year 2 &middot; Trimester 2` with `<%= StandingLabel %>`.

- [ ] **Step 10: Bind the PHONE input value**

Find (around line 104):
```html
<input id="phone" type="text" value="+60 12-345 6789" class="h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-900 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px" />
```
Replace `value="+60 12-345 6789"` with `value="<%= Phone %>"`.

- [ ] **Step 11: Bind the MAILING ADDRESS input value**

Find (around line 114):
```html
<input id="address" type="text" value="INTI International College Penang, Bayan Lepas" class="h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-900 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px" />
```
Replace `value="INTI International College Penang, Bayan Lepas"` with `value="<%= MailingAddress %>"`.

- [ ] **Step 12: Build**

Run:
```
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" src.csproj /t:Build /p:Configuration=Debug /nologo /v:minimal
```
Expected: `Build succeeded`, 0 errors.

- [ ] **Step 13: Manual browser verification**

Run the site, log in as `p26017888` (the seeded password hash in the dump), and open `shared/account.aspx`. Confirm the Profile card shows:
- Avatar `OZ`, name `Ong Zhi Bo`, subtitle `Bachelor of Computer Science`, badge `ACTIVE`.
- FULL NAME `Ong Zhi Bo`, STUDENT ID `p26017888`, EMAIL `p26017888@student.newinti.edu.my`, MAJOR `Bachelor of Computer Science`.
- INTAKE `Aug 2025`, CURRENT STANDING `Year 1 · Trimester 3`.
- PHONE `+60 12-345 6789`, MAILING ADDRESS `INTI International College Penang, Bayan Lepas, Penang`.
- The Password, Preferences, and Active Sessions cards look unchanged.

- [ ] **Step 14: Commit**

```
git add "shared/account.aspx"
git commit -m "feat(account): bind profile card fields to database"
```

---

## Self-Review

- **Spec coverage:** DB columns + migration (Task 1) ✓; model/query/mapping incl. intake join (Task 2) ✓; code-behind session guard + all display properties (Task 3) ✓; markup bindings for every Profile field incl. initials, status, intake, standing, phone, address (Task 4) ✓; password/preferences/sessions left untouched ✓; no write-back / Save button unchanged ✓.
- **Type consistency:** `Student.Phone`/`MailingAddress` (string) and `IntakeDate` (`DateTime?`) defined in Task 2 are read in Task 3; property names (`Initials`, `StudentIdLabel`, `StatusBadge`, `IntakeLabel`, `StandingLabel`, `Phone`, `MailingAddress`, `FullName`, `ProgrammeName`, `Email`) defined in Task 3 match the `<%= %>` bindings in Task 4.
- **Edge cases:** null phone/address → `""` (Task 2 mapping + Task 3 getters); null intake → `"—"`; single-word name → first letter only; non-student session → redirect to login.
- **Placeholders:** none — every step has concrete code/commands.
