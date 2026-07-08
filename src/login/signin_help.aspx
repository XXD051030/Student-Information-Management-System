<%@ Page Language="C#" MasterPageFile="LoginLayout.master" AutoEventWireup="true" Title="Sign-in Help - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="w-full max-w-xl">
        <div class="mb-6">
            <a href="<%= ResolveUrl("~/login/login.aspx") %>" class="inline-flex items-center gap-2 text-gray-500 hover:text-indigo-600 transition-colors" style="font-size:13px;font-weight:600">
                <i data-lucide="arrow-left" class="h-4 w-4"></i>
                Back to sign in
            </a>
        </div>

        <section class="overflow-hidden rounded-2xl border border-gray-200/80 bg-white shadow-[0_18px_45px_-28px_rgba(15,23,42,0.35)]">
            <div class="bg-gradient-to-br from-indigo-950 via-slate-950 to-[#e0162b] px-8 py-8 text-white">
                <span class="inline-flex items-center gap-2 rounded-full border border-white/20 bg-white/10 px-3 py-1 text-white/85 backdrop-blur" style="font-size:12px;font-weight:700">
                    <i data-lucide="circle-help" class="h-3.5 w-3.5"></i>
                    Sign-in help
                </span>
                <h1 class="mt-5 text-white" style="font-size:30px;font-weight:750;line-height:1.15">Not sure how to get into your account?</h1>
                <p class="mt-4 max-w-md text-white/75" style="font-size:14px;line-height:1.7">Choose the situation that matches you. Some problems can be fixed with password reset, but account and email issues need campus IT support.</p>
            </div>

            <div class="divide-y divide-gray-100">
                <div class="px-8 py-6">
                    <div class="flex items-start gap-4">
                        <span class="mt-0.5 flex h-11 w-11 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600">
                            <i data-lucide="key-round" class="h-5 w-5"></i>
                        </span>
                        <div class="min-w-0 flex-1">
                            <h2 class="text-gray-900" style="font-size:15px;font-weight:750">I forgot my password</h2>
                            <p class="mt-2 text-gray-500" style="font-size:13.5px;line-height:1.7">Use password reset if you still know your INTI portal email address.</p>
                            <a href="<%= ResolveUrl("~/login/forgot_password.aspx") %>" class="mt-4 inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-4 py-2.5 text-white hover:bg-indigo-700 transition-colors" style="font-size:13px;font-weight:750">
                                Reset password
                                <i data-lucide="arrow-right" class="h-4 w-4"></i>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="px-8 py-6">
                    <div class="flex items-start gap-4">
                        <span class="mt-0.5 flex h-11 w-11 items-center justify-center rounded-xl bg-amber-50 text-amber-600">
                            <i data-lucide="mail-question" class="h-5 w-5"></i>
                        </span>
                        <div>
                            <h2 class="text-gray-900" style="font-size:15px;font-weight:750">I forgot my email</h2>
                            <p class="mt-2 text-gray-500" style="font-size:13.5px;line-height:1.7">Ask campus IT to check your portal account. Bring your student or staff ID so they can confirm the correct email address.</p>
                        </div>
                    </div>
                </div>

                <div class="px-8 py-6">
                    <div class="flex items-start gap-4">
                        <span class="mt-0.5 flex h-11 w-11 items-center justify-center rounded-xl bg-rose-50 text-[#e0162b]">
                            <i data-lucide="user-plus" class="h-5 w-5"></i>
                        </span>
                        <div>
                            <h2 class="text-gray-900" style="font-size:15px;font-weight:750">I do not have an account</h2>
                            <p class="mt-2 text-gray-500" style="font-size:13.5px;line-height:1.7">Visit campus IT or Student Services. They need to create or activate your account before you can sign in.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex flex-col gap-3 bg-gray-50 px-8 py-6 sm:flex-row sm:items-center sm:justify-between">
                <p class="text-gray-500" style="font-size:12.5px;line-height:1.6">Tip: use your institutional INTI email, not a personal email address.</p>
                <a href="<%= ResolveUrl("~/login/help_center.aspx") %>" class="inline-flex items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-gray-700 hover:border-indigo-200 hover:text-indigo-600 transition-colors" style="font-size:13px;font-weight:700">
                    Open Help Center
                    <i data-lucide="life-buoy" class="h-4 w-4"></i>
                </a>
            </div>
        </section>
    </div>
</asp:Content>
