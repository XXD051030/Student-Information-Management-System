<%@ Page Language="C#" MasterPageFile="~/shared/DashboardLayout.master" AutoEventWireup="true" CodeBehind="timetable.aspx.cs" Inherits="student_information_management_system.timetable" Title="Timetable - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Title --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500">Academic schedule</p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Class timetable</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">
                Your weekly schedule for <span class="text-slate-900 font-semibold">Y2 &middot; Trimester 2 (Sep 2026)</span>.
            </p>
        </div>
        <div class="flex items-center gap-2">
            <span class="rounded-full bg-slate-100 px-3 py-1 text-slate-700" style="font-size:12px;font-weight:600">Y2 &middot; Trimester 2 (Sep 2026)</span>
            <button class="inline-flex items-center gap-2 rounded-xl bg-[#e0162b] px-4 h-10 text-white hover:bg-[#a01020] transition-colors shadow-[0_8px_20px_-8px_rgba(224,22,43,0.55)]"
                style="font-size:13px;font-weight:600">
                <i data-lucide="download" class="h-4 w-4"></i> Download PDF
            </button>
        </div>
    </div>

    <%-- Summary header --%>
    <section class="mt-6 rounded-lg border border-slate-200 bg-white">
        <div class="grid gap-0 sm:grid-cols-2 lg:grid-cols-4">

            <%-- Major --%>
            <div class="p-6 border-slate-100 border-b sm:border-b lg:border-b-0 lg:border-r">
                <div class="flex items-center gap-2 text-slate-500">
                    <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                        <i data-lucide="graduation-cap" class="h-4 w-4"></i>
                    </span>
                    <p style="font-size:11px;font-weight:600;letter-spacing:0.06em">MAJOR</p>
                </div>
                <p class="mt-2 text-slate-900" style="font-size:15px;font-weight:600;letter-spacing:-0.005em">BSc (Hons) Computer Science</p>
            </div>

            <%-- Courses taken --%>
            <div class="p-6 border-slate-100 border-b sm:border-b lg:border-b-0 lg:border-r">
                <div class="flex items-center gap-2 text-slate-500">
                    <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                        <i data-lucide="book-open" class="h-4 w-4"></i>
                    </span>
                    <p style="font-size:11px;font-weight:600;letter-spacing:0.06em">COURSES TAKEN</p>
                </div>
                <p class="mt-2 text-slate-900" style="font-size:15px;font-weight:600;letter-spacing:-0.005em">5</p>
            </div>

            <%-- Total credit hours --%>
            <div class="p-6 border-slate-100 border-b sm:border-b lg:border-b-0 lg:border-r">
                <div class="flex items-center gap-2 text-slate-500">
                    <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                        <i data-lucide="hash" class="h-4 w-4"></i>
                    </span>
                    <p style="font-size:11px;font-weight:600;letter-spacing:0.06em">TOTAL CREDIT HOURS</p>
                </div>
                <p class="mt-2 text-slate-900" style="font-size:15px;font-weight:600;letter-spacing:-0.005em">17 credits</p>
            </div>

            <%-- Weekly contact --%>
            <div class="p-6 border-slate-100">
                <div class="flex items-center gap-2 text-slate-500">
                    <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                        <i data-lucide="calendar" class="h-4 w-4"></i>
                    </span>
                    <p style="font-size:11px;font-weight:600;letter-spacing:0.06em">WEEKLY CONTACT</p>
                </div>
                <p class="mt-2 text-slate-900" style="font-size:15px;font-weight:600;letter-spacing:-0.005em">22 hrs</p>
            </div>
        </div>

        <%-- Courses this semester --%>
        <div class="border-t border-slate-100 p-6">
            <p class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.06em">COURSES THIS SEMESTER</p>
            <ul class="mt-3 grid gap-3 md:grid-cols-2 lg:grid-cols-3">

                <%-- CSC2104 --%>
                <li class="flex items-start gap-3 rounded-xl border border-slate-200 p-3">
                    <span class="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#e0162b15;color:#e0162b">
                        <i data-lucide="book-open" class="h-4 w-4"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2104</span>
                            <span class="rounded-md bg-slate-50 px-1.5 py-0.5 text-slate-500 border border-slate-200" style="font-size:10.5px;font-weight:600">4 cr</span>
                        </div>
                        <p class="mt-1 text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Software Engineering</p>
                        <p class="text-slate-500 truncate" style="font-size:12px">Dr. Lim Wei Jian</p>
                    </div>
                </li>

                <%-- CSC2103 --%>
                <li class="flex items-start gap-3 rounded-xl border border-slate-200 p-3">
                    <span class="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#0ea5e915;color:#0ea5e9">
                        <i data-lucide="book-open" class="h-4 w-4"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2103</span>
                            <span class="rounded-md bg-slate-50 px-1.5 py-0.5 text-slate-500 border border-slate-200" style="font-size:10.5px;font-weight:600">4 cr</span>
                        </div>
                        <p class="mt-1 text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Database Systems</p>
                        <p class="text-slate-500 truncate" style="font-size:12px">Ms. Tan Hui Ling</p>
                    </div>
                </li>

                <%-- CSC2202 --%>
                <li class="flex items-start gap-3 rounded-xl border border-slate-200 p-3">
                    <span class="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#8b5cf615;color:#8b5cf6">
                        <i data-lucide="book-open" class="h-4 w-4"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2202</span>
                            <span class="rounded-md bg-slate-50 px-1.5 py-0.5 text-slate-500 border border-slate-200" style="font-size:10.5px;font-weight:600">4 cr</span>
                        </div>
                        <p class="mt-1 text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Algorithms &amp; Complexity</p>
                        <p class="text-slate-500 truncate" style="font-size:12px">Dr. Rajesh Kumar</p>
                    </div>
                </li>

                <%-- MTH2101 --%>
                <li class="flex items-start gap-3 rounded-xl border border-slate-200 p-3">
                    <span class="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#10b98115;color:#10b981">
                        <i data-lucide="book-open" class="h-4 w-4"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">MTH2101</span>
                            <span class="rounded-md bg-slate-50 px-1.5 py-0.5 text-slate-500 border border-slate-200" style="font-size:10.5px;font-weight:600">3 cr</span>
                        </div>
                        <p class="mt-1 text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Discrete Mathematics</p>
                        <p class="text-slate-500 truncate" style="font-size:12px">Mr. Chong Kah Wai</p>
                    </div>
                </li>

                <%-- ENG2001 --%>
                <li class="flex items-start gap-3 rounded-xl border border-slate-200 p-3">
                    <span class="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#f59e0b15;color:#f59e0b">
                        <i data-lucide="book-open" class="h-4 w-4"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">ENG2001</span>
                            <span class="rounded-md bg-slate-50 px-1.5 py-0.5 text-slate-500 border border-slate-200" style="font-size:10.5px;font-weight:600">2 cr</span>
                        </div>
                        <p class="mt-1 text-slate-900 truncate" style="font-size:13.5px;font-weight:600">Technical Communication</p>
                        <p class="text-slate-500 truncate" style="font-size:12px">Ms. Aisha Rahman</p>
                    </div>
                </li>

            </ul>
        </div>
    </section>

    <%-- Timetable grid --%>
    <section class="mt-6 rounded-lg border border-slate-200 bg-white p-4 lg:p-6">
        <header class="flex items-center justify-between mb-4">
            <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Weekly schedule</h2>
            <p class="text-slate-500" style="font-size:12px">Mon &#8211; Fri &middot; 8:00 am &#8211; 6:00 pm</p>
        </header>

        <div class="overflow-x-auto">
            <div class="min-w-[920px] overflow-hidden rounded-md border border-slate-200 bg-white">

                <%-- Day header strip --%>
                <div class="grid border-b border-slate-200 bg-slate-50"
                    style="grid-template-columns:68px repeat(5, minmax(0, 1fr))">
                    <div class="px-3 py-3 text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.08em">TIME</div>

                    <%-- Monday --%>
                    <div class="flex items-center justify-between border-l border-slate-200 px-4 py-3">
                        <div>
                            <p class="text-slate-800" style="font-size:13px;font-weight:700;letter-spacing:0.01em">Monday</p>
                            <p class="text-slate-400" style="font-size:10.5px;font-weight:500">2 classes</p>
                        </div>
                    </div>

                    <%-- Tuesday --%>
                    <div class="flex items-center justify-between border-l border-slate-200 px-4 py-3">
                        <div>
                            <p class="text-slate-800" style="font-size:13px;font-weight:700;letter-spacing:0.01em">Tuesday</p>
                            <p class="text-slate-400" style="font-size:10.5px;font-weight:500">3 classes</p>
                        </div>
                    </div>

                    <%-- Wednesday --%>
                    <div class="flex items-center justify-between border-l border-slate-200 px-4 py-3">
                        <div>
                            <p class="text-slate-800" style="font-size:13px;font-weight:700;letter-spacing:0.01em">Wednesday</p>
                            <p class="text-slate-400" style="font-size:10.5px;font-weight:500">2 classes</p>
                        </div>
                    </div>

                    <%-- Thursday --%>
                    <div class="flex items-center justify-between border-l border-slate-200 px-4 py-3">
                        <div>
                            <p class="text-slate-800" style="font-size:13px;font-weight:700;letter-spacing:0.01em">Thursday</p>
                            <p class="text-slate-400" style="font-size:10.5px;font-weight:500">2 classes</p>
                        </div>
                    </div>

                    <%-- Friday --%>
                    <div class="flex items-center justify-between border-l border-slate-200 px-4 py-3">
                        <div>
                            <p class="text-slate-800" style="font-size:13px;font-weight:700;letter-spacing:0.01em">Friday</p>
                            <p class="text-slate-400" style="font-size:10.5px;font-weight:500">2 classes</p>
                        </div>
                    </div>
                </div>

                <%-- Grid body --%>
                <div class="grid relative" style="grid-template-columns:68px repeat(5, minmax(0, 1fr))">

                    <%-- Time gutter (8am–6pm = 11 rows × 80px = 880px) --%>
                    <div class="relative border-r border-slate-200" style="height:880px">
                        <div class="absolute right-3 text-slate-400" style="top:6px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">8am</div>
                        <div class="absolute right-3 text-slate-400" style="top:86px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">9am</div>
                        <div class="absolute right-3 text-slate-400" style="top:166px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">10am</div>
                        <div class="absolute right-3 text-slate-400" style="top:246px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">11am</div>
                        <div class="absolute right-3 text-slate-400" style="top:326px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">12pm</div>
                        <div class="absolute right-3 text-slate-400" style="top:406px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">1pm</div>
                        <div class="absolute right-3 text-slate-400" style="top:486px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">2pm</div>
                        <div class="absolute right-3 text-slate-400" style="top:566px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">3pm</div>
                        <div class="absolute right-3 text-slate-400" style="top:646px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">4pm</div>
                        <div class="absolute right-3 text-slate-400" style="top:726px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">5pm</div>
                        <div class="absolute right-3 text-slate-400" style="top:806px;font-size:10.5px;font-weight:600;letter-spacing:0.04em">6pm</div>
                    </div>

                    <%-- Monday column: CSC2104 9-11 Lecture, CSC2103 13-15 Lab --%>
                    <div class="relative border-l border-slate-200" style="height:880px">
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:80px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:160px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:240px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:320px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:400px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:480px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:560px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:640px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:720px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:800px"></div>
                        <%-- CSC2104 Lecture 9am-11am: top=(9-8)*80+4=84, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:84px;height:152px;background-color:#e0162b0F;border:1px solid #e0162b33;box-shadow:inset 3px 0 0 #e0162b">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#e0162b;color:white;letter-spacing:0.02em">CSC2104</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Lecture</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Software Engineering</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Dr. Lim Wei Jian
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block C &middot; C-3-04
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">9am&#8211;11am</p>
                        </div>
                        <%-- CSC2103 Lab 1pm-3pm: top=(13-8)*80+4=404, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:404px;height:152px;background-color:#0ea5e90F;border:1px solid #0ea5e933;box-shadow:inset 3px 0 0 #0ea5e9">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#0ea5e9;color:white;letter-spacing:0.02em">CSC2103</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Lab</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Database Systems</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Ms. Tan Hui Ling
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Lab B &middot; B-2-12
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">1pm&#8211;3pm</p>
                        </div>
                    </div>

                    <%-- Tuesday column: MTH2101 8-10, CSC2202 11-13, ENG2001 15-17 --%>
                    <div class="relative border-l border-slate-200" style="height:880px">
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:80px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:160px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:240px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:320px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:400px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:480px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:560px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:640px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:720px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:800px"></div>
                        <%-- MTH2101 Lecture 8am-10am: top=(8-8)*80+4=4, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:4px;height:152px;background-color:#10b9810F;border:1px solid #10b98133;box-shadow:inset 3px 0 0 #10b981">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#10b981;color:white;letter-spacing:0.02em">MTH2101</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Lecture</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Discrete Mathematics</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Mr. Chong Kah Wai
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block A &middot; A-1-08
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">8am&#8211;10am</p>
                        </div>
                        <%-- CSC2202 Lecture 11am-1pm: top=(11-8)*80+4=244, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:244px;height:152px;background-color:#8b5cf60F;border:1px solid #8b5cf633;box-shadow:inset 3px 0 0 #8b5cf6">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#8b5cf6;color:white;letter-spacing:0.02em">CSC2202</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Lecture</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Algorithms &amp; Complexity</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Dr. Rajesh Kumar
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block C &middot; C-2-01
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">11am&#8211;1pm</p>
                        </div>
                        <%-- ENG2001 Tutorial 3pm-5pm: top=(15-8)*80+4=564, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:564px;height:152px;background-color:#f59e0b0F;border:1px solid #f59e0b33;box-shadow:inset 3px 0 0 #f59e0b">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#f59e0b;color:white;letter-spacing:0.02em">ENG2001</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Tutorial</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Technical Communication</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Ms. Aisha Rahman
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block D &middot; D-1-05
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">3pm&#8211;5pm</p>
                        </div>
                    </div>

                    <%-- Wednesday column: CSC2104 10-12 Lab, CSC2202 14-16 Tutorial --%>
                    <div class="relative border-l border-slate-200" style="height:880px">
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:80px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:160px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:240px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:320px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:400px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:480px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:560px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:640px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:720px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:800px"></div>
                        <%-- CSC2104 Lab 10am-12pm: top=(10-8)*80+4=164, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:164px;height:152px;background-color:#e0162b0F;border:1px solid #e0162b33;box-shadow:inset 3px 0 0 #e0162b">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#e0162b;color:white;letter-spacing:0.02em">CSC2104</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Lab</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Software Engineering</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Dr. Lim Wei Jian
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Lab C &middot; C-3-09
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">10am&#8211;12pm</p>
                        </div>
                        <%-- CSC2202 Tutorial 2pm-4pm: top=(14-8)*80+4=484, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:484px;height:152px;background-color:#8b5cf60F;border:1px solid #8b5cf633;box-shadow:inset 3px 0 0 #8b5cf6">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#8b5cf6;color:white;letter-spacing:0.02em">CSC2202</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Tutorial</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Algorithms &amp; Complexity</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Dr. Rajesh Kumar
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block C &middot; C-2-01
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">2pm&#8211;4pm</p>
                        </div>
                    </div>

                    <%-- Thursday column: CSC2103 9-11 Lecture, MTH2101 13-15 Tutorial --%>
                    <div class="relative border-l border-slate-200" style="height:880px">
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:80px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:160px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:240px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:320px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:400px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:480px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:560px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:640px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:720px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:800px"></div>
                        <%-- CSC2103 Lecture 9am-11am: top=(9-8)*80+4=84, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:84px;height:152px;background-color:#0ea5e90F;border:1px solid #0ea5e933;box-shadow:inset 3px 0 0 #0ea5e9">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#0ea5e9;color:white;letter-spacing:0.02em">CSC2103</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Lecture</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Database Systems</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Ms. Tan Hui Ling
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block B &middot; B-3-02
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">9am&#8211;11am</p>
                        </div>
                        <%-- MTH2101 Tutorial 1pm-3pm: top=(13-8)*80+4=404, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:404px;height:152px;background-color:#10b9810F;border:1px solid #10b98133;box-shadow:inset 3px 0 0 #10b981">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#10b981;color:white;letter-spacing:0.02em">MTH2101</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Tutorial</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Discrete Mathematics</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Mr. Chong Kah Wai
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block A &middot; A-1-08
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">1pm&#8211;3pm</p>
                        </div>
                    </div>

                    <%-- Friday column: ENG2001 8-10 Lecture, CSC2104 11-13 Tutorial --%>
                    <div class="relative border-l border-slate-200" style="height:880px">
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:80px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:160px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:240px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:320px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:400px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:480px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:560px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:640px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:720px"></div>
                        <div class="absolute inset-x-0 border-t border-slate-100" style="top:800px"></div>
                        <%-- ENG2001 Lecture 8am-10am: top=(8-8)*80+4=4, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:4px;height:152px;background-color:#f59e0b0F;border:1px solid #f59e0b33;box-shadow:inset 3px 0 0 #f59e0b">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#f59e0b;color:white;letter-spacing:0.02em">ENG2001</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Lecture</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Technical Communication</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Ms. Aisha Rahman
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block D &middot; D-1-05
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">8am&#8211;10am</p>
                        </div>
                        <%-- CSC2104 Tutorial 11am-1pm: top=(11-8)*80+4=244, height=2*80-8=152 --%>
                        <div class="absolute left-2 right-2 rounded-md p-2.5 overflow-hidden"
                            style="top:244px;height:152px;background-color:#e0162b0F;border:1px solid #e0162b33;box-shadow:inset 3px 0 0 #e0162b">
                            <div class="flex items-center gap-1 flex-wrap">
                                <span class="rounded px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;background-color:#e0162b;color:white;letter-spacing:0.02em">CSC2104</span>
                                <span class="rounded border border-slate-200 bg-white/80 px-1.5 py-0.5 text-slate-600" style="font-size:9.5px;font-weight:600">Tutorial</span>
                            </div>
                            <p class="mt-1.5 text-slate-900 leading-tight" style="font-size:12px;font-weight:700">Software Engineering</p>
                            <p class="mt-1 text-slate-600 truncate flex items-center gap-1" style="font-size:10.5px;font-weight:500">
                                <i data-lucide="user" class="h-3 w-3 shrink-0 text-slate-400"></i> Dr. Lim Wei Jian
                            </p>
                            <p class="mt-0.5 text-slate-500 truncate flex items-center gap-1" style="font-size:10.5px">
                                <i data-lucide="map-pin" class="h-3 w-3 shrink-0 text-slate-400"></i> Block C &middot; C-3-04
                            </p>
                            <p class="absolute bottom-2 right-2 rounded border border-slate-200 bg-white/85 px-1.5 py-0.5 text-slate-700"
                                style="font-size:9.5px;font-weight:700">11am&#8211;1pm</p>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </section>

</asp:Content>
