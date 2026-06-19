# Student Information Management System

A web-based student information portal for INTI International College, built with
**ASP.NET Web Forms** and **SQL Server**. The system serves three roles —
**Student**, **Lecturer**, and **Admin** — each with its own dashboard and a set of
role-gated pages. Access is enforced both at the page level and at the data level, so
every query only returns rows the signed-in user is allowed to see.

---

## Features

### Student
- **Dashboard** — today's classes, CGPA, attendance, pending tasks, and announcements
- **Courses & Course Detail** — enrolled courses with materials, assignments, and grades
- **Enrollment** — view current enrolments and request add/drop
- **Grades** — published grades and credit-weighted CGPA
- **Timetable** — weekly class schedule
- **Attendance** — attendance records and rate per course
- **Account** — profile details
- **Notifications** — announcements targeted to the student

### Lecturer
- **Dashboard** — teaching overview
- **My Courses** & **Course Dashboard** — per-offering overview and statistics
- **People** — student roster for a course offering
- **Materials** — upload and manage course materials
- **Grades** — record and publish grades
- **Attendance / Take Attendance** — create sessions and mark the roster
- **At-Risk Students** — students flagged for low performance or attendance
- **Announcements** — post announcements to a course
- **Account** — profile details

### Admin
- **Dashboard** — administrative overview
- **User Management** — manage user accounts
- **Programmes & Courses** — manage programmes, courses, and offerings
- **Academic Calendar** — semester events (registration, exams, breaks, add/drop)
- **Academic Performance** — cohort performance views
- **Add/Drop Requests** — review and act on student enrolment-change requests
- **Course Attendance** & **Course Pass/Fail** — cohort-level reporting
- **Report Generator** — generate reports with PDF and Excel export
- **Student Detail** — drill into an individual student's record

### Common
- **Sign-in** with optional "remember me"
- **Email notifications** sent over SMTP

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | ASP.NET Web Forms (`.aspx` pages, `.master` layouts, `.ascx` controls) |
| Language / Runtime | C# on .NET Framework 4.7.2 |
| Database | SQL Server (LocalDB) |
| Data access | ADO.NET (`System.Data.SqlClient`) with parameterized queries |
| Frontend | Tailwind CSS (Play CDN) + Lucide icons (CDN), vanilla JavaScript |
| Email | `System.Net.Mail` over SMTP (Gmail by default) |
| Authentication | Session-based login, SHA-256 password hashing, remember-me cookies |
| Package manager | NuGet (`Microsoft.CodeDom.Providers.DotNetCompilerPlatform`) |

There is **no Node/npm build step** — Tailwind and icons are loaded from CDNs at runtime,
so the UI needs an internet connection to render.

---

## Architecture

The source lives under `src/` and is organized by concern and role:

| Folder | Responsibility |
|--------|----------------|
| `security/` | `SecurePage` base (enforces login + no-cache); role-gated `StudentPage` / `LecturerPage` / `AdminPage`; `RoleRoutes` maps each role to its landing page |
| `services/` | Business logic and data access. A `UserContext` carries the signed-in user's id and role; `ServiceAccess` provides the row-level authorization checks (`CanView…` / `CanManage…`) and a SQL scope predicate so queries are filtered to what the user may see. Domain logic is split into `services/student/`, `services/lecturer/`, and `services/email/`, plus report generation (`ReportService`). |
| `db/` | `db.cs` opens a connection from the `SimsDb` connection string; the `.sql` file is the full schema + seed data |
| `login/` | Sign-in page and login layout |
| `student/` `lecturer/` `admin/` | Role-specific pages, each with its own master layout |
| `controls/` | Per-role sidebar and topbar user controls |
| `js/` | Client-side scripts organized by role and feature |
| `uploads/` | Uploaded course materials |

**Authentication & authorization.** On sign-in, the submitted password is SHA-256 hashed
and compared against `USERS.password_hash`; on success the user's id, role, and username
are stored in session. Every authenticated page inherits from `SecurePage`, which redirects
unauthenticated visitors to the login page, and role pages additionally redirect users whose
role doesn't match. Beyond page gating, the service layer re-checks authorization on each
data operation using `UserContext` + `ServiceAccess`, so a student can only ever read their
own data and a lecturer only the offerings they teach. Opting into "remember me" issues a
token cookie (managed by `CookieService`) for auto-login until it expires.

---

## Prerequisites

- **Visual Studio 2022** (v17) with the *ASP.NET and web development* workload
- **.NET Framework 4.7.2** developer pack
- **SQL Server LocalDB** (installed with Visual Studio)

---

## Setup & Run

