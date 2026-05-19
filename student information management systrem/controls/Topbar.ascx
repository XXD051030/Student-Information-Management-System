<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Topbar.ascx.cs" Inherits="student_information_management_system.controls.Topbar" %>

<header class="sticky top-0 z-20 flex h-16 items-center gap-3 border-b border-slate-200 bg-white/80 backdrop-blur-md px-6">
    <button data-action="toggle-menu" aria-label="Menu" aria-expanded="false" class="lg:hidden rounded-lg p-2 text-slate-600 hover:bg-slate-100">
        <i data-lucide="menu" class="h-5 w-5"></i>
    </button>

    <div class="ml-auto flex items-center gap-2">
        <button class="inline-flex h-10 w-10 items-center justify-center rounded-xl text-slate-500 hover:bg-slate-100 hover:text-slate-900 transition-colors" aria-label="Help">
            <i data-lucide="help-circle" class="h-5 w-5"></i>
        </button>

        <a href="notifications.aspx" class="relative inline-flex h-10 w-10 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-600 hover:bg-slate-50 hover:text-slate-900 transition-colors" aria-label="Notifications">
            <i data-lucide="bell" class="h-4 w-4"></i>
            <span id="topbar-notif-count" class="absolute -right-1 -top-1 inline-flex min-w-[18px] h-[18px] items-center justify-center rounded-full bg-[#e0162b] px-1 text-white ring-2 ring-white" style="font-size:10px;font-weight:700">3</span>
        </a>

        <a href="account.aspx" class="flex items-center gap-2.5 rounded-full border border-slate-200 bg-white pl-1 pr-3 py-1 hover:border-[#e0162b]/30 hover:bg-[#e0162b]/[0.03] transition-colors" aria-label="Open account">
            <div class="flex h-8 w-8 items-center justify-center rounded-full bg-gradient-to-br from-[#e0162b] to-[#a01020] text-white" style="font-size:12.5px;font-weight:600">AY</div>
            <div class="leading-tight text-left">
                <div class="text-slate-900" style="font-size:13px;font-weight:600">Aisyah Yusoff</div>
                <div class="text-slate-500" style="font-size:11px">BSc Computer Science &middot; Y2</div>
            </div>
        </a>
    </div>
</header>
