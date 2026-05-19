<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Sidebar.ascx.cs" Inherits="student_information_management_system.controls.Sidebar" %>

<aside id="mobile-menu" data-open="false" class="flex fixed inset-y-0 left-0 z-50 w-64 shrink-0 flex-col border-r border-slate-200 bg-white -translate-x-full transition-transform duration-300 data-[open=true]:translate-x-0 lg:static lg:translate-x-0">
    <div class="flex h-20 items-center px-6 border-b border-slate-100">
        <img src="<%= ResolveUrl("~/img/inti_logo.png") %>" alt="INTI" class="h-10 w-auto object-contain" />
        <button data-action="close-menu" aria-label="Close menu" class="ml-auto lg:hidden inline-flex h-9 w-9 items-center justify-center rounded-md text-slate-500 hover:bg-slate-100 hover:text-slate-900 transition-colors">
            <i data-lucide="x" class="h-4 w-4"></i>
        </button>
    </div>

    <nav class="flex-1 overflow-y-auto px-3 py-5">
        <p class="px-3 pb-2 text-slate-400" style="font-size:11px;font-weight:600;letter-spacing:0.08em">MAIN MENU</p>
        <ul class="space-y-0.5">
            <li>
                <a href="dashboard.aspx" data-nav-link="dashboard.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="layout-dashboard" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Dashboard</span>
                </a>
            </li>
            <li>
                <a href="courses.aspx" data-nav-link="courses.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="book-open" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">My Courses</span>
                    <span class="rounded-md px-1.5 bg-slate-100 text-slate-600" style="font-size:11px;font-weight:600">6</span>
                </a>
            </li>
            <li>
                <a href="enrollment.aspx" data-nav-link="enrollment.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="book-plus" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Course Enrollment</span>
                    <span class="rounded-md px-1.5 bg-slate-100 text-slate-600" style="font-size:11px;font-weight:600">New</span>
                </a>
            </li>
            <li>
                <details open>
                    <summary class="group flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition-all cursor-pointer list-none" style="font-size:14px;font-weight:500">
                        <i data-lucide="wallet" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                        <span class="flex-1 text-left">Payment</span>
                        <i data-lucide="chevron-down" class="h-4 w-4 text-slate-400"></i>
                    </summary>
                    <ul class="mt-0.5 ml-7 border-l border-slate-100 pl-3 space-y-0.5">
                        <li><a href="payment.aspx" data-nav-link="payment.aspx" class="block rounded-lg px-3 py-2 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:13px;font-weight:500">Payment</a></li>
                        <li><a href="payment-history.aspx" data-nav-link="payment-history.aspx" class="block rounded-lg px-3 py-2 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:13px;font-weight:500">Payment History</a></li>
                    </ul>
                </details>
            </li>
            <li>
                <a href="timetable.aspx" data-nav-link="timetable.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="calendar-days" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Timetable</span>
                </a>
            </li>
            <li>
                <a href="assignments.aspx" data-nav-link="assignments.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="clipboard-list" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Assignments</span>
                    <span class="rounded-md px-1.5 bg-slate-100 text-slate-600" style="font-size:11px;font-weight:600">3</span>
                </a>
            </li>
            <li>
                <a href="grades.aspx" data-nav-link="grades.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="graduation-cap" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Grades</span>
                </a>
            </li>
            <li>
                <a href="notifications.aspx" data-nav-link="notifications.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="bell" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Notifications</span>
                    <span class="rounded-md px-1.5 bg-slate-100 text-slate-600" style="font-size:11px;font-weight:600">3</span>
                </a>
            </li>
            <li>
                <a href="attendance.aspx" data-nav-link="attendance.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="user-check" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    <span class="flex-1">Attendance</span>
                </a>
            </li>
        </ul>

        <p class="mt-7 px-3 pb-2 text-slate-400" style="font-size:11px;font-weight:600;letter-spacing:0.08em">SUPPORT</p>
        <ul class="space-y-0.5">
            <li>
                <a href="account.aspx" data-nav-link="account.aspx" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 transition-all text-slate-600 hover:bg-slate-50 hover:text-slate-900 data-[active=true]:bg-[#e0162b]/10 data-[active=true]:text-[#a01020] data-[active=true]:font-semibold" style="font-size:14px;font-weight:500">
                    <i data-lucide="user-cog" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    Account
                </a>
            </li>
            <li>
                <a href="#" class="group flex items-center gap-3 rounded-xl px-3 py-2.5 text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition-all" style="font-size:14px;font-weight:500">
                    <i data-lucide="life-buoy" class="h-4 w-4 text-slate-400 group-hover:text-slate-700"></i>
                    Help &amp; Support
                </a>
            </li>
        </ul>
    </nav>

    <div class="border-t border-slate-100 p-3">
        <a href="login.aspx" class="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-slate-600 hover:bg-slate-50 hover:text-[#e0162b] transition-colors" style="font-size:14px;font-weight:500">
            <i data-lucide="log-out" class="h-4 w-4 text-slate-400"></i>
            Sign out
        </a>
    </div>
</aside>