1. **Create the database.** Run `src/db/student information management system.sql` against
   your LocalDB instance (e.g. in SQL Server Management Studio, or with
   `sqlcmd -S "(localdb)\MSSQLLocalDB" -i "..."`). The script creates the
   `StudentInformationManagementSystem` database, all tables, and the seed data.

   The application reads the `SimsDb` connection string from `src/web.config`:

   ```
   Server=(localdb)\MSSQLLocalDB;Database=StudentInformationManagementSystem;Integrated Security=True;MultipleActiveResultSets=True;
   ```

   If your SQL Server instance differs, update that connection string.

2. **Create `src/smtp.config`.** Copy `src/smtp.config.example` to `src/smtp.config`.
   This file is required: `web.config` references it via `configSource`, so the app will not
   start without it. Leave the credentials blank if you don't need outgoing email, or fill in
   a sender account to enable email notifications.

3. **Open the solution.** Open `src.sln` in Visual Studio. NuGet packages are restored
   automatically on build.

4. **Build and run.** Build the solution and start it with IIS Express. The app launches at
   `https://localhost:44317/` and lands on the sign-in page (`login/login.aspx`).

---

## Default Test Accounts

The database seed script (`src/db/student information management system.sql`) inserts the
accounts below. **Every account uses the password `aaaaaaaa`, and you log in with the email.**

### Admin

| Name  | Login email            | Username |
|-------|------------------------|----------|
| admin | `admin@newinti.edu.my` | admin    |

### Lecturers

| Name             | Login email                         | Username  | Department             |
|------------------|-------------------------------------|-----------|------------------------|
| Dr. Sarah Tan    | `lecturer@lecturer.newinti.edu.my`  | lecturer  | Computer Science       |
| Dr. James Lim    | `lecturer2@lecturer.newinti.edu.my` | lecturer2 | Business               |
| Ms. Aisha Rahman | `lecturer3@lecturer.newinti.edu.my` | lecturer3 | Information Technology  |

### Students

| Name         | Login email                        | Username  | Programme                            | Date of birth | Status | Intake    | Phone             | Mailing address                                              |
|--------------|------------------------------------|-----------|--------------------------------------|---------------|--------|-----------|-------------------|--------------------------------------------------------------|
| Ong Zhi Bo   | `p26017888@student.newinti.edu.my` | p26017888 | Bachelor of Computer Science (BCS)   | 2003-04-15    | ACTIVE | 2025-S3   | +60 12-345 6789   | INTI International College Penang, Bayan Lepas, Penang       |
| Lee Wei Ming | `p26017001@student.newinti.edu.my` | p26017001 | Bachelor of Computer Science (BCS)   | 2004-07-22    | ACTIVE | 2026-S1   | +60 16-222 1188   | 12 Jalan Sungai Pinang, George Town, Penang                  |
| Nurul Huda   | `p26017002@student.newinti.edu.my` | p26017002 | Bachelor of Business Administration (BBA) | 2003-11-03 | ACTIVE | 2026-S2   | +60 13-987 6543   | 48 Lorong Bayan Indah, Bayan Lepas, Penang                   |
| Raj Kumar    | `p26017003@student.newinti.edu.my` | p26017003 | Diploma in Information Technology (DIT)   | 2005-02-28 | ACTIVE | 2025-S3   | +60 19-555 7321   | 7 Persiaran Gurney, George Town, Penang                      |

---

## Project Structure

```
Student-Information-Management-System/
├── src.sln                     # Visual Studio solution
├── README.md
└── src/
    ├── web.config              # connection string, SMTP configSource, default document
    ├── Global.asax(.cs)        # application entry point
    ├── packages.config         # NuGet packages
    ├── src.csproj
    ├── site.master             # root master page (loads Tailwind + Lucide)
    ├── smtp.config.example     # template for src/smtp.config (gitignored)
    ├── security/               # base pages, role gates, route map
    ├── services/               # business logic, authorization, data access
    │   ├── student/            # student-side readers and models
    │   ├── lecturer/           # lecturer-side readers and models
    │   └── email/              # email composition and sending
    ├── db/                     # db.cs + SQL schema and seed script
    ├── login/                  # sign-in page and layout
    ├── student/                # student pages + layout
    ├── lecturer/               # lecturer pages + layout
    ├── admin/                  # admin pages + layout
    ├── controls/               # sidebar / topbar user controls
    ├── js/                     # client-side scripts, by role/feature
    ├── img/                    # static images
    └── uploads/                # uploaded course materials
```

---

## Notes & Known Limitations

- Authorization is enforced per operation in the service layer (`ServiceAccess`), in
  addition to page-level role gating — a user can only read or modify data they own or
  are responsible for.
- The project has **no automated test suite**.
- Styling depends on the **Tailwind and Lucide CDNs**, so the UI requires an internet
  connection to render correctly.
- `src/smtp.config` (and any local credential files) are gitignored; use the provided
  `.example` template to create your own.
