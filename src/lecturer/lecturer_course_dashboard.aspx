<%@ Page Language="C#" MasterPageFile="~/lecturer/LecturerLayout.master" AutoEventWireup="true" CodeBehind="lecturer_course_dashboard.aspx.cs" Inherits="src.lecturer.lecturer_course_dashboard" Title="Course Dashboard - INTI Lecturer Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <div id="course-dashboard-root"
        style="--course-accent:<%= AccentColor %>;--course-accent-soft:<%= AccentColor %>15;--course-accent-dark:color-mix(in srgb,var(--course-accent) 72%,#000)">

    <%-- Back --%>
    <a href="<%= ResolveUrl("~/lecturer/lecturer_courses.aspx") %>" class="inline-flex items-center gap-1.5 text-slate-500 hover:text-slate-900 transition-colors" style="font-size:13px;font-weight:500">
        <i data-lucide="arrow-left" class="h-3.5 w-3.5"></i> Back to My Courses
    </a>

    <%-- Course header (DB-driven) --%>
    <section class="relative mt-4 overflow-hidden rounded-3xl p-7 lg:p-9 text-white" style="background:linear-gradient(135deg,var(--course-accent) 0%,#1e293b 100%)">
        <div class="pointer-events-none absolute -top-16 -right-10 h-64 w-64 rounded-full bg-white/10 blur-3xl"></div>
        <div class="relative max-w-2xl">
            <div class="flex items-center gap-2">
                <span class="rounded-md bg-white/15 px-2 py-0.5 backdrop-blur" style="font-size:11px;font-weight:600;letter-spacing:0.04em"><%: CourseCode %></span>
                <% if (!string.IsNullOrEmpty(LevelLabel)) { %>
                <span class="text-white/70" style="font-size:12px"><%: LevelLabel %></span>
                <% } %>
            </div>
            <h1 class="mt-3 text-white" style="font-size:30px;font-weight:700;letter-spacing:-0.015em;line-height:1.15">
                <%: CourseName %>
            </h1>
            <% if (!string.IsNullOrEmpty(Description)) { %>
            <p class="mt-2 text-white/80" style="font-size:14.5px;line-height:1.6"><%: Description %></p>
            <% } %>
            <div class="mt-4 flex flex-wrap gap-x-5 gap-y-1 text-white/80" style="font-size:13px">
                <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-4 w-4"></i> <%: SemesterName %></span>
                <span class="inline-flex items-center gap-1.5"><i data-lucide="award" class="h-4 w-4"></i> <%: CreditHours %> credits</span>
                <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-4 w-4"></i> <%: EnrolledLabel %></span>
            </div>
        </div>
    </section>

    <%-- Overview metrics --%>
    <section class="mt-6 grid grid-cols-2 gap-4 xl:grid-cols-4">

        <%-- Students --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2 text-slate-500">
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                    <i data-lucide="users" class="h-4 w-4"></i>
                </span>
                <p style="font-size:12.5px;font-weight:500">Students</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= EnrolledCount %></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">enrolled</p>
        </div>

        <%-- Class average --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2 text-slate-500">
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                    <i data-lucide="trending-up" class="h-4 w-4"></i>
                </span>
                <p style="font-size:12.5px;font-weight:500">Class average</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= AverageGradeDisplay %></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">published grades</p>
        </div>

        <%-- Attendance --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2 text-slate-500">
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                    <i data-lucide="clipboard-check" class="h-4 w-4"></i>
                </span>
                <p style="font-size:12.5px;font-weight:500">Attendance</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= AttendanceDisplay %></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">present rate</p>
        </div>

        <%-- Pending grading --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2 text-slate-500">
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                    <i data-lucide="pen-line" class="h-4 w-4"></i>
                </span>
                <p style="font-size:12.5px;font-weight:500">Pending grading</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= PendingGrading %></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">to mark</p>
        </div>

    </section>

    <%-- Manage this course (clickable cards -> sub-pages) --%>
    <section class="mt-8">
        <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Manage this course</h2>
        <p class="mt-0.5 text-slate-500" style="font-size:13px">Jump into a section to manage it.</p>

        <div class="mt-4 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">

            <%-- Announcements --%>
            <a href="<%= AnnouncementsUrl %>" class="group rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
                <div class="flex items-start justify-between">
                    <span class="flex h-11 w-11 items-center justify-center rounded-xl" style="background-color:var(--course-accent-soft);color:var(--course-accent)">
                        <i data-lucide="megaphone" class="h-5 w-5"></i>
                    </span>
                    <i data-lucide="arrow-up-right" class="h-4 w-4 text-slate-300 group-hover:text-slate-500 transition-colors"></i>
                </div>
                <p class="mt-4 text-slate-900" style="font-size:15px;font-weight:600">Announcements</p>
                <p class="mt-0.5 text-slate-500" style="font-size:12.5px"><%= AnnouncementLabel %></p>
            </a>

            <%-- People --%>
            <a href="<%= PeopleUrl %>" class="group rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
                <div class="flex items-start justify-between">
                    <span class="flex h-11 w-11 items-center justify-center rounded-xl" style="background-color:var(--course-accent-soft);color:var(--course-accent)">
                        <i data-lucide="users" class="h-5 w-5"></i>
                    </span>
                    <i data-lucide="arrow-up-right" class="h-4 w-4 text-slate-300 group-hover:text-slate-500 transition-colors"></i>
                </div>
                <p class="mt-4 text-slate-900" style="font-size:15px;font-weight:600">People</p>
                <p class="mt-0.5 text-slate-500" style="font-size:12.5px"><%= EnrolledLabel %></p>
            </a>

            <%-- Grades --%>
            <a href="<%= GradesUrl %>" class="group rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
                <div class="flex items-start justify-between">
                    <span class="flex h-11 w-11 items-center justify-center rounded-xl" style="background-color:var(--course-accent-soft);color:var(--course-accent)">
                        <i data-lucide="graduation-cap" class="h-5 w-5"></i>
                    </span>
                    <i data-lucide="arrow-up-right" class="h-4 w-4 text-slate-300 group-hover:text-slate-500 transition-colors"></i>
                </div>
                <p class="mt-4 text-slate-900" style="font-size:15px;font-weight:600">Grades</p>
                <p class="mt-0.5 text-slate-500" style="font-size:12.5px"><%= AssessmentLabel %></p>
            </a>

            <%-- Materials --%>
            <a href="<%= MaterialsUrl %>" class="group rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
                <div class="flex items-start justify-between">
                    <span class="flex h-11 w-11 items-center justify-center rounded-xl" style="background-color:var(--course-accent-soft);color:var(--course-accent)">
                        <i data-lucide="folder" class="h-5 w-5"></i>
                    </span>
                    <i data-lucide="arrow-up-right" class="h-4 w-4 text-slate-300 group-hover:text-slate-500 transition-colors"></i>
                </div>
                <p class="mt-4 text-slate-900" style="font-size:15px;font-weight:600">Materials</p>
                <p class="mt-0.5 text-slate-500" style="font-size:12.5px"><%= MaterialLabel %></p>
            </a>

        </div>
    </section>

    <section class="mt-8">
        <div>
            <div>
                <h2 class="text-slate-900" style="font-size:18px;font-weight:700">Course Content</h2>
                <p class="mt-0.5 text-slate-500" style="font-size:13px">Preview weekly lecture notes and published assessments as students see them.</p>
            </div>
        </div>

        <div class="mt-4 grid gap-6 xl:grid-cols-2">
            <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white">
                <header class="border-b border-slate-100 px-6 py-5">
                    <h3 class="text-slate-900" style="font-size:16px;font-weight:700">Weekly Modules</h3>
                    <p class="mt-0.5 text-slate-500" style="font-size:12.5px"><%= ModuleCount %> modules containing lecture notes</p>
                </header>
                <ul class="divide-y divide-slate-100">
                    <asp:Repeater ID="modulesRepeater" runat="server">
                        <ItemTemplate>
                            <li>
                                <button type="button" data-course-module-toggle class="flex w-full items-center gap-4 px-6 py-4 text-left hover:bg-slate-50/70">
                                    <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:var(--course-accent-soft);color:var(--course-accent);font-size:12px;font-weight:800"><%# Eval("Week") %></span>
                                    <div class="min-w-0 flex-1">
                                        <p class="truncate text-slate-900" style="font-size:14px;font-weight:700"><%# Server.HtmlEncode(Eval("Title").ToString()) %></p>
                                        <p class="mt-0.5 truncate text-slate-500" style="font-size:12px"><%# Server.HtmlEncode(Eval("Description").ToString()) %></p>
                                    </div>
                                    <span class="text-slate-400" style="font-size:11.5px;font-weight:600"><%# ((System.Collections.ICollection)Eval("Items")).Count %> items</span>
                                    <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 transition-transform" data-module-chevron></i>
                                </button>
                                <ul data-course-module-items class="hidden bg-slate-50/60 px-5 py-3">
                                    <asp:Repeater runat="server" DataSource='<%# Eval("Items") %>'>
                                        <ItemTemplate>
                                            <li>
                                                <a href='<%# MaterialPreviewUrl(Eval("MaterialId")) %>' class="flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white">
                                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-white text-slate-500"><i data-lucide="book-open" class="h-4 w-4"></i></span>
                                                    <span class="min-w-0 flex-1 truncate text-slate-800" style="font-size:13px;font-weight:600"><%# Server.HtmlEncode(Eval("Title").ToString()) %></span>
                                                    <i data-lucide="eye" class="h-4 w-4 text-slate-400"></i>
                                                </a>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ul>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
                <% if (ModuleCount == 0) { %><p class="px-6 py-10 text-center text-slate-400" style="font-size:13px">No weekly lecture notes yet.</p><% } %>
            </div>

            <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white">
                <header class="border-b border-slate-100 px-6 py-5">
                    <h3 class="text-slate-900" style="font-size:16px;font-weight:700">Assignments, Quizzes &amp; Tests</h3>
                    <p class="mt-0.5 text-slate-500" style="font-size:12.5px"><%= AssessmentCount %> published assessments</p>
                </header>
                <ul class="divide-y divide-slate-100">
                    <asp:Repeater ID="assessmentsRepeater" runat="server">
                        <ItemTemplate>
                            <li>
                                <a href='<%# MaterialPreviewUrl(Eval("MaterialId")) %>' class="flex items-center gap-4 px-6 py-4 hover:bg-slate-50/70">
                                    <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl" style="background-color:var(--course-accent-soft);color:var(--course-accent)"><i data-lucide='<%# AssessmentIcon(Eval("MaterialType")) %>' class="h-5 w-5"></i></span>
                                    <div class="min-w-0 flex-1">
                                        <div class="flex items-center gap-2">
                                            <p class="truncate text-slate-900" style="font-size:14px;font-weight:700"><%# Server.HtmlEncode(Eval("Title").ToString()) %></p>
                                            <span class="rounded bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:700"><%# Server.HtmlEncode(Eval("MaterialType").ToString()) %></span>
                                        </div>
                                        <p class="mt-1 text-slate-500" style="font-size:12px">Due <%# DueDateDisplay(Eval("DueDate")) %> &middot; <%# WeightDisplay(Eval("Weight")) %></p>
                                    </div>
                                    <i data-lucide="eye" class="h-4 w-4 text-slate-400"></i>
                                </a>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
                <% if (AssessmentCount == 0) { %><p class="px-6 py-10 text-center text-slate-400" style="font-size:13px">No assignments, quizzes, or tests yet.</p><% } %>
            </div>
        </div>
    </section>

    </div>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/lecturer/course-dashboard.js") %>?v=2"></script>
</asp:Content>
