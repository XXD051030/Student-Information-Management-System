<%@ Page Language="C#" MasterPageFile="LoginLayout.master" AutoEventWireup="true" Title="Help Center - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="w-full max-w-2xl">
        <div class="mb-6 flex flex-wrap items-center justify-between gap-3">
            <a href="<%= ResolveUrl("~/login/login.aspx") %>" class="inline-flex items-center gap-2 text-gray-500 hover:text-indigo-600 transition-colors" style="font-size:13px;font-weight:600">
                <i data-lucide="arrow-left" class="h-4 w-4"></i>
                Back to sign in
            </a>
            <span class="inline-flex items-center gap-2 rounded-full border border-indigo-100 bg-indigo-50 px-3 py-1 text-indigo-700" style="font-size:12px;font-weight:600">
                <i data-lucide="life-buoy" class="h-3.5 w-3.5"></i>
                Help Center
            </span>
        </div>

        <section class="overflow-hidden rounded-2xl border border-gray-200/80 bg-white shadow-[0_18px_45px_-28px_rgba(15,23,42,0.35)]">
            <div class="relative bg-gradient-to-br from-white via-indigo-50 to-rose-50 px-8 py-8">
                <div class="absolute right-8 top-8 hidden h-16 w-16 items-center justify-center rounded-2xl bg-white text-indigo-600 shadow-[0_14px_35px_-22px_rgba(79,70,229,0.65)] ring-1 ring-indigo-100 sm:flex">
                    <i data-lucide="messages-square" class="h-8 w-8"></i>
                </div>
                <p class="text-indigo-600" style="font-size:12px;font-weight:800;letter-spacing:0.08em">SIGN-IN SUPPORT</p>
                <h1 class="mt-3 max-w-md text-gray-950" style="font-size:30px;font-weight:750;line-height:1.15">Need help getting into your portal?</h1>
                <p class="mt-4 max-w-lg text-gray-500" style="font-size:14px;line-height:1.7">Try these quick checks first. If you are still blocked, the IT Helpdesk can help you reset access.</p>
            </div>

            <div class="grid gap-4 border-y border-gray-100 bg-white px-8 py-6 sm:grid-cols-3">
                <a href="<%= ResolveUrl("~/login/forgot_password.aspx") %>" class="group rounded-xl border border-gray-200 bg-gray-50/70 px-4 py-4 hover:border-indigo-200 hover:bg-indigo-50 transition-colors">
                    <i data-lucide="key-round" class="h-5 w-5 text-indigo-600"></i>
                    <p class="mt-3 text-gray-900" style="font-size:13.5px;font-weight:700">Reset password</p>
                    <p class="mt-1 text-gray-500" style="font-size:12.5px;line-height:1.45">Request a new reset link.</p>
                </a>
                <div class="rounded-xl border border-gray-200 bg-gray-50/70 px-4 py-4">
                    <i data-lucide="badge-help" class="h-5 w-5 text-[#e0162b]"></i>
                    <p class="mt-3 text-gray-900" style="font-size:13.5px;font-weight:700">Ask campus IT</p>
                    <p class="mt-1 text-gray-500" style="font-size:12.5px;line-height:1.45">For locked accounts.</p>
                </div>
                <a href="<%= ResolveUrl("~/login/login.aspx") %>" class="group rounded-xl border border-gray-200 bg-gray-50/70 px-4 py-4 hover:border-emerald-200 hover:bg-emerald-50 transition-colors">
                    <i data-lucide="log-in" class="h-5 w-5 text-emerald-600"></i>
                    <p class="mt-3 text-gray-900" style="font-size:13.5px;font-weight:700">Try again</p>
                    <p class="mt-1 text-gray-500" style="font-size:12.5px;line-height:1.45">Return to secure sign-in.</p>
                </a>
            </div>

            <div class="divide-y divide-gray-100">
                <div class="px-8 py-5">
                    <div class="flex items-start gap-4">
                        <span class="mt-0.5 flex h-9 w-9 items-center justify-center rounded-lg bg-indigo-50 text-indigo-600">
                            <i data-lucide="at-sign" class="h-4 w-4"></i>
                        </span>
                        <div>
                            <h2 class="text-gray-900" style="font-size:14.5px;font-weight:700">Use your INTI email</h2>
                            <p class="mt-1 text-gray-500" style="font-size:13px;line-height:1.7">Sign in with your institutional email, such as your student or lecturer email. Personal email addresses are not accepted for portal access.</p>
                        </div>
                    </div>
                </div>

                <div class="px-8 py-5">
                    <div class="flex items-start gap-4">
                        <span class="mt-0.5 flex h-9 w-9 items-center justify-center rounded-lg bg-amber-50 text-amber-600">
                            <i data-lucide="refresh-cw" class="h-4 w-4"></i>
                        </span>
                        <div>
                            <h2 class="text-gray-900" style="font-size:14.5px;font-weight:700">If a reset link does not arrive</h2>
                            <p class="mt-1 text-gray-500" style="font-size:13px;line-height:1.7">Check spam or junk mail, then wait a few minutes before requesting another link. If the email is still missing, ask campus IT to verify the account.</p>
                        </div>
                    </div>
                </div>

                <div class="px-8 py-5">
                    <div class="flex items-start gap-4">
                        <span class="mt-0.5 flex h-9 w-9 items-center justify-center rounded-lg bg-rose-50 text-[#e0162b]">
                            <i data-lucide="circle-alert" class="h-4 w-4"></i>
                        </span>
                        <div>
                            <h2 class="text-gray-900" style="font-size:14.5px;font-weight:700">Locked out or password unknown</h2>
                            <p class="mt-1 text-gray-500" style="font-size:13px;line-height:1.7">Prepare your full name, student or staff ID, portal email and a screenshot of the error so campus IT can verify the account.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="bg-slate-950 px-8 py-6 text-white">
                <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                        <p class="text-white" style="font-size:14px;font-weight:700">Campus IT Helpdesk</p>
                        <p class="mt-1 text-white/60" style="font-size:12.5px">Monday-Friday, 9:00 AM-5:00 PM (MYT)</p>
                    </div>
                    <div class="inline-flex items-center justify-center gap-2 rounded-xl bg-white px-4 py-2.5 text-slate-950" style="font-size:13px;font-weight:750">
                        Bring your student or staff ID
                        <i data-lucide="id-card" class="h-4 w-4"></i>
                    </div>
                </div>
            </div>
        </section>
    </div>
</asp:Content>
