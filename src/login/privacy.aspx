<%@ Page Language="C#" MasterPageFile="LoginLayout.master" AutoEventWireup="true" Title="Privacy - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="w-full max-w-2xl">
        <div class="mb-6 flex flex-wrap items-center justify-between gap-3">
            <a href="<%= ResolveUrl("~/login/login.aspx") %>" class="inline-flex items-center gap-2 text-gray-500 hover:text-indigo-600 transition-colors" style="font-size:13px;font-weight:600">
                <i data-lucide="arrow-left" class="h-4 w-4"></i>
                Back to sign in
            </a>
            <span class="inline-flex items-center gap-2 rounded-full border border-emerald-100 bg-emerald-50 px-3 py-1 text-emerald-700" style="font-size:12px;font-weight:600">
                <i data-lucide="shield-check" class="h-3.5 w-3.5"></i>
                Privacy first
            </span>
        </div>

        <section class="overflow-hidden rounded-2xl border border-gray-200/80 bg-white shadow-[0_18px_45px_-28px_rgba(15,23,42,0.35)]">
            <div class="relative border-b border-gray-100 bg-gradient-to-br from-slate-950 via-indigo-950 to-[#e0162b] px-8 py-8 text-white">
                <div class="absolute right-8 top-8 flex h-14 w-14 items-center justify-center rounded-2xl bg-white/10 ring-1 ring-white/20 backdrop-blur">
                    <i data-lucide="lock-keyhole" class="h-7 w-7 text-amber-200"></i>
                </div>
                <p class="text-white/70" style="font-size:12px;font-weight:700;letter-spacing:0.08em">INTI STUDENT PORTAL</p>
                <h1 class="mt-3 max-w-md text-white" style="font-size:30px;font-weight:750;line-height:1.15">Your portal data stays protected and purposeful.</h1>
                <p class="mt-4 max-w-lg text-white/78" style="font-size:14px;line-height:1.7">We use account, academic and activity information only to run the portal, support learning services and keep the system secure.</p>
            </div>

            <div class="grid gap-0 md:grid-cols-3">
                <div class="border-b border-gray-100 px-6 py-5 md:border-b-0 md:border-r">
                    <p class="text-gray-900" style="font-size:22px;font-weight:750">3</p>
                    <p class="mt-1 text-gray-500" style="font-size:12.5px">Core data groups</p>
                </div>
                <div class="border-b border-gray-100 px-6 py-5 md:border-b-0 md:border-r">
                    <p class="text-gray-900" style="font-size:22px;font-weight:750">Secure</p>
                    <p class="mt-1 text-gray-500" style="font-size:12.5px">Sign-in and password handling</p>
                </div>
                <div class="px-6 py-5">
                    <p class="text-gray-900" style="font-size:22px;font-weight:750">Limited</p>
                    <p class="mt-1 text-gray-500" style="font-size:12.5px">Access by role and responsibility</p>
                </div>
            </div>

            <div class="divide-y divide-gray-100">
                <div class="grid gap-4 px-8 py-6 sm:grid-cols-[44px_1fr]">
                    <span class="flex h-11 w-11 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600">
                        <i data-lucide="database" class="h-5 w-5"></i>
                    </span>
                    <div>
                        <h2 class="text-gray-900" style="font-size:15px;font-weight:700">What we collect</h2>
                        <p class="mt-2 text-gray-500" style="font-size:13.5px;line-height:1.75">Your name, student or staff ID, institutional email, programme details, enrolments, attendance, grades, notifications and basic security records such as sign-in activity.</p>
                    </div>
                </div>

                <div class="grid gap-4 px-8 py-6 sm:grid-cols-[44px_1fr]">
                    <span class="flex h-11 w-11 items-center justify-center rounded-xl bg-rose-50 text-[#e0162b]">
                        <i data-lucide="sparkles" class="h-5 w-5"></i>
                    </span>
                    <div>
                        <h2 class="text-gray-900" style="font-size:15px;font-weight:700">How it is used</h2>
                        <p class="mt-2 text-gray-500" style="font-size:13.5px;line-height:1.75">The portal uses your data to show the right dashboard, timetable, course material, grade records, account notices and support information for your role.</p>
                    </div>
                </div>

                <div class="grid gap-4 px-8 py-6 sm:grid-cols-[44px_1fr]">
                    <span class="flex h-11 w-11 items-center justify-center rounded-xl bg-amber-50 text-amber-600">
                        <i data-lucide="users-round" class="h-5 w-5"></i>
                    </span>
                    <div>
                        <h2 class="text-gray-900" style="font-size:15px;font-weight:700">Who can access it</h2>
                        <p class="mt-2 text-gray-500" style="font-size:13.5px;line-height:1.75">Students see their own records. Lecturers see records connected to their assigned courses. Administrators can access records needed for academic and support operations.</p>
                    </div>
                </div>

                <div class="grid gap-4 px-8 py-6 sm:grid-cols-[44px_1fr]">
                    <span class="flex h-11 w-11 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                        <i data-lucide="mail" class="h-5 w-5"></i>
                    </span>
                    <div>
                        <h2 class="text-gray-900" style="font-size:15px;font-weight:700">Questions or corrections</h2>
                        <p class="mt-2 text-gray-500" style="font-size:13.5px;line-height:1.75">If your profile or academic record looks incorrect, contact support with your student ID, the page name and a short description of the issue.</p>
                        <div class="mt-4 inline-flex items-center gap-2 rounded-xl bg-gray-900 px-4 py-2.5 text-white" style="font-size:13px;font-weight:700">
                            Visit Student Services for support
                            <i data-lucide="map-pin" class="h-4 w-4"></i>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</asp:Content>
