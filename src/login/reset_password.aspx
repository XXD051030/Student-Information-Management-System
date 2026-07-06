<%@ Page Language="C#" MasterPageFile="LoginLayout.master" AutoEventWireup="true" CodeBehind="reset_password.aspx.cs" Inherits="src.login.reset_password" Title="Reset password - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="flex w-full max-w-md flex-col">

        <div class="mb-10">
            <div class="inline-flex items-center gap-2 rounded-full border border-indigo-100 bg-indigo-50/70 px-3 py-1 text-indigo-700" style="font-size:12px;font-weight:500">
                <i data-lucide="lock" class="h-3.5 w-3.5"></i>
                Reset password
            </div>
            <h2 id="reset-heading" class="mt-4 text-gray-900" style="font-size:28px;font-weight:700;letter-spacing:-0.005em">Choose a new password</h2>
            <p id="reset-subtitle" class="mt-2 text-gray-500" style="font-size:15px;line-height:1.6">Pick a strong password you don't use anywhere else.</p>
        </div>

        <div class="rounded-2xl border border-gray-200/80 bg-white p-8 shadow-[0_8px_30px_-12px_rgba(15,23,42,0.12)]">

            <!-- RESET FORM -->
            <div id="form-card">
                <div class="flex flex-col gap-4">
                    <!-- New password -->
                    <div class="relative rounded-xl border bg-white transition-all border-gray-200 hover:border-gray-300">
                        <label for="password" class="pointer-events-none absolute left-4 transition-all top-1/2 -translate-y-1/2 text-gray-400" style="font-size:14px;font-weight:500" id="pw-label">New password</label>
                        <input id="password" name="password" type="password" autocomplete="new-password" autofocus class="block w-full bg-transparent pl-4 pr-12 pt-6 pb-2 text-gray-900 outline-none" style="font-size:14px;font-weight:400;height:56px" />
                        <button type="button" data-action="toggle-pw" data-target="password" aria-label="Show password" class="absolute right-3 top-1/2 -translate-y-1/2 rounded-md p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-700 transition-colors">
                            <i data-lucide="eye" class="h-4 w-4"></i>
                        </button>
                    </div>

                    <!-- Confirm password -->
                    <div class="relative rounded-xl border bg-white transition-all border-gray-200 hover:border-gray-300">
                        <label for="confirm" class="pointer-events-none absolute left-4 transition-all top-1/2 -translate-y-1/2 text-gray-400" style="font-size:14px;font-weight:500" id="confirm-label">Confirm new password</label>
                        <input id="confirm" name="confirm" type="password" autocomplete="new-password" class="block w-full bg-transparent pl-4 pr-12 pt-6 pb-2 text-gray-900 outline-none" style="font-size:14px;font-weight:400;height:56px" />
                        <button type="button" data-action="toggle-pw" data-target="confirm" aria-label="Show password" class="absolute right-3 top-1/2 -translate-y-1/2 rounded-md p-1.5 text-gray-400 hover:bg-gray-100 hover:text-gray-700 transition-colors">
                            <i data-lucide="eye" class="h-4 w-4"></i>
                        </button>
                    </div>
                </div>

                <!-- Requirements checklist -->
                <ul id="pw-rules" class="mt-4 grid grid-cols-1 gap-1.5 px-1" style="font-size:13px">
                    <li data-rule="len"    class="flex items-center gap-2 text-gray-400"><i data-lucide="circle" class="h-3.5 w-3.5"></i>At least 8 characters</li>
                    <li data-rule="upper"  class="flex items-center gap-2 text-gray-400"><i data-lucide="circle" class="h-3.5 w-3.5"></i>An uppercase letter</li>
                    <li data-rule="lower"  class="flex items-center gap-2 text-gray-400"><i data-lucide="circle" class="h-3.5 w-3.5"></i>A lowercase letter</li>
                    <li data-rule="digit"  class="flex items-center gap-2 text-gray-400"><i data-lucide="circle" class="h-3.5 w-3.5"></i>A number</li>
                    <li data-rule="symbol" class="flex items-center gap-2 text-gray-400"><i data-lucide="circle" class="h-3.5 w-3.5"></i>A symbol</li>
                    <li data-rule="match"  class="flex items-center gap-2 text-gray-400"><i data-lucide="circle" class="h-3.5 w-3.5"></i>Both passwords match</li>
                </ul>

                <div class="mt-2 min-h-[20px] px-1">
                    <div id="reset-error" class="hidden items-center gap-1.5 text-red-600" style="font-size:13px">
                        <i data-lucide="alert-circle" class="h-3.5 w-3.5"></i>
                        <span id="reset-error-text"></span>
                    </div>
                </div>

                <button id="reset_submit" runat="server" type="submit" onserverclick="ResetSubmit_Click" ClientIDMode="Static" disabled="disabled" class="mt-4 group flex w-full items-center justify-center gap-2 rounded-xl px-4 transition-all h-12 bg-indigo-300 text-white cursor-not-allowed" style="font-size:15px;font-weight:600">
                    <span id="reset-label">Reset password</span>
                    <i data-lucide="arrow-right" class="h-4 w-4 transition-transform group-hover:translate-x-0.5"></i>
                </button>
            </div>

            <!-- INVALID LINK (hidden initially) -->
            <div id="invalid-card" class="hidden">
                <div class="flex flex-col items-center text-center">
                    <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-red-50 ring-1 ring-red-100">
                        <i data-lucide="link-2-off" class="h-6 w-6 text-red-600"></i>
                    </div>
                    <h3 class="mt-5 text-gray-900" style="font-size:18px;font-weight:700">This link isn't valid</h3>
                    <p class="mt-2 text-gray-500" style="font-size:14px;line-height:1.6">
                        Your reset link is invalid or has expired. Request a new one to continue.
                    </p>
                    <a href="<%= ResolveUrl("~/login/forgot_password.aspx") %>" class="mt-6 inline-flex items-center justify-center gap-2 rounded-xl px-5 h-11 bg-gradient-to-r from-indigo-600 to-indigo-700 text-white shadow-[0_8px_20px_-8px_rgba(79,70,229,0.6)] hover:from-indigo-700 hover:to-indigo-800 transition-all" style="font-size:14px;font-weight:600">
                        Request a new link
                    </a>
                </div>
            </div>

            <!-- SUCCESS (hidden initially) -->
            <div id="success-card" class="hidden">
                <div class="flex flex-col items-center text-center">
                    <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-50 ring-1 ring-emerald-100">
                        <i data-lucide="check-circle-2" class="h-6 w-6 text-emerald-600"></i>
                    </div>
                    <h3 class="mt-5 text-gray-900" style="font-size:18px;font-weight:700">Password updated</h3>
                    <p class="mt-2 text-gray-500" style="font-size:14px;line-height:1.6">
                        Your password has been reset. You can now sign in with your new password.
                    </p>
                    <a href="<%= ResolveUrl("~/login/login.aspx") %>" class="mt-6 inline-flex items-center justify-center gap-2 rounded-xl px-5 h-11 bg-gradient-to-r from-indigo-600 to-indigo-700 text-white shadow-[0_8px_20px_-8px_rgba(79,70,229,0.6)] hover:from-indigo-700 hover:to-indigo-800 transition-all" style="font-size:14px;font-weight:600">
                        Continue to sign in
                    </a>
                </div>
            </div>

        </div>

        <div id="back-row" class="mt-8 flex items-center justify-center px-1" style="font-size:13px">
            <a href="<%= ResolveUrl("~/login/login.aspx") %>" class="inline-flex items-center gap-1.5 text-gray-500 hover:text-indigo-600 transition-colors">
                <i data-lucide="arrow-left" class="h-3.5 w-3.5"></i>
                Back to sign in
            </a>
        </div>
    </div>

    <asp:HiddenField ID="TokenField"   runat="server" ClientIDMode="Static" Value="" />
    <asp:HiddenField ID="ShowInvalid"  runat="server" ClientIDMode="Static" Value="" />
    <asp:HiddenField ID="ShowSuccess"  runat="server" ClientIDMode="Static" Value="" />
    <asp:HiddenField ID="ServerError"  runat="server" ClientIDMode="Static" Value="" />
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/login/reset_password.js") %>"></script>
</asp:Content>
