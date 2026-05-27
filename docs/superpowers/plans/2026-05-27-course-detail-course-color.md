# Course Detail Course Color Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every red accent on `student/course_detail.aspx` use the selected course's `COURSES.color` value from the database.

**Architecture:** The page already receives `Header.Color` from `CourseDetailService.GetHeader()`. The implementation will validate that value through the existing `AccentColor(string color)` helper, expose it once as CSS custom properties on a page root element, and reuse those variables in markup and JavaScript.

**Tech Stack:** ASP.NET Web Forms, C# code-behind, server-rendered ASPX markup, Tailwind utility classes, vanilla JavaScript.

---

## File Structure

- Modify `student/course_detail.aspx`: add a root wrapper with course accent CSS variables and replace fixed `#e0162b` markup styles with `var(--course-accent)` or `var(--course-accent-soft)`.
- Modify `js/course-detail/course-detail.js`: read `--course-accent` from the page root for active tabs and pinned-course state.
- No DB files change: `COURSES.color` already exists in `db/seed_data.sql`, and `CourseHeader.Color` is already loaded in `services/CourseDetailService.cs`.
- No code-behind change is required unless the implementation needs a server helper beyond the existing `AccentColor(string color)` method.

---

### Task 1: Bind Course Accent Variables In The ASPX Page

**Files:**
- Modify: `student/course_detail.aspx`
- Reference: `student/course_detail.aspx.cs`

- [ ] **Step 1: Run the baseline failing static check**

Run:

```powershell
Select-String -Path 'student\course_detail.aspx','js\course-detail\course-detail.js' -Pattern '#e0162b'
```

Expected: FAIL for the target behavior by reporting fixed red matches in both files.

- [ ] **Step 2: Add the page root with validated course accent variables**

In `student/course_detail.aspx`, immediately after:

```aspx
<asp:Content ContentPlaceHolderID="MainContent" runat="server">
```

add:

```aspx
    <div id="course-detail-root"
        style="--course-accent:<%= AccentColor(Header.Color) %>;--course-accent-soft:<%= AccentColor(Header.Color) %>15;--course-accent-dark:color-mix(in srgb,var(--course-accent) 72%,#000)">
```

Then add the closing tag immediately before the closing `MainContent` content tag:

```aspx
    </div>

</asp:Content>
```

- [ ] **Step 3: Update the course header gradient**

Replace:

```aspx
    <section class="relative mt-4 overflow-hidden rounded-3xl p-7 lg:p-9 text-white" style="background:linear-gradient(135deg,#e0162b 0%,#1e293b 100%)">
```

with:

```aspx
    <section class="relative mt-4 overflow-hidden rounded-3xl p-7 lg:p-9 text-white" style="background:linear-gradient(135deg,var(--course-accent) 0%,#1e293b 100%)">
```

- [ ] **Step 4: Update tab button and indicator accent styles**

For every tab button in `student/course_detail.aspx`, remove hard-coded red text utility classes such as:

```aspx
text-[#e0162b] data-[active=true]:text-[#e0162b]
```

Keep the neutral inactive classes:

```aspx
data-[active=false]:text-slate-500 data-[active=false]:hover:text-slate-900
```

For every tab indicator, replace:

```aspx
class="tab-indicator absolute inset-x-2 -bottom-px h-0.5 rounded-full bg-[#e0162b]"
```

or:

```aspx
class="tab-indicator absolute inset-x-2 -bottom-px h-0.5 rounded-full bg-[#e0162b] hidden"
```

with:

```aspx
class="tab-indicator absolute inset-x-2 -bottom-px h-0.5 rounded-full"
style="background-color:var(--course-accent)"
```

or the hidden variant:

```aspx
class="tab-indicator absolute inset-x-2 -bottom-px h-0.5 rounded-full hidden"
style="background-color:var(--course-accent)"
```

- [ ] **Step 5: Update module badge accent styles**

Replace the module week badge style:

```aspx
style="background-color:#e0162b15;color:#e0162b;font-size:12px;font-weight:700"
```

with:

```aspx
style="background-color:var(--course-accent-soft);color:var(--course-accent);font-size:12px;font-weight:700"
```

- [ ] **Step 6: Update announcement accent styles**

Replace the announcement avatar:

```aspx
<div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[#e0162b] text-white" style="font-size:12px;font-weight:600"><%# Server.HtmlEncode(Initials(Eval("AuthorName").ToString())) %></div>
```

with:

```aspx
<div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-white" style="background-color:var(--course-accent);font-size:12px;font-weight:600"><%# Server.HtmlEncode(Initials(Eval("AuthorName").ToString())) %></div>
```

Replace the pinned announcement expression:

```aspx
<%# (bool)Eval("IsPinned") ? "<span class=\"inline-flex items-center gap-1 rounded-md bg-[#e0162b]/10 px-1.5 py-0.5 text-[#a01020]\" style=\"font-size:10.5px;font-weight:600\">Pinned</span>" : "" %>
```

with:

```aspx
<%# (bool)Eval("IsPinned") ? "<span class=\"inline-flex items-center gap-1 rounded-md px-1.5 py-0.5\" style=\"background-color:var(--course-accent-soft);color:var(--course-accent-dark);font-size:10.5px;font-weight:600\">Pinned</span>" : "" %>
```

