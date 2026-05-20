<%@ Page Language="C#" MasterPageFile="~/shared/DashboardLayout.master" AutoEventWireup="true" CodeBehind="notifications.aspx.cs" Inherits="student_information_management_system.notifications" Title="Notifications - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500">Inbox</p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Notifications</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">
                Updates from your courses, lecturers, and the registrar. <span id="unread-count" class="font-semibold text-[#a01020]">3</span> unread.
            </p>
        </div>
        <button class="inline-flex items-center gap-2 rounded-md border border-slate-200 bg-white px-3 h-10 text-slate-700 hover:bg-slate-50 transition-colors" style="font-size:13px;font-weight:600">
            <i data-lucide="check-check" class="h-4 w-4"></i> Mark all as read
        </button>
    </div>

    <%-- Body: list + detail --%>
    <section class="mt-6 grid gap-4 lg:grid-cols-[minmax(320px,400px)_1fr]">

        <%-- List --%>
        <div class="rounded-lg border border-slate-200 bg-white">
            <div class="border-b border-slate-100 p-3">
                <div class="relative">
                    <i data-lucide="search" class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400"></i>
                    <input placeholder="Search notifications&hellip;" class="h-9 w-full rounded-md border border-slate-200 bg-white pl-9 pr-3 text-slate-900 placeholder:text-slate-400 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:12.5px" />
                </div>
            </div>
            <ul class="max-h-[640px] divide-y divide-slate-100 overflow-y-auto">

                <%-- n1: assignment (unread, pinned, active by default) --%>
                <li>
                    <button data-action="toggle-read" data-id="n1" data-read="false" class="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors bg-[#e0162b]/[0.04] data-[read=true]:opacity-70">
                        <span class="mt-1.5 h-2 w-2 shrink-0 rounded-full" style="background-color:#e0162b;outline:3px solid #e0162b22"></span>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="rounded border bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20 px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;letter-spacing:0.04em">ASSIGNMENT</span>
                                <i data-lucide="pin" class="h-3 w-3 text-amber-500"></i>
                                <span class="ml-auto text-slate-400 truncate" style="font-size:10.5px">10:24 AM</span>
                            </div>
                            <p class="mt-1 line-clamp-2 text-slate-900" style="font-size:13px;font-weight:600;line-height:1.4">Assignment due tomorrow: ER Diagram Design</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:11.5px">CSC2103 &middot; Database Systems</p>
                        </div>
                    </button>
                </li>

                <%-- n2: grade (unread) --%>
                <li>
                    <button data-action="toggle-read" data-id="n2" data-read="false" class="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-slate-50 data-[read=true]:opacity-70">
                        <span class="mt-1.5 h-2 w-2 shrink-0 rounded-full" style="background-color:#10b981;outline:3px solid #10b98122"></span>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="rounded border bg-emerald-50 text-emerald-700 border-emerald-100 px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;letter-spacing:0.04em">GRADE</span>
                                <span class="ml-auto text-slate-400 truncate" style="font-size:10.5px">9:02 AM</span>
                            </div>
                            <p class="mt-1 line-clamp-2 text-slate-900" style="font-size:13px;font-weight:600;line-height:1.4">Grade released: Quiz 2 &mdash; Requirements (85/100)</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:11.5px">CSC2104 &middot; Software Engineering</p>
                        </div>
                    </button>
                </li>

                <%-- n3: announcement (unread) --%>
                <li>
                    <button data-action="toggle-read" data-id="n3" data-read="false" class="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-slate-50 data-[read=true]:opacity-70">
                        <span class="mt-1.5 h-2 w-2 shrink-0 rounded-full" style="background-color:#0ea5e9;outline:3px solid #0ea5e922"></span>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="rounded border bg-sky-50 text-sky-700 border-sky-100 px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;letter-spacing:0.04em">ANNOUNCEMENT</span>
                                <span class="ml-auto text-slate-400 truncate" style="font-size:10.5px">Yesterday &middot; 4:48 PM</span>
                            </div>
                            <p class="mt-1 line-clamp-2 text-slate-900" style="font-size:13px;font-weight:600;line-height:1.4">Lecture room change for Algorithms tomorrow</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:11.5px">Dr. Rajesh Kumar</p>
                        </div>
                    </button>
                </li>

                <%-- n4: payment (read) --%>
                <li>
                    <button data-action="toggle-read" data-id="n4" data-read="true" class="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-slate-50 opacity-70">
                        <span class="mt-1.5 h-2 w-2 shrink-0 rounded-full" style="background-color:transparent"></span>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="rounded border bg-amber-50 text-amber-700 border-amber-100 px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;letter-spacing:0.04em">PAYMENT</span>
                                <span class="ml-auto text-slate-400 truncate" style="font-size:10.5px">12 Jan</span>
                            </div>
                            <p class="mt-1 line-clamp-2 text-slate-700" style="font-size:13px;font-weight:500;line-height:1.4">Tuition payment receipt available</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:11.5px">Finance Office</p>
                        </div>
                    </button>
                </li>

                <%-- n5: system (read) --%>
                <li>
                    <button data-action="toggle-read" data-id="n5" data-read="true" class="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-slate-50 opacity-70">
                        <span class="mt-1.5 h-2 w-2 shrink-0 rounded-full" style="background-color:transparent"></span>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="rounded border bg-slate-100 text-slate-700 border-slate-200 px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;letter-spacing:0.04em">SYSTEM</span>
                                <span class="ml-auto text-slate-400 truncate" style="font-size:10.5px">28 Apr</span>
                            </div>
                            <p class="mt-1 line-clamp-2 text-slate-700" style="font-size:13px;font-weight:500;line-height:1.4">Course enrollment opens 1 August 2026</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:11.5px">Registrar's Office</p>
                        </div>
                    </button>
                </li>

                <%-- n6: announcement (read) --%>
                <li>
                    <button data-action="toggle-read" data-id="n6" data-read="true" class="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-slate-50 opacity-70">
                        <span class="mt-1.5 h-2 w-2 shrink-0 rounded-full" style="background-color:transparent"></span>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="rounded border bg-sky-50 text-sky-700 border-sky-100 px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;letter-spacing:0.04em">ANNOUNCEMENT</span>
                                <span class="ml-auto text-slate-400 truncate" style="font-size:10.5px">26 Apr</span>
                            </div>
                            <p class="mt-1 line-clamp-2 text-slate-700" style="font-size:13px;font-weight:500;line-height:1.4">New module published: Sprint Planning Essentials</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:11.5px">CSC2104 &middot; Software Engineering</p>
                        </div>
                    </button>
                </li>

                <%-- n7: system (read) --%>
                <li>
                    <button data-action="toggle-read" data-id="n7" data-read="true" class="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-slate-50 opacity-70">
                        <span class="mt-1.5 h-2 w-2 shrink-0 rounded-full" style="background-color:transparent"></span>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="rounded border bg-slate-100 text-slate-700 border-slate-200 px-1.5 py-0.5" style="font-size:9.5px;font-weight:700;letter-spacing:0.04em">SYSTEM</span>
                                <span class="ml-auto text-slate-400 truncate" style="font-size:10.5px">25 Apr</span>
                            </div>
                            <p class="mt-1 line-clamp-2 text-slate-700" style="font-size:13px;font-weight:500;line-height:1.4">Library book due in 3 days</p>
                            <p class="mt-0.5 text-slate-500 truncate" style="font-size:11.5px">INTI Library</p>
                        </div>
                    </button>
                </li>

            </ul>
        </div>

        <%-- Detail panel: shows n1 by default --%>
        <div class="rounded-lg border border-slate-200 bg-white">
            <article class="flex h-full flex-col">
                <header class="flex items-center justify-between border-b border-slate-100 px-5 py-3">
                    <div class="ml-auto flex items-center gap-1">
                        <button class="inline-flex h-9 w-9 items-center justify-center rounded-md hover:bg-slate-100 transition-colors" title="Pin">
                            <i data-lucide="pin" class="h-4 w-4 text-amber-500"></i>
                        </button>
                        <button class="inline-flex h-9 w-9 items-center justify-center rounded-md hover:bg-slate-100 transition-colors" title="Archive">
                            <i data-lucide="archive" class="h-4 w-4 text-slate-500"></i>
                        </button>
                        <button class="inline-flex h-9 w-9 items-center justify-center rounded-md hover:bg-slate-100 transition-colors" title="Delete">
                            <i data-lucide="trash-2" class="h-4 w-4 text-slate-500"></i>
                        </button>
                    </div>
                </header>

                <div class="flex-1 overflow-y-auto px-7 py-6">
                    <div class="flex items-center gap-2">
                        <span class="rounded border bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20 px-1.5 py-0.5" style="font-size:10.5px;font-weight:700;letter-spacing:0.04em">ASSIGNMENT</span>
                        <span class="text-slate-400" style="font-size:11.5px">&middot;</span>
                        <span class="text-slate-500" style="font-size:12px">CSC2103 &middot; Database Systems</span>
                    </div>

                    <h2 class="mt-3 text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em;line-height:1.25">
                        Assignment due tomorrow: ER Diagram Design
                    </h2>

                    <div class="mt-2 inline-flex items-center gap-1.5 text-slate-500" style="font-size:12px">
                        <i data-lucide="clock" class="h-3.5 w-3.5 text-slate-400"></i>
                        Today &middot; 10:24 AM
                    </div>

                    <div class="mt-5 grid grid-cols-2 gap-3 sm:grid-cols-3">
                        <div class="rounded-md border border-slate-200 bg-slate-50/50 px-3 py-2.5">
                            <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">COURSE</p>
                            <p class="mt-0.5 text-slate-900" style="font-size:13px;font-weight:600">CSC2103</p>
                        </div>
                        <div class="rounded-md border border-slate-200 bg-slate-50/50 px-3 py-2.5">
                            <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">DUE</p>
                            <p class="mt-0.5 text-slate-900" style="font-size:13px;font-weight:600">4 May 2026 &middot; 23:59</p>
                        </div>
                        <div class="rounded-md border border-slate-200 bg-slate-50/50 px-3 py-2.5">
                            <p class="text-slate-400" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">WEIGHT</p>
                            <p class="mt-0.5 text-slate-900" style="font-size:13px;font-weight:600">10%</p>
                        </div>
                    </div>

                    <div class="mt-6 space-y-3 text-slate-700" style="font-size:14px;line-height:1.7">
                        <p>This is a reminder that your assignment 'ER Diagram Design' for CSC2103 &mdash; Database Systems is due on 4 May 2026 at 11:59 PM.</p>
                        <p style="white-space:pre-line">Make sure your submission includes:
&bull; A complete ERD using crow's foot notation
&bull; Identification of all primary, foreign, and composite keys
&bull; A short documentation page explaining your design decisions</p>
                        <p>Late submissions will incur a 10% penalty per day. Please reach out to your lecturer Ms. Tan Hui Ling if you need any clarification on the requirements.</p>
                    </div>
                </div>

                <footer class="border-t border-slate-100 bg-slate-50/40 px-5 py-3 flex items-center justify-end gap-2">
                    <button class="inline-flex items-center gap-1.5 rounded-md border border-slate-200 bg-white px-3 h-9 text-slate-700 hover:bg-slate-50 transition-colors" style="font-size:12.5px;font-weight:600">
                        Mark unread
                    </button>
                </footer>
            </article>
        </div>

    </section>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/notifications/notifications.js") %>"></script>
</asp:Content>
