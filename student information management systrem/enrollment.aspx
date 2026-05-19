<%@ Page Language="C#" MasterPageFile="~/DashboardLayout.master" AutoEventWireup="true" CodeBehind="enrollment.aspx.cs" Inherits="student_information_management_system.enrollment" Title="Course Enrollment - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- BODY PORTED FROM course-enrollment-page.tsx --%>

    <%-- Header --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500">Academic Year 2026 / 2027</p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Course Enrollment</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">
                Register for courses for <span class="text-slate-900 font-semibold">Y2 &middot; Trimester 2 (Sep 2026)</span>.
            </p>
        </div>
    </div>

    <%-- Phase banner --%>
    <section class="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50/60 p-5 lg:p-6">
        <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex items-center gap-3">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-600 text-white">
                    <i data-lucide="check-circle-2" class="h-5 w-5"></i>
                </div>
                <div>
                    <p class="text-emerald-700" style="font-size:11.5px;font-weight:700;letter-spacing:0.04em">ENROLLMENT OPEN</p>
                    <p class="mt-0.5 text-slate-900" style="font-size:15px;font-weight:600">Registration period &middot; 1 Aug &#8211; 20 Aug 2026</p>
                </div>
            </div>

            <%-- Phase timeline --%>
            <ol class="flex items-center gap-2">
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full bg-emerald-600 text-white" style="font-size:11px;font-weight:700">1</span>
                    <span class="hidden sm:inline text-slate-900" style="font-size:12px;font-weight:600">Registration period</span>
                    <span class="hidden sm:inline w-6 h-px bg-slate-300"></span>
                </li>
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full bg-white text-slate-400 ring-1 ring-slate-200" style="font-size:11px;font-weight:700">2</span>
                    <span class="hidden sm:inline text-slate-500" style="font-size:12px;font-weight:500">Add / Drop period</span>
                    <span class="hidden sm:inline w-6 h-px bg-slate-300"></span>
                </li>
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full bg-white text-slate-400 ring-1 ring-slate-200" style="font-size:11px;font-weight:700">3</span>
                    <span class="hidden sm:inline text-slate-500" style="font-size:12px;font-weight:500">Enrollment locked</span>
                </li>
            </ol>
        </div>
    </section>

    <%-- Stats --%>
    <section class="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
        <%-- Courses selected --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Courses Selected</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><span id="enroll-count">0</span></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">courses in basket</p>
        </div>
        <%-- Credits selected --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Credits Selected</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="shield-check" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><span id="enroll-credits">0</span></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">Limit: 12&#8211;21</p>
        </div>
        <%-- Total fee --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Estimated Fee</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="wallet" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">RM <span id="enroll-total">0</span></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">RM 150 / credit</p>
        </div>
        <%-- Already registered --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Already Registered</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="check-circle-2" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-emerald-600" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">3</p>
            <p class="mt-1 text-slate-400" style="font-size:12px">courses confirmed</p>
        </div>
    </section>

    <%-- Course list --%>
    <section class="mt-6 grid gap-3">

        <%-- CSC2201 — Database Systems (already registered) --%>
        <article class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:#0ea5e915;color:#0ea5e9">
                    <i data-lucide="book-open" class="h-5 w-5"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2201</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">4 credits</span>
                        <span class="inline-flex items-center gap-1 rounded-md bg-emerald-50 px-1.5 py-0.5 text-emerald-700" style="font-size:10.5px;font-weight:600">
                            <i data-lucide="check-circle-2" class="h-3 w-3"></i> Registered
                        </span>
                    </div>
                    <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Database Systems</h3>
                    <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Relational design, SQL, transactions, normalization, and NoSQL basics.</p>
                    <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i>Dr. Lim Wei Han</span>
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i>Mon 09:00&#8211;10:30 &middot; Wed 11:00&#8211;12:30</span>
                        <span class="inline-flex items-center gap-1.5">
                            <span class="h-3.5 w-3.5 rounded-full" style="background-color:#bbf7d0"></span>
                            Seats: 28/40
                        </span>
                    </div>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <span class="inline-flex items-center gap-1.5 rounded-xl bg-emerald-50 border border-emerald-200 px-3.5 h-10 text-emerald-700" style="font-size:13px;font-weight:600">
                        <i data-lucide="check-circle-2" class="h-4 w-4"></i> Registered
                    </span>
                </div>
            </div>
        </article>

        <%-- CSC2202 — Computer Networks (already registered) --%>
        <article class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:#6366f115;color:#6366f1">
                    <i data-lucide="book-open" class="h-5 w-5"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2202</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">3 credits</span>
                        <span class="inline-flex items-center gap-1 rounded-md bg-emerald-50 px-1.5 py-0.5 text-emerald-700" style="font-size:10.5px;font-weight:600">
                            <i data-lucide="check-circle-2" class="h-3 w-3"></i> Registered
                        </span>
                    </div>
                    <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Computer Networks</h3>
                    <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">OSI/TCP-IP models, routing, transport, and application protocols.</p>
                    <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i>Mr. Daniel Lee</span>
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i>Tue 10:00&#8211;11:30 &middot; Thu 14:00&#8211;15:30</span>
                        <span class="inline-flex items-center gap-1.5">
                            <span class="h-3.5 w-3.5 rounded-full" style="background-color:#fde68a"></span>
                            Seats: 32/35
                        </span>
                    </div>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <span class="inline-flex items-center gap-1.5 rounded-xl bg-emerald-50 border border-emerald-200 px-3.5 h-10 text-emerald-700" style="font-size:13px;font-weight:600">
                        <i data-lucide="check-circle-2" class="h-4 w-4"></i> Registered
                    </span>
                </div>
            </div>
        </article>

        <%-- CSC2203 — Operating Systems (already registered) --%>
        <article class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:#a855f715;color:#a855f7">
                    <i data-lucide="book-open" class="h-5 w-5"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2203</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">4 credits</span>
                        <span class="inline-flex items-center gap-1 rounded-md bg-emerald-50 px-1.5 py-0.5 text-emerald-700" style="font-size:10.5px;font-weight:600">
                            <i data-lucide="check-circle-2" class="h-3 w-3"></i> Registered
                        </span>
                    </div>
                    <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Operating Systems</h3>
                    <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Processes, threads, scheduling, memory, and file systems.</p>
                    <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i>Dr. Mei Lin</span>
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i>Mon 14:00&#8211;15:30 &middot; Fri 09:00&#8211;10:30</span>
                        <span class="inline-flex items-center gap-1.5">
                            <span class="h-3.5 w-3.5 rounded-full" style="background-color:#bbf7d0"></span>
                            Seats: 30/40
                        </span>
                    </div>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <span class="inline-flex items-center gap-1.5 rounded-xl bg-emerald-50 border border-emerald-200 px-3.5 h-10 text-emerald-700" style="font-size:13px;font-weight:600">
                        <i data-lucide="check-circle-2" class="h-4 w-4"></i> Registered
                    </span>
                </div>
            </div>
        </article>

        <%-- CSC2204 — Human-Computer Interaction (enrollable, no prereqs, seats available) --%>
        <label data-course-row data-code="CSC2204" data-name="Human&#8211;Computer Interaction" data-credits="3" data-fee="450"
               class="block rounded-2xl border border-slate-200 bg-white p-5 cursor-pointer hover:border-slate-300 hover:shadow-sm transition-all">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:#10b98115;color:#10b981">
                    <i data-lucide="book-open" class="h-5 w-5"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2204</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">3 credits</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">RM 450</span>
                    </div>
                    <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Human&#8211;Computer Interaction</h3>
                    <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Usability, design principles, prototyping, and user research methods.</p>
                    <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i>Ms. Sarah Choo</span>
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i>Wed 14:00&#8211;16:00</span>
                        <span class="inline-flex items-center gap-1.5">
                            <span class="h-3.5 w-3.5 rounded-full" style="background-color:#bbf7d0"></span>
                            Seats: 22/40
                        </span>
                    </div>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <input type="checkbox" data-action="toggle-enroll" data-code="CSC2204"
                           class="h-5 w-5 rounded border-slate-300 text-[#e0162b] accent-[#e0162b] cursor-pointer" />
                </div>
            </div>
        </label>

        <%-- CSC2205 — Mobile App Development (full, seats 40/40) --%>
        <article class="rounded-2xl border border-slate-200 bg-white p-5 opacity-70">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:#e0162b15;color:#e0162b">
                    <i data-lucide="book-open" class="h-5 w-5"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2205</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">3 credits</span>
                        <span class="inline-flex items-center gap-1 rounded-md bg-[#e0162b]/10 px-1.5 py-0.5 text-[#a01020]" style="font-size:10.5px;font-weight:600">
                            <i data-lucide="alert-circle" class="h-3 w-3"></i> Full
                        </span>
                    </div>
                    <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Mobile App Development</h3>
                    <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Cross-platform mobile development with React Native.</p>
                    <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i>Mr. Daniel Lee</span>
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i>Thu 09:00&#8211;11:00</span>
                        <span class="inline-flex items-center gap-1.5">
                            <span class="h-3.5 w-3.5 rounded-full" style="background-color:#fecaca"></span>
                            Seats: 40/40
                        </span>
                    </div>
                    <p class="mt-2 inline-flex items-center gap-1.5 text-[#a01020]" style="font-size:12px;font-weight:500">
                        <i data-lucide="info" class="h-3.5 w-3.5"></i>
                        Class is full &#8212; no seats available.
                    </p>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <button disabled class="inline-flex items-center gap-1.5 rounded-xl px-3.5 h-10 bg-slate-100 text-slate-400 cursor-not-allowed" style="font-size:13px;font-weight:600">
                        <i data-lucide="plus" class="h-4 w-4"></i> Add course
                    </button>
                </div>
            </div>
        </article>

        <%-- MTH2102 — Probability & Statistics (enrollable, prereq MTH1002 met) --%>
        <label data-course-row data-code="MTH2102" data-name="Probability &amp; Statistics" data-credits="3" data-fee="450"
               class="block rounded-2xl border border-slate-200 bg-white p-5 cursor-pointer hover:border-slate-300 hover:shadow-sm transition-all">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:#f59e0b15;color:#f59e0b">
                    <i data-lucide="book-open" class="h-5 w-5"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">MTH2102</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">3 credits</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">RM 450</span>
                    </div>
                    <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Probability &amp; Statistics</h3>
                    <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Probability theory, distributions, statistical inference for computing.</p>
                    <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i>Dr. Aravind P.</span>
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i>Tue 14:00&#8211;15:30 &middot; Fri 11:00&#8211;12:30</span>
                        <span class="inline-flex items-center gap-1.5">
                            <span class="h-3.5 w-3.5 rounded-full" style="background-color:#bbf7d0"></span>
                            Seats: 18/50
                        </span>
                    </div>
                    <p class="mt-2 text-slate-500" style="font-size:12px">
                        <span class="text-slate-400">Prerequisites:</span>
                        <span class="ml-1 rounded-md px-1.5 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:10.5px;font-weight:600">MTH1002</span>
                    </p>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <input type="checkbox" data-action="toggle-enroll" data-code="MTH2102"
                           class="h-5 w-5 rounded border-slate-300 text-[#e0162b] accent-[#e0162b] cursor-pointer" />
                </div>
            </div>
        </label>

        <%-- BUS2001 — Entrepreneurship & Innovation (enrollable, no prereqs) --%>
        <label data-course-row data-code="BUS2001" data-name="Entrepreneurship &amp; Innovation" data-credits="2" data-fee="300"
               class="block rounded-2xl border border-slate-200 bg-white p-5 cursor-pointer hover:border-slate-300 hover:shadow-sm transition-all">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:#0f766e15;color:#0f766e">
                    <i data-lucide="book-open" class="h-5 w-5"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">BUS2001</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">2 credits</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">RM 300</span>
                    </div>
                    <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Entrepreneurship &amp; Innovation</h3>
                    <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Lean startup, business model canvas, pitching to investors.</p>
                    <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i>Ms. Jenny Wong</span>
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i>Fri 15:00&#8211;17:00</span>
                        <span class="inline-flex items-center gap-1.5">
                            <span class="h-3.5 w-3.5 rounded-full" style="background-color:#bbf7d0"></span>
                            Seats: 14/60
                        </span>
                    </div>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <input type="checkbox" data-action="toggle-enroll" data-code="BUS2001"
                           class="h-5 w-5 rounded border-slate-300 text-[#e0162b] accent-[#e0162b] cursor-pointer" />
                </div>
            </div>
        </label>

        <%-- CSC3102 — Artificial Intelligence (blocked: prereq CSC2103 not completed) --%>
        <article class="rounded-2xl border border-slate-200 bg-white p-5 opacity-70">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style="background-color:#f59e0b15;color:#f59e0b">
                    <i data-lucide="book-open" class="h-5 w-5"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC3102</span>
                        <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">4 credits</span>
                    </div>
                    <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Artificial Intelligence</h3>
                    <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Search, knowledge representation, machine learning fundamentals.</p>
                    <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i>Dr. Aravind P.</span>
                        <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i>Mon 11:00&#8211;12:30 &middot; Thu 11:00&#8211;12:30</span>
                        <span class="inline-flex items-center gap-1.5">
                            <span class="h-3.5 w-3.5 rounded-full" style="background-color:#fecaca"></span>
                            Seats: 35/35
                        </span>
                    </div>
                    <p class="mt-2 text-slate-500" style="font-size:12px">
                        <span class="text-slate-400">Prerequisites:</span>
                        <span class="ml-1 rounded-md px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020]" style="font-size:10.5px;font-weight:600">CSC2103</span>
                        <span class="ml-1 rounded-md px-1.5 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:10.5px;font-weight:600">MTH2102</span>
                    </p>
                    <p class="mt-2 inline-flex items-center gap-1.5 text-[#a01020]" style="font-size:12px;font-weight:500">
                        <i data-lucide="info" class="h-3.5 w-3.5"></i>
                        Prerequisite not met: CSC2103
                    </p>
                </div>
                <div class="flex shrink-0 items-center gap-2">
                    <button disabled class="inline-flex items-center gap-1.5 rounded-xl px-3.5 h-10 bg-slate-100 text-slate-400 cursor-not-allowed" style="font-size:13px;font-weight:600">
                        <i data-lucide="plus" class="h-4 w-4"></i> Add course
                    </button>
                </div>
            </div>
        </article>

    </section>

    <%-- Submit / confirm enrollment --%>
    <section class="mt-6 flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 lg:flex-row lg:items-center lg:justify-between">
        <div>
            <p class="text-slate-900" style="font-size:14.5px;font-weight:600">Confirm enrollment</p>
            <p class="mt-0.5 text-slate-500" style="font-size:12.5px">
                You may add or drop courses during the Add/Drop period (1 &#8211; 14 Sep 2026).
            </p>
            <p class="mt-1 text-slate-500" style="font-size:12.5px">
                Selected: <span class="text-slate-900 font-semibold"><span id="enroll-count-footer">0</span> course(s)</span>
                &middot; <span class="text-slate-900 font-semibold"><span id="enroll-credits-footer">0</span> credits</span>
                &middot; <span class="text-slate-900 font-semibold">RM <span id="enroll-total-footer">0.00</span></span>
            </p>
        </div>
        <div class="flex items-center gap-2">
            <button data-action="proceed-to-payment" disabled id="enroll-submit"
                    class="inline-flex items-center gap-2 rounded-xl px-5 h-11 bg-slate-100 text-slate-400 cursor-not-allowed transition-all"
                    style="font-size:13.5px;font-weight:600">
                <i data-lucide="check-circle-2" class="h-4 w-4"></i>
                Proceed to Payment
            </button>
        </div>
    </section>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/enrollment/enrollment.js") %>"></script>
</asp:Content>
