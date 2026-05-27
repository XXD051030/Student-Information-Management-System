# Notification Unread Badges Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add database-backed unread notification badges to the sidebar and topbar, with hidden badges at `0`, exact numbers from `1` to `9`, and `9+` for counts above `9`.

**Architecture:** Store per-user read receipts in a new `NOTIFICATION_READS` table keyed by `user_id` and `announcement_id`. `AnnouncementService` becomes the single source for visible notifications, unread counts, and read/write operations; the sidebar, topbar, and notifications page render from that service. The notifications page updates read state through ASP.NET WebMethods so badges stay correct after navigation, refresh, logout/login, and across devices.

**Tech Stack:** ASP.NET Web Forms, .NET Framework 4.7.2, C#, SQL Server LocalDB, raw `System.Data.SqlClient`, Tailwind Play CDN classes, vanilla JavaScript.

---

## Confirmed Requirements

- The sidebar and topbar both keep their notification icons.
- When unread notifications exist, both areas show an unread alert badge.
- Sidebar badge appears on the right side of the `Notifications` navigation row and uses this style shape:

```html
<span class="rounded-md px-1.5 bg-slate-100 text-slate-600" style="font-size:11px;font-weight:600">6</span>
```

- Topbar badge is a red circular badge on the bell icon and contains the unread count.
- Badge display rule is shared:
  - unread count `0`: hide the badge
  - unread count `1` to `9`: show the exact number
  - unread count greater than `9`: show `9+`
- Read state must be database-backed, not only client-side session state.

---

## Current Project Context

- `controls/sidebar.ascx` has a `Notifications` nav link with a bell icon but no badge.
- `controls/sidebar.ascx.cs` is currently empty.
- `controls/topbar.ascx` has a notification bell with a hardcoded badge value `3`.
- `controls/topbar.ascx.cs` already loads the logged-in student through `StudentService.GetByUserId`.
- `shared/notifications.aspx.cs` currently loads `AnnouncementService.GetAllForStudent(userId)` and treats every returned notification as unread.
- `js/notifications/notifications.js` currently tracks read/unread state only in the browser by changing `data-read`.
- The live database has `ANNOUNCEMENTS` and `ANNOUNCEMENT_TARGETS`, but no read-state table or column.
- `doc/project-context.md` must be updated whenever a page, control, service, script, SQL script, project file, route, or data flow changes.

---

## File Structure

- Create `db/notification_reads.sql`: idempotent schema patch for per-user notification read receipts.
- Modify `src.csproj`: include `db\notification_reads.sql` as content.
- Modify `services/AnnouncementService.cs`: add `StudentNotification.IsRead`, query read state, count unread notifications, and mark read/unread/all-read.
- Modify `controls/sidebar.ascx.cs`: load unread notification count for the logged-in user and expose formatted badge text.
- Modify `controls/sidebar.ascx`: render the sidebar count badge beside the `Notifications` label.
- Modify `controls/topbar.ascx.cs`: load unread notification count and expose formatted badge text.
- Modify `controls/topbar.ascx`: replace the hardcoded `3` with the server-backed badge.
- Modify `shared/notifications.aspx.cs`: bind `data-read` from the database and expose WebMethods for read/unread updates.
- Modify `shared/notifications.aspx`: render `data-read` from `StudentNotification.IsRead`.
- Modify `js/notifications/notifications.js`: call WebMethods when notifications are read/unread and update sidebar/topbar badges from the returned count.
- Modify `doc/project-context.md`: document the read-receipt table, service methods, badge behavior, and script flow.

---

### Task 1: Add The Read-Receipt Database Patch

**Files:**
- Create: `db/notification_reads.sql`
- Modify: `src.csproj`

- [ ] **Step 1: Run the baseline schema check**

Run:

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT OBJECT_ID('dbo.NOTIFICATION_READS') AS notification_reads_object_id"
```

Expected before implementation: the result column `notification_reads_object_id` is `NULL`.

- [ ] **Step 2: Create `db/notification_reads.sql`**

Create this file:

```sql
USE [StudentInformationManagementSystem]
GO

