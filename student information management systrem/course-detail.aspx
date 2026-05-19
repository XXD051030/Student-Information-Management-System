<%@ Page Language="C#" MasterPageFile="~/DashboardLayout.master" AutoEventWireup="true" CodeBehind="course-detail.aspx.cs" Inherits="student_information_management_system.course_detail" Title="Course Detail - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Breadcrumb / back --%>
    <a href="courses.aspx" class="inline-flex items-center gap-1.5 text-slate-500 hover:text-slate-900 transition-colors" style="font-size:13px;font-weight:500">
        <i data-lucide="arrow-left" class="h-3.5 w-3.5"></i> Back to My Courses
    </a>

    <%-- Course header — CSC2104 Software Engineering --%>
    <section class="relative mt-4 overflow-hidden rounded-3xl p-7 lg:p-9 text-white" style="background:linear-gradient(135deg,#e0162b 0%,#1e293b 100%)">
        <div class="pointer-events-none absolute -top-16 -right-10 h-64 w-64 rounded-full bg-white/10 blur-3xl"></div>
        <div class="relative flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
            <div class="max-w-2xl">
                <div class="flex items-center gap-2">
                    <span class="rounded-md bg-white/15 px-2 py-0.5 backdrop-blur" style="font-size:11px;font-weight:600;letter-spacing:0.04em">CSC2104</span>
                    <span class="text-white/70" style="font-size:12px">Y2 &middot; Trimester 1</span>
                </div>
                <h1 class="mt-3 text-white" style="font-size:30px;font-weight:700;letter-spacing:-0.015em;line-height:1.15">
                    Software Engineering
                </h1>
                <p class="mt-2 text-white/80 max-w-xl" style="font-size:14.5px;line-height:1.6">
                    Software lifecycle, requirements, agile, testing, and team collaboration.
                </p>
                <div class="mt-4 flex flex-wrap gap-x-5 gap-y-1 text-white/80" style="font-size:13px">
                    <span>&#128100; Dr. Lim Wei Han</span>
                    <span>&#127891; 4 credits</span>
                    <span>&#128218; 12 modules</span>
                </div>
            </div>
            <div class="shrink-0">
                <button data-action="toggle-pin" data-code="CSC2104"
                    class="inline-flex items-center gap-2 rounded-2xl border border-white/25 bg-white/10 px-5 py-2.5 text-white backdrop-blur hover:bg-white/20 transition-colors"
                    style="font-size:13px;font-weight:600" aria-label="Toggle pin">
                    <i data-lucide="pin" class="h-4 w-4"></i>
                    Pin course
                </button>
            </div>
        </div>
    </section>

    <%-- Tab navigation --%>
    <nav class="mt-6 border-b border-slate-200">
        <ul class="flex gap-1 overflow-x-auto">
            <li>
                <button data-action="switch-tab" data-tab="modules" data-active="true"
                    class="relative inline-flex items-center gap-2 px-4 py-3 transition-colors text-[#e0162b] data-[active=true]:text-[#e0162b] data-[active=false]:text-slate-500 data-[active=false]:hover:text-slate-900"
                    style="font-size:13.5px;font-weight:600">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                    Modules
                    <span class="tab-indicator absolute inset-x-2 -bottom-px h-0.5 rounded-full bg-[#e0162b]"></span>
                </button>
            </li>
            <li>
                <button data-action="switch-tab" data-tab="announcements" data-active="false"
                    class="relative inline-flex items-center gap-2 px-4 py-3 transition-colors text-slate-500 hover:text-slate-900"
                    style="font-size:13.5px;font-weight:600">
                    <i data-lucide="megaphone" class="h-4 w-4"></i>
                    Announcements
                    <span class="tab-indicator absolute inset-x-2 -bottom-px h-0.5 rounded-full bg-[#e0162b] hidden"></span>
                </button>
            </li>
            <li>
                <button data-action="switch-tab" data-tab="assignments" data-active="false"
                    class="relative inline-flex items-center gap-2 px-4 py-3 transition-colors text-slate-500 hover:text-slate-900"
                    style="font-size:13.5px;font-weight:600">
                    <i data-lucide="clipboard-list" class="h-4 w-4"></i>
                    Assignments
                    <span class="tab-indicator absolute inset-x-2 -bottom-px h-0.5 rounded-full bg-[#e0162b] hidden"></span>
                </button>
            </li>
            <li>
                <button data-action="switch-tab" data-tab="grades" data-active="false"
                    class="relative inline-flex items-center gap-2 px-4 py-3 transition-colors text-slate-500 hover:text-slate-900"
                    style="font-size:13.5px;font-weight:600">
                    <i data-lucide="graduation-cap" class="h-4 w-4"></i>
                    Grades
                    <span class="tab-indicator absolute inset-x-2 -bottom-px h-0.5 rounded-full bg-[#e0162b] hidden"></span>
                </button>
            </li>
        </ul>
    </nav>

    <%-- Tab content --%>
    <section class="mt-6">

        <%-- ==================== MODULES PANE ==================== --%>
        <div data-pane="modules">
            <div class="grid gap-6 lg:grid-cols-3">

                <%-- Module accordion --%>
                <div class="lg:col-span-2 rounded-2xl border border-slate-200 bg-white">
                    <header class="flex items-center justify-between p-6 pb-4">
                        <div>
                            <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Course Modules</h2>
                            <p class="text-slate-500 mt-0.5" style="font-size:13px">12 weekly modules &middot; materials updated weekly</p>
                        </div>
                    </header>
                    <ul class="divide-y divide-slate-100" id="module-accordion">

                        <%-- Week 1 --%>
                        <li>
                            <button data-action="toggle-module" data-week="1"
                                class="flex w-full items-center gap-4 px-6 py-4 hover:bg-slate-50/60 transition-colors text-left">
                                <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#e0162b15;color:#e0162b;font-size:12px;font-weight:700">1</span>
                                <div class="min-w-0 flex-1">
                                    <p class="text-slate-900 truncate" style="font-size:14px;font-weight:600">Introduction &amp; Course Overview</p>
                                    <p class="text-slate-500 mt-0.5 truncate" style="font-size:12.5px">Course logistics, learning outcomes, assessment plan.</p>
                                </div>
                                <span class="text-slate-400" style="font-size:11.5px;font-weight:600">3 items</span>
                                <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 transition-transform module-chevron" data-open="true" style="transform:rotate(90deg)"></i>
                            </button>
                            <ul class="bg-slate-50/50 px-6 pb-4 module-items" data-week="1">
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
                                        <i data-lucide="paperclip" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">01-introduction.pptx</p>
                                        <p class="text-slate-400" style="font-size:11px">3.4 MB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-rose-50 text-rose-600">
                                        <i data-lucide="play-circle" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">Welcome video (12 min)</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                                        <i data-lucide="file-text" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">Syllabus.pdf</p>
                                        <p class="text-slate-400" style="font-size:11px">240 KB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                            </ul>
                        </li>

                        <%-- Week 2 --%>
                        <li>
                            <button data-action="toggle-module" data-week="2"
                                class="flex w-full items-center gap-4 px-6 py-4 hover:bg-slate-50/60 transition-colors text-left">
                                <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#e0162b15;color:#e0162b;font-size:12px;font-weight:700">2</span>
                                <div class="min-w-0 flex-1">
                                    <p class="text-slate-900 truncate" style="font-size:14px;font-weight:600">Software Development Lifecycle</p>
                                    <p class="text-slate-500 mt-0.5 truncate" style="font-size:12.5px">Waterfall, iterative, agile &mdash; when each fits.</p>
                                </div>
                                <span class="text-slate-400" style="font-size:11.5px;font-weight:600">2 items</span>
                                <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 transition-transform module-chevron" data-open="false"></i>
                            </button>
                            <ul class="bg-slate-50/50 px-6 pb-4 module-items hidden" data-week="2">
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
                                        <i data-lucide="paperclip" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">02-sdlc.pptx</p>
                                        <p class="text-slate-400" style="font-size:11px">5.1 MB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                                        <i data-lucide="file-text" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">Reading: Pressman ch.2</p>
                                        <p class="text-slate-400" style="font-size:11px">1.2 MB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                            </ul>
                        </li>

                        <%-- Week 3 --%>
                        <li>
                            <button data-action="toggle-module" data-week="3"
                                class="flex w-full items-center gap-4 px-6 py-4 hover:bg-slate-50/60 transition-colors text-left">
                                <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#e0162b15;color:#e0162b;font-size:12px;font-weight:700">3</span>
                                <div class="min-w-0 flex-1">
                                    <p class="text-slate-900 truncate" style="font-size:14px;font-weight:600">Requirements Engineering</p>
                                    <p class="text-slate-500 mt-0.5 truncate" style="font-size:12.5px">Elicitation, user stories, acceptance criteria.</p>
                                </div>
                                <span class="text-slate-400" style="font-size:11.5px;font-weight:600">3 items</span>
                                <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 transition-transform module-chevron" data-open="false"></i>
                            </button>
                            <ul class="bg-slate-50/50 px-6 pb-4 module-items hidden" data-week="3">
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
                                        <i data-lucide="paperclip" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">03-requirements.pptx</p>
                                        <p class="text-slate-400" style="font-size:11px">4.0 MB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-rose-50 text-rose-600">
                                        <i data-lucide="play-circle" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">Stakeholder interviews (18 min)</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                                        <i data-lucide="file-text" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">User-stories-template.docx</p>
                                        <p class="text-slate-400" style="font-size:11px">60 KB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                            </ul>
                        </li>

                        <%-- Week 4 --%>
                        <li>
                            <button data-action="toggle-module" data-week="4"
                                class="flex w-full items-center gap-4 px-6 py-4 hover:bg-slate-50/60 transition-colors text-left">
                                <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#e0162b15;color:#e0162b;font-size:12px;font-weight:700">4</span>
                                <div class="min-w-0 flex-1">
                                    <p class="text-slate-900 truncate" style="font-size:14px;font-weight:600">Agile &amp; Scrum</p>
                                    <p class="text-slate-500 mt-0.5 truncate" style="font-size:12.5px">Sprints, ceremonies, roles, scaling agile.</p>
                                </div>
                                <span class="text-slate-400" style="font-size:11.5px;font-weight:600">2 items</span>
                                <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 transition-transform module-chevron" data-open="false"></i>
                            </button>
                            <ul class="bg-slate-50/50 px-6 pb-4 module-items hidden" data-week="4">
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
                                        <i data-lucide="paperclip" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">04-agile.pptx</p>
                                        <p class="text-slate-400" style="font-size:11px">4.6 MB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                                        <i data-lucide="file-text" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">Scrum-guide.pdf</p>
                                        <p class="text-slate-400" style="font-size:11px">1.8 MB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                            </ul>
                        </li>

                        <%-- Week 5 --%>
                        <li>
                            <button data-action="toggle-module" data-week="5"
                                class="flex w-full items-center gap-4 px-6 py-4 hover:bg-slate-50/60 transition-colors text-left">
                                <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg" style="background-color:#e0162b15;color:#e0162b;font-size:12px;font-weight:700">5</span>
                                <div class="min-w-0 flex-1">
                                    <p class="text-slate-900 truncate" style="font-size:14px;font-weight:600">Software Architecture</p>
                                    <p class="text-slate-500 mt-0.5 truncate" style="font-size:12.5px">Layered, microservices, event-driven patterns.</p>
                                </div>
                                <span class="text-slate-400" style="font-size:11.5px;font-weight:600">2 items</span>
                                <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 transition-transform module-chevron" data-open="false"></i>
                            </button>
                            <ul class="bg-slate-50/50 px-6 pb-4 module-items hidden" data-week="5">
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
                                        <i data-lucide="paperclip" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">05-architecture.pptx</p>
                                        <p class="text-slate-400" style="font-size:11px">6.8 MB</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                                <li class="ml-12 flex items-center gap-3 rounded-xl px-3 py-2.5 hover:bg-white transition-colors">
                                    <span class="flex h-8 w-8 items-center justify-center rounded-lg bg-rose-50 text-rose-600">
                                        <i data-lucide="play-circle" class="h-4 w-4"></i>
                                    </span>
                                    <div class="min-w-0 flex-1">
                                        <p class="text-slate-900 truncate" style="font-size:13px;font-weight:500">Architecture deep-dive (24 min)</p>
                                    </div>
                                    <button class="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition-colors" aria-label="Download">
                                        <i data-lucide="download" class="h-4 w-4"></i>
                                    </button>
                                </li>
                            </ul>
                        </li>

                    </ul>
                </div>

                <%-- Course details sidebar --%>
                <aside class="rounded-2xl border border-slate-200 bg-white p-6">
                    <h3 class="text-slate-900" style="font-size:15px;font-weight:600">Course Details</h3>
                    <dl class="mt-4 space-y-3">
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Mode</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500">On-campus + LMS</dd>
                        </div>
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Contact hours</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500">3h lecture &middot; 2h lab</dd>
                        </div>
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Prerequisites</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500">CSC1102 OOP</dd>
                        </div>
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Textbook</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500">Sommerville, 11th ed.</dd>
                        </div>
                        <div class="flex justify-between gap-4">
                            <dt class="text-slate-500" style="font-size:12.5px">Office hours</dt>
                            <dd class="text-slate-900 text-right" style="font-size:12.5px;font-weight:500">Wed 14:00 &ndash; 16:00</dd>
                        </div>
                    </dl>
                    <div class="mt-5 rounded-xl bg-slate-50 p-4">
                        <p class="text-slate-500" style="font-size:11.5px;font-weight:600;letter-spacing:0.04em">LEARNING OUTCOMES</p>
                        <ul class="mt-2 space-y-2 text-slate-700" style="font-size:12.5px;line-height:1.55">
                            <li>&bull; Apply software engineering principles to real projects.</li>
                            <li>&bull; Practice agile collaboration and version control.</li>
                            <li>&bull; Design, test, and document quality software.</li>
                        </ul>
                    </div>
                </aside>

            </div>
        </div>

        <%-- ==================== ANNOUNCEMENTS PANE ==================== --%>
        <div data-pane="announcements" class="hidden">
            <div class="rounded-2xl border border-slate-200 bg-white">
                <header class="flex items-center justify-between p-6 pb-4">
                    <div>
                        <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Announcements</h2>
                        <p class="text-slate-500 mt-0.5" style="font-size:13px">Messages from your lecturer</p>
                    </div>
                </header>
                <ul class="divide-y divide-slate-100">

                    <%-- Announcement 1 — Pinned --%>
                    <li>
                        <button data-action="open-announcement" data-idx="0"
                            class="flex w-full items-start gap-3 px-6 py-5 text-left hover:bg-slate-50/60 transition-colors">
                            <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[#e0162b] text-white" style="font-size:12px;font-weight:600">WH</div>
                            <div class="min-w-0 flex-1">
                                <div class="flex items-center gap-2 flex-wrap">
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:600">Dr. Lim Wei Han</span>
                                    <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">Lecturer</span>
                                    <span class="text-slate-400" style="font-size:11.5px">&middot; Today &middot; 09:14</span>
                                    <span class="inline-flex items-center gap-1 rounded-md bg-[#e0162b]/10 px-1.5 py-0.5 text-[#a01020]" style="font-size:10.5px;font-weight:600">
                                        <i data-lucide="pin" class="h-3 w-3" style="fill:currentColor"></i> Pinned
                                    </span>
                                </div>
                                <p class="mt-1.5 text-slate-900" style="font-size:14px;font-weight:600">Reminder: ER diagram due tomorrow</p>
                                <p class="mt-1 text-slate-600" style="font-size:13px;line-height:1.6">Please submit your individual ER diagram via the Assignments tab before 11:59 PM tomorrow.</p>
                                <p class="mt-2 inline-flex items-center gap-1 text-slate-500" style="font-size:11.5px">
                                    <i data-lucide="paperclip" class="h-3 w-3"></i>
                                    2 attachments
                                </p>
                            </div>
                            <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 mt-1"></i>
                        </button>
                        <%-- Expanded detail (hidden; JS would show; static fallback is list view) --%>
                    </li>

                    <%-- Announcement 2 --%>
                    <li>
                        <button data-action="open-announcement" data-idx="1"
                            class="flex w-full items-start gap-3 px-6 py-5 text-left hover:bg-slate-50/60 transition-colors">
                            <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[#e0162b] text-white" style="font-size:12px;font-weight:600">WH</div>
                            <div class="min-w-0 flex-1">
                                <div class="flex items-center gap-2 flex-wrap">
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:600">Dr. Lim Wei Han</span>
                                    <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">Lecturer</span>
                                    <span class="text-slate-400" style="font-size:11.5px">&middot; Mon &middot; 16:32</span>
                                </div>
                                <p class="mt-1.5 text-slate-900" style="font-size:14px;font-weight:600">Lab session swap &mdash; Week 10</p>
                                <p class="mt-1 text-slate-600" style="font-size:13px;line-height:1.6">Next week&#8217;s lab will be held in Block C Lab 5 instead of Lab 3.</p>
                            </div>
                            <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 mt-1"></i>
                        </button>
                    </li>

                    <%-- Announcement 3 --%>
                    <li>
                        <button data-action="open-announcement" data-idx="2"
                            class="flex w-full items-start gap-3 px-6 py-5 text-left hover:bg-slate-50/60 transition-colors">
                            <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[#e0162b] text-white" style="font-size:12px;font-weight:600">WH</div>
                            <div class="min-w-0 flex-1">
                                <div class="flex items-center gap-2 flex-wrap">
                                    <span class="text-slate-900" style="font-size:13.5px;font-weight:600">Dr. Lim Wei Han</span>
                                    <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">Lecturer</span>
                                    <span class="text-slate-400" style="font-size:11.5px">&middot; Last week</span>
                                </div>
                                <p class="mt-1.5 text-slate-900" style="font-size:14px;font-weight:600">Week 8 slides uploaded</p>
                                <p class="mt-1 text-slate-600" style="font-size:13px;line-height:1.6">Slides for Week 8 (Software Architecture) have been uploaded. Recommended reading is Sommerville chapter 6.</p>
                                <p class="mt-2 inline-flex items-center gap-1 text-slate-500" style="font-size:11.5px">
                                    <i data-lucide="paperclip" class="h-3 w-3"></i>
                                    1 attachment
                                </p>
                            </div>
                            <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 mt-1"></i>
                        </button>
                    </li>

                </ul>
            </div>
        </div>

        <%-- ==================== ASSIGNMENTS PANE ==================== --%>
        <div data-pane="assignments" class="hidden">
            <div class="grid gap-3">

                <%-- Assignment 1 — ER Diagram (open, urgent) --%>
                <button data-action="open-assignment" data-idx="0"
                    class="group flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 text-left hover:border-slate-300 hover:shadow-sm transition-all sm:flex-row sm:items-center">
                    <span class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-[#e0162b]/10 text-[#e0162b]">
                        <i data-lucide="clipboard-list" class="h-5 w-5"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <h3 class="text-slate-900" style="font-size:14.5px;font-weight:600">ER Diagram Design</h3>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">10%</span>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">Individual</span>
                        </div>
                        <p class="mt-1 text-slate-500" style="font-size:12.5px">Design an ER diagram for the case study provided in module 6.</p>
                        <p class="mt-1 inline-flex items-center gap-1" style="font-size:12px">
                            <i data-lucide="calendar-clock" class="h-3.5 w-3.5 text-slate-500"></i>
                            <i data-lucide="alert-circle" class="h-3.5 w-3.5 text-[#e0162b]"></i>
                            <span class="text-[#e0162b] font-semibold">Tomorrow &middot; 11:59 PM</span>
                        </p>
                    </div>
                    <div class="flex items-center gap-2">
                        <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 group-hover:text-slate-500 transition-colors"></i>
                    </div>
                </button>

                <%-- Assignment 2 — Sprint 1 Retrospective (open) --%>
                <button data-action="open-assignment" data-idx="1"
                    class="group flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 text-left hover:border-slate-300 hover:shadow-sm transition-all sm:flex-row sm:items-center">
                    <span class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-amber-50 text-amber-600">
                        <i data-lucide="clipboard-list" class="h-5 w-5"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <h3 class="text-slate-900" style="font-size:14.5px;font-weight:600">Sprint 1 Retrospective Report</h3>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">15%</span>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">Group (3&ndash;4)</span>
                        </div>
                        <p class="mt-1 text-slate-500" style="font-size:12.5px">Submit your team&#8217;s sprint retrospective in PDF format (max 4 pages).</p>
                        <p class="mt-1 inline-flex items-center gap-1 text-slate-500" style="font-size:12px">
                            <i data-lucide="calendar-clock" class="h-3.5 w-3.5"></i>
                            <span>In 6 days</span>
                        </p>
                    </div>
                    <div class="flex items-center gap-2">
                        <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 group-hover:text-slate-500 transition-colors"></i>
                    </div>
                </button>

                <%-- Assignment 3 — User Story Mapping (submitted) --%>
                <button data-action="open-assignment" data-idx="2"
                    class="group flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 text-left hover:border-slate-300 hover:shadow-sm transition-all sm:flex-row sm:items-center">
                    <span class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                        <i data-lucide="check-circle-2" class="h-5 w-5"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <h3 class="text-slate-900" style="font-size:14.5px;font-weight:600">User Story Mapping (Group)</h3>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">10%</span>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">Group</span>
                        </div>
                        <p class="mt-1 text-slate-500" style="font-size:12.5px">Group submission via Miro board export.</p>
                        <p class="mt-1 inline-flex items-center gap-1 text-slate-500" style="font-size:12px">
                            <span>Submitted &middot; 28 Apr</span>
                        </p>
                    </div>
                    <div class="flex items-center gap-2">
                        <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 group-hover:text-slate-500 transition-colors"></i>
                    </div>
                </button>

                <%-- Assignment 4 — Quiz 1 (graded) --%>
                <button data-action="open-assignment" data-idx="3"
                    class="group flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 text-left hover:border-slate-300 hover:shadow-sm transition-all sm:flex-row sm:items-center">
                    <span class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600">
                        <i data-lucide="award" class="h-5 w-5"></i>
                    </span>
                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                            <h3 class="text-slate-900" style="font-size:14.5px;font-weight:600">Quiz 1 &mdash; SDLC</h3>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">5%</span>
                            <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">Individual</span>
                        </div>
                        <p class="mt-1 text-slate-500" style="font-size:12.5px">20 multiple-choice questions on SDLC fundamentals.</p>
                        <p class="mt-1 inline-flex items-center gap-1 text-slate-500" style="font-size:12px">
                            <span>Graded &middot; 15 Apr</span>
                        </p>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="rounded-lg bg-emerald-50 px-3 py-1.5 text-emerald-700" style="font-size:12.5px;font-weight:700">92 / 100</span>
                        <i data-lucide="chevron-right" class="h-4 w-4 text-slate-300 group-hover:text-slate-500 transition-colors"></i>
                    </div>
                </button>

            </div>
        </div>

        <%-- ==================== GRADES PANE ==================== --%>
        <div data-pane="grades" class="hidden">
            <div class="grid gap-6 lg:grid-cols-3">

                <%-- Overall summary card --%>
                <div class="rounded-2xl border border-slate-200 bg-white p-6">
                    <h3 class="text-slate-900" style="font-size:15px;font-weight:600">Overall Grade</h3>
                    <p class="text-slate-500 mt-0.5" style="font-size:12.5px">Based on 4 graded items</p>
                    <%-- Static donut representation (no recharts in plain HTML) --%>
                    <div class="relative mx-auto mt-3 h-44 w-44 flex items-center justify-center">
                        <svg viewBox="0 0 120 120" class="w-full h-full -rotate-90">
                            <circle cx="60" cy="60" r="48" fill="none" stroke="#f1f5f9" stroke-width="12" />
                            <circle cx="60" cy="60" r="48" fill="none" stroke="#e0162b" stroke-width="12"
                                stroke-dasharray="301.6" stroke-dashoffset="60.3" stroke-linecap="round" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <div class="text-slate-900" style="font-size:32px;font-weight:700;letter-spacing:-0.01em">85%</div>
                            <div class="text-slate-500" style="font-size:12px">Average</div>
                        </div>
                    </div>
                    <div class="mt-4 grid grid-cols-2 gap-3">
                        <div class="rounded-xl bg-slate-50 p-3">
                            <div class="text-slate-500" style="font-size:11.5px;font-weight:500">Earned (weighted)</div>
                            <div class="text-slate-900 mt-1" style="font-size:18px;font-weight:700">20.6<span class="text-slate-400" style="font-size:12px"> /100</span></div>
                        </div>
                        <div class="rounded-xl bg-slate-50 p-3">
                            <div class="text-slate-500" style="font-size:11.5px;font-weight:500">Completed</div>
                            <div class="text-slate-900 mt-1" style="font-size:18px;font-weight:700">20<span class="text-slate-400" style="font-size:12px">%</span></div>
                        </div>
                    </div>
                </div>

                <%-- Score breakdown bar chart (static SVG approximation) --%>
                <div class="lg:col-span-2 rounded-2xl border border-slate-200 bg-white p-6">
                    <header class="mb-4 flex items-center justify-between">
                        <div>
                            <h3 class="text-slate-900" style="font-size:15px;font-weight:600">Score Breakdown</h3>
                            <p class="text-slate-500 mt-0.5" style="font-size:12.5px">Per-assessment scores out of 100</p>
                        </div>
                        <div class="flex items-center gap-3 text-slate-500" style="font-size:11.5px">
                            <span class="inline-flex items-center gap-1.5">
                                <span class="h-2.5 w-2.5 rounded-sm" style="background-color:#e0162b"></span> Score
                            </span>
                        </div>
                    </header>
                    <%-- Static bar chart --%>
                    <div class="h-72 flex items-end gap-3 px-2 pb-8 relative">
                        <div class="absolute inset-x-2 bottom-8 top-0 flex flex-col justify-between pointer-events-none">
                            <div class="border-b border-slate-100 flex items-center text-slate-400" style="font-size:10px">100</div>
                            <div class="border-b border-slate-100 flex items-center text-slate-400" style="font-size:10px">75</div>
                            <div class="border-b border-slate-100 flex items-center text-slate-400" style="font-size:10px">50</div>
                            <div class="border-b border-slate-100 flex items-center text-slate-400" style="font-size:10px">25</div>
                            <div class="border-b border-slate-100 flex items-center text-slate-400" style="font-size:10px">0</div>
                        </div>
                        <%-- Bar: Quiz 1 — 92% --%>
                        <div class="flex-1 flex flex-col items-center gap-1 z-10">
                            <div class="w-full rounded-t-md" style="height:66%;background-color:#e0162b"></div>
                            <span class="text-slate-500 text-center" style="font-size:10px">1. Quiz 1</span>
                        </div>
                        <%-- Bar: Quiz 2 — 85% --%>
                        <div class="flex-1 flex flex-col items-center gap-1 z-10">
                            <div class="w-full rounded-t-md" style="height:61%;background-color:#e0162b"></div>
                            <span class="text-slate-500 text-center" style="font-size:10px">2. Quiz 2</span>
                        </div>
                        <%-- Bar: User Story — 88% --%>
                        <div class="flex-1 flex flex-col items-center gap-1 z-10">
                            <div class="w-full rounded-t-md" style="height:63%;background-color:#e0162b"></div>
                            <span class="text-slate-500 text-center" style="font-size:10px">3. User St&hellip;</span>
                        </div>
                        <%-- Bar: Mid-term — 78% --%>
                        <div class="flex-1 flex flex-col items-center gap-1 z-10">
                            <div class="w-full rounded-t-md" style="height:56%;background-color:#e0162b"></div>
                            <span class="text-slate-500 text-center" style="font-size:10px">4. Mid-term</span>
                        </div>
                    </div>
                </div>

                <%-- All assessments table --%>
                <div class="lg:col-span-3 rounded-2xl border border-slate-200 bg-white">
                    <header class="flex items-center justify-between p-6 pb-4">
                        <div>
                            <h3 class="text-slate-900" style="font-size:15px;font-weight:600">All Assessments</h3>
                            <p class="text-slate-500 mt-0.5" style="font-size:12.5px">Detailed marks and weighting</p>
                        </div>
                    </header>
                    <div class="overflow-x-auto">
                        <table class="w-full">
                            <thead>
                                <tr class="text-slate-500" style="font-size:11.5px;font-weight:600;letter-spacing:0.04em">
                                    <th class="text-left px-6 py-3">ASSESSMENT</th>
                                    <th class="text-left px-3 py-3">TYPE</th>
                                    <th class="text-right px-3 py-3">WEIGHT</th>
                                    <th class="text-right px-3 py-3">SCORE</th>
                                    <th class="text-right px-6 py-3">CONTRIB.</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100">
                                <tr class="hover:bg-slate-50/60">
                                    <td class="px-6 py-3.5 text-slate-900" style="font-size:13px;font-weight:500">Quiz 1 &mdash; SDLC</td>
                                    <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">Quiz</td>
                                    <td class="px-3 py-3.5 text-right text-slate-600" style="font-size:12.5px">5%</td>
                                    <td class="px-3 py-3.5 text-right" style="font-size:13px;font-weight:600"><span class="text-emerald-700">92 / 100</span></td>
                                    <td class="px-6 py-3.5 text-right text-slate-700" style="font-size:12.5px;font-weight:600">4.6 pts</td>
                                </tr>
                                <tr class="hover:bg-slate-50/60">
                                    <td class="px-6 py-3.5 text-slate-900" style="font-size:13px;font-weight:500">Quiz 2 &mdash; Requirements</td>
                                    <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">Quiz</td>
                                    <td class="px-3 py-3.5 text-right text-slate-600" style="font-size:12.5px">5%</td>
                                    <td class="px-3 py-3.5 text-right" style="font-size:13px;font-weight:600"><span class="text-emerald-700">85 / 100</span></td>
                                    <td class="px-6 py-3.5 text-right text-slate-700" style="font-size:12.5px;font-weight:600">4.3 pts</td>
                                </tr>
                                <tr class="hover:bg-slate-50/60">
                                    <td class="px-6 py-3.5 text-slate-900" style="font-size:13px;font-weight:500">User Story Mapping</td>
                                    <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">Assignment</td>
                                    <td class="px-3 py-3.5 text-right text-slate-600" style="font-size:12.5px">10%</td>
                                    <td class="px-3 py-3.5 text-right" style="font-size:13px;font-weight:600"><span class="text-emerald-700">88 / 100</span></td>
                                    <td class="px-6 py-3.5 text-right text-slate-700" style="font-size:12.5px;font-weight:600">8.8 pts</td>
                                </tr>
                                <tr class="hover:bg-slate-50/60">
                                    <td class="px-6 py-3.5 text-slate-900" style="font-size:13px;font-weight:500">Mid-term Test</td>
                                    <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">Test</td>
                                    <td class="px-3 py-3.5 text-right text-slate-600" style="font-size:12.5px">25%</td>
                                    <td class="px-3 py-3.5 text-right" style="font-size:13px;font-weight:600"><span class="text-amber-600">78 / 100</span></td>
                                    <td class="px-6 py-3.5 text-right text-slate-700" style="font-size:12.5px;font-weight:600">19.5 pts</td>
                                </tr>
                                <tr class="hover:bg-slate-50/60">
                                    <td class="px-6 py-3.5 text-slate-900" style="font-size:13px;font-weight:500">Sprint 1 Report</td>
                                    <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">Assignment</td>
                                    <td class="px-3 py-3.5 text-right text-slate-600" style="font-size:12.5px">15%</td>
                                    <td class="px-3 py-3.5 text-right" style="font-size:13px;font-weight:600"><span class="text-slate-400">Pending</span></td>
                                    <td class="px-6 py-3.5 text-right text-slate-700" style="font-size:12.5px;font-weight:600">&mdash;</td>
                                </tr>
                                <tr class="hover:bg-slate-50/60">
                                    <td class="px-6 py-3.5 text-slate-900" style="font-size:13px;font-weight:500">ER Diagram</td>
                                    <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">Assignment</td>
                                    <td class="px-3 py-3.5 text-right text-slate-600" style="font-size:12.5px">10%</td>
                                    <td class="px-3 py-3.5 text-right" style="font-size:13px;font-weight:600"><span class="text-slate-400">Pending</span></td>
                                    <td class="px-6 py-3.5 text-right text-slate-700" style="font-size:12.5px;font-weight:600">&mdash;</td>
                                </tr>
                                <tr class="hover:bg-slate-50/60">
                                    <td class="px-6 py-3.5 text-slate-900" style="font-size:13px;font-weight:500">Final Project</td>
                                    <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">Project</td>
                                    <td class="px-3 py-3.5 text-right text-slate-600" style="font-size:12.5px">30%</td>
                                    <td class="px-3 py-3.5 text-right" style="font-size:13px;font-weight:600"><span class="text-slate-400">Pending</span></td>
                                    <td class="px-6 py-3.5 text-right text-slate-700" style="font-size:12.5px;font-weight:600">&mdash;</td>
                                </tr>
                            </tbody>
                            <tfoot>
                                <tr class="bg-slate-50">
                                    <td class="px-6 py-3.5 text-slate-900" colspan="2" style="font-size:13px;font-weight:700">Total</td>
                                    <td class="px-3 py-3.5 text-right text-slate-900" style="font-size:13px;font-weight:700">100%</td>
                                    <td class="px-3 py-3.5 text-right text-slate-500" style="font-size:12.5px">&mdash;</td>
                                    <td class="px-6 py-3.5 text-right text-slate-900" style="font-size:13px;font-weight:700">37.2 pts</td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>

            </div>
        </div>

    </section>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/course-detail/course-detail.js") %>"></script>
</asp:Content>
