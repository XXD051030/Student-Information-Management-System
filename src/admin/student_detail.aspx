<%@ Page Language="C#" MasterPageFile="~/admin/AdminLayout.master" AutoEventWireup="true" CodeBehind="student_detail.aspx.cs" Inherits="src.admin.student_detail" Title="Student Detail - INTI Admin Portal" %>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <a href="<%= ResolveUrl("~/admin/academic_performance.aspx") %>" class="inline-flex items-center gap-1.5 text-slate-600 hover:text-[#a01020] transition-colors" style="font-size:13px;font-weight:600">
        <i data-lucide="arrow-left" class="h-4 w-4"></i> Back to Academic Performance
    </a>

    <div class="mt-4">

        <%-- Header card --%>
        <section class="rounded-lg border border-slate-200 bg-white">
            <div class="flex flex-col gap-5 px-6 py-6 lg:flex-row lg:items-start lg:justify-between">
                <div class="flex items-start gap-4">
                    <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-[#e0162b]/10 text-[#a01020]" style="font-size:22px;font-weight:700;letter-spacing:-0.01em"><%= Initials() %></div>
                    <div>
                        <div class="flex flex-wrap items-center gap-2">
                            <h1 class="text-slate-900" style="font-size:24px;font-weight:700;letter-spacing:-0.01em"><%= Html(Student.Name) %></h1>
                            <span class="inline-flex items-center gap-1 rounded-full border px-2 py-0.5 bg-emerald-50 text-emerald-700 border-emerald-100" style="font-size:11.5px;font-weight:600">Dean's List</span>
                        </div>
                        <div class="mt-1 text-slate-500" style="font-size:13px">Student ID: <span class="text-slate-700 font-medium"><%= Html(Student.StudentId) %></span></div>
                        <div class="mt-3 flex flex-wrap items-center gap-x-5 gap-y-2 text-slate-600" style="font-size:12.5px">
                            <span class="inline-flex items-center gap-1.5"><i data-lucide="graduation-cap" class="h-4 w-4 text-slate-400"></i> <%= Html(Student.Programme) %></span>
                            <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-clock" class="h-4 w-4 text-slate-400"></i> <%= Html(Student.Session) %></span>
                            <span class="inline-flex items-center gap-1.5"><i data-lucide="mail" class="h-4 w-4 text-slate-400"></i> <%= Html(Student.Email) %></span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <%-- Stat strip --%>
        <section class="mt-4" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px">
            <div class="rounded-2xl border border-slate-200 bg-white p-4 hover:border-slate-300 hover:shadow-sm transition-all">
                <div class="flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:500"><i data-lucide="activity" class="h-3.5 w-3.5 text-slate-400"></i> Overall CGPA</div>
                <div class="mt-1 text-emerald-600" style="font-size:24px;font-weight:700;letter-spacing:-0.01em"><%= DecimalNumber(Student.Cgpa) %></div>
                <div class="text-slate-400" style="font-size:11.5px">Semester <%= Student.Semester %></div>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-4 hover:border-slate-300 hover:shadow-sm transition-all">
                <div class="flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:500"><i data-lucide="activity" class="h-3.5 w-3.5 text-slate-400"></i> Current Sem GPA</div>
                <div class="mt-1 text-emerald-600" style="font-size:24px;font-weight:700;letter-spacing:-0.01em"><%= DecimalNumber(Student.CurrentGpa) %></div>
                <div class="text-slate-400" style="font-size:11.5px"><%= Html(Student.Session) %></div>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-4 hover:border-slate-300 hover:shadow-sm transition-all">
                <div class="flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:500"><i data-lucide="activity" class="h-3.5 w-3.5 text-slate-400"></i> Courses Completed</div>
                <div class="mt-1 text-slate-900" style="font-size:24px;font-weight:700;letter-spacing:-0.01em"><%= Student.CompletedCourses.ToString("N0") %></div>
                <div class="text-slate-400" style="font-size:11.5px"><%= Student.CreditHours.ToString("N0") %> credit hrs</div>
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white p-4 hover:border-slate-300 hover:shadow-sm transition-all">
                <div class="flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:500"><i data-lucide="activity" class="h-3.5 w-3.5 text-slate-400"></i> Attendance</div>
                <div class="mt-1 text-emerald-600" style="font-size:24px;font-weight:700;letter-spacing:-0.01em"><%= Percent(Student.Attendance) %></div>
                <div class="text-slate-400" style="font-size:11.5px">all semesters</div>
            </div>
        </section>

        <%-- CGPA trend --%>
        <section class="mt-6 rounded-lg border border-slate-200 bg-white">
            <div class="border-b border-slate-100 px-6 py-4"><h2 class="text-slate-900" style="font-size:15px;font-weight:700">CGPA Trend</h2><p class="mt-0.5 text-slate-500" style="font-size:12.5px">Cumulative GPA vs semester GPA across all completed semesters.</p></div>
            <div class="px-6 py-6">
                <div class="w-full overflow-x-auto">
                    <%= CgpaTrendChart() %>
                </div>
            </div>
        </section>

        <%-- Attendance by semester --%>
        <section class="mt-6 rounded-lg border border-slate-200 bg-white">
            <div class="flex items-center justify-between border-b border-slate-100 px-6 py-4">
                <div><h2 class="text-slate-900" style="font-size:15px;font-weight:700">Attendance by Semester</h2><p class="mt-0.5 text-slate-500" style="font-size:12.5px">Per-course attendance rate across each semester.</p></div>
                <div class="inline-flex items-center gap-1.5 text-slate-500" style="font-size:12.5px"><i data-lucide="calendar-check" class="h-4 w-4 text-slate-400"></i> Overall <%= Percent(Student.Attendance) %></div>
            </div>
            <ul class="divide-y divide-slate-100">
                <%= AttendanceBySemesterHtml() %>
            </ul>
        </section>

        <%-- Semester results --%>
        <section class="mt-6 rounded-lg border border-slate-200 bg-white">
            <div class="border-b border-slate-100 px-6 py-4"><h2 class="text-slate-900" style="font-size:15px;font-weight:700">Semester Results</h2><p class="mt-0.5 text-slate-500" style="font-size:12.5px">Expand each semester to view course grades.</p></div>
            <ul class="divide-y divide-slate-100">
                <%= SemesterResultsHtml() %>
            </ul>
        </section>

    </div>

</asp:Content>
<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/admin/shared/icons.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/toast.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/ui.js") %>?v=accordion1"></script>
</asp:Content>

