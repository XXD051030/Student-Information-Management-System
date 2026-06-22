<%@ Page Language="C#" MasterPageFile="~/student/StudentLayout.master" AutoEventWireup="true" CodeBehind="enrollment.aspx.cs" Inherits="src.student.enrollment" Title="Course Enrollment - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500"><%= Server.HtmlEncode(AcademicYearLabel) %></p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Course Enrollment</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">
                Register for courses for <span class="text-slate-900 font-semibold"><%= Server.HtmlEncode(YearAndTrimesterLabel) %> &middot; <%= Server.HtmlEncode(TermLabel) %></span>.
            </p>
        </div>
    </div>

    <%-- Phase banner --%>
    <section class="mt-6 rounded-2xl border <%= IsAddDropPhase ? "border-amber-200 bg-amber-50/60" : "border-emerald-200 bg-emerald-50/60" %> p-5 lg:p-6">
        <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <div class="flex items-center gap-3">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl <%= IsAddDropPhase ? "bg-amber-500" : "bg-emerald-600" %> text-white">
                    <i data-lucide="<%= IsAddDropPhase ? "refresh-cw" : "check-circle-2" %>" class="h-5 w-5"></i>
                </div>
                <div>
                    <p class="<%= IsAddDropPhase ? "text-amber-700" : "text-emerald-700" %>" style="font-size:11.5px;font-weight:700;letter-spacing:0.04em"><%= IsAddDropPhase ? "ADD / DROP PERIOD OPEN" : RegistrationOpen ? "ENROLLMENT OPEN" : "ENROLLMENT CLOSED" %></p>
                    <p class="mt-0.5 text-slate-900" style="font-size:15px;font-weight:600">Registration period &middot; <%= Server.HtmlEncode(RegistrationDateRange) %></p>
                </div>
            </div>

            <%-- Phase timeline --%>
            <ol class="flex items-center gap-2">
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full <%= ActivePhase >= 1 ? "bg-emerald-600 text-white" : "bg-white text-slate-400 ring-1 ring-slate-200" %>" style="font-size:11px;font-weight:700">1</span>
                    <span class="hidden sm:inline text-slate-900" style="font-size:12px;font-weight:600">Registration period</span>
                    <span class="hidden sm:inline w-6 h-px bg-slate-300"></span>
                </li>
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full <%= ActivePhase >= 2 ? "bg-emerald-600 text-white" : "bg-white text-slate-400 ring-1 ring-slate-200" %>" style="font-size:11px;font-weight:700">2</span>
                    <span class="hidden sm:inline text-slate-500" style="font-size:12px;font-weight:500">Add / Drop period</span>
                    <span class="hidden sm:inline w-6 h-px bg-slate-300"></span>
                </li>
                <li class="flex items-center gap-2">
                    <span class="flex h-7 w-7 items-center justify-center rounded-full <%= ActivePhase >= 3 ? "bg-emerald-600 text-white" : "bg-white text-slate-400 ring-1 ring-slate-200" %>" style="font-size:11px;font-weight:700">3</span>
                    <span class="hidden sm:inline text-slate-500" style="font-size:12px;font-weight:500">Enrollment locked</span>
                </li>
            </ol>
        </div>
    </section>

    <%-- Stats --%>
    <section class="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
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
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Credits Selected</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="shield-check" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><span id="enroll-credits" data-min-credits="<%= MinCredits %>" data-max-credits="<%= MaxCredits %>">0</span></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">Limit: <%= MinCredits %>&#8211;<%= MaxCredits %></p>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Estimated Fee</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="wallet" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">RM <span id="enroll-total">0</span></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">RM <%= ((int)FeePerCredit) %> / credit</p>
        </div>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <div class="flex items-start justify-between">
                <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Already Registered</p>
                <span class="flex h-7 w-7 items-center justify-center rounded-lg bg-slate-50 text-slate-500">
                    <i data-lucide="check-circle-2" class="h-4 w-4"></i>
                </span>
            </div>
            <p class="mt-1.5 text-emerald-600" style="font-size:28px;font-weight:700;letter-spacing:-0.01em"><%= AlreadyRegisteredCount %></p>
            <p class="mt-1 text-slate-400" style="font-size:12px">courses confirmed</p>
        </div>
    </section>

    <%-- Course list --%>
    <section class="mt-6 grid gap-3">
        <asp:Repeater ID="offeringsRepeater" runat="server">
            <ItemTemplate>
                <article data-course-row data-code='<%# Server.HtmlEncode(Eval("CourseCode").ToString()) %>'
                         data-name='<%# Server.HtmlEncode(Eval("CourseName").ToString()) %>'
                         data-credits='<%# Eval("CreditHours") %>' data-fee='<%# RowFee(Eval("CreditHours")).ToString(System.Globalization.CultureInfo.InvariantCulture) %>'
                         class="rounded-2xl border border-slate-200 bg-white p-5">
                    <div class="flex flex-col gap-4 lg:flex-row lg:items-start">
                        <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl" style='background-color:<%# AccentColor(Eval("Color") as string) %>15;color:<%# AccentColor(Eval("Color") as string) %>'>
                            <i data-lucide="book-open" class="h-5 w-5"></i>
                        </div>
                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode(Eval("CourseCode").ToString()) %></span>
                                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Eval("CreditHours") %> credits</span>
                                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">RM <%# ((int)RowFee(Eval("CreditHours"))) %></span>
                                <asp:Panel runat="server" Visible='<%# RowRegistered(Eval("MyStatus")) %>' CssClass="inline-flex items-center gap-1 rounded-md bg-emerald-50 px-1.5 py-0.5 text-emerald-700" style="font-size:10.5px;font-weight:600">
                                    <i data-lucide="check-circle-2" class="h-3 w-3"></i> Registered
                                </asp:Panel>
                            </div>
                            <h3 class="mt-1.5 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3"><%# Server.HtmlEncode(Eval("CourseName").ToString()) %></h3>
                            <p class="mt-1 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55"><%# Server.HtmlEncode(Eval("Description").ToString()) %></p>
                            <div class="mt-3 grid gap-2 text-slate-600 sm:grid-cols-2 lg:grid-cols-3" style="font-size:12px">
                                <span class="inline-flex items-center gap-1.5"><i data-lucide="users" class="h-3.5 w-3.5 text-slate-400"></i><%# Server.HtmlEncode(Eval("LecturerName").ToString()) %></span>
                                <span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-days" class="h-3.5 w-3.5 text-slate-400"></i><%# Server.HtmlEncode(Eval("Schedule").ToString()) %></span>
                                <span class="inline-flex items-center gap-1.5">
                                    <span class="h-3.5 w-3.5 rounded-full" style='background-color:<%# SeatDotColor(Eval("EnrolledCount"), Eval("Capacity")) %>'></span>
                                    Seats: <%# Eval("EnrolledCount") %>/<%# Eval("Capacity") %>
                                </span>
                            </div>
                            <asp:Panel runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("Prerequisites") as string) %>' CssClass="mt-2 text-slate-500" style="font-size:12px">
                                <span class="text-slate-400">Prerequisites:</span>
                                <span class="ml-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600"><%# Server.HtmlEncode((Eval("Prerequisites") as string) ?? "") %></span>
                            </asp:Panel>
                        </div>
                        <div class="flex shrink-0 items-center gap-2">
                            <%-- Phase 1: static "Registered" badge --%>
                            <asp:Panel runat="server" Visible='<%# RowRegistered(Eval("MyStatus")) %>' CssClass="inline-flex items-center gap-1.5 rounded-xl bg-emerald-50 border border-emerald-200 px-3.5 h-10 text-emerald-700" style="font-size:13px;font-weight:600">
                                <i data-lucide="check-circle-2" class="h-4 w-4"></i> Registered
                            </asp:Panel>
                            <%-- Phase 2: enrolled course — show badge + Request Drop button --%>
                            <asp:Panel runat="server" Visible='<%# RowDroppable(Eval("MyStatus")) %>' CssClass="flex items-center gap-2">
                                <span class="inline-flex items-center gap-1.5 rounded-xl bg-emerald-50 border border-emerald-200 px-3.5 h-10 text-emerald-700" style="font-size:13px;font-weight:600">
                                    <i data-lucide="check-circle-2" class="h-4 w-4"></i> Enrolled
                                </span>
                                <button type="button" data-action="request-drop"
                                        data-offering='<%# Eval("OfferingId") %>'
                                        data-code='<%# Server.HtmlEncode(Eval("CourseCode").ToString()) %>'
                                        aria-label="Request to drop this course"
                                        class="inline-flex items-center gap-1.5 rounded-xl px-3.5 h-10 bg-[#e0162b]/10 border border-[#e0162b]/20 text-[#a01020] hover:bg-[#e0162b]/20 transition-all" style="font-size:13px;font-weight:600">
                                    <i data-lucide="x-circle" class="h-4 w-4"></i> Request Drop
                                </button>
                            </asp:Panel>
                            <%-- Phase 2: pending request --%>
                            <asp:Panel runat="server" Visible='<%# RowPending(Eval("MyStatus")) %>' CssClass="inline-flex items-center gap-1.5 rounded-xl bg-amber-50 border border-amber-200 px-3.5 h-10 text-amber-700" style="font-size:13px;font-weight:600">
                                <i data-lucide="clock" class="h-4 w-4"></i> Pending Review
                            </asp:Panel>
                            <%-- Phase 2: rejected add request --%>
                            <asp:Panel runat="server" Visible='<%# RowRejected(Eval("MyStatus")) %>' CssClass="inline-flex items-center gap-1.5 rounded-xl bg-red-50 border border-red-200 px-3.5 h-10 text-red-700" style="font-size:13px;font-weight:600">
                                <i data-lucide="x-circle" class="h-4 w-4"></i> Rejected
                            </asp:Panel>
                            <%-- Any phase: full seat --%>
                            <asp:Panel runat="server" Visible='<%# RowFull(Eval("MyStatus"), Eval("EnrolledCount"), Eval("Capacity")) %>'>
                                <button disabled class="inline-flex items-center gap-1.5 rounded-xl px-3.5 h-10 bg-slate-100 text-slate-400 cursor-not-allowed" style="font-size:13px;font-weight:600">
                                    <i data-lucide="alert-circle" class="h-4 w-4"></i> Full
                                </button>
                            </asp:Panel>
                            <%-- Any phase: prerequisite not yet passed --%>
                            <asp:Panel runat="server" Visible='<%# RowLockedByPrerequisite(Eval("MyStatus"), Eval("EnrolledCount"), Eval("Capacity"), Eval("PrerequisiteMet")) %>'>
                                <button disabled title='<%# "Requires " + Server.HtmlEncode((Eval("Prerequisites") as string) ?? "") %>' class="inline-flex items-center gap-1.5 rounded-xl px-3.5 h-10 bg-slate-100 text-slate-400 cursor-not-allowed" style="font-size:13px;font-weight:600">
                                    <i data-lucide="lock" class="h-4 w-4"></i> Prerequisite Required
                                </button>
                            </asp:Panel>
                            <%-- Phase 1: checkbox to add to basket --%>
                            <asp:Panel runat="server" Visible='<%# RowOpen(Eval("MyStatus"), Eval("EnrolledCount"), Eval("Capacity"), Eval("PrerequisiteMet")) %>'>
                                <input type="checkbox" data-action="toggle-enroll" data-code='<%# Server.HtmlEncode(Eval("CourseCode").ToString()) %>' data-offering='<%# Eval("OfferingId") %>'
                                       class="h-5 w-5 rounded border-slate-300 text-[#e0162b] accent-[#e0162b] cursor-pointer" />
                            </asp:Panel>
                            <%-- Phase 2: Request Add button (available, not full) --%>
                            <asp:Panel runat="server" Visible='<%# RowAddable(Eval("MyStatus"), Eval("EnrolledCount"), Eval("Capacity"), Eval("PrerequisiteMet")) %>'>
                                <button type="button" data-action="request-add"
                                        data-offering='<%# Eval("OfferingId") %>'
                                        data-code='<%# Server.HtmlEncode(Eval("CourseCode").ToString()) %>'
                                        aria-label="Request to add this course"
                                        class="inline-flex items-center gap-1.5 rounded-xl px-3.5 h-10 bg-[#e0162b] text-white hover:bg-[#a01020] transition-all" style="font-size:13px;font-weight:600">
                                    <i data-lucide="plus-circle" class="h-4 w-4"></i> Request Add
                                </button>
                            </asp:Panel>
                        </div>
                    </div>
                </article>
            </ItemTemplate>
        </asp:Repeater>
    </section>

    <%-- Phase 1: Submit / confirm enrollment --%>
    <section class="mt-6 flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-5 lg:flex-row lg:items-center lg:justify-between" style="<%= IsAddDropPhase ? "display:none" : "" %>">
        <div>
            <p class="text-slate-900" style="font-size:14.5px;font-weight:600">Confirm enrollment</p>
            <p class="mt-0.5 text-slate-500" style="font-size:12.5px">
                You may add or drop courses during the Add/Drop period (<%= Server.HtmlEncode(AddDropDateRange) %>).
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

    <%-- Phase 2: Add/Drop info footer --%>
    <section class="mt-6 rounded-2xl border border-amber-200 bg-amber-50/60 p-5" style="<%= !IsAddDropPhase ? "display:none" : "" %>">
        <div class="flex items-center gap-3">
            <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-amber-500 text-white">
                <i data-lucide="info" class="h-4 w-4"></i>
            </span>
            <div>
                <p class="text-amber-800" style="font-size:14px;font-weight:600">Requests go to admin for review</p>
                <p class="mt-0.5 text-slate-600" style="font-size:12.5px">The status of your requests will update on this page once admin takes action.</p>
            </div>
        </div>
    </section>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/student/enrollment.js") %>"></script>
</asp:Content>
