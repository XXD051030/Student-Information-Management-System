<%@ Page Language="C#" MasterPageFile="~/DashboardLayout.master" AutoEventWireup="true" CodeBehind="grades.aspx.cs" Inherits="student_information_management_system.grades" Title="Grades - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500">Academic record</p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Grades</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">
                Your performance across courses and semesters.
            </p>
        </div>
        <div class="flex items-center gap-2">
            <span class="inline-flex items-center gap-2 rounded-full bg-slate-100 px-3 py-1 text-slate-700" style="font-size:12px;font-weight:600">
                <i data-lucide="calendar" class="h-3.5 w-3.5"></i>
                All semesters
            </span>
            <button class="inline-flex items-center gap-2 rounded-md border border-slate-200 bg-white px-3 h-10 text-slate-700 hover:bg-slate-50 transition-colors" style="font-size:13px;font-weight:600">
                <i data-lucide="download" class="h-4 w-4"></i> Transcript
            </button>
        </div>
    </div>

    <%-- Headline KPIs --%>
    <section class="mt-6 grid gap-4 lg:grid-cols-4">
        <%-- CGPA hero --%>
        <div class="lg:col-span-2 rounded-lg border border-slate-200 bg-gradient-to-br from-[#e0162b] to-[#a01020] p-6 text-white relative overflow-hidden">
            <div class="pointer-events-none absolute -top-10 -right-10 h-48 w-48 rounded-full bg-white/10 blur-3xl"></div>
            <div class="relative flex items-start justify-between">
                <div>
                    <p class="text-white/80" style="font-size:11.5px;font-weight:600;letter-spacing:0.08em">CGPA &middot; FILTERED</p>
                    <p class="mt-2 text-white" style="font-size:56px;font-weight:800;letter-spacing:-0.02em;line-height:1">3.96</p>
                    <p class="mt-2 text-white/80" style="font-size:13px">out of 4.00 &middot; across 4 semesters</p>
                </div>
                <span class="inline-flex items-center gap-1 rounded border bg-white/15 backdrop-blur px-2.5 py-1 text-white border-white/25" style="font-size:11.5px;font-weight:700">
                    <i data-lucide="trophy" class="h-3.5 w-3.5"></i> First Class
                </span>
            </div>
            <div class="mt-5 grid grid-cols-2 gap-4 border-t border-white/15 pt-4">
                <div>
                    <p class="text-white/70" style="font-size:11px;font-weight:600;letter-spacing:0.06em">CREDITS EARNED</p>
                    <p class="mt-1 text-white" style="font-size:20px;font-weight:700">50<span class="text-white/60" style="font-size:13px"> / 50</span></p>
                </div>
                <div>
                    <p class="text-white/70" style="font-size:11px;font-weight:600;letter-spacing:0.06em">CURRENT GPA</p>
                    <p class="mt-1 text-white" style="font-size:20px;font-weight:700">4.00<span class="text-white/60" style="font-size:13px"> &middot; Y2 T2</span></p>
                </div>
            </div>
        </div>

        <%-- Stat: Best semester --%>
        <div class="rounded-lg border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2 text-slate-500">
                <span class="flex h-7 w-7 items-center justify-center rounded-md bg-slate-100 text-slate-600">
                    <i data-lucide="trending-up" class="h-4 w-4"></i>
                </span>
                <p style="font-size:11px;font-weight:600;letter-spacing:0.06em">BEST SEMESTER</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">Y2 T2</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">GPA 4.00</p>
        </div>

        <%-- Stat: Courses graded --%>
        <div class="rounded-lg border border-slate-200 bg-white p-5">
            <div class="flex items-center gap-2 text-slate-500">
                <span class="flex h-7 w-7 items-center justify-center rounded-md bg-slate-100 text-slate-600">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </span>
                <p style="font-size:11px;font-weight:600;letter-spacing:0.06em">COURSES GRADED</p>
            </div>
            <p class="mt-2 text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">16</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">Within filter</p>
        </div>
    </section>

    <%-- Charts (rendered as static lists since recharts cannot port) --%>
    <section class="mt-6 grid gap-4 lg:grid-cols-5">
        <%-- GPA per semester --%>
        <div class="lg:col-span-3 rounded-lg border border-slate-200 bg-white p-6">
            <header class="flex items-center justify-between">
                <div>
                    <h2 class="text-slate-900" style="font-size:15px;font-weight:600">GPA per semester</h2>
                    <p class="text-slate-500 mt-0.5" style="font-size:12.5px">Per-semester GPA across your studies</p>
                </div>
                <span class="inline-flex items-center gap-1.5 text-slate-500" style="font-size:11.5px">
                    <span class="h-2.5 w-2.5 rounded-sm bg-[#e0162b]"></span> GPA (0&ndash;4)
                </span>
            </header>
            <ul class="mt-5 space-y-3">
                <li class="grid grid-cols-12 items-center gap-3">
                    <span class="col-span-2 text-slate-700" style="font-size:12.5px;font-weight:600">Y1 T1</span>
                    <div class="col-span-8 h-3 rounded-full bg-slate-100 overflow-hidden">
                        <div class="h-full rounded-full bg-[#e0162b]" style="width:100%"></div>
                    </div>
                    <span class="col-span-2 text-right text-slate-900" style="font-size:13px;font-weight:700">4.00</span>
                </li>
                <li class="grid grid-cols-12 items-center gap-3">
                    <span class="col-span-2 text-slate-700" style="font-size:12.5px;font-weight:600">Y1 T2</span>
                    <div class="col-span-8 h-3 rounded-full bg-slate-100 overflow-hidden">
                        <div class="h-full rounded-full bg-[#e0162b]" style="width:97.75%"></div>
                    </div>
                    <span class="col-span-2 text-right text-slate-900" style="font-size:13px;font-weight:700">3.91</span>
                </li>
                <li class="grid grid-cols-12 items-center gap-3">
                    <span class="col-span-2 text-slate-700" style="font-size:12.5px;font-weight:600">Y2 T1</span>
                    <div class="col-span-8 h-3 rounded-full bg-slate-100 overflow-hidden">
                        <div class="h-full rounded-full bg-[#e0162b]" style="width:98.25%"></div>
                    </div>
                    <span class="col-span-2 text-right text-slate-900" style="font-size:13px;font-weight:700">3.93</span>
                </li>
                <li class="grid grid-cols-12 items-center gap-3">
                    <span class="col-span-2 text-slate-700" style="font-size:12.5px;font-weight:600">Y2 T2</span>
                    <div class="col-span-8 h-3 rounded-full bg-slate-100 overflow-hidden">
                        <div class="h-full rounded-full bg-[#e0162b]" style="width:100%"></div>
                    </div>
                    <span class="col-span-2 text-right text-slate-900" style="font-size:13px;font-weight:700">4.00</span>
                </li>
            </ul>
        </div>

        <%-- Grade distribution --%>
        <div class="lg:col-span-2 rounded-lg border border-slate-200 bg-white p-6">
            <header class="flex items-center justify-between">
                <div>
                    <h2 class="text-slate-900" style="font-size:15px;font-weight:600">Grade distribution</h2>
                    <p class="text-slate-500 mt-0.5" style="font-size:12.5px">Letter grades within filter</p>
                </div>
            </header>
            <ul class="mt-5 space-y-3">
                <li class="grid grid-cols-12 items-center gap-3">
                    <span class="col-span-3 inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A+</span>
                    <div class="col-span-7 h-3 rounded-full bg-slate-100 overflow-hidden">
                        <div class="h-full rounded-full" style="width:7.69%;background-color:#10b981"></div>
                    </div>
                    <span class="col-span-2 text-right text-slate-900" style="font-size:12.5px;font-weight:700">1</span>
                </li>
                <li class="grid grid-cols-12 items-center gap-3">
                    <span class="col-span-3 inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                    <div class="col-span-7 h-3 rounded-full bg-slate-100 overflow-hidden">
                        <div class="h-full rounded-full" style="width:100%;background-color:#10b981"></div>
                    </div>
                    <span class="col-span-2 text-right text-slate-900" style="font-size:12.5px;font-weight:700">13</span>
                </li>
                <li class="grid grid-cols-12 items-center gap-3">
                    <span class="col-span-3 inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A-</span>
                    <div class="col-span-7 h-3 rounded-full bg-slate-100 overflow-hidden">
                        <div class="h-full rounded-full" style="width:15.38%;background-color:#10b981"></div>
                    </div>
                    <span class="col-span-2 text-right text-slate-900" style="font-size:12.5px;font-weight:700">2</span>
                </li>
            </ul>
        </div>
    </section>

    <%-- Semester sections --%>
    <section class="mt-6 space-y-6">

        <%-- Y2T2 (current) --%>
        <div class="rounded-lg border border-slate-200 bg-white">
            <header class="flex flex-col gap-3 border-b border-slate-100 p-5 lg:flex-row lg:items-center lg:justify-between">
                <div>
                    <div class="flex items-center gap-2">
                        <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Year 2 &middot; Trimester 2 (May 2026)</h2>
                        <span class="rounded bg-[#e0162b]/10 text-[#a01020] px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">CURRENT</span>
                    </div>
                    <p class="text-slate-500 mt-0.5" style="font-size:12.5px">4 courses &middot; 13 credits</p>
                </div>
                <div class="flex items-center gap-5">
                    <div>
                        <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">GPA</p>
                        <p class="text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">4.00</p>
                    </div>
                    <div>
                        <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">EARNED</p>
                        <p class="text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">13<span class="text-slate-400" style="font-size:12px"> cr</span></p>
                    </div>
                </div>
            </header>
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead>
                        <tr class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.04em">
                            <th class="text-left px-5 py-3">COURSE</th>
                            <th class="text-center px-2 py-3">CREDITS</th>
                            <th class="text-center px-2 py-3">CURRENT</th>
                            <th class="text-center px-2 py-3">FINAL EXAM</th>
                            <th class="text-center px-2 py-3">GRADE</th>
                            <th class="text-right px-5 py-3">GP</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#e0162b"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">CSC2104</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Software Engineering</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Dr. Lim Wei Jian</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">4</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">82.6</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">45% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="rounded bg-slate-50 border border-slate-200 text-slate-500 px-1.5 py-0.5" style="font-size:10.5px;font-weight:600">Pending</span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#0ea5e9"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">CSC2103</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Database Systems</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Ms. Tan Hui Ling</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">4</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">85.4</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">35% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="rounded bg-slate-50 border border-slate-200 text-slate-500 px-1.5 py-0.5" style="font-size:10.5px;font-weight:600">Pending</span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#10b981"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">MTH2101</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Discrete Mathematics</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Mr. Chong Kah Wai</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">3</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">87.3</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">55% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="rounded bg-slate-50 border border-slate-200 text-slate-500 px-1.5 py-0.5" style="font-size:10.5px;font-weight:600">Pending</span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#f59e0b"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">ENG2001</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Technical Communication</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Ms. Aisha Rahman</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">2</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">86.0</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">20% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="rounded bg-slate-50 border border-slate-200 text-slate-500 px-1.5 py-0.5" style="font-size:10.5px;font-weight:600">Pending</span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- Y2T1 (completed) --%>
        <div class="rounded-lg border border-slate-200 bg-white">
            <header class="flex flex-col gap-3 border-b border-slate-100 p-5 lg:flex-row lg:items-center lg:justify-between">
                <div>
                    <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Year 2 &middot; Trimester 1 (Jan 2026)</h2>
                    <p class="text-slate-500 mt-0.5" style="font-size:12.5px">4 courses &middot; 14 credits</p>
                </div>
                <div class="flex items-center gap-5">
                    <div>
                        <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">GPA</p>
                        <p class="text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">3.93</p>
                    </div>
                    <div>
                        <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">EARNED</p>
                        <p class="text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">14<span class="text-slate-400" style="font-size:12px"> cr</span></p>
                    </div>
                </div>
            </header>
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead>
                        <tr class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.04em">
                            <th class="text-left px-5 py-3">COURSE</th>
                            <th class="text-center px-2 py-3">CREDITS</th>
                            <th class="text-center px-2 py-3">CURRENT</th>
                            <th class="text-center px-2 py-3">FINAL EXAM</th>
                            <th class="text-center px-2 py-3">GRADE</th>
                            <th class="text-right px-5 py-3">GP</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#e0162b"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">CSC2101</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Object-Oriented Programming</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Dr. Lim Wei Jian</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">4</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">89.2</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">88<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#0ea5e9"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">CSC2102</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Data Structures</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Ms. Tan Hui Ling</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">4</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">83.9</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">82<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#10b981"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">MTH2001</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Linear Algebra</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Mr. Chong Kah Wai</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">3</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">75.2</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">74<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A-</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">3.67</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#8b5cf6"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">BUS2001</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Business Fundamentals</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Ms. Nurul Iman</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">3</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">84.0</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">81<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- Y1T2 (completed) --%>
        <div class="rounded-lg border border-slate-200 bg-white">
            <header class="flex flex-col gap-3 border-b border-slate-100 p-5 lg:flex-row lg:items-center lg:justify-between">
                <div>
                    <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Year 1 &middot; Trimester 2 (Sep 2025)</h2>
                    <p class="text-slate-500 mt-0.5" style="font-size:12.5px">4 courses &middot; 11 credits</p>
                </div>
                <div class="flex items-center gap-5">
                    <div>
                        <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">GPA</p>
                        <p class="text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">3.91</p>
                    </div>
                    <div>
                        <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">EARNED</p>
                        <p class="text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">11<span class="text-slate-400" style="font-size:12px"> cr</span></p>
                    </div>
                </div>
            </header>
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead>
                        <tr class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.04em">
                            <th class="text-left px-5 py-3">COURSE</th>
                            <th class="text-center px-2 py-3">CREDITS</th>
                            <th class="text-center px-2 py-3">CURRENT</th>
                            <th class="text-center px-2 py-3">FINAL EXAM</th>
                            <th class="text-center px-2 py-3">GRADE</th>
                            <th class="text-right px-5 py-3">GP</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#e0162b"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">CSC1102</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Programming Fundamentals II</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Mr. Daniel Tan</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">4</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">87.7</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">87<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#10b981"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">MTH1002</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Calculus II</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Ms. Aisha Rahman</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">3</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">76.4</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">76<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A-</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">3.67</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#f59e0b"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">ENG1001</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">English for Academic Use</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Ms. Joanne Lee</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">2</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">82.8</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">80<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#0ea5e9"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">GEN1001</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Critical Thinking</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Mr. Hafiz Zulkifli</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">2</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">88.6</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">85<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- Y1T1 (completed) --%>
        <div class="rounded-lg border border-slate-200 bg-white">
            <header class="flex flex-col gap-3 border-b border-slate-100 p-5 lg:flex-row lg:items-center lg:justify-between">
                <div>
                    <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Year 1 &middot; Trimester 1 (May 2025)</h2>
                    <p class="text-slate-500 mt-0.5" style="font-size:12.5px">4 courses &middot; 12 credits</p>
                </div>
                <div class="flex items-center gap-5">
                    <div>
                        <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">GPA</p>
                        <p class="text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">4.00</p>
                    </div>
                    <div>
                        <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">EARNED</p>
                        <p class="text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">12<span class="text-slate-400" style="font-size:12px"> cr</span></p>
                    </div>
                </div>
            </header>
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead>
                        <tr class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.04em">
                            <th class="text-left px-5 py-3">COURSE</th>
                            <th class="text-center px-2 py-3">CREDITS</th>
                            <th class="text-center px-2 py-3">CURRENT</th>
                            <th class="text-center px-2 py-3">FINAL EXAM</th>
                            <th class="text-center px-2 py-3">GRADE</th>
                            <th class="text-right px-5 py-3">GP</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#e0162b"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">CSC1101</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Programming Fundamentals I</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Mr. Daniel Tan</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">4</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">91.2</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">92<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A+</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#10b981"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">MTH1001</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Calculus I</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Ms. Aisha Rahman</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">3</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">80.4</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">80<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#8b5cf6"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">GEN1002</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Malaysian Studies</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Mr. Hafiz Zulkifli</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">3</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">85.0</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">82<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                        <tr>
                            <td class="px-5 py-3.5">
                                <div class="flex items-center gap-3">
                                    <span class="h-9 w-1 rounded-sm shrink-0" style="background-color:#0ea5e9"></span>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2">
                                            <span class="rounded bg-slate-100 text-slate-600 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700">ICT1001</span>
                                            <span class="text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Introduction to ICT</span>
                                        </div>
                                        <p class="text-slate-500 truncate mt-0.5" style="font-size:11.5px">Ms. Tan Hui Ling</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center text-slate-700" style="font-size:12.5px;font-weight:600">2</td>
                            <td class="px-2 py-3.5 text-center">
                                <div>
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:700">89.8</span><span class="text-slate-400" style="font-size:11px">%</span>
                                    <p class="text-slate-400" style="font-size:10.5px">100% graded</p>
                                </div>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="text-slate-900" style="font-size:12.5px;font-weight:600">88<span class="text-slate-400" style="font-size:10.5px"> /100</span></span>
                            </td>
                            <td class="px-2 py-3.5 text-center">
                                <span class="inline-flex items-center justify-center rounded border px-2 py-0.5" style="font-size:12px;font-weight:700;background-color:#10b98115;border-color:#10b98140;color:#10b981">A</span>
                            </td>
                            <td class="px-5 py-3.5 text-right text-slate-900" style="font-size:13.5px;font-weight:700">4.00</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </section>

</asp:Content>
