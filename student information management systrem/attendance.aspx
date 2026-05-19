<%@ Page Language="C#" MasterPageFile="~/DashboardLayout.master" AutoEventWireup="true" CodeBehind="attendance.aspx.cs" Inherits="student_information_management_system.attendance" Title="Attendance - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500">Academic record</p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Attendance</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">Your personal attendance log, visible only to you.</p>
        </div>
        <div class="flex flex-wrap items-center gap-2">
            <span class="inline-flex items-center gap-2 rounded-full bg-slate-100 px-3 py-1 text-slate-700" style="font-size:12px;font-weight:600">
                <i data-lucide="calendar-days" class="h-3.5 w-3.5"></i>
                Current semester
            </span>
            <button class="inline-flex items-center gap-2 rounded-md border border-slate-200 bg-white px-3 h-10 text-slate-700 hover:bg-slate-50 transition-colors" style="font-size:13px;font-weight:600">
                <i data-lucide="download" class="h-4 w-4"></i> Export report
            </button>
        </div>
    </div>

    <%-- Privacy banner --%>
    <div class="mt-4 flex items-start gap-2.5 rounded-md border border-sky-100 bg-sky-50/70 px-4 py-2.5 text-sky-800">
        <i data-lucide="shield-check" class="h-4 w-4 mt-0.5 shrink-0"></i>
        <p style="font-size:12.5px;line-height:1.5">
            These records are private to you. Only you and the registrar can view them. Lecturers see classroom rolls, not personal histories.
        </p>
    </div>

    <%-- Hero summary (overall: 28 attended / 98 required = 28.6%) --%>
    <section class="mt-6">
        <div class="rounded-lg border border-slate-200 bg-gradient-to-br from-[#e0162b] to-[#a01020] p-6 text-white relative overflow-hidden">
            <div class="pointer-events-none absolute -top-10 -right-10 h-48 w-48 rounded-full bg-white/10 blur-3xl"></div>
            <div class="relative flex items-start justify-between">
                <div>
                    <p class="text-white/80" style="font-size:11.5px;font-weight:600;letter-spacing:0.08em">OVERALL ATTENDANCE</p>
                    <p class="mt-2" style="font-size:56px;font-weight:800;letter-spacing:-0.02em;line-height:1">28.6<span class="text-white/70" style="font-size:24px;font-weight:700">%</span></p>
                    <p class="mt-2 text-white/80" style="font-size:13px">28 attended / 98 required across 4 courses</p>
                </div>
                <span class="inline-flex items-center gap-1 rounded border bg-white/15 backdrop-blur px-2.5 py-1 text-white border-white/25" style="font-size:11.5px;font-weight:700">
                    <i data-lucide="trending-up" class="h-3.5 w-3.5"></i> Term in progress
                </span>
            </div>
            <div class="mt-5 grid grid-cols-3 gap-2 border-t border-white/15 pt-4">
                <div>
                    <p class="text-white/70" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">PRESENT</p>
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700">27</p>
                </div>
                <div>
                    <p class="text-white/70" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">MC</p>
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700">1</p>
                </div>
                <div>
                    <p class="text-white/70" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">ABSENT</p>
                    <p class="mt-1 text-white" style="font-size:18px;font-weight:700">3</p>
                </div>
            </div>
        </div>
    </section>

    <%-- Per-course cards --%>
    <section class="mt-6">
        <div class="flex items-center justify-between mb-3">
            <h2 class="text-slate-900" style="font-size:15px;font-weight:600">By course</h2>
            <span class="text-slate-500" style="font-size:12px">Recorded sessions so far this term</span>
        </div>
        <div class="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">

            <%-- CSC2104 (active) --%>
            <div class="text-left rounded-lg border bg-white p-5 border-[#e0162b]/40 shadow-[0_8px_24px_-12px_rgba(224,22,43,0.35)] ring-1 ring-[#e0162b]/20">
                <div class="flex items-center gap-2.5">
                    <span class="h-9 w-1.5 rounded-full" style="background-color:#e0162b"></span>
                    <div class="min-w-0 flex-1">
                        <p class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.06em">CSC2104</p>
                        <p class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Software Engineering</p>
                    </div>
                </div>
                <div class="mt-4 flex items-baseline gap-1.5">
                    <span style="font-size:28px;font-weight:700;color:#e0162b;letter-spacing:-0.01em">32%</span>
                    <span class="text-slate-400" style="font-size:11.5px">9 / 28</span>
                </div>
                <div class="mt-2 h-1.5 rounded-full bg-slate-100 overflow-hidden">
                    <div class="h-full rounded-full" style="width:32.1%;background-color:#e0162b"></div>
                </div>
                <div class="mt-3 flex items-center gap-1.5 flex-wrap">
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#10b981"></span> 8 P
                    </span>
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#0ea5e9"></span> 1 MC
                    </span>
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#e0162b"></span> 1 A
                    </span>
                </div>
            </div>

            <%-- CSC2103 --%>
            <div class="text-left rounded-lg border bg-white p-5 border-slate-200">
                <div class="flex items-center gap-2.5">
                    <span class="h-9 w-1.5 rounded-full" style="background-color:#0ea5e9"></span>
                    <div class="min-w-0 flex-1">
                        <p class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.06em">CSC2103</p>
                        <p class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Database Systems</p>
                    </div>
                </div>
                <div class="mt-4 flex items-baseline gap-1.5">
                    <span style="font-size:28px;font-weight:700;color:#e0162b;letter-spacing:-0.01em">29%</span>
                    <span class="text-slate-400" style="font-size:11.5px">8 / 28</span>
                </div>
                <div class="mt-2 h-1.5 rounded-full bg-slate-100 overflow-hidden">
                    <div class="h-full rounded-full" style="width:28.6%;background-color:#e0162b"></div>
                </div>
                <div class="mt-3 flex items-center gap-1.5 flex-wrap">
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#10b981"></span> 8 P
                    </span>
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#0ea5e9"></span> 0 MC
                    </span>
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#e0162b"></span> 1 A
                    </span>
                </div>
            </div>

            <%-- MTH2101 --%>
            <div class="text-left rounded-lg border bg-white p-5 border-slate-200">
                <div class="flex items-center gap-2.5">
                    <span class="h-9 w-1.5 rounded-full" style="background-color:#10b981"></span>
                    <div class="min-w-0 flex-1">
                        <p class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.06em">MTH2101</p>
                        <p class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Discrete Mathematics</p>
                    </div>
                </div>
                <div class="mt-4 flex items-baseline gap-1.5">
                    <span style="font-size:28px;font-weight:700;color:#e0162b;letter-spacing:-0.01em">29%</span>
                    <span class="text-slate-400" style="font-size:11.5px">8 / 28</span>
                </div>
                <div class="mt-2 h-1.5 rounded-full bg-slate-100 overflow-hidden">
                    <div class="h-full rounded-full" style="width:28.6%;background-color:#e0162b"></div>
                </div>
                <div class="mt-3 flex items-center gap-1.5 flex-wrap">
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#10b981"></span> 8 P
                    </span>
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#0ea5e9"></span> 0 MC
                    </span>
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#e0162b"></span> 0 A
                    </span>
                </div>
            </div>

            <%-- ENG2001 --%>
            <div class="text-left rounded-lg border bg-white p-5 border-slate-200">
                <div class="flex items-center gap-2.5">
                    <span class="h-9 w-1.5 rounded-full" style="background-color:#f59e0b"></span>
                    <div class="min-w-0 flex-1">
                        <p class="text-slate-500" style="font-size:11px;font-weight:700;letter-spacing:0.06em">ENG2001</p>
                        <p class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Technical Communication</p>
                    </div>
                </div>
                <div class="mt-4 flex items-baseline gap-1.5">
                    <span style="font-size:28px;font-weight:700;color:#e0162b;letter-spacing:-0.01em">21%</span>
                    <span class="text-slate-400" style="font-size:11.5px">3 / 14</span>
                </div>
                <div class="mt-2 h-1.5 rounded-full bg-slate-100 overflow-hidden">
                    <div class="h-full rounded-full" style="width:21.4%;background-color:#e0162b"></div>
                </div>
                <div class="mt-3 flex items-center gap-1.5 flex-wrap">
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#10b981"></span> 3 P
                    </span>
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#0ea5e9"></span> 0 MC
                    </span>
                    <span class="inline-flex items-center gap-1 rounded bg-slate-50 border border-slate-200 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700">
                        <span class="h-1.5 w-1.5 rounded-full" style="background-color:#e0162b"></span> 1 A
                    </span>
                </div>
            </div>
        </div>
    </section>

    <%-- Detail: CSC2104 sessions --%>
    <section class="mt-6 rounded-lg border border-slate-200 bg-white">
        <header class="flex flex-col gap-3 border-b border-slate-100 px-6 py-5 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex items-center gap-3 min-w-0">
                <span class="h-10 w-1.5 rounded-full" style="background-color:#e0162b"></span>
                <div class="min-w-0">
                    <p class="text-slate-500" style="font-size:11.5px;font-weight:700;letter-spacing:0.06em">CSC2104</p>
                    <h3 class="text-slate-900 truncate" style="font-size:18px;font-weight:700;letter-spacing:-0.01em">Software Engineering</h3>
                    <p class="text-slate-500 truncate" style="font-size:12.5px">Dr. Lim Wei Jian</p>
                </div>
            </div>
            <span class="inline-flex items-center gap-2 rounded-full bg-slate-100 px-3 py-1 text-slate-700" style="font-size:12px;font-weight:600">
                <i data-lucide="filter" class="h-3.5 w-3.5"></i>
                All sessions
            </span>
        </header>

        <%-- KPI strip --%>
        <div class="grid gap-px bg-slate-100 sm:grid-cols-3">
            <div class="bg-white px-6 py-4">
                <div class="flex items-center gap-1.5 text-slate-500">
                    <span class="h-2 w-2 rounded-full" style="background-color:#10b981"></span>
                    <p style="font-size:10.5px;font-weight:700;letter-spacing:0.06em">PRESENT</p>
                </div>
                <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700">8</p>
            </div>
            <div class="bg-white px-6 py-4">
                <div class="flex items-center gap-1.5 text-slate-500">
                    <span class="h-2 w-2 rounded-full" style="background-color:#0ea5e9"></span>
                    <p style="font-size:10.5px;font-weight:700;letter-spacing:0.06em">MC</p>
                </div>
                <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700">1</p>
            </div>
            <div class="bg-white px-6 py-4">
                <div class="flex items-center gap-1.5 text-slate-500">
                    <span class="h-2 w-2 rounded-full" style="background-color:#e0162b"></span>
                    <p style="font-size:10.5px;font-weight:700;letter-spacing:0.06em">ABSENT</p>
                </div>
                <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700">1</p>
            </div>
        </div>

        <%-- Sessions table --%>
        <div class="overflow-x-auto">
            <table class="w-full text-left table-fixed">
                <colgroup>
                    <col style="width:22%" />
                    <col style="width:20%" />
                    <col style="width:18%" />
                    <col style="width:20%" />
                    <col style="width:20%" />
                </colgroup>
                <thead class="bg-slate-50/60 text-slate-500" style="font-size:10.5px;font-weight:700;letter-spacing:0.06em">
                    <tr>
                        <th class="px-6 py-3">DATE</th>
                        <th class="px-4 py-3">TIME</th>
                        <th class="px-4 py-3">TYPE</th>
                        <th class="px-4 py-3">ROOM</th>
                        <th class="px-6 py-3">STATUS</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">2 May 2026</div><div class="text-slate-500" style="font-size:11px">Fri</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">09:00 &ndash; 10:30</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">LECTURE</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-2-12</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="check-circle-2" class="h-3 w-3"></i> PRESENT</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">30 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Wed</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">14:00 &ndash; 16:00</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">TUTORIAL</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-3-04</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="check-circle-2" class="h-3 w-3"></i> PRESENT</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">28 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Mon</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">09:00 &ndash; 10:30</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">LECTURE</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-2-12</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="check-circle-2" class="h-3 w-3"></i> PRESENT</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">25 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Fri</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">09:00 &ndash; 10:30</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">LECTURE</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-2-12</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="check-circle-2" class="h-3 w-3"></i> PRESENT</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">23 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Wed</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">14:00 &ndash; 16:00</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">TUTORIAL</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-3-04</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="x-circle" class="h-3 w-3"></i> ABSENT</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">21 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Mon</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">09:00 &ndash; 10:30</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">LECTURE</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-2-12</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="check-circle-2" class="h-3 w-3"></i> PRESENT</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">18 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Fri</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">09:00 &ndash; 10:30</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">LECTURE</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-2-12</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="check-circle-2" class="h-3 w-3"></i> PRESENT</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">16 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Wed</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">14:00 &ndash; 16:00</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">TUTORIAL</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-3-04</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-sky-50 text-sky-700 border-sky-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="shield-check" class="h-3 w-3"></i> MC</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">14 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Mon</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">09:00 &ndash; 10:30</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">LECTURE</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-2-12</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="check-circle-2" class="h-3 w-3"></i> PRESENT</span></td>
                    </tr>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5"><div class="text-slate-900" style="font-size:13px;font-weight:600">11 Apr 2026</div><div class="text-slate-500" style="font-size:11px">Fri</div></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">09:00 &ndash; 10:30</td>
                        <td class="px-4 py-3.5"><span class="inline-flex items-center rounded border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-slate-700" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">LECTURE</span></td>
                        <td class="px-4 py-3.5 text-slate-700" style="font-size:12.5px">B-2-12</td>
                        <td class="px-6 py-3.5"><span class="inline-flex items-center gap-1 rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em"><i data-lucide="check-circle-2" class="h-3 w-3"></i> PRESENT</span></td>
                    </tr>
                </tbody>
            </table>
        </div>

        <footer class="flex items-center justify-between border-t border-slate-100 px-6 py-3">
            <p class="text-slate-500" style="font-size:12px">Showing 10 of 10 recorded sessions &middot; 28 required this semester</p>
        </footer>
    </section>

</asp:Content>
