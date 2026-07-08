<%@ Page Language="C#" MasterPageFile="~/lecturer/LecturerLayout.master" AutoEventWireup="true" CodeBehind="lecturer_attendance_history.aspx.cs" Inherits="src.lecturer.lecturer_attendance_history" Title="Attendance History - INTI Lecturer Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <a href="<%= ResolveUrl("~/lecturer/lecturer_attendance.aspx") %>" class="inline-flex items-center gap-1.5 text-slate-600 transition-colors hover:text-[#a01020]" style="font-size:13px;font-weight:600">
                <i data-lucide="arrow-left" class="h-4 w-4"></i> Back to Attendance
            </a>
            <h1 class="mt-4 text-slate-900" style="font-size:28px;font-weight:700">Attendance history</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">Review attendance sessions previously recorded for your courses.</p>
        </div>
        <a href="<%= ResolveUrl("~/lecturer/lecturer_take_attendance.aspx") %>" class="inline-flex h-10 items-center gap-2 rounded-xl bg-[#e0162b] px-4 text-white transition-colors hover:bg-[#a01020]" style="font-size:13px;font-weight:600">
            <i data-lucide="plus" class="h-4 w-4"></i> New attendance
        </a>
    </div>

    <section class="mt-6 overflow-hidden rounded-lg border border-slate-200 bg-white">
        <div class="flex flex-col gap-3 border-b border-slate-100 px-6 py-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
                <h2 class="text-slate-900" style="font-size:16px;font-weight:700">Recorded sessions</h2>
                <p class="mt-0.5 text-slate-500" style="font-size:12.5px"><%= SessionCount %> attendance sessions</p>
            </div>
            <div class="flex flex-col gap-2 sm:flex-row">
                <asp:DropDownList ID="courseFilterSelect" runat="server" ClientIDMode="Static" data-history-course="true"
                    CssClass="h-9 rounded-md border border-slate-200 bg-white px-3 text-slate-700 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10 sm:w-48"
                    style="font-size:12.5px" />
                <div class="relative">
                    <i data-lucide="search" class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400"></i>
                    <input data-history-search type="search" placeholder="Search course or date" class="h-9 w-full rounded-md border border-slate-200 bg-white pl-9 pr-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10 sm:w-64" style="font-size:12.5px" />
                </div>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="min-w-full">
                <thead class="border-b border-slate-100 bg-slate-50/60 text-slate-500">
                    <tr>
                        <th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:700">Course</th>
                        <th class="px-4 py-3 text-left uppercase" style="font-size:11px;font-weight:700">Date</th>
                        <th class="px-4 py-3 text-left uppercase" style="font-size:11px;font-weight:700">Time</th>
                        <th class="px-4 py-3 text-center uppercase" style="font-size:11px;font-weight:700">Present</th>
                        <th class="px-4 py-3 text-center uppercase" style="font-size:11px;font-weight:700">Late</th>
                        <th class="px-4 py-3 text-center uppercase" style="font-size:11px;font-weight:700">Absent</th>
                        <th class="px-6 py-3 text-right uppercase" style="font-size:11px;font-weight:700">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    <asp:Repeater ID="historyRepeater" runat="server">
                        <ItemTemplate>
                            <tr data-history-row data-history-course='<%#: Eval("CourseCode") %>' data-history-text='<%# SearchText(Container.DataItem) %>' class="hover:bg-slate-50/60">
                                <td class="px-6 py-4">
                                    <p class="text-slate-900" style="font-size:13px;font-weight:700"><%#: Eval("CourseCode") %></p>
                                    <p class="mt-0.5 text-slate-500" style="font-size:12px"><%#: Eval("CourseName") %></p>
                                </td>
                                <td class="px-4 py-4 text-slate-700" style="font-size:12.5px"><%# DateLabel(Eval("SessionDate")) %></td>
                                <td class="px-4 py-4 text-slate-700" style="font-size:12.5px"><%# TimeLabel(Eval("StartTime"), Eval("EndTime")) %></td>
                                <td class="px-4 py-4 text-center"><span class="rounded-full bg-emerald-50 px-2 py-1 text-emerald-700" style="font-size:11.5px;font-weight:700"><%# Eval("PresentCount") %></span></td>
                                <td class="px-4 py-4 text-center"><span class="rounded-full bg-amber-50 px-2 py-1 text-amber-700" style="font-size:11.5px;font-weight:700"><%# Eval("LateCount") %></span></td>
                                <td class="px-4 py-4 text-center"><span class="rounded-full bg-red-50 px-2 py-1 text-[#a01020]" style="font-size:11.5px;font-weight:700"><%# Eval("AbsentCount") %></span></td>
                                <td class="px-6 py-4 text-right">
                                    <a href='<%# ViewUrl(Container.DataItem) %>' class="inline-flex h-8 items-center gap-1.5 rounded-md border border-slate-200 bg-white px-3 text-slate-700 transition-colors hover:bg-slate-50" style="font-size:12px;font-weight:700">
                                        <i data-lucide="eye" class="h-3.5 w-3.5"></i> View
                                    </a>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <asp:Panel ID="emptyPanel" runat="server" Visible="false" CssClass="px-6 py-12 text-center text-slate-500" style="font-size:13px">
            No attendance sessions have been recorded yet.
        </asp:Panel>
        <p data-history-empty hidden class="px-6 py-12 text-center text-slate-500" style="font-size:13px">No attendance sessions match your search.</p>
    </section>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script>
        (function () {
            var search = document.querySelector('[data-history-search]');
            var course = document.querySelector('[data-history-course]');
            if (!search || !course) return;

            function applyFilters() {
                var query = search.value.trim().toLowerCase();
                var selectedCourse = course.value;
                var visible = 0;
                document.querySelectorAll('[data-history-row]').forEach(function (row) {
                    var searchMatch = !query || (row.getAttribute('data-history-text') || '').toLowerCase().indexOf(query) >= 0;
                    var courseMatch = selectedCourse === 'all' || row.getAttribute('data-history-course') === selectedCourse;
                    var match = searchMatch && courseMatch;
                    row.hidden = !match;
                    if (match) visible++;
                });
                var empty = document.querySelector('[data-history-empty]');
                if (empty) empty.hidden = visible !== 0;
            }

            search.addEventListener('input', applyFilters);
            course.addEventListener('change', applyFilters);
        })();
    </script>
</asp:Content>
