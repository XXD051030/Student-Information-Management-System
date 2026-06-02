<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="lecturer_topbar.ascx.cs" Inherits="src.controls.lecturer_topbar" %>

<header class="sticky top-0 z-30 flex h-16 items-center gap-3 border-b border-slate-200 bg-white/80 px-6 backdrop-blur-md">
    <button type="button" data-action="toggle-menu" aria-label="Menu" aria-expanded="false"
            class="rounded-lg p-2 text-slate-600 hover:bg-slate-100 lg:hidden">
        <i data-lucide="menu" class="h-5 w-5"></i>
    </button>

    <div class="ml-auto flex items-center gap-2.5 rounded-full border border-slate-200 bg-white py-1 pl-3 pr-1">
        <div class="text-right leading-tight">
            <div class="text-slate-900" style="font-size:13px;font-weight:600"><%= DisplayName %></div>
            <div class="text-slate-500" style="font-size:11px"><%= RoleLabel %></div>
        </div>
        <span class="flex h-8 w-8 items-center justify-center rounded-full bg-indigo-600 text-white" style="font-size:13px;font-weight:600">
            <i data-lucide="presentation" class="h-4 w-4"></i>
        </span>
    </div>
</header>