IF OBJECT_ID('dbo.NOTIFICATION_READS', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.NOTIFICATION_READS
    (
        user_id INT NOT NULL,
        announcement_id INT NOT NULL,
        read_at DATETIME2 NOT NULL CONSTRAINT DF_NOTIFICATION_READS_read_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_NOTIFICATION_READS PRIMARY KEY (user_id, announcement_id),
        CONSTRAINT FK_NOTIFICATION_READS_USERS FOREIGN KEY (user_id)
            REFERENCES dbo.USERS(user_id),
        CONSTRAINT FK_NOTIFICATION_READS_ANNOUNCEMENTS FOREIGN KEY (announcement_id)
            REFERENCES dbo.ANNOUNCEMENTS(announcement_id)
    );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_NOTIFICATION_READS_announcement_id'
      AND object_id = OBJECT_ID('dbo.NOTIFICATION_READS')
)
BEGIN
    CREATE INDEX IX_NOTIFICATION_READS_announcement_id
        ON dbo.NOTIFICATION_READS(announcement_id);
END
GO
```

- [ ] **Step 3: Include the SQL patch in `src.csproj`**

In the first `<ItemGroup>` that contains SQL content, add:

```xml
    <Content Include="db\notification_reads.sql" />
```

Place it near the other `db\*.sql` entries:

```xml
    <Content Include="db\enrollment.sql" />
    <Content Include="db\notification_reads.sql" />
    <Content Include="db\user1_demo_data.sql" />
```

- [ ] **Step 4: Apply the schema patch locally**

Run:

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -i "db\notification_reads.sql"
```

Expected: command completes without SQL errors.

- [ ] **Step 5: Verify the table exists**