- [ ] **Step 7: Update assignment accent styles**

Replace:

```aspx
<span class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-[#e0162b]/10 text-[#e0162b]">
```

with:

```aspx
<span class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:var(--course-accent-soft);color:var(--course-accent)">
```

- [ ] **Step 8: Update grade and score chart accent styles**

Replace:

```aspx
<circle cx="60" cy="60" r="48" fill="none" stroke="#e0162b" stroke-width="12"
```

with:

```aspx
<circle cx="60" cy="60" r="48" fill="none" style="stroke:var(--course-accent)" stroke-width="12"
```

Replace:

```aspx
<span class="h-2.5 w-2.5 rounded-sm" style="background-color:#e0162b"></span> Score
```

with:

```aspx
<span class="h-2.5 w-2.5 rounded-sm" style="background-color:var(--course-accent)"></span> Score
```

Replace:

```aspx
style='height:<%# (bool)Eval("IsGraded") ? System.Math.Round(System.Convert.ToDecimal(Eval("Marks")) / System.Convert.ToInt32(Eval("MaxMarks")) * 72, 0) : 0 %>%;background-color:#e0162b'
```

with:

```aspx
style='height:<%# (bool)Eval("IsGraded") ? System.Math.Round(System.Convert.ToDecimal(Eval("Marks")) / System.Convert.ToInt32(Eval("MaxMarks")) * 72, 0) : 0 %>%;background-color:var(--course-accent)'
```

- [ ] **Step 9: Run the page static check**

Run:

```powershell
Select-String -Path 'student\course_detail.aspx' -Pattern '#e0162b'
```

Expected: no output.

- [ ] **Step 10: Commit the ASPX change**

Run:

```powershell
git add -- student\course_detail.aspx
git commit -m "feat: bind course detail markup to course color"
```

Expected: one commit containing only the ASPX page change.

---

### Task 2: Use The Course Accent In Course Detail JavaScript

**Files:**
- Modify: `js/course-detail/course-detail.js`

- [ ] **Step 1: Run the baseline failing JavaScript check**

Run:

```powershell
Select-String -Path 'js\course-detail\course-detail.js' -Pattern '#e0162b'
```

Expected: FAIL for the target behavior by reporting `var ACTIVE = "#e0162b";`.

- [ ] **Step 2: Replace the fixed active color with a CSS-variable reader**

Replace:

```javascript
    var ACTIVE = "#e0162b";   // crimson accent for the active tab / pinned state
    var INACTIVE = "#64748b"; // slate-500 for inactive tabs
```

with:

```javascript
    var INACTIVE = "#64748b"; // slate-500 for inactive tabs

    function activeColor() {
        var root = document.getElementById("course-detail-root") || document.documentElement;
        var color = window.getComputedStyle(root).getPropertyValue("--course-accent").trim();
        return color || INACTIVE;
    }
```

- [ ] **Step 3: Update tab and pin painting to call `activeColor()`**

Replace:

```javascript
                btn.style.color = active ? ACTIVE : INACTIVE;
```

with:

```javascript
                btn.style.color = active ? activeColor() : INACTIVE;
```

Replace:

```javascript
        btn.style.color = loadPins().indexOf(code) !== -1 ? ACTIVE : "";
```

with:

```javascript
        btn.style.color = loadPins().indexOf(code) !== -1 ? activeColor() : "";
```

- [ ] **Step 4: Run the JavaScript static check**

Run:

```powershell
Select-String -Path 'js\course-detail\course-detail.js' -Pattern '#e0162b'
```

Expected: no output.

- [ ] **Step 5: Commit the JavaScript change**

Run:

```powershell
git add -- js\course-detail\course-detail.js
git commit -m "feat: bind course detail script to course color"
```

Expected: one commit containing only the JavaScript change.

---

### Task 3: Verify The Completed Change

**Files:**
- Check: `student/course_detail.aspx`
- Check: `js/course-detail/course-detail.js`
- Build: `..\src.sln`

- [ ] **Step 1: Confirm no fixed course-detail red remains**

Run:

```powershell
Select-String -Path 'student\course_detail.aspx','js\course-detail\course-detail.js' -Pattern '#e0162b'
```

Expected: no output.

- [ ] **Step 2: Confirm the DB color still reaches the page model**

Run:

```powershell
Select-String -Path 'services\CourseDetailService.cs' -Pattern 'c.color|Color ='
```

Expected: output includes `c.color` in the header query and `Color = reader["color"] == System.DBNull.Value ? "" : reader["color"].ToString()`.

- [ ] **Step 3: Build the Web Forms project**

Run:

```powershell
MSBuild ..\src.sln /p:Configuration=Debug /p:Platform="Any CPU"
```

Expected: build succeeds with `0 Error(s)`.

- [ ] **Step 4: Manually inspect two course offerings**

Open the app and inspect:

```text
/student/course_detail.aspx?offering=1
/student/course_detail.aspx?offering=2
```

Expected: offering `1` uses the CS101 red accent from the DB, and offering `2` uses the CS201 blue accent from the DB across the header, tabs, modules, announcements, assignments, grade donut, chart bars, and pin active state.

- [ ] **Step 5: Commit any verification-only plan updates**

Run:

```powershell
git status --short
```

Expected: no unintended file changes remain beyond user-owned existing worktree changes.
