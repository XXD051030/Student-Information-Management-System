<%@ Page Language="C#" MasterPageFile="~/admin/AdminLayout.master" AutoEventWireup="true" CodeBehind="admin_account.aspx.cs" Inherits="src.admin.admin_account" Title="Account - INTI Admin Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div>
        <p class="text-slate-500" style="font-size:13px;font-weight:500">Settings</p>
        <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Account</h1>
        <p class="mt-1 text-slate-500" style="font-size:14px">Manage your profile and password.</p>
    </div>

    <div class="mt-6 space-y-5">

        <%-- Profile card --%>
        <section class="rounded-lg border border-slate-200 bg-white">
            <div class="border-b border-slate-100 px-6 py-4">
                <h2 class="text-slate-900" style="font-size:15px;font-weight:700">Profile</h2>
            </div>
            <div class="px-6 py-6">
                <div class="flex items-center gap-5">
                    <div class="relative inline-block">
                        <% if (!string.IsNullOrEmpty(IconUrl)) { %>
                            <img id="profile-icon-img" src="<%= IconUrl %>" alt="<%= Server.HtmlEncode(DisplayName) %>" class="h-20 w-20 rounded-full object-cover"
                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex';" />
                            <div id="profile-icon-initials" class="flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-[#e0162b] to-[#a01020] text-white" style="display:none;font-size:26px;font-weight:700">A</div>
                        <% } else { %>
                            <div id="profile-icon-initials" class="flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-[#e0162b] to-[#a01020] text-white" style="font-size:26px;font-weight:700">A</div>
                        <% } %>
                        <button type="button" id="change-icon-btn"
                                data-upload-url="<%= ResolveUrl("~/icon_upload.ashx") %>"
                                class="absolute -bottom-1 -right-1 inline-flex h-7 w-7 items-center justify-center rounded-full border-2 border-white bg-slate-700 text-white hover:bg-slate-900 transition-colors"
                                title="Change profile photo">
                            <i data-lucide="camera" class="h-3.5 w-3.5"></i>
                        </button>
                        <input type="file" id="icon-file-input" accept="image/jpeg,image/jpg,image/png,image/gif,image/webp" class="hidden" />
                    </div>
                    <div class="min-w-0">
                        <p class="text-slate-900 truncate" style="font-size:18px;font-weight:700;letter-spacing:-0.01em"><%= DisplayName %></p>
                        <p class="text-slate-500" style="font-size:13px"><%= RoleLabel %></p>
                        <div class="mt-2 inline-flex items-center gap-1.5 rounded border border-emerald-100 bg-emerald-50 px-2 py-0.5 text-emerald-700" style="font-size:11px;font-weight:700;letter-spacing:0.04em">
                            <span class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span> ADMINISTRATOR
                        </div>
                    </div>
                </div>

                <div class="mt-6" style="display:grid;grid-template-columns:1fr 1fr;gap:16px">

                    <%-- Read-only: Username --%>
                    <div>
                        <span class="inline-flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:600;letter-spacing:0.04em">
                            <i data-lucide="user" class="h-3.5 w-3.5 text-slate-400"></i> USERNAME
                        </span>
                        <div class="mt-1.5 flex h-10 w-full items-center rounded-md border border-slate-200 bg-slate-50/70 px-3">
                            <span class="text-slate-700 truncate" style="font-size:13px"><%= DisplayName %></span>
                        </div>
                    </div>

                    <%-- Read-only: Role --%>
                    <div>
                        <span class="inline-flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:600;letter-spacing:0.04em">
                            <i data-lucide="shield" class="h-3.5 w-3.5 text-slate-400"></i> ROLE
                        </span>
                        <div class="mt-1.5 flex h-10 w-full items-center rounded-md border border-slate-200 bg-slate-50/70 px-3">
                            <span class="text-slate-700 truncate" style="font-size:13px"><%= RoleLabel %></span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <%-- Change password --%>
        <section class="rounded-lg border border-slate-200 bg-white">
            <div class="border-b border-slate-100 px-6 py-4">
                <h2 class="text-slate-900 inline-flex items-center gap-2" style="font-size:15px;font-weight:700">
                    <i data-lucide="lock" class="h-4 w-4 text-slate-500"></i> Change password
                </h2>
                <p class="text-slate-500" style="font-size:12.5px">Use at least 8 characters with uppercase and lowercase letters, a number, and a symbol.</p>
            </div>

            <div id="password-form" class="px-6 py-6" style="display:grid;grid-template-columns:1fr 1fr;gap:16px">

                <%-- Current password (wide) --%>
                <label class="block" style="grid-column:1 / -1">
                    <span class="inline-flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:600;letter-spacing:0.04em">
                        <i data-lucide="lock" class="h-3.5 w-3.5 text-slate-400"></i> CURRENT PASSWORD
                    </span>
                    <div class="mt-1.5 relative">
                        <input id="pw-current" type="password" class="h-10 w-full rounded-md border border-slate-200 bg-white pl-3 pr-10 text-slate-900 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px" />
                        <button type="button" data-toggle-pw="pw-current" class="absolute right-2 top-1/2 -translate-y-1/2 inline-flex h-7 w-7 items-center justify-center rounded text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors" aria-label="Show password">
                            <i data-lucide="eye" class="h-4 w-4"></i>
                        </button>
                    </div>
                </label>

                <%-- New password --%>
                <label>
                    <span class="inline-flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:600;letter-spacing:0.04em">
                        <i data-lucide="lock" class="h-3.5 w-3.5 text-slate-400"></i> NEW PASSWORD
                    </span>
                    <div class="mt-1.5 relative">
                        <input id="pw-new" type="password" class="h-10 w-full rounded-md border border-slate-200 bg-white pl-3 pr-10 text-slate-900 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px" />
                        <button type="button" data-toggle-pw="pw-new" class="absolute right-2 top-1/2 -translate-y-1/2 inline-flex h-7 w-7 items-center justify-center rounded text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors" aria-label="Show password">
                            <i data-lucide="eye" class="h-4 w-4"></i>
                        </button>
                    </div>
                </label>

                <%-- Re-enter new password --%>
                <label>
                    <span class="inline-flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:600;letter-spacing:0.04em">
                        <i data-lucide="lock" class="h-3.5 w-3.5 text-slate-400"></i> RE-ENTER NEW PASSWORD
                    </span>
                    <div class="mt-1.5 relative">
                        <input id="pw-confirm" type="password" class="h-10 w-full rounded-md border border-slate-200 bg-white pl-3 pr-10 text-slate-900 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px" />
                        <button type="button" data-toggle-pw="pw-confirm" class="absolute right-2 top-1/2 -translate-y-1/2 inline-flex h-7 w-7 items-center justify-center rounded text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors" aria-label="Show password">
                            <i data-lucide="eye" class="h-4 w-4"></i>
                        </button>
                    </div>
                </label>

                <%-- Message slot --%>
                <div id="pw-msg" class="hidden items-start gap-2 rounded-md border px-3 py-2" style="font-size:12.5px;grid-column:1 / -1">
                    <i data-lucide="alert-circle" class="h-4 w-4 mt-0.5"></i>
                    <span id="pw-msg-text"></span>
                </div>

                <div class="flex items-center justify-end gap-2 pt-1" style="grid-column:1 / -1">
                    <button type="button" id="pw-submit-btn" class="inline-flex items-center gap-1.5 rounded-md bg-[#e0162b] px-4 h-10 text-white hover:bg-[#a01020] transition-colors shadow-[0_8px_18px_-10px_rgba(224,22,43,0.6)]" style="font-size:13px;font-weight:600">Update password</button>
                </div>
            </div>
        </section>

        <%-- Sign out --%>
        <section class="rounded-lg border border-[#e0162b]/20 bg-[#e0162b]/5 px-6 py-5 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div>
                <h3 class="text-[#a01020] inline-flex items-center gap-1.5" style="font-size:14px;font-weight:700">
                    <i data-lucide="log-out" class="h-4 w-4"></i> Sign out
                </h3>
                <p class="text-[#a01020]/80 mt-0.5" style="font-size:12.5px">End your session on this device.</p>
            </div>
            <a href="<%= ResolveUrl("~/login/login.aspx") %>" data-action="logout" class="inline-flex items-center justify-center gap-1.5 rounded-md bg-[#e0162b] px-4 h-10 text-white hover:bg-[#a01020] transition-colors shadow-[0_8px_18px_-10px_rgba(224,22,43,0.6)]" style="font-size:13px;font-weight:600">
                <i data-lucide="log-out" class="h-4 w-4"></i> Sign out
            </a>
        </section>

    </div>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/shared/account.js") %>"></script>
</asp:Content>
