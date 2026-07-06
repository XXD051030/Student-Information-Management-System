<%@ Page Language="C#" MasterPageFile="~/student/StudentLayout.master" AutoEventWireup="true" CodeBehind="help.aspx.cs" Inherits="src.shared.help" Title="Help & Support - INTI Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div>
        <p class="text-slate-500" style="font-size:13px;font-weight:500">Support</p>
        <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Help &amp; Support</h1>
        <p class="mt-1 text-slate-500" style="font-size:14px"><%= Subtitle %></p>
    </div>

    <div class="mt-6 grid gap-5 lg:grid-cols-3 lg:items-start">

        <%-- Left column: getting started + FAQ --%>
        <div class="space-y-5 lg:col-span-2">

            <%-- Getting started --%>
            <section class="rounded-lg border border-slate-200 bg-white">
                <div class="border-b border-slate-100 px-6 py-4">
                    <h2 class="text-slate-900 inline-flex items-center gap-2" style="font-size:15px;font-weight:700">
                        <i data-lucide="compass" class="h-4 w-4 text-slate-500"></i> Getting started
                    </h2>
                </div>
                <div class="px-6 py-5">
                    <p class="text-slate-600" style="font-size:13.5px;line-height:1.7"><%= Intro %></p>
                    <ul class="mt-4 space-y-2.5">
                        <li class="flex items-start gap-2.5 text-slate-600" style="font-size:13px">
                            <i data-lucide="panel-left" class="h-4 w-4 mt-0.5 text-slate-400 shrink-0"></i>
                            <span>Use the sidebar on the left to move between sections of the portal.</span>
                        </li>
                        <li class="flex items-start gap-2.5 text-slate-600" style="font-size:13px">
                            <i data-lucide="user-cog" class="h-4 w-4 mt-0.5 text-slate-400 shrink-0"></i>
                            <span>Open <strong class="text-slate-700">Account</strong> to update your profile, photo and password.</span>
                        </li>
                        <li class="flex items-start gap-2.5 text-slate-600" style="font-size:13px">
                            <i data-lucide="bell" class="h-4 w-4 mt-0.5 text-slate-400 shrink-0"></i>
                            <span>Check the bell icon in the top bar for your latest notifications.</span>
                        </li>
                    </ul>
                </div>
            </section>

            <%-- FAQ (content branches by role) --%>
            <section class="rounded-lg border border-slate-200 bg-white">
                <div class="border-b border-slate-100 px-6 py-4">
                    <h2 class="text-slate-900 inline-flex items-center gap-2" style="font-size:15px;font-weight:700">
                        <i data-lucide="help-circle" class="h-4 w-4 text-slate-500"></i> Frequently asked questions
                    </h2>
                </div>
                <div class="divide-y divide-slate-100">

                    <% if (IsLecturer) { %>

                        <%-- ===== Lecturer FAQ ===== --%>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I take attendance for a class?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Open <strong class="text-slate-600">Attendance</strong> in the sidebar, choose the course and session, then use <strong class="text-slate-600">Take attendance</strong>. This also covers extra or replacement classes, and you can review earlier sessions from the attendance history.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I enter or update grades?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Open <strong class="text-slate-600">Grades</strong> in the sidebar, pick the course, then record marks for assignments and the final grade. Saved grades become visible to enrolled students.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">Where do I see students who are at risk?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Open <strong class="text-slate-600">Academic Performance</strong> in the sidebar to review how each class is doing and which students are flagged as at risk.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">Where are my courses and weekly schedule?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65"><strong class="text-slate-600">My Courses</strong> lists the courses you teach, and your weekly classes appear on your <strong class="text-slate-600">Timetable</strong>.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I share materials with students?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Use <strong class="text-slate-600">Materials</strong> in the sidebar to upload files or link resources to a course, so enrolled students can open them.</p>
                        </div>

                    <% } else if (IsAdmin) { %>

                        <%-- ===== Admin FAQ ===== --%>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I manage programmes and courses?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Use the <strong class="text-slate-600">Programme &amp; Course</strong> section in the sidebar to view and maintain programmes, modules and course offerings.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I handle add/drop requests?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Open <strong class="text-slate-600">Add/Drop Requests</strong> in the sidebar to review students' enrolment changes and approve or reject them.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">Where are the attendance and pass/fail reports?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Use <strong class="text-slate-600">Course Attendance</strong> and <strong class="text-slate-600">Pass / Fail</strong> in the sidebar to monitor attendance rates and outcomes per course.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I manage the academic calendar?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Open <strong class="text-slate-600">Academic Calendar</strong> in the sidebar to view and maintain semester start and end dates, which drive the timetable and registration windows.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">Something in the system isn't working — who do I contact?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Email the IT Helpdesk with the page, the action you were taking, and a screenshot if you have one, so it can be investigated quickly.</p>
                        </div>

                    <% } else { %>

                        <%-- ===== Student FAQ ===== --%>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I reset or change my password?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Go to <strong class="text-slate-600">Account</strong> in the sidebar and open <strong class="text-slate-600">Change password</strong>. If you're locked out and can't sign in at all, email the IT Helpdesk and we'll help you back in.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">Where can I see my class timetable?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Open <strong class="text-slate-600">Timetable</strong> in the sidebar. It shows your weekly classes for the current semester, with the time, room and lecturer for each one.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I enrol in courses or request an add/drop?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Use <strong class="text-slate-600">Course Enrollment</strong> in the sidebar during the registration window. Once classes have started, changes are handled as add/drop requests that your faculty reviews.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">Where do I check my grades?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Open <strong class="text-slate-600">Grades</strong> in the sidebar to see results for each course along with your overall standing.</p>
                        </div>
                        <div class="px-6 py-4">
                            <p class="text-slate-900" style="font-size:13.5px;font-weight:600">How do I view or pay my fees?</p>
                            <p class="mt-1 text-slate-500" style="font-size:13px;line-height:1.65">Open the <strong class="text-slate-600">Payment</strong> section in the sidebar to view your statement and any outstanding balance. For billing questions, email Finance.</p>
                        </div>

                    <% } %>

                </div>
            </section>

        </div>

        <%-- Right column: contact --%>
        <aside class="space-y-5">
            <section class="rounded-lg border border-slate-200 bg-white">
                <div class="border-b border-slate-100 px-6 py-4">
                    <h2 class="text-slate-900 inline-flex items-center gap-2" style="font-size:15px;font-weight:700">
                        <i data-lucide="life-buoy" class="h-4 w-4 text-slate-500"></i> Contact us
                    </h2>
                </div>
                <div class="px-6 py-5 space-y-3">
                    <p class="text-slate-600" style="font-size:13px;line-height:1.6">Can't find what you need above? Reach out and we'll get back to you.</p>

                    <%-- General support --%>
                    <a href="mailto:support@newinti.edu.my" class="flex items-start gap-3 rounded-lg border border-slate-200 px-4 py-3 hover:bg-slate-50 transition-colors">
                        <span class="mt-0.5 flex h-9 w-9 items-center justify-center rounded-md bg-[#e0162b]/10 text-[#e0162b] shrink-0">
                            <i data-lucide="mail" class="h-4 w-4"></i>
                        </span>
                        <span class="min-w-0">
                            <span class="block text-slate-900" style="font-size:13px;font-weight:600">General support</span>
                            <span class="block text-slate-500 truncate" style="font-size:12.5px">support@newinti.edu.my</span>
                        </span>
                    </a>

                    <%-- IT helpdesk --%>
                    <a href="mailto:ithelpdesk@newinti.edu.my" class="flex items-start gap-3 rounded-lg border border-slate-200 px-4 py-3 hover:bg-slate-50 transition-colors">
                        <span class="mt-0.5 flex h-9 w-9 items-center justify-center rounded-md bg-slate-100 text-slate-600 shrink-0">
                            <i data-lucide="wrench" class="h-4 w-4"></i>
                        </span>
                        <span class="min-w-0">
                            <span class="block text-slate-900" style="font-size:13px;font-weight:600">IT Helpdesk &middot; login &amp; technical</span>
                            <span class="block text-slate-500 truncate" style="font-size:12.5px">ithelpdesk@newinti.edu.my</span>
                        </span>
                    </a>

                    <% if (IsStudent) { %>
                    <%-- Finance (students only) --%>
                    <a href="mailto:finance@newinti.edu.my" class="flex items-start gap-3 rounded-lg border border-slate-200 px-4 py-3 hover:bg-slate-50 transition-colors">
                        <span class="mt-0.5 flex h-9 w-9 items-center justify-center rounded-md bg-slate-100 text-slate-600 shrink-0">
                            <i data-lucide="wallet" class="h-4 w-4"></i>
                        </span>
                        <span class="min-w-0">
                            <span class="block text-slate-900" style="font-size:13px;font-weight:600">Finance &amp; fees</span>
                            <span class="block text-slate-500 truncate" style="font-size:12.5px">finance@newinti.edu.my</span>
                        </span>
                    </a>
                    <% } %>

                    <%-- Office hours --%>
                    <div class="flex items-start gap-3 rounded-lg bg-slate-50 px-4 py-3">
                        <i data-lucide="clock" class="h-4 w-4 mt-0.5 text-slate-400 shrink-0"></i>
                        <div>
                            <p class="text-slate-700" style="font-size:12.5px;font-weight:600">Office hours</p>
                            <p class="text-slate-500" style="font-size:12.5px">Monday&ndash;Friday, 9:00 AM &ndash; 5:00 PM (MYT)</p>
                            <p class="text-slate-400 mt-1" style="font-size:11.5px">We aim to reply within 1&ndash;2 working days.</p>
                        </div>
                    </div>
                </div>
            </section>
        </aside>

    </div>

</asp:Content>