Run:

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT c.COLUMN_NAME, c.DATA_TYPE, c.IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS c WHERE c.TABLE_NAME = 'NOTIFICATION_READS' ORDER BY c.ORDINAL_POSITION"
```

Expected: rows for `user_id`, `announcement_id`, and `read_at`.

- [ ] **Step 6: Commit**

Run:

```powershell
git status --short
git add db/notification_reads.sql src.csproj
git commit -m "feat(notifications): add read receipt table"
```

Expected: commit includes only `db/notification_reads.sql` and `src.csproj`.

---

### Task 2: Add Notification Read State To `AnnouncementService`

**Files:**
- Modify: `services/AnnouncementService.cs`

- [ ] **Step 1: Add the read-state property to `StudentNotification`**

In `services/AnnouncementService.cs`, add this property inside `StudentNotification`:

```csharp
public bool IsRead { get; set; }
```

The class should include:

```csharp
public class StudentNotification
{
    public int AnnouncementId { get; set; }
    public string Title { get; set; }
    public string Content { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsPinned { get; set; }
    public bool HasAttachment { get; set; }
    public string CourseCode { get; set; }
    public string CourseName { get; set; }
    public string AuthorName { get; set; }
    public string AuthorRole { get; set; }
    public bool IsRead { get; set; }
}
```

- [ ] **Step 2: Update `SelectAllForStudent` to return read state**

Replace the `SelectAllForStudent` constant with:

```csharp
private const string SelectAllForStudent =
    "SELECT an.announcement_id, an.title, " +
    "CAST(an.content AS varchar(max)) AS content, an.created_at, an.is_pinned, " +
    "CASE WHEN an.file_url IS NULL THEN 0 ELSE 1 END AS has_attachment, " +
    "ISNULL(l.full_name, u.username) AS author_name, u.role, " +
    "ca.course_code, ca.course_name, " +
    "CASE WHEN nr.announcement_id IS NULL THEN 0 ELSE 1 END AS is_read " +
    "FROM ANNOUNCEMENTS an " +
    "JOIN USERS u ON u.user_id = an.created_by " +
    "LEFT JOIN LECTURERS l ON l.user_id = u.user_id " +
    "CROSS APPLY ( " +
    "  SELECT TOP 1 c.course_code, c.course_name " +
    "  FROM ANNOUNCEMENT_TARGETS at " +
    "  JOIN COURSE_OFFERINGS o ON at.offering_id = o.offering_id " +
    "  JOIN COURSES c ON o.course_id = c.course_id " +
    "  JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
    "  JOIN STUDENTS s ON e.student_id = s.student_id " +
    "  WHERE at.announcement_id = an.announcement_id " +
    "    AND s.user_id = @userId AND e.status = 'ENROLLED' " +
    "  ORDER BY c.course_code " +
    ") ca " +
    "LEFT JOIN NOTIFICATION_READS nr ON nr.announcement_id = an.announcement_id AND nr.user_id = @userId " +
    "ORDER BY an.is_pinned DESC, an.created_at DESC";
```

- [ ] **Step 3: Map `is_read` in `GetAllForStudent`**

Inside the `new StudentNotification` initializer, add:

```csharp
IsRead = (int)reader["is_read"] == 1
```

The initializer should end like this:

```csharp
AuthorName = reader["author_name"].ToString(),
AuthorRole = reader["role"].ToString(),
CourseCode = reader["course_code"].ToString(),
CourseName = reader["course_name"].ToString(),
IsRead = (int)reader["is_read"] == 1
```

- [ ] **Step 4: Add shared SQL for visible notification IDs**

Inside `AnnouncementService`, below `SelectAllForStudent`, add:

```csharp
private const string VisibleNotificationIdsForStudent =
    "SELECT DISTINCT an.announcement_id " +
    "FROM ANNOUNCEMENTS an " +
    "JOIN ANNOUNCEMENT_TARGETS at ON at.announcement_id = an.announcement_id " +
    "JOIN COURSE_OFFERINGS o ON at.offering_id = o.offering_id " +
    "JOIN ENROLMENTS e ON e.offering_id = o.offering_id " +
    "JOIN STUDENTS s ON e.student_id = s.student_id " +
    "WHERE s.user_id = @userId AND e.status = 'ENROLLED'";
```

- [ ] **Step 5: Add `GetUnreadCountForStudent`**

Below `GetAllForStudent`, add:

```csharp
public static int GetUnreadCountForStudent(int userId)
{
    string sql =
        "SELECT COUNT(*) " +
        "FROM (" + VisibleNotificationIdsForStudent + ") visible " +
        "LEFT JOIN NOTIFICATION_READS nr ON nr.announcement_id = visible.announcement_id AND nr.user_id = @userId " +
        "WHERE nr.announcement_id IS NULL";

    using (var conn = Db.OpenConnection())
    using (var cmd = new SqlCommand(sql, conn))
    {
        cmd.Parameters.AddWithValue("@userId", userId);
        return (int)cmd.ExecuteScalar();
    }
}
```

- [ ] **Step 6: Add `MarkRead`**

Below `GetUnreadCountForStudent`, add:

```csharp
public static void MarkRead(int userId, int announcementId)
{
    string sql =
        "IF EXISTS (" + VisibleNotificationIdsForStudent + " AND an.announcement_id = @announcementId) " +
        "BEGIN " +
        "  IF EXISTS (SELECT 1 FROM NOTIFICATION_READS WHERE user_id = @userId AND announcement_id = @announcementId) " +
        "    UPDATE NOTIFICATION_READS SET read_at = SYSUTCDATETIME() WHERE user_id = @userId AND announcement_id = @announcementId; " +
        "  ELSE " +
        "    INSERT INTO NOTIFICATION_READS (user_id, announcement_id, read_at) VALUES (@userId, @announcementId, SYSUTCDATETIME()); " +
        "END";

    using (var conn = Db.OpenConnection())
    using (var cmd = new SqlCommand(sql, conn))
    {
        cmd.Parameters.AddWithValue("@userId", userId);
        cmd.Parameters.AddWithValue("@announcementId", announcementId);
        cmd.ExecuteNonQuery();
    }
}
```

- [ ] **Step 7: Add `MarkUnread`**

Below `MarkRead`, add:

```csharp
public static void MarkUnread(int userId, int announcementId)
{
    const string sql =
        "DELETE FROM NOTIFICATION_READS " +
        "WHERE user_id = @userId AND announcement_id = @announcementId";

    using (var conn = Db.OpenConnection())
    using (var cmd = new SqlCommand(sql, conn))
    {
        cmd.Parameters.AddWithValue("@userId", userId);
        cmd.Parameters.AddWithValue("@announcementId", announcementId);
        cmd.ExecuteNonQuery();
    }
}
```

- [ ] **Step 8: Add `MarkAllRead`**

Below `MarkUnread`, add:

```csharp
public static void MarkAllRead(int userId)
{
    string sql =
        "INSERT INTO NOTIFICATION_READS (user_id, announcement_id, read_at) " +
        "SELECT @userId, visible.announcement_id, SYSUTCDATETIME() " +
        "FROM (" + VisibleNotificationIdsForStudent + ") visible " +
        "WHERE NOT EXISTS ( " +
        "  SELECT 1 FROM NOTIFICATION_READS nr " +
        "  WHERE nr.user_id = @userId AND nr.announcement_id = visible.announcement_id " +
        ")";

    using (var conn = Db.OpenConnection())
    using (var cmd = new SqlCommand(sql, conn))
    {
        cmd.Parameters.AddWithValue("@userId", userId);
        cmd.ExecuteNonQuery();
    }
}
```

- [ ] **Step 9: Build-check the service**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src\src.csproj" /t:Build /p:Configuration=Debug /v:minimal
```

Expected: build succeeds. If it fails on SQL string syntax, fix the string before continuing.

- [ ] **Step 10: Commit**

Run:

```powershell
git status --short
git add services/AnnouncementService.cs
git commit -m "feat(notifications): track unread state in service"
```

Expected: commit includes only `services/AnnouncementService.cs`.

---

### Task 3: Render Server-Backed Badges In Sidebar And Topbar

**Files:**
- Modify: `controls/sidebar.ascx.cs`
- Modify: `controls/sidebar.ascx`
- Modify: `controls/topbar.ascx.cs`
- Modify: `controls/topbar.ascx`

- [ ] **Step 1: Update `controls/sidebar.ascx.cs`**

Replace the file content with:

```csharp
using System;
using System.Web.UI;
using src.services;

namespace src.controls
{
    public partial class sidebar : UserControl
    {
        private int _unreadNotificationCount;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["user_id"] == null) return;

            _unreadNotificationCount = AnnouncementService.GetUnreadCountForStudent((int)Session["user_id"]);
        }

        protected int UnreadNotificationCount
        {
            get { return _unreadNotificationCount; }
        }

        protected string NotificationBadgeText
        {
            get { return _unreadNotificationCount > 9 ? "9+" : _unreadNotificationCount.ToString(); }
        }

        protected string NotificationBadgeVisibilityClass
        {
            get { return _unreadNotificationCount > 0 ? "" : " hidden"; }
        }
    }
}
```

- [ ] **Step 2: Add the sidebar badge markup**

In `controls/sidebar.ascx`, replace the current `Notifications` link body:

```aspx
                    <i data-lucide="bell" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Notifications</span>
```

with:

```aspx
                    <i data-lucide="bell" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Notifications</span>
                    <span id="sidebar-notif-count"
                          data-notification-count-badge
                          class="rounded-md px-1.5 bg-slate-100 text-slate-600<%= NotificationBadgeVisibilityClass %>"
                          style="font-size:11px;font-weight:600"><%= NotificationBadgeText %></span>
```

- [ ] **Step 3: Update `controls/topbar.ascx.cs`**

Add a private field beside `_student`:

```csharp
private int _unreadNotificationCount;
```

In `Page_Load`, after:

```csharp
_student = StudentService.GetByUserId((int)Session["user_id"]);
```

add:

```csharp
_unreadNotificationCount = AnnouncementService.GetUnreadCountForStudent((int)Session["user_id"]);
```

At the bottom of the class, add:

```csharp
protected int UnreadNotificationCount
{
    get { return _unreadNotificationCount; }
}

protected string NotificationBadgeText
{
    get { return _unreadNotificationCount > 9 ? "9+" : _unreadNotificationCount.ToString(); }
}

protected string NotificationBadgeVisibilityClass
{
    get { return _unreadNotificationCount > 0 ? "" : " hidden"; }
}
```

- [ ] **Step 4: Replace the hardcoded topbar badge**

In `controls/topbar.ascx`, replace:

```aspx
            <span id="topbar-notif-count"
                  class="absolute -right-1 -top-1 inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-[#e0162b] px-1 text-white ring-2 ring-white"
                  style="font-size:10px;font-weight:700">
                3
            </span>
```

with:

```aspx
            <span id="topbar-notif-count"
                  data-notification-count-badge
                  class="absolute -right-1 -top-1 inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-[#e0162b] px-1 text-white ring-2 ring-white<%= NotificationBadgeVisibilityClass %>"
                  style="font-size:10px;font-weight:700"><%= NotificationBadgeText %></span>
```

- [ ] **Step 5: Static-check hardcoded badge removal**

Run:

```powershell
Select-String -Path 'controls\topbar.ascx' -Pattern '>\s*3\s*</span>' -Quiet
```

Expected: no output, or `False`.

- [ ] **Step 6: Build-check the controls**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src\src.csproj" /t:Build /p:Configuration=Debug /v:minimal
```

Expected: build succeeds.

- [ ] **Step 7: Commit**

Run:

```powershell
git status --short
git add controls/sidebar.ascx controls/sidebar.ascx.cs controls/topbar.ascx controls/topbar.ascx.cs
git commit -m "feat(notifications): show unread badges in navigation"
```

Expected: commit includes only the four control files.

---

### Task 4: Bind Database Read State On The Notifications Page

**Files:**
- Modify: `shared/notifications.aspx.cs`
- Modify: `shared/notifications.aspx`

- [ ] **Step 1: Add WebMethod support imports**

At the top of `shared/notifications.aspx.cs`, add:

```csharp
using System.Linq;
using System.Web.Services;
```

The imports should include:

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using src.services;
```

- [ ] **Step 2: Replace the `UnreadCount` property**

Replace:

```csharp
// No read-state column exists in the schema, so every fetched
// notification starts as unread; the client tracks reads per session.
protected int UnreadCount
{
    get { return Notifications.Count; }
}
```

with:

```csharp
protected int UnreadCount
{
    get { return Notifications.Count(n => !n.IsRead); }
}
```

- [ ] **Step 3: Add `ReadFlag` helper**

Below `UnreadCount`, add:

```csharp
protected string ReadFlag(object isRead)
{
    return ((bool)isRead) ? "true" : "false";
}
```

- [ ] **Step 4: Add shared WebMethod response helpers**

Inside the `notification` page class, below `PinnedFlag`, add:

```csharp
private static int CurrentUserIdOrReject()
{
    HttpContext context = HttpContext.Current;
    if (context == null || context.Session == null || context.Session["user_id"] == null)
    {
        if (context != null) context.Response.StatusCode = 401;
        return 0;
    }

    return (int)context.Session["user_id"];
}

private static string BadgeText(int unreadCount)
{
    return unreadCount > 9 ? "9+" : unreadCount.ToString();
}

private static object CountResponse(int userId)
{
    int unreadCount = AnnouncementService.GetUnreadCountForStudent(userId);
    return new
    {
        ok = true,
        unreadCount = unreadCount,
        badgeText = BadgeText(unreadCount)
    };
}
```

- [ ] **Step 5: Add `MarkRead` WebMethod**

Below `CountResponse`, add:

```csharp
[WebMethod(EnableSession = true)]
public static object MarkRead(int announcementId)
{
    int userId = CurrentUserIdOrReject();
    if (userId == 0) return new { ok = false };

    AnnouncementService.MarkRead(userId, announcementId);
    return CountResponse(userId);
}
```

- [ ] **Step 6: Add `MarkUnread` WebMethod**

Below `MarkRead`, add:

```csharp
[WebMethod(EnableSession = true)]
public static object MarkUnread(int announcementId)
{
    int userId = CurrentUserIdOrReject();
    if (userId == 0) return new { ok = false };

    AnnouncementService.MarkUnread(userId, announcementId);
    return CountResponse(userId);
}
```

- [ ] **Step 7: Add `MarkAllRead` WebMethod**

Below `MarkUnread`, add:

```csharp
[WebMethod(EnableSession = true)]
public static object MarkAllRead()
{
    int userId = CurrentUserIdOrReject();
    if (userId == 0) return new { ok = false };

    AnnouncementService.MarkAllRead(userId);
    return CountResponse(userId);
}
```

- [ ] **Step 8: Render database read state in the notification list**

In `shared/notifications.aspx`, replace:

```aspx
                                data-read="false"
```

with:

```aspx
                                data-read="<%# ReadFlag(Eval("IsRead")) %>"
```

- [ ] **Step 9: Build-check the page**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src\src.csproj" /t:Build /p:Configuration=Debug /v:minimal
```

Expected: build succeeds.

- [ ] **Step 10: Commit**

Run:

```powershell
git status --short
git add shared/notifications.aspx shared/notifications.aspx.cs
git commit -m "feat(notifications): persist read actions from inbox"
```

Expected: commit includes only the notifications page files.

---

### Task 5: Persist Read Actions From `notifications.js`

**Files:**
- Modify: `js/notifications/notifications.js`

- [ ] **Step 1: Add badge and fetch helpers**

In `js/notifications/notifications.js`, after:

```javascript
var current = null;
```

add:

```javascript
function badgeText(n) {
    return n > 9 ? '9+' : String(n);
}

function localUnreadCount() {
    var n = 0;
    for (var i = 0; i < items.length; i++) {
        if (items[i].getAttribute('data-read') !== 'true') n++;
    }
    return n;
}

function syncBadges(unreadCount) {
    if (unreadEl) unreadEl.textContent = unreadCount;

    var badges = document.querySelectorAll('[data-notification-count-badge]');
    for (var i = 0; i < badges.length; i++) {
        badges[i].textContent = badgeText(unreadCount);
        if (unreadCount > 0) {
            badges[i].classList.remove('hidden');
        } else {
            badges[i].classList.add('hidden');
        }
    }
}

function postJson(url, payload) {
    return fetch(url, {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify(payload || {})
    }).then(function (response) {
        if (!response.ok) throw new Error('Notification update failed');
        return response.json();
    }).then(function (json) {
        return json.d || json;
    });
}

function applyServerCount(result) {
    if (result && typeof result.unreadCount === 'number') {
        syncBadges(result.unreadCount);
    } else {
        syncBadges(localUnreadCount());
    }
}
```

- [ ] **Step 2: Replace `recount`**

Replace the existing `recount` function with:

```javascript
function recount() {
    syncBadges(localUnreadCount());
}
```

- [ ] **Step 3: Split local styling from server persistence**

Replace the existing `setRead` function:

```javascript
function setRead(item, read) {
    item.setAttribute('data-read', read ? 'true' : 'false');
    item.style.opacity = read ? '0.7' : '';
    paintDot(item);
    recount();
}
```

with:

```javascript
function applyReadState(item, read) {
    item.setAttribute('data-read', read ? 'true' : 'false');
    item.style.opacity = read ? '0.7' : '';
    paintDot(item);
}

function setRead(item, read) {
    var currentRead = item.getAttribute('data-read') === 'true';
    if (currentRead === read) {
        recount();
        return;
    }

    applyReadState(item, read);
    recount();

    var id = parseInt(item.getAttribute('data-id'), 10);
    var endpoint = read ? '/shared/notifications.aspx/MarkRead' : '/shared/notifications.aspx/MarkUnread';

    postJson(endpoint, { announcementId: id }).then(function (result) {
        applyServerCount(result);
    }).catch(function () {
        applyReadState(item, currentRead);
        recount();
    });
}
```

- [ ] **Step 4: Update mark-all-read behavior**

Replace:

```javascript
var markAll = document.getElementById('mark-all-read');
if (markAll) markAll.addEventListener('click', function () {
    items.forEach(function (item) { setRead(item, true); });
});
```

with:

```javascript
var markAll = document.getElementById('mark-all-read');
if (markAll) markAll.addEventListener('click', function () {
    var previous = items.map(function (item) {
        return item.getAttribute('data-read') === 'true';
    });

    items.forEach(function (item) { applyReadState(item, true); });
    syncBadges(0);

    postJson('/shared/notifications.aspx/MarkAllRead', {}).then(function (result) {
        applyServerCount(result);
    }).catch(function () {
        items.forEach(function (item, index) {
            applyReadState(item, previous[index]);
        });
        recount();
    });
});
```

- [ ] **Step 5: Keep existing selection behavior**

Leave this line inside `select(item)`:

```javascript
setRead(item, true);
```

Expected behavior: selecting a notification marks it read in the database and updates both badges.

- [ ] **Step 6: Static-check JavaScript syntax**

Run:

```powershell
node --check js\notifications\notifications.js
```

Expected: no syntax errors.

- [ ] **Step 7: Commit**

Run:

```powershell
git status --short
git add js/notifications/notifications.js
git commit -m "feat(notifications): sync badges after read actions"
```

Expected: commit includes only `js/notifications/notifications.js`.

---

### Task 6: Verify End-To-End Badge Behavior

**Files:**
- Verify: database, sidebar, topbar, notifications page, JavaScript

- [ ] **Step 1: Ensure there are unread notifications for user 1**

Run:

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "DELETE FROM NOTIFICATION_READS WHERE user_id = 1; SELECT COUNT(*) AS unread_count FROM (SELECT DISTINCT an.announcement_id FROM ANNOUNCEMENTS an JOIN ANNOUNCEMENT_TARGETS at ON at.announcement_id = an.announcement_id JOIN COURSE_OFFERINGS o ON at.offering_id = o.offering_id JOIN ENROLMENTS e ON e.offering_id = o.offering_id JOIN STUDENTS s ON e.student_id = s.student_id WHERE s.user_id = 1 AND e.status = 'ENROLLED') visible"
```

Expected: `unread_count` is greater than `0` for the demo user if seed/demo data is present.

- [ ] **Step 2: Build the project**

Run:

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\zhibo\Desktop\bcscunp_sem1\5026CMD Software Engineer\src\src\src.csproj" /t:Build /p:Configuration=Debug /v:minimal
```

Expected: build succeeds.

- [ ] **Step 3: Manual browser verification**

Start the app through Visual Studio/IIS Express at:

```text
https://localhost:44368/
```

Use a student login that maps to `user_id = 1`.

Verify:

- On `shared/dashboard.aspx`, sidebar `Notifications` shows an unread badge when unread count is greater than `0`.
- On `shared/dashboard.aspx`, topbar bell shows a red unread badge when unread count is greater than `0`.
- If the unread count is greater than `9`, both badges show `9+`.
- On `shared/notifications.aspx`, selecting one unread item marks it read and decreases the sidebar/topbar badges.
- Clicking `Mark all as read` hides both badges.
- Clicking `Mark unread` for the selected item shows both badges again with count `1`.
- Refreshing `shared/notifications.aspx` keeps the same read/unread state.
- Navigating to another dashboard page keeps the same badge count.

- [ ] **Step 4: Verify database persistence after reading one notification**

After selecting one notification in the browser, run:

```powershell
sqlcmd -S "(localdb)\MSSQLLocalDB" -d StudentInformationManagementSystem -E -Q "SELECT TOP 5 user_id, announcement_id, read_at FROM NOTIFICATION_READS WHERE user_id = 1 ORDER BY read_at DESC"
```

Expected: at least one row exists for `user_id = 1`.

- [ ] **Step 5: Commit verification-only fixes if needed**

If manual verification required a code fix, stage only the files changed for this feature:

```powershell
git status --short
git add db/notification_reads.sql src.csproj services/AnnouncementService.cs controls/sidebar.ascx controls/sidebar.ascx.cs controls/topbar.ascx controls/topbar.ascx.cs shared/notifications.aspx shared/notifications.aspx.cs js/notifications/notifications.js
git commit -m "fix(notifications): polish unread badge behavior"
```

Expected: skip this commit if no fixes were needed.

---

### Task 7: Update Project Context Documentation

**Files:**
- Modify: `doc/project-context.md`

- [ ] **Step 1: Update the source tree section**

In `doc/project-context.md`, add `notification_reads.sql` under `db/`:

```text
    notification_reads.sql
```

- [ ] **Step 2: Update the shared controls section**

In the `controls/sidebar.ascx` section, add:

```markdown
- The `Notifications` nav row renders `#sidebar-notif-count` with `data-notification-count-badge`.
- The badge is hidden when unread count is `0`, shows `1` through `9`, and shows `9+` above `9`.
- The count comes from `AnnouncementService.GetUnreadCountForStudent(Session["user_id"])` through `controls/sidebar.ascx.cs`.
```

In the `controls/topbar.ascx` section, add:

```markdown
- The notification bell renders `#topbar-notif-count` with `data-notification-count-badge`.
- The badge is hidden when unread count is `0`, shows `1` through `9`, and shows `9+` above `9`.
- The hardcoded notification count was replaced by `AnnouncementService.GetUnreadCountForStudent(Session["user_id"])` through `controls/topbar.ascx.cs`.
```

- [ ] **Step 3: Update the notifications page section**

Add or update the `shared/notifications.aspx.cs` notes with:

```markdown
- Notification read state is database-backed by `NOTIFICATION_READS`.
- `UnreadCount` counts `Notifications` where `IsRead == false`.
- WebMethods:
  - `MarkRead(int announcementId)`.
  - `MarkUnread(int announcementId)`.
  - `MarkAllRead()`.
- Each WebMethod requires `Session["user_id"]`, writes through `AnnouncementService`, and returns `{ ok, unreadCount, badgeText }`.
```

Add or update the `js/notifications/notifications.js` notes with:

```markdown
- Selecting a notification posts to `/shared/notifications.aspx/MarkRead`.
- `Mark unread` posts to `/shared/notifications.aspx/MarkUnread`.
- `Mark all as read` posts to `/shared/notifications.aspx/MarkAllRead`.
- The script updates all `[data-notification-count-badge]` elements after each successful server response.
```

- [ ] **Step 4: Update database table usage**

In the database table usage table, add:

```markdown
| `NOTIFICATION_READS` | `AnnouncementService` for per-user read state and unread notification counts |
```

- [ ] **Step 5: Update database scripts section**

Add a section for the new script:

```markdown
### `db/notification_reads.sql`

Idempotent schema patch for notification read receipts.

Creates:

- `NOTIFICATION_READS(user_id, announcement_id, read_at)`.
- Primary key `(user_id, announcement_id)`.
- Foreign keys to `USERS(user_id)` and `ANNOUNCEMENTS(announcement_id)`.
- Index `IX_NOTIFICATION_READS_announcement_id`.

Used by:

- `AnnouncementService.GetAllForStudent`.
- `AnnouncementService.GetUnreadCountForStudent`.
- `AnnouncementService.MarkRead`.
- `AnnouncementService.MarkUnread`.
- `AnnouncementService.MarkAllRead`.
```

- [ ] **Step 6: Verify documentation mentions the new DB table**

Run:

```powershell
Select-String -Path 'doc\project-context.md' -Pattern 'NOTIFICATION_READS|notification_reads.sql|data-notification-count-badge'
```

Expected: matches appear in the source tree, controls/page notes, and DB table usage sections.

- [ ] **Step 7: Commit**

Run:

```powershell
git status --short
git add doc/project-context.md
git commit -m "docs(notifications): document unread badge flow"
```

Expected: commit includes only `doc/project-context.md`.

---

## Final Verification Checklist

- [ ] `db/notification_reads.sql` applies cleanly through `sqlcmd`.
- [ ] `src.csproj` includes `db\notification_reads.sql`.
- [ ] `AnnouncementService.GetAllForStudent` returns `StudentNotification.IsRead`.
- [ ] `AnnouncementService.GetUnreadCountForStudent` counts visible unread notifications for the logged-in user.
- [ ] `AnnouncementService.MarkRead`, `MarkUnread`, and `MarkAllRead` persist read state in `NOTIFICATION_READS`.
- [ ] Sidebar badge appears beside `Notifications`, hides at `0`, and shows `9+` above `9`.
- [ ] Topbar bell badge is no longer hardcoded and follows the same count rule.
- [ ] Notification list items render `data-read` from the database.
- [ ] Selecting an unread notification persists it as read and updates both badges.
- [ ] `Mark all as read` persists all visible notifications as read and hides both badges.
- [ ] `Mark unread` persists the selected notification as unread and shows both badges.
- [ ] `node --check js\notifications\notifications.js` passes.
- [ ] MSBuild passes.
- [ ] `doc/project-context.md` documents the new DB table, service methods, and badge behavior.

---

## Notes For The Implementer

- Do not store read state on `ANNOUNCEMENTS`; an announcement can be unread for one student and read for another.
- Do not rely on browser-only state for badge counts; the count must survive refresh and navigation.
- Stage only files related to this feature. This worktree currently has unrelated modified/deleted/untracked files, so avoid broad `git add .`.
- If the LocalDB database has not been patched, the app will fail when `AnnouncementService` references `NOTIFICATION_READS`. Apply `db/notification_reads.sql` before manual browser testing.
