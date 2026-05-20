<%@ Page Language="C#" MasterPageFile="~/shared/DashboardLayout.master" AutoEventWireup="true" CodeBehind="payment-history.aspx.cs" Inherits="student_information_management_system.payment_history" Title="Payment History - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- BODY PORTED FROM payment-history-page.tsx --%>

    <%-- Page header --%>
    <div>
        <p class="text-slate-500" style="font-size:13px;font-weight:500">Payment</p>
        <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">
            Payment history
        </h1>
        <p class="mt-1 text-slate-500" style="font-size:14px">
            All transactions on your student account.
        </p>
    </div>

    <%-- Summary stat cards --%>
    <section class="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-4">

        <%-- Total paid --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Total paid</p>
            <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">RM 13,927</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">Across all semesters</p>
        </div>

        <%-- This year (2026) --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <p class="text-slate-500" style="font-size:12.5px;font-weight:500">This year (2026)</p>
            <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">RM 4,862</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">Paid in 2026</p>
        </div>

        <%-- Refunded --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Refunded</p>
            <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">RM 500</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">Lifetime</p>
        </div>

        <%-- Receipts --%>
        <div class="rounded-2xl border border-slate-200 bg-white p-5">
            <p class="text-slate-500" style="font-size:12.5px;font-weight:500">Receipts</p>
            <p class="mt-1 text-slate-900" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">6</p>
            <p class="mt-0.5 text-slate-400" style="font-size:11.5px">Total transactions</p>
        </div>

    </section>

    <%-- Transactions table --%>
    <section class="mt-8 rounded-2xl border border-slate-200 bg-white">

        <%-- Table header / filter bar --%>
        <header class="flex flex-col gap-4 p-6 lg:flex-row lg:items-end lg:justify-between">
            <div>
                <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Transactions</h2>
                <p class="text-slate-500 mt-0.5" style="font-size:13px">6 of 6 shown</p>
            </div>
            <div class="flex flex-wrap items-center gap-2">

                <%-- Status filter --%>
                <div class="relative">
                    <span class="pointer-events-none absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-400">
                        <i data-lucide="receipt" class="h-3.5 w-3.5"></i>
                    </span>
                    <select class="h-9 appearance-none rounded-xl border border-slate-200 bg-white pl-7 pr-8 text-slate-700 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10"
                            style="font-size:12.5px;font-weight:500">
                        <option value="all">All statuses</option>
                        <option value="paid">Paid</option>
                        <option value="pending">Pending</option>
                        <option value="refunded">Refunded</option>
                        <option value="failed">Failed</option>
                    </select>
                    <i data-lucide="chevron-down" class="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400"></i>
                </div>

                <%-- Method filter --%>
                <div class="relative">
                    <span class="pointer-events-none absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-400">
                        <i data-lucide="credit-card" class="h-3.5 w-3.5"></i>
                    </span>
                    <select class="h-9 appearance-none rounded-xl border border-slate-200 bg-white pl-7 pr-8 text-slate-700 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10"
                            style="font-size:12.5px;font-weight:500">
                        <option value="all">All methods</option>
                        <option value="fpx">FPX</option>
                        <option value="card">Card</option>
                        <option value="ewallet">E-Wallet</option>
                        <option value="bank">Bank transfer</option>
                    </select>
                    <i data-lucide="chevron-down" class="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400"></i>
                </div>

                <%-- Year filter --%>
                <div class="relative">
                    <span class="pointer-events-none absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-400">
                        <i data-lucide="calendar" class="h-3.5 w-3.5"></i>
                    </span>
                    <select class="h-9 appearance-none rounded-xl border border-slate-200 bg-white pl-7 pr-8 text-slate-700 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10"
                            style="font-size:12.5px;font-weight:500">
                        <option value="all">All years</option>
                        <option value="2026">2026</option>
                        <option value="2025">2025</option>
                        <option value="2024">2024</option>
                    </select>
                    <i data-lucide="chevron-down" class="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400"></i>
                </div>

                <%-- Search --%>
                <div class="relative w-44">
                    <i data-lucide="search" class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400"></i>
                    <input
                        type="text"
                        placeholder="Search invoice&#8230;"
                        class="h-9 w-full rounded-xl border border-slate-200 bg-white pl-8 pr-3 text-slate-900 placeholder:text-slate-400 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10"
                        style="font-size:12.5px" />
                </div>

            </div>
        </header>

        <%-- Table --%>
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead>
                    <tr class="text-slate-500" style="font-size:11px;font-weight:600;letter-spacing:0.04em">
                        <th class="text-left px-6 py-3">INVOICE</th>
                        <th class="text-left px-3 py-3">DESCRIPTION</th>
                        <th class="text-left px-3 py-3">DATE</th>
                        <th class="text-left px-3 py-3">METHOD</th>
                        <th class="text-right px-3 py-3">AMOUNT</th>
                        <th class="text-center px-3 py-3">STATUS</th>
                        <th class="text-right px-6 py-3">ACTION</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">

                    <%-- Row 1: INV-2026-0418 — Tuition Y2 T1 2025/26 — paid --%>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5 text-slate-900" style="font-size:12.5px;font-weight:600">INV-2026-0418</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">
                            <div>Tuition &mdash; Y2 T1 2025/26</div>
                            <div class="text-slate-400" style="font-size:11px">Y2 &middot; Trimester 1</div>
                        </td>
                        <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">12 Jan 2026</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">FPX Online Banking</td>
                        <td class="px-3 py-3.5 text-right text-slate-900" style="font-size:12.5px;font-weight:600">RM 4,862</td>
                        <td class="px-3 py-3.5 text-center">
                            <span class="inline-flex rounded-md px-2 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:11px;font-weight:600">Paid</span>
                        </td>
                        <td class="px-6 py-3.5 text-right">
                            <button class="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-slate-700 hover:bg-slate-50 transition-colors"
                                    style="font-size:11.5px;font-weight:600">
                                <i data-lucide="download" class="h-3.5 w-3.5"></i> PDF
                            </button>
                        </td>
                    </tr>

                    <%-- Row 2: INV-2025-0922 — Tuition Y1 T2 2024/25 — paid --%>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5 text-slate-900" style="font-size:12.5px;font-weight:600">INV-2025-0922</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">
                            <div>Tuition &mdash; Y1 T2 2024/25</div>
                            <div class="text-slate-400" style="font-size:11px">Y1 &middot; Trimester 2</div>
                        </td>
                        <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">01 Sep 2025</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">Credit / Debit Card</td>
                        <td class="px-3 py-3.5 text-right text-slate-900" style="font-size:12.5px;font-weight:600">RM 4,540</td>
                        <td class="px-3 py-3.5 text-center">
                            <span class="inline-flex rounded-md px-2 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:11px;font-weight:600">Paid</span>
                        </td>
                        <td class="px-6 py-3.5 text-right">
                            <button class="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-slate-700 hover:bg-slate-50 transition-colors"
                                    style="font-size:11.5px;font-weight:600">
                                <i data-lucide="download" class="h-3.5 w-3.5"></i> PDF
                            </button>
                        </td>
                    </tr>

                    <%-- Row 3: INV-2025-0501 — Library fine — paid --%>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5 text-slate-900" style="font-size:12.5px;font-weight:600">INV-2025-0501</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">
                            <div>Library fine</div>
                            <div class="text-slate-400" style="font-size:11px">Y1 &middot; Trimester 2</div>
                        </td>
                        <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">10 May 2025</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">E-Wallet</td>
                        <td class="px-3 py-3.5 text-right text-slate-900" style="font-size:12.5px;font-weight:600">RM 25</td>
                        <td class="px-3 py-3.5 text-center">
                            <span class="inline-flex rounded-md px-2 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:11px;font-weight:600">Paid</span>
                        </td>
                        <td class="px-6 py-3.5 text-right">
                            <button class="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-slate-700 hover:bg-slate-50 transition-colors"
                                    style="font-size:11.5px;font-weight:600">
                                <i data-lucide="download" class="h-3.5 w-3.5"></i> PDF
                            </button>
                        </td>
                    </tr>

                    <%-- Row 4: INV-2025-0118 — Tuition Y1 T1 2024/25 — paid --%>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5 text-slate-900" style="font-size:12.5px;font-weight:600">INV-2025-0118</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">
                            <div>Tuition &mdash; Y1 T1 2024/25</div>
                            <div class="text-slate-400" style="font-size:11px">Y1 &middot; Trimester 1</div>
                        </td>
                        <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">08 Jan 2025</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">Bank Transfer</td>
                        <td class="px-3 py-3.5 text-right text-slate-900" style="font-size:12.5px;font-weight:600">RM 4,380</td>
                        <td class="px-3 py-3.5 text-center">
                            <span class="inline-flex rounded-md px-2 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:11px;font-weight:600">Paid</span>
                        </td>
                        <td class="px-6 py-3.5 text-right">
                            <button class="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-slate-700 hover:bg-slate-50 transition-colors"
                                    style="font-size:11.5px;font-weight:600">
                                <i data-lucide="download" class="h-3.5 w-3.5"></i> PDF
                            </button>
                        </td>
                    </tr>

                    <%-- Row 5: INV-2024-1124 — Hostel deposit (refunded) — refunded --%>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5 text-slate-900" style="font-size:12.5px;font-weight:600">INV-2024-1124</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">
                            <div>Hostel deposit (refunded)</div>
                            <div class="text-slate-400" style="font-size:11px">Y1 &middot; Trimester 1</div>
                        </td>
                        <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">20 Nov 2024</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">FPX Online Banking</td>
                        <td class="px-3 py-3.5 text-right text-slate-900" style="font-size:12.5px;font-weight:600">RM 500</td>
                        <td class="px-3 py-3.5 text-center">
                            <span class="inline-flex rounded-md px-2 py-0.5 bg-slate-100 text-slate-600" style="font-size:11px;font-weight:600">Refunded</span>
                        </td>
                        <td class="px-6 py-3.5 text-right">
                            <button class="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-slate-700 hover:bg-slate-50 transition-colors"
                                    style="font-size:11.5px;font-weight:600">
                                <i data-lucide="download" class="h-3.5 w-3.5"></i> PDF
                            </button>
                        </td>
                    </tr>

                    <%-- Row 6: INV-2024-0928 — Co-curricular activity fee — paid --%>
                    <tr class="hover:bg-slate-50/60">
                        <td class="px-6 py-3.5 text-slate-900" style="font-size:12.5px;font-weight:600">INV-2024-0928</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">
                            <div>Co-curricular activity fee</div>
                            <div class="text-slate-400" style="font-size:11px">Y1 &middot; Trimester 1</div>
                        </td>
                        <td class="px-3 py-3.5 text-slate-500" style="font-size:12.5px">12 Sep 2024</td>
                        <td class="px-3 py-3.5 text-slate-700" style="font-size:12.5px">Credit / Debit Card</td>
                        <td class="px-3 py-3.5 text-right text-slate-900" style="font-size:12.5px;font-weight:600">RM 120</td>
                        <td class="px-3 py-3.5 text-center">
                            <span class="inline-flex rounded-md px-2 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:11px;font-weight:600">Paid</span>
                        </td>
                        <td class="px-6 py-3.5 text-right">
                            <button class="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-slate-700 hover:bg-slate-50 transition-colors"
                                    style="font-size:11.5px;font-weight:600">
                                <i data-lucide="download" class="h-3.5 w-3.5"></i> PDF
                            </button>
                        </td>
                    </tr>

                </tbody>
            </table>
        </div>

    </section>

</asp:Content>
