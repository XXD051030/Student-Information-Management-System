<%@ Page Language="C#" MasterPageFile="LoginLayout.master" AutoEventWireup="true" CodeBehind="forgot_password.aspx.cs" Inherits="src.login.forgot_password" Title="Forgot password - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="flex w-full max-w-md flex-col">

        <div class="mb-10">
            <div class="inline-flex items-center gap-2 rounded-full border border-indigo-100 bg-indigo-50/70 px-3 py-1 text-indigo-700" style="font-size:12px;font-weight:500">
                <i data-lucide="key-round" class="h-3.5 w-3.5"></i>
                Account recovery
            </div>
            <h2 id="forgot-heading" class="mt-4 text-gray-900" style="font-size:28px;font-weight:700;letter-spacing:-0.005em">Forgot your password?</h2>
            <p id="forgot-subtitle" class="mt-2 text-gray-500" style="font-size:15px;line-height:1.6">Enter your email and we'll send you a link to reset it.</p>
        </div>

        <div class="rounded-2xl border border-gray-200/80 bg-white p-8 shadow-[0_8px_30px_-12px_rgba(15,23,42,0.12)]">

            <!-- REQUEST FORM -->
            <div id="request-card">
                <div class="flex flex-col gap-2">
                    <div id="email-wrap" class="relative rounded-xl border bg-white transition-all border-gray-200 hover:border-gray-300">
                        <label for="email" class="pointer-events-none absolute left-4 transition-all top-1/2 -translate-y-1/2 text-gray-400" style="font-size:14px;font-weight:500" id="email-label">Email address</label>
                        <input id="email" name="email" type="email" autocomplete="email" autofocus class="block w-full bg-transparent px-4 pt-6 pb-2 text-gray-900 outline-none" style="font-size:14px;font-weight:400;height:56px" />
                    </div>
                    <div class="min-h-[20px] px-1">
                        <p id="email-helper" class="text-gray-500" style="font-size:13px">Use the email you sign in with.</p>
                        <div id="email-error" class="hidden items-center gap-1.5 text-red-600" style="font-size:13px">
                            <i data-lucide="alert-circle" class="h-3.5 w-3.5"></i>
                            <span id="email-error-text">Please enter a valid email.</span>
                        </div>
                    </div>
                </div>

                <button id="send_submit" runat="server" type="submit" onserverclick="SendSubmit_Click" ClientIDMode="Static" disabled="disabled" class="mt-6 group flex w-full items-center justify-center gap-2 rounded-xl px-4 transition-all h-12 bg-indigo-300 text-white cursor-not-allowed" style="font-size:15px;font-weight:600">
                    <span id="send-label">Send reset link</span>
                    <span id="send-arrow" class="inline-flex"><i data-lucide="arrow-right" class="h-4 w-4 transition-transform group-hover:translate-x-0.5"></i></span>
                    <span id="send-spinner" class="hidden"><i data-lucide="loader-2" class="h-4 w-4 animate-spin"></i></span>
                </button>
            </div>

            <!-- SENT CONFIRMATION (hidden initially) -->
            <div id="sent-card" class="hidden">
                <div class="flex flex-col items-center text-center">
                    <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-50 ring-1 ring-emerald-100">
                        <i data-lucide="mail-check" class="h-6 w-6 text-emerald-600"></i>
                    </div>
                    <h3 class="mt-5 text-gray-900" style="font-size:18px;font-weight:700">Check your inbox</h3>
                    <p class="mt-2 text-gray-500" style="font-size:14px;line-height:1.6">
                        If an account exists for that email, we've sent a link to reset your password. The link expires in 1&nbsp;hour.
                    </p>
                </div>
            </div>

        </div>

        <div class="mt-8 flex items-center justify-center px-1" style="font-size:13px">
            <a href="<%= ResolveUrl("~/login/login.aspx") %>" class="inline-flex items-center gap-1.5 text-gray-500 hover:text-indigo-600 transition-colors">
                <i data-lucide="arrow-left" class="h-3.5 w-3.5"></i>
                Back to sign in
            </a>
        </div>
    </div>

    <asp:HiddenField ID="ShowSent"     runat="server" ClientIDMode="Static" Value="" />
    <asp:HiddenField ID="ServerError"  runat="server" ClientIDMode="Static" Value="" />
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/login/forgot_password.js") %>"></script>
</asp:Content>
