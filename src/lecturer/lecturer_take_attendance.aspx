<%@ Page Language="C#" MasterPageFile="~/lecturer/LecturerLayout.master" AutoEventWireup="true" CodeBehind="lecturer_take_attendance.aspx.cs" Inherits="src.lecturer.lecturer_take_attendance" Title="Take Attendance - INTI Lecturer Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <a href="<%= BackUrl %>" class="inline-flex items-center gap-1.5 text-slate-600 transition-colors hover:text-[#a01020]" style="font-size:13px;font-weight:600">
        <i data-lucide="arrow-left" class="h-4 w-4"></i> Back to Attendance
    </a>

    <asp:Panel ID="statusBanner" runat="server" Visible="false" style="font-size:13px;font-weight:600">
        <i ID="statusIcon" runat="server" class="h-4 w-4"></i>
        <asp:Label ID="statusMessage" runat="server" />
    </asp:Panel>

    <section class="mt-4 rounded-lg border border-slate-200 bg-white">
        <div class="border-b border-slate-100 px-6 py-4">
            <h1 class="text-slate-900" style="font-size:18px;font-weight:700">Attendance session</h1>
            <p class="mt-0.5 text-slate-500" style="font-size:12.5px">Choose any assigned course, date, and time for regular, replacement, or additional classes.</p>
        </div>

        <div class="grid gap-4 px-6 py-5 md:grid-cols-2 xl:grid-cols-[1.35fr_1fr_1fr_1fr] xl:items-end">
            <label class="block">
                <span class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.05em">COURSE</span>
                <asp:DropDownList ID="courseSelect" runat="server" AutoPostBack="true" OnSelectedIndexChanged="CourseSelect_Changed"
                    CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-800 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10"
                    style="font-size:13px" />
            </label>
            <label class="block">
                <span class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.05em">DATE <span class="text-[#e0162b]">*</span></span>
                <asp:TextBox ID="dateInput" runat="server" TextMode="Date" required="required"
                    CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-800 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" />
            </label>
            <label class="block">
                <span class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.05em">START TIME <span class="text-[#e0162b]">*</span></span>
                <asp:TextBox ID="startTimeInput" runat="server" TextMode="Time" required="required"
                    CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-800 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" />
            </label>
            <label class="block">
                <span class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.05em">END TIME <span class="text-[#e0162b]">*</span></span>
                <asp:TextBox ID="endTimeInput" runat="server" TextMode="Time" required="required"
                    CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-800 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" />
            </label>
        </div>
    </section>

    <section class="mt-4 rounded-lg border border-slate-200 bg-white">
        <div class="flex flex-col gap-4 px-6 py-5 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex items-start gap-4">
                <span class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl" style='background-color:<%= AccentColor %>15;color:<%= AccentColor %>'>
                    <i data-lucide="clipboard-check" class="h-5 w-5"></i>
                </span>
                <div>
                    <div class="flex flex-wrap items-center gap-2">
                        <h2 class="text-slate-900" style="font-size:22px;font-weight:700"><%: CourseCode %></h2>
                        <span class="rounded-full bg-slate-100 px-2.5 py-0.5 text-slate-600" style="font-size:11.5px;font-weight:600"><%: EnrolledCountDisplay %></span>
                    </div>
                    <p class="mt-1 text-slate-700" style="font-size:14px;font-weight:500"><%: CourseName %></p>
                </div>
            </div>
            <div class="flex flex-wrap items-center gap-2">
                <button ID="markAllPresent" runat="server" type="button" clientidmode="Static"
                    class="inline-flex h-10 items-center gap-1.5 rounded-md border border-slate-200 bg-white px-3 text-slate-700 transition-colors hover:bg-slate-50"
                    style="font-size:13px;font-weight:600">
                    <i data-lucide="check-check" class="h-4 w-4"></i> Mark all present
                </button>
                <asp:LinkButton ID="saveBtn" runat="server" OnClick="SaveAttendance_Click"
                    CssClass="inline-flex h-10 items-center gap-2 rounded-xl bg-[#e0162b] px-4 text-white shadow-[0_8px_20px_-8px_rgba(224,22,43,0.55)] transition-colors hover:bg-[#a01020]"
                    style="font-size:13px;font-weight:600">
                    <i data-lucide="save" class="h-4 w-4"></i> Save attendance
                </asp:LinkButton>
            </div>
        </div>
    </section>

    <asp:Panel ID="rosterPanel" runat="server" CssClass="mt-6 rounded-lg border border-slate-200 bg-white">
        <div class="border-b border-slate-100 px-6 py-4">
            <h2 class="text-slate-900" style="font-size:15px;font-weight:700">Student roster</h2>
            <p class="mt-0.5 text-slate-500" style="font-size:12.5px">Mark each student present, late, or absent, then save.</p>
        </div>

        <div class="overflow-x-auto">
            <table class="min-w-full">
                <thead class="border-b border-slate-100 bg-slate-50/60 text-slate-500">
                    <tr>
                        <th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">ID</th>
                        <th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Name</th>
                        <th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Email</th>
                        <th class="px-6 py-3 text-right uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Attendance</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rosterRepeater" runat="server">
                        <ItemTemplate>
                            <tr class="border-b border-slate-100 hover:bg-slate-50/60" data-roster-row data-enrolment-id='<%# Eval("EnrolmentId") %>'>
                                <td class="px-6 py-3 text-slate-500" style="font-size:12.5px"><%#: Eval("StudentId") %></td>
                                <td class="px-6 py-3" style="font-size:12.5px"><span class="font-medium text-slate-900"><%#: Eval("FullName") %></span></td>
                                <td class="px-6 py-3 text-slate-500" style="font-size:12.5px"><%#: Eval("Email") %></td>
                                <td class="px-6 py-3">
                                    <div class="flex justify-end">
                                        <div class="inline-flex divide-x divide-slate-200 overflow-hidden rounded-lg border border-slate-200">
                                            <button type="button" data-status="PRESENT" data-enrolment-id='<%# Eval("EnrolmentId") %>' data-active='<%# SegActive(Eval("Status"), "PRESENT") %>'
                                                class="px-3 py-1.5 text-slate-600 transition-colors hover:bg-slate-50 data-[active=true]:bg-emerald-500 data-[active=true]:text-white" style="font-size:12px;font-weight:600">Present</button>
                                            <button type="button" data-status="LATE" data-enrolment-id='<%# Eval("EnrolmentId") %>' data-active='<%# SegActive(Eval("Status"), "LATE") %>'
                                                class="px-3 py-1.5 text-slate-600 transition-colors hover:bg-slate-50 data-[active=true]:bg-amber-500 data-[active=true]:text-white" style="font-size:12px;font-weight:600">Late</button>
                                            <button type="button" data-status="ABSENT" data-enrolment-id='<%# Eval("EnrolmentId") %>' data-active='<%# SegActive(Eval("Status"), "ABSENT") %>'
                                                class="px-3 py-1.5 text-slate-600 transition-colors hover:bg-slate-50 data-[active=true]:bg-[#e0162b] data-[active=true]:text-white" style="font-size:12px;font-weight:600">Absent</button>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <asp:PlaceHolder ID="emptyPanel" runat="server" Visible="false">
            <p class="m-6 rounded-lg border border-dashed border-slate-200 p-4 text-slate-500" style="font-size:13px">No students are enrolled in this course.</p>
        </asp:PlaceHolder>
    </asp:Panel>

    <asp:HiddenField ID="attendanceData" runat="server" />
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script>
        (function () {
            var hidden = document.getElementById('<%= attendanceData.ClientID %>');
            if (!hidden) return;
            var map = {};
            try { map = JSON.parse(hidden.value || '{}') || {}; } catch (e) { map = {}; }

            function setActive(row, status) {
                row.querySelectorAll('[data-status]').forEach(function (button) {
                    button.setAttribute('data-active', button.getAttribute('data-status') === status ? 'true' : 'false');
                });
            }

            document.addEventListener('click', function (event) {
                var button = event.target.closest('[data-status][data-enrolment-id]');
                if (button) {
                    var enrolmentId = button.getAttribute('data-enrolment-id');
                    var status = button.getAttribute('data-status');
                    map[enrolmentId] = status;
                    hidden.value = JSON.stringify(map);
                    setActive(button.closest('[data-roster-row]'), status);
                    return;
                }

                if (event.target.closest('#markAllPresent')) {
                    document.querySelectorAll('[data-roster-row]').forEach(function (row) {
                        map[row.getAttribute('data-enrolment-id')] = 'PRESENT';
                        setActive(row, 'PRESENT');
                    });
                    hidden.value = JSON.stringify(map);
                }
            });
        })();
    </script>
</asp:Content>
