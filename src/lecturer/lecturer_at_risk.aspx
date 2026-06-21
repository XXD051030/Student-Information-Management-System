<%@ Page Language="C#" MasterPageFile="~/lecturer/LecturerLayout.master" AutoEventWireup="true" CodeBehind="lecturer_at_risk.aspx.cs" Inherits="student_information_management_system.lecturer_at_risk" Title="Academic Performance - INTI Lecturer Portal" %>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div>
        <p class="text-slate-500" style="font-size:13px;font-weight:500">Lecturer Module</p>
        <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700">Academic Performance</h1>
        <p class="mt-1 text-slate-500" style="font-size:14px">Analyse marks, attendance, and outcomes for students in your courses.</p>
    </div>

    <section class="mt-6 rounded-xl border border-slate-200 bg-white p-4">
        <div class="grid gap-4 md:grid-cols-3">
            <label class="block">
                <span class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.05em">ACADEMIC YEAR</span>
                <asp:DropDownList ID="academicYearFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-700" style="font-size:13px" />
            </label>
            <label class="block">
                <span class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.05em">SEMESTER</span>
                <asp:DropDownList ID="semesterFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-700" style="font-size:13px" />
            </label>
            <label class="block">
                <span class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.05em">COURSE</span>
                <asp:DropDownList ID="courseFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="FilterChanged" CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-700" style="font-size:13px" />
            </label>
        </div>
    </section>

    <section class="mt-6" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:16px">
        <div class="rounded-2xl border border-slate-200 bg-white p-4"><p class="text-slate-500 text-xs">Average GPA</p><p class="mt-1 text-2xl font-bold text-slate-900"><%= Gpa(AverageGpa) %></p><p class="text-xs text-slate-400">Published results</p></div>
        <div class="rounded-2xl border border-slate-200 bg-white p-4"><p class="text-slate-500 text-xs">Average Marks</p><p class="mt-1 text-2xl font-bold text-slate-900"><%= Marks(AverageMarks) %></p><p class="text-xs text-slate-400">Graded assessments</p></div>
        <div class="rounded-2xl border border-slate-200 bg-white p-4"><p class="text-slate-500 text-xs">Pass Rate</p><p class="mt-1 text-2xl font-bold text-emerald-600"><%= Percent(PassRate) %></p><p class="text-xs text-slate-400">Marked results</p></div>
        <div class="rounded-2xl border border-slate-200 bg-white p-4"><p class="text-slate-500 text-xs">Fail Rate</p><p class="mt-1 text-2xl font-bold text-[#a01020]"><%= Percent(FailRate) %></p><p class="text-xs text-slate-400">Marked results</p></div>
        <div class="rounded-2xl border border-slate-200 bg-white p-4"><p class="text-slate-500 text-xs">At-Risk Students</p><p class="mt-1 text-2xl font-bold text-[#a01020]"><%= AtRiskCount %></p><p class="text-xs text-slate-400">Course enrolments flagged</p></div>
        <div class="rounded-2xl border border-slate-200 bg-white p-4"><p class="text-slate-500 text-xs">Top Performers</p><p class="mt-1 text-2xl font-bold text-emerald-600"><%= TopPerformerCount %></p><p class="text-xs text-slate-400">Marks 80% or above</p></div>
    </section>

    <section class="mt-6 rounded-lg border border-slate-200 bg-white" data-tabs>
        <div class="flex flex-wrap gap-1 border-b border-slate-100 px-4 pt-3">
            <button type="button" data-tab="overview" class="tab-button">Result Overview</button>
            <button type="button" data-tab="students" class="tab-button">Student Results</button>
            <button type="button" data-tab="attendance" class="tab-button">Attendance</button>
            <button type="button" data-tab="atrisk" class="tab-button">At-Risk Students</button>
            <button type="button" data-tab="top" class="tab-button">Top Performers</button>
        </div>

        <div data-tab-panel="overview" class="p-6">
            <div class="rounded-xl border border-slate-200 p-5">
                <h3 class="font-bold text-slate-900">Marks Distribution</h3><p class="mt-1 text-xs text-slate-500">Assessment averages across your courses.</p>
                <div class="mt-4 space-y-3">
                    <div><div class="band-label"><span>A (80-100)</span><span><%= Percent(GradeBandPercent(80m, 101m)) %></span></div><div class="band-track"><div class="h-full bg-emerald-500" style="width:<%= BarWidth(GradeBandPercent(80m, 101m)) %>%"></div></div></div>
                    <div><div class="band-label"><span>B (70-79)</span><span><%= Percent(GradeBandPercent(70m, 80m)) %></span></div><div class="band-track"><div class="h-full bg-sky-500" style="width:<%= BarWidth(GradeBandPercent(70m, 80m)) %>%"></div></div></div>
                    <div><div class="band-label"><span>C (60-69)</span><span><%= Percent(GradeBandPercent(60m, 70m)) %></span></div><div class="band-track"><div class="h-full bg-amber-500" style="width:<%= BarWidth(GradeBandPercent(60m, 70m)) %>%"></div></div></div>
                    <div><div class="band-label"><span>D (50-59)</span><span><%= Percent(GradeBandPercent(50m, 60m)) %></span></div><div class="band-track"><div class="h-full bg-orange-500" style="width:<%= BarWidth(GradeBandPercent(50m, 60m)) %>%"></div></div></div>
                    <div><div class="band-label"><span>F (Below 50)</span><span><%= Percent(GradeBandPercent(0m, 50m)) %></span></div><div class="band-track"><div class="h-full bg-[#e0162b]" style="width:<%= BarWidth(GradeBandPercent(0m, 50m)) %>%"></div></div></div>
                </div>
            </div>
        </div>

        <div data-tab-panel="students"><div data-table data-page-size="20"><div class="table-tools"><input data-table-search placeholder="Search student, ID or course..." class="search-input" /></div><div class="overflow-x-auto"><table class="min-w-full"><thead class="table-head"><tr><th>ID</th><th>Name</th><th>Programme</th><th>Sem</th><th>Course</th><th>Grade</th><th class="text-right">GPA</th><th class="text-right">Marks</th><th>Status</th></tr></thead><tbody>
            <asp:Repeater ID="studentRepeater" runat="server"><ItemTemplate><tr data-row data-search='<%# Html(Eval("StudentId")) %> <%# Html(Eval("FullName")) %> <%# Html(Eval("CourseCode")) %>' data-prog='<%# Html(Eval("ProgrammeCode")) %>' data-course='<%# Html(Eval("CourseCode")) %>'><td><%# Html(Eval("StudentId")) %></td><td class="font-medium text-slate-900"><%# Html(Eval("FullName")) %></td><td><%# Html(Eval("ProgrammeCode")) %></td><td><%# Eval("Semester") %></td><td><span class="font-medium"><%# Html(Eval("CourseCode")) %></span> &middot; <%# Html(Eval("CourseName")) %></td><td><%# Html(Eval("LetterGrade")) %></td><td class="text-right"><%# Gpa(Eval("GradePoint")) %></td><td class="text-right"><%# Marks(Eval("AverageMarks")) %></td><td><span class='status-badge <%# StatusClass(Eval("Status")) %>'><%# Html(Eval("Status")) %></span></td></tr></ItemTemplate></asp:Repeater>
            <tr data-table-empty style="display:none"><td colspan="9" class="empty-cell">No results match your filters.</td></tr></tbody></table></div></div></div>

        <div data-tab-panel="attendance"><div data-table data-page-size="20"><div class="table-tools"><input data-table-search placeholder="Search course..." class="search-input" /></div><div class="overflow-x-auto"><table class="min-w-full"><thead class="table-head"><tr><th>Code</th><th>Course</th><th>Programme</th><th class="text-right">Enrolled</th><th class="text-right">Average Attendance</th></tr></thead><tbody>
            <asp:Repeater ID="attendanceRepeater" runat="server"><ItemTemplate><tr data-row data-search='<%# Html(Eval("CourseCode")) %> <%# Html(Eval("CourseName")) %>' data-prog='<%# Html(Eval("ProgrammeCode")) %>' data-course='<%# Html(Eval("CourseCode")) %>'><td class="font-medium"><%# Html(Eval("CourseCode")) %></td><td><%# Html(Eval("CourseName")) %></td><td><%# Html(Eval("ProgrammeCode")) %></td><td class="text-right"><%# Eval("Enrolled") %></td><td class="text-right"><%# Marks(Eval("AverageAttendance")) %></td></tr></ItemTemplate></asp:Repeater>
            <tr data-table-empty style="display:none"><td colspan="5" class="empty-cell">No courses match your filters.</td></tr></tbody></table></div></div></div>

        <div data-tab-panel="atrisk"><div data-table data-page-size="20"><div class="table-tools"><input data-table-search placeholder="Search student, ID or course..." class="search-input" /></div><div class="overflow-x-auto"><table class="min-w-full"><thead class="table-head"><tr><th>ID</th><th>Name</th><th>Programme</th><th>Course</th><th class="text-right">Marks</th><th class="text-right">Attendance</th><th>Risk</th><th>Reason</th></tr></thead><tbody>
            <asp:Repeater ID="riskRepeater" runat="server"><ItemTemplate><tr data-row data-search='<%# Html(Eval("StudentId")) %> <%# Html(Eval("FullName")) %> <%# Html(Eval("CourseCode")) %>' data-prog='<%# Html(Eval("ProgrammeCode")) %>' data-course='<%# Html(Eval("CourseCode")) %>'><td><%# Html(Eval("StudentId")) %></td><td class="font-medium text-slate-900"><%# Html(Eval("FullName")) %></td><td><%# Html(Eval("ProgrammeCode")) %></td><td><%# Html(Eval("CourseCode")) %></td><td class="text-right font-semibold text-[#a01020]"><%# Marks(Eval("AverageMarks")) %></td><td class="text-right"><%# Marks(Eval("AttendanceRate")) %></td><td><span class='status-badge <%# RiskClass(Eval("RiskLevel")) %>'><%# Html(Eval("RiskLevel")) %></span></td><td><%# Html(Eval("RiskReason")) %></td></tr></ItemTemplate></asp:Repeater>
            <tr data-table-empty style="display:none"><td colspan="8" class="empty-cell">No at-risk students match your filters.</td></tr></tbody></table></div></div></div>

        <div data-tab-panel="top"><div data-table data-page-size="20"><div class="table-tools"><input data-table-search placeholder="Search student, ID or course..." class="search-input" /></div><div class="overflow-x-auto"><table class="min-w-full"><thead class="table-head"><tr><th>ID</th><th>Name</th><th>Programme</th><th>Course</th><th class="text-right">Marks</th><th>Grade</th></tr></thead><tbody>
            <asp:Repeater ID="topRepeater" runat="server"><ItemTemplate><tr data-row data-search='<%# Html(Eval("StudentId")) %> <%# Html(Eval("FullName")) %> <%# Html(Eval("CourseCode")) %>' data-prog='<%# Html(Eval("ProgrammeCode")) %>' data-course='<%# Html(Eval("CourseCode")) %>'><td><%# Html(Eval("StudentId")) %></td><td class="font-medium text-slate-900"><%# Html(Eval("FullName")) %></td><td><%# Html(Eval("ProgrammeCode")) %></td><td><%# Html(Eval("CourseCode")) %></td><td class="text-right font-semibold text-emerald-600"><%# Marks(Eval("AverageMarks")) %></td><td><%# Html(Eval("LetterGrade")) %></td></tr></ItemTemplate></asp:Repeater>
            <tr data-table-empty style="display:none"><td colspan="6" class="empty-cell">No top performers match your filters.</td></tr></tbody></table></div></div></div>
    </section>

    <style>
        .tab-button{border-bottom-width:2px;border-color:transparent;border-radius:.5rem .5rem 0 0;padding:.5rem .75rem;color:#64748b;font-size:13px;font-weight:600}.tab-button[data-active=true]{border-color:#e0162b;color:#a01020}.band-label{display:flex;justify-content:space-between;color:#334155;font-size:12.5px}.band-track{height:.5rem;margin-top:.25rem;overflow:hidden;border-radius:9999px;background:#f1f5f9}.table-tools{display:flex;flex-wrap:wrap;align-items:center;gap:.5rem;padding:1rem 1.5rem}.search-input{height:2.25rem;min-width:16rem;flex:1;border:1px solid #e2e8f0;border-radius:.375rem;padding:0 .75rem;font-size:12.5px}.filter-select{height:2.25rem;border:1px solid #e2e8f0;border-radius:.375rem;background:#fff;padding:0 .75rem;font-size:12.5px}.table-head{border-top:1px solid #f1f5f9;border-bottom:1px solid #f1f5f9;background:rgba(248,250,252,.6);color:#64748b}.table-head th,tbody td{padding:.75rem 1.5rem;text-align:left;font-size:12.5px}.table-head .text-right,tbody .text-right{text-align:right}tbody tr[data-row]{border-bottom:1px solid #f1f5f9}.status-badge{display:inline-flex;border:1px solid;border-radius:9999px;padding:.125rem .5rem;font-size:11.5px;font-weight:600}.empty-cell{padding:2.5rem;text-align:center;color:#94a3b8}
    </style>
</asp:Content>
<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/admin/shared/table.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/ui.js") %>"></script>
</asp:Content>
