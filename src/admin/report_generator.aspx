<%@ Page Language="C#" MasterPageFile="~/admin/AdminLayout.master" AutoEventWireup="true" CodeBehind="report_generator.aspx.cs" Inherits="src.admin.report_generator" Title="Report Generator - INTI Admin Portal" %>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <div>
        <p class="text-slate-500" style="font-size:13px;font-weight:500">Admin</p>
        <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Report Generator</h1>
        <p class="mt-1 text-slate-500" style="font-size:14px">Select a report, apply filters, preview, and export to PDF or Excel.</p>
    </div>

    <section class="mt-6" style="display:flex;flex-wrap:wrap;gap:16px;align-items:flex-start">
        <%-- Report types --%>
        <div class="rounded-lg border border-slate-200 bg-white" style="flex:1 1 320px;max-width:400px;min-width:0">
            <div class="border-b border-slate-100 px-6 py-4"><h2 class="text-slate-900" style="font-size:15px;font-weight:700">Report Types</h2><p class="mt-0.5 text-slate-500" style="font-size:12.5px">Choose a report to generate</p></div>
            <ul class="p-2" id="report-list">
                <li><button type="button" data-report data-active="true" class="flex w-full items-start gap-3 rounded-xl px-3 py-3 text-left hover:bg-slate-50 data-[active=true]:bg-[#e0162b]/10"><span class="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-700"><i data-lucide="file-text" class="h-4 w-4"></i></span><div class="min-w-0 flex-1"><div class="flex items-center justify-between"><div class="text-slate-900 truncate" style="font-size:13px;font-weight:600">Student Academic Report</div><i data-lucide="chevron-right" class="h-4 w-4 text-slate-400"></i></div><div class="text-slate-500 truncate" style="font-size:12px">Per-student academic summary with grades and CGPA</div></div></button></li>
                <li><button type="button" data-report class="flex w-full items-start gap-3 rounded-xl px-3 py-3 text-left hover:bg-slate-50 data-[active=true]:bg-[#e0162b]/10"><span class="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-700"><i data-lucide="file-text" class="h-4 w-4"></i></span><div class="min-w-0 flex-1"><div class="flex items-center justify-between"><div class="text-slate-900 truncate" style="font-size:13px;font-weight:600">Programme Performance Report</div><i data-lucide="chevron-right" class="h-4 w-4 text-slate-400"></i></div><div class="text-slate-500 truncate" style="font-size:12px">Programme-level pass rate, GPA, enrolment</div></div></button></li>
                <li><button type="button" data-report class="flex w-full items-start gap-3 rounded-xl px-3 py-3 text-left hover:bg-slate-50 data-[active=true]:bg-[#e0162b]/10"><span class="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-700"><i data-lucide="file-text" class="h-4 w-4"></i></span><div class="min-w-0 flex-1"><div class="flex items-center justify-between"><div class="text-slate-900 truncate" style="font-size:13px;font-weight:600">Course Performance Report</div><i data-lucide="chevron-right" class="h-4 w-4 text-slate-400"></i></div><div class="text-slate-500 truncate" style="font-size:12px">Course-level outcomes and grade distribution</div></div></button></li>
                <li><button type="button" data-report class="flex w-full items-start gap-3 rounded-xl px-3 py-3 text-left hover:bg-slate-50 data-[active=true]:bg-[#e0162b]/10"><span class="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-700"><i data-lucide="file-text" class="h-4 w-4"></i></span><div class="min-w-0 flex-1"><div class="flex items-center justify-between"><div class="text-slate-900 truncate" style="font-size:13px;font-weight:600">Attendance Summary Report</div><i data-lucide="chevron-right" class="h-4 w-4 text-slate-400"></i></div><div class="text-slate-500 truncate" style="font-size:12px">Attendance percentages by student / course</div></div></button></li>
                <li><button type="button" data-report class="flex w-full items-start gap-3 rounded-xl px-3 py-3 text-left hover:bg-slate-50 data-[active=true]:bg-[#e0162b]/10"><span class="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-700"><i data-lucide="file-text" class="h-4 w-4"></i></span><div class="min-w-0 flex-1"><div class="flex items-center justify-between"><div class="text-slate-900 truncate" style="font-size:13px;font-weight:600">At-Risk Student Report</div><i data-lucide="chevron-right" class="h-4 w-4 text-slate-400"></i></div><div class="text-slate-500 truncate" style="font-size:12px">Students requiring academic intervention</div></div></button></li>
                <li><button type="button" data-report class="flex w-full items-start gap-3 rounded-xl px-3 py-3 text-left hover:bg-slate-50 data-[active=true]:bg-[#e0162b]/10"><span class="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-700"><i data-lucide="file-text" class="h-4 w-4"></i></span><div class="min-w-0 flex-1"><div class="flex items-center justify-between"><div class="text-slate-900 truncate" style="font-size:13px;font-weight:600">Top-Performing Student Report</div><i data-lucide="chevron-right" class="h-4 w-4 text-slate-400"></i></div><div class="text-slate-500 truncate" style="font-size:12px">Dean's List / scholarship candidates</div></div></button></li>
                <li><button type="button" data-report class="flex w-full items-start gap-3 rounded-xl px-3 py-3 text-left hover:bg-slate-50 data-[active=true]:bg-[#e0162b]/10"><span class="mt-0.5 flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-700"><i data-lucide="file-text" class="h-4 w-4"></i></span><div class="min-w-0 flex-1"><div class="flex items-center justify-between"><div class="text-slate-900 truncate" style="font-size:13px;font-weight:600">Enrolment Summary Report</div><i data-lucide="chevron-right" class="h-4 w-4 text-slate-400"></i></div><div class="text-slate-500 truncate" style="font-size:12px">Semester-by-semester enrolment overview</div></div></button></li>
            </ul>
        </div>

        <%-- Config + Preview --%>
        <div class="space-y-6" style="flex:2 1 480px;min-width:0">
            <div class="rounded-lg border border-slate-200 bg-white">
                <div class="flex items-start justify-between gap-3 border-b border-slate-100 px-6 py-4">
                    <div>
                        <div class="flex items-center gap-2"><h2 class="text-slate-900" style="font-size:18px;font-weight:700;letter-spacing:-0.01em">Student Academic Report</h2><span class="inline-flex items-center gap-1 rounded-full border px-2 py-0.5 bg-sky-50 text-sky-700 border-sky-100" style="font-size:11.5px;font-weight:600">PDF &middot; Excel</span></div>
                        <p class="mt-1 text-slate-500" style="font-size:13px">Per-student academic summary with grades and CGPA</p>
                    </div>
                    <div class="flex items-center gap-2">
                        <button type="button" data-toast="Student Academic Report generated" data-toast-desc="PDF &middot; AY 2025/26 &middot; Sem 1" class="inline-flex items-center gap-1.5 rounded-md border border-slate-200 bg-white px-3 h-10 text-slate-700 hover:bg-slate-50 transition-colors" style="font-size:13px;font-weight:600"><i data-lucide="file-text" class="h-4 w-4"></i> Generate PDF</button>
                        <button type="button" data-toast="Student Academic Report generated" data-toast-desc="Excel &middot; AY 2025/26 &middot; Sem 1" class="inline-flex items-center gap-1.5 rounded-md bg-[#e0162b] px-4 h-10 text-white hover:bg-[#a01020] transition-colors shadow-[0_8px_18px_-10px_rgba(224,22,43,0.9)]" style="font-size:13px;font-weight:600"><i data-lucide="file-spreadsheet" class="h-4 w-4"></i> Generate Excel</button>
                    </div>
                </div>
                <div class="px-6 py-6">
                    <h3 class="text-slate-900" style="font-size:14px;font-weight:700">Filters</h3>
                    <p class="mt-0.5 text-slate-500" style="font-size:12.5px">Refine the report scope before generating.</p>
                    <div class="mt-5" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px">
                        <label class="block"><span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Academic Year</span><div class="mt-1.5"><select class="h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"><option>2025/26</option><option>2024/25</option></select></div></label>
                        <label class="block"><span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Semester</span><div class="mt-1.5"><select class="h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"><option>1</option><option>2</option></select></div></label>
                        <label class="block"><span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Programme</span><div class="mt-1.5"><select class="h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"><option value="">All programmes</option><option>BCS</option><option>BIT</option><option>BBA</option></select></div></label>
                        <label class="block"><span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Date From</span><div class="mt-1.5"><input type="date" value="2025-09-01" class="h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px" /></div></label>
                        <label class="block"><span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Date To</span><div class="mt-1.5"><input type="date" value="2026-06-30" class="h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px" /></div></label>
                        <label class="block"><span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Status</span><div class="mt-1.5"><select class="h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"><option value="">Any</option><option>Pass</option><option>Fail</option></select></div></label>
                    </div>
                </div>
            </div>

            <div class="rounded-lg border border-slate-200 bg-white">
                <div class="flex items-start justify-between gap-3 border-b border-slate-100 px-6 py-4">
                    <div><h2 class="text-slate-900" style="font-size:15px;font-weight:700">Preview</h2><p class="mt-0.5 text-slate-500" style="font-size:12.5px">Sample of records that will appear in the report</p></div>
                    <button type="button" data-toast="Preview download started" data-toast-desc="Student Academic Report" class="inline-flex items-center gap-1.5 rounded-md border border-slate-200 bg-white px-3 h-10 text-slate-700 hover:bg-slate-50 transition-colors" style="font-size:13px;font-weight:600"><i data-lucide="download" class="h-4 w-4"></i> Download</button>
                </div>
                <div class="overflow-x-auto px-6 py-4">
                    <table class="min-w-full">
                        <thead class="border-b border-slate-100 text-slate-500"><tr>
                            <th class="py-2 text-left uppercase" style="font-size:11px;font-weight:600">ID</th><th class="py-2 text-left uppercase" style="font-size:11px;font-weight:600">Name</th><th class="py-2 text-left uppercase" style="font-size:11px;font-weight:600">Programme</th><th class="py-2 text-right uppercase" style="font-size:11px;font-weight:600">CGPA</th><th class="py-2 text-left uppercase" style="font-size:11px;font-weight:600">Status</th>
                        </tr></thead>
                        <tbody>
                            <tr class="border-b border-slate-100" style="font-size:12.5px"><td class="py-2 text-slate-500">S12039</td><td class="py-2 text-slate-900">Lim Wei Jian</td><td class="py-2">BCS</td><td class="py-2 text-right">3.75</td><td class="py-2">Good Standing</td></tr>
                            <tr class="border-b border-slate-100" style="font-size:12.5px"><td class="py-2 text-slate-500">S12040</td><td class="py-2 text-slate-900">Nur Aisyah</td><td class="py-2">BIT</td><td class="py-2 text-right">2.30</td><td class="py-2">Probation</td></tr>
                            <tr class="border-b border-slate-100" style="font-size:12.5px"><td class="py-2 text-slate-500">S12041</td><td class="py-2 text-slate-900">Raj Kumar</td><td class="py-2">BBA</td><td class="py-2 text-right">3.45</td><td class="py-2">Good Standing</td></tr>
                            <tr class="border-b border-slate-100" style="font-size:12.5px"><td class="py-2 text-slate-500">S12042</td><td class="py-2 text-slate-900">Tan Mei Ling</td><td class="py-2">BCS</td><td class="py-2 text-right">1.80</td><td class="py-2">At Risk</td></tr>
                        </tbody>
                    </table>
                    <div class="mt-3 text-slate-400" style="font-size:11.5px">Showing 4 of 2,847 &mdash; full results in exported file.</div>
                </div>
            </div>
        </div>
    </section>

</asp:Content>
<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/admin/shared/icons.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/toast.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/table.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/ui.js") %>"></script>
    <script>
      (function () {
        var items = document.querySelectorAll("[data-report]");
        items.forEach(function (b) {
          b.addEventListener("click", function () {
            items.forEach(function (x) { x.setAttribute("data-active", "false"); });
            b.setAttribute("data-active", "true");
          });
        });
      })();
    </script>
</asp:Content>
