<%@ Page Language="C#" MasterPageFile="~/DashboardLayout.master" AutoEventWireup="true" CodeBehind="assignments.aspx.cs" Inherits="student_information_management_system.assignments" Title="Assignments - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div>
        <p class="text-slate-500" style="font-size:13px;font-weight:500">Coursework</p>
        <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Assignments</h1>
        <p class="mt-1 text-slate-500" style="font-size:14px">
            Everything due this semester &middot; <span class="text-slate-900 font-semibold">Y2 &middot; Trimester 2 (May &ndash; Aug 2026)</span>
        </p>
    </div>

    <%-- KPI strip --%>
    <section class="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">

        <%-- Open assignments --%>
        <div class="rounded-lg border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2">
                <span class="flex h-7 w-7 items-center justify-center rounded-md bg-[#e0162b]/10 text-[#e0162b]">
                    <i data-lucide="clipboard-list" class="h-4 w-4"></i>
                </span>
                <p class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.06em">OPEN ASSIGNMENTS</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:26px;font-weight:700;letter-spacing:-0.01em">6</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">65% of grade remaining</p>
        </div>

        <%-- Due this week --%>
        <div class="rounded-lg border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2">
                <span class="flex h-7 w-7 items-center justify-center rounded-md bg-slate-100 text-slate-600">
                    <i data-lucide="calendar-clock" class="h-4 w-4"></i>
                </span>
                <p class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.06em">DUE THIS WEEK</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:26px;font-weight:700;letter-spacing:-0.01em">1</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">Next 7 days</p>
        </div>

        <%-- Overdue --%>
        <div class="rounded-lg border border-[#e0162b]/30 bg-[#e0162b]/5 p-5">
            <div class="flex items-center gap-2">
                <span class="flex h-7 w-7 items-center justify-center rounded-md bg-[#e0162b] text-white">
                    <i data-lucide="alert-triangle" class="h-4 w-4"></i>
                </span>
                <p class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.06em">OVERDUE</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:26px;font-weight:700;letter-spacing:-0.01em">4</p>
            <p class="mt-0.5 text-[#a01020]" style="font-size:11.5px">Submit ASAP</p>
        </div>

        <%-- Graded --%>
        <div class="rounded-lg border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2">
                <span class="flex h-7 w-7 items-center justify-center rounded-md bg-slate-100 text-slate-600">
                    <i data-lucide="graduation-cap" class="h-4 w-4"></i>
                </span>
                <p class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.06em">GRADED</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:26px;font-weight:700;letter-spacing:-0.01em">3</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">Results released</p>
        </div>

    </section>

    <%-- Toolbar + List --%>
    <section class="mt-8 rounded-lg border border-slate-200 bg-white">

        <%-- Filter bar --%>
        <div class="flex flex-col gap-4 border-b border-slate-100 p-4 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex flex-wrap gap-1 rounded-md bg-slate-100 p-1">
                <button data-action="filter" data-status="all" data-active="true"
                    class="inline-flex items-center gap-1.5 rounded px-3 py-1.5 bg-white text-slate-900 shadow-sm transition-all"
                    style="font-size:12.5px;font-weight:600">
                    All
                    <span class="rounded bg-[#e0162b] text-white px-1.5" style="font-size:10.5px;font-weight:700">10</span>
                </button>
                <button data-action="filter" data-status="urgent" data-active="false"
                    class="inline-flex items-center gap-1.5 rounded px-3 py-1.5 text-slate-600 hover:text-slate-900 transition-all"
                    style="font-size:12.5px;font-weight:600">
                    Urgent
                    <span class="rounded bg-slate-200 text-slate-600 px-1.5" style="font-size:10.5px;font-weight:700">4</span>
                </button>
                <button data-action="filter" data-status="soon" data-active="false"
                    class="inline-flex items-center gap-1.5 rounded px-3 py-1.5 text-slate-600 hover:text-slate-900 transition-all"
                    style="font-size:12.5px;font-weight:600">
                    Soon
                    <span class="rounded bg-slate-200 text-slate-600 px-1.5" style="font-size:10.5px;font-weight:700">1</span>
                </button>
                <button data-action="filter" data-status="ok" data-active="false"
                    class="inline-flex items-center gap-1.5 rounded px-3 py-1.5 text-slate-600 hover:text-slate-900 transition-all"
                    style="font-size:12.5px;font-weight:600">
                    On Track
                    <span class="rounded bg-slate-200 text-slate-600 px-1.5" style="font-size:10.5px;font-weight:700">5</span>
                </button>
            </div>
        </div>

        <%-- Assignment rows --%>
        <ul class="divide-y divide-slate-100">

            <%-- a1: ER Diagram Design — overdue → urgent --%>
            <li>
                <a data-action="open-assignment" data-course-code="CSC2103" data-row data-status="urgent"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#0ea5e9"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#0ea5e915;color:#0ea5e9">CSC2103</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Database Systems</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20" style="font-size:10.5px;font-weight:700">Overdue 15d</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">ER Diagram Design</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">Design an ER diagram for the BookHaven case study.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 04 May 2026 &middot; 23:59
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> Individual
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> PDF &middot; max 5 MB
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">10<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a2: Sprint 1 Retrospective Report — overdue → urgent --%>
            <li>
                <a data-action="open-assignment" data-course-code="CSC2104" data-row data-status="urgent"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#e0162b"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#e0162b15;color:#e0162b">CSC2104</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Software Engineering</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20" style="font-size:10.5px;font-weight:700">Overdue 10d</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">Sprint 1 Retrospective Report</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">Reflect on your team&#39;s first sprint outcomes and metrics.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 09 May 2026 &middot; 23:59
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i> Group
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> PDF &middot; max 4 pages
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">15<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a3: Discrete Maths — Problem Set 4 — overdue → urgent --%>
            <li>
                <a data-action="open-assignment" data-course-code="MTH2101" data-row data-status="urgent"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#10b981"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#10b98115;color:#10b981">MTH2101</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Discrete Mathematics</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20" style="font-size:10.5px;font-weight:700">Overdue 7d</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">Discrete Maths &mdash; Problem Set 4</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">Set theory, relations, and graph problems (Q1&ndash;Q12).</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 12 May 2026 &middot; 23:59
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> Individual
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> Handwritten &middot; scanned PDF
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">8<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a4: Algorithms Assignment 2 — overdue → urgent --%>
            <li>
                <a data-action="open-assignment" data-course-code="CSC2202" data-row data-status="urgent"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#8b5cf6"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#8b5cf615;color:#8b5cf6">CSC2202</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Algorithms &amp; Complexity</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20" style="font-size:10.5px;font-weight:700">Overdue 1d</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">Algorithms Assignment 2</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">Greedy and divide-and-conquer problem set with proofs.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 18 May 2026 &middot; 23:59
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> Individual
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> PDF + source code zip
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">12<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a5: Technical Report Draft — due in 3d → soon --%>
            <li>
                <a data-action="open-assignment" data-course-code="ENG2001" data-row data-status="soon"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#f59e0b"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#f59e0b15;color:#f59e0b">ENG2001</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Technical Communication</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-amber-50 text-amber-700 border-amber-100" style="font-size:10.5px;font-weight:700">Due in 3d</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">Technical Report Draft</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">Submit the first draft of your technical report.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 22 May 2026 &middot; 23:59
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> Individual
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> DOCX &middot; 1500 words
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">10<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a6: Database Mid-term Project — due in 16d → ok --%>
            <li>
                <a data-action="open-assignment" data-course-code="CSC2103" data-row data-status="ok"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#0ea5e9"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#0ea5e915;color:#0ea5e9">CSC2103</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Database Systems</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-slate-50 text-slate-600 border-slate-200" style="font-size:10.5px;font-weight:700">Due in 16d</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">Database Mid-term Project</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">Normalize the schema and write 8 SQL analytical queries.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 04 Jun 2026 &middot; 23:59
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> Project
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> ZIP &middot; sql + report
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">20<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a7: User Story Mapping (Group) — submitted → ok --%>
            <li>
                <a data-action="open-assignment" data-course-code="CSC2104" data-row data-status="ok"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#e0162b"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#e0162b15;color:#e0162b">CSC2104</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Software Engineering</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-sky-50 text-sky-700 border-sky-100" style="font-size:10.5px;font-weight:700">Submitted</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">User Story Mapping (Group)</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">Group submission via Miro board export.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 28 Apr 2026 &middot; 22:14
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i> Group
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> Miro PDF export
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">10<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a8: Quiz 2 — Requirements — graded → ok --%>
            <li>
                <a data-action="open-assignment" data-course-code="CSC2104" data-row data-status="ok"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#e0162b"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#e0162b15;color:#e0162b">CSC2104</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Software Engineering</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-emerald-50 text-emerald-700 border-emerald-100" style="font-size:10.5px;font-weight:700">Graded</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">Quiz 2 &mdash; Requirements</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">20 MCQs on requirements engineering.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 22 Apr 2026 &middot; 14:30
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> Quiz
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> Online &middot; auto-graded
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">5<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <span class="inline-flex items-center gap-1 rounded border border-emerald-100 bg-emerald-50 px-2 py-0.5 text-emerald-700" style="font-size:11px;font-weight:700">
                                <i data-lucide="check-circle-2" class="h-3.5 w-3.5"></i> 85 / 100
                            </span>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a9: Quiz 1 — SDLC — graded → ok --%>
            <li>
                <a data-action="open-assignment" data-course-code="CSC2104" data-row data-status="ok"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#e0162b"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#e0162b15;color:#e0162b">CSC2104</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Software Engineering</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-emerald-50 text-emerald-700 border-emerald-100" style="font-size:10.5px;font-weight:700">Graded</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">Quiz 1 &mdash; SDLC</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">20 MCQs covering waterfall, agile, and Scrum.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 15 Apr 2026 &middot; 14:30
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> Quiz
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> Online &middot; auto-graded
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">5<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <span class="inline-flex items-center gap-1 rounded border border-emerald-100 bg-emerald-50 px-2 py-0.5 text-emerald-700" style="font-size:11px;font-weight:700">
                                <i data-lucide="check-circle-2" class="h-3.5 w-3.5"></i> 92 / 100
                            </span>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

            <%-- a10: Algebra of Sets — Quiz — graded → ok --%>
            <li>
                <a data-action="open-assignment" data-course-code="MTH2101" data-row data-status="ok"
                   href="#"
                   class="group flex w-full items-stretch gap-4 px-5 py-4 hover:bg-slate-50/80 transition-colors">
                    <span class="w-1 rounded-sm shrink-0" style="background-color:#10b981"></span>
                    <div class="flex flex-1 flex-col gap-2 lg:flex-row lg:items-center lg:gap-4">
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;background-color:#10b98115;color:#10b981">MTH2101</span>
                                <span class="text-slate-500 truncate" style="font-size:11.5px;font-weight:500">Discrete Mathematics</span>
                                <span class="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 bg-emerald-50 text-emerald-700 border-emerald-100" style="font-size:10.5px;font-weight:700">Graded</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 truncate" style="font-size:14px;font-weight:600">Algebra of Sets &mdash; Quiz</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:12.5px">Short quiz on union, intersection, and identities.</p>
                            <div class="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-slate-500" style="font-size:11.5px">
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-400"></i> 10 Apr 2026 &middot; 10:00
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> Quiz
                                </span>
                                <span class="inline-flex items-center gap-1">
                                    <i data-lucide="file-text" class="h-3.5 w-3.5 text-slate-400"></i> Online &middot; auto-graded
                                </span>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 lg:flex-col lg:items-end lg:gap-1.5">
                            <div class="flex flex-col items-start lg:items-end">
                                <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                                <p class="text-slate-900" style="font-size:15px;font-weight:700;letter-spacing:-0.005em">5<span class="text-slate-400" style="font-size:11px">%</span></p>
                            </div>
                            <span class="inline-flex items-center gap-1 rounded border border-emerald-100 bg-emerald-50 px-2 py-0.5 text-emerald-700" style="font-size:11px;font-weight:700">
                                <i data-lucide="check-circle-2" class="h-3.5 w-3.5"></i> 88 / 100
                            </span>
                            <i data-lucide="arrow-up-right" class="hidden h-4 w-4 text-slate-300 group-hover:text-[#e0162b] transition-colors lg:block"></i>
                        </div>
                    </div>
                </a>
            </li>

        </ul>

    </section>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/assignments/assignments.js") %>"></script>
</asp:Content>
