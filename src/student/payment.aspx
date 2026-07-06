<%@ Page Language="C#" MasterPageFile="~/student/StudentLayout.master" AutoEventWireup="true" CodeBehind="payment.aspx.cs" Inherits="src.student.payment" Title="Payment - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- BODY PORTED FROM payment-checkout-page.tsx --%>

    <%-- Header --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500">Step 2 of 2 &middot; Payment</p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Complete your payment</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">
                Settle the tuition for <span class="text-slate-900 font-semibold"><asp:Literal ID="litTermHeader" runat="server" /></span> to finalize your enrollment.
            </p>
        </div>
        <div class="flex items-center gap-2 rounded-xl border border-emerald-200 bg-emerald-50 px-3 py-2 text-emerald-700">
            <i data-lucide="shield" class="h-4 w-4"></i>
            <span style="font-size:12.5px;font-weight:600">Secure &middot; 256-bit encryption</span>
        </div>
    </div>

    <%-- Empty state (hidden when rows are present) --%>
    <div id="payment-empty" class="hidden mt-6 rounded-2xl border border-amber-200 bg-amber-50 p-6 text-center">
        <i data-lucide="alert-circle" class="h-8 w-8 mx-auto text-amber-500"></i>
        <p class="mt-3 text-slate-900" style="font-size:15px;font-weight:600">No courses selected</p>
        <p class="mt-1 text-slate-500" style="font-size:13px">
            You have not selected any courses for payment. Please go back to enrollment and select your courses.
        </p>
        <a href="<%= ResolveUrl("enrollment.aspx") %>"
           class="mt-4 inline-flex items-center gap-2 rounded-xl bg-[#e0162b] px-5 h-10 text-white"
           style="font-size:13px;font-weight:600">
            <i data-lucide="arrow-left" class="h-4 w-4"></i>
            Back to Enrollment
        </a>
    </div>

    <%-- Main grid --%>
    <section class="mt-6 grid gap-6 lg:grid-cols-3">

        <%-- Left: Invoice summary --%>
        <div class="lg:col-span-2 rounded-2xl border border-slate-200 bg-white">
            <header class="flex items-center justify-between border-b border-slate-100 p-6">
                <div>
                    <h2 class="text-slate-900" style="font-size:16px;font-weight:600">Invoice summary</h2>
                    <p class="text-slate-500 mt-0.5" style="font-size:13px"><asp:Literal ID="litTermSummary" runat="server" /></p>
                </div>
                <span class="rounded-md bg-amber-50 px-2 py-1 text-amber-700" style="font-size:11.5px;font-weight:600">Pending payment</span>
            </header>

            <%-- Student info row --%>
            <div class="border-b border-slate-100 px-6 py-4 grid gap-1 sm:grid-cols-2">
                <div>
                    <p class="text-slate-400" style="font-size:11px;font-weight:600;letter-spacing:0.05em;text-transform:uppercase">Student</p>
                    <p class="mt-0.5 text-slate-900" style="font-size:13.5px;font-weight:600"><asp:Literal ID="litStudentName" runat="server" /></p>
                    <p class="text-slate-500" style="font-size:12px"><asp:Literal ID="litStudentIdProgramme" runat="server" /></p>
                </div>
                <div>
                    <p class="text-slate-400" style="font-size:11px;font-weight:600;letter-spacing:0.05em;text-transform:uppercase">Due date</p>
                    <p class="mt-0.5 text-slate-900" style="font-size:13.5px;font-weight:600">31 Aug 2026</p>
                    <p class="text-slate-500" style="font-size:12px"><asp:Literal ID="litStudentEmail" runat="server" /></p>
                </div>
            </div>

            <%-- Line-items table (populated by JS from sessionStorage) --%>
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead>
                        <tr class="border-b border-slate-100">
                            <th class="px-6 py-3 text-left text-slate-400" style="font-size:11px;font-weight:700;letter-spacing:0.05em;text-transform:uppercase">Course</th>
                            <th class="px-6 py-3 text-left text-slate-400" style="font-size:11px;font-weight:700;letter-spacing:0.05em;text-transform:uppercase">Name</th>
                            <th class="px-6 py-3 text-left text-slate-400" style="font-size:11px;font-weight:700;letter-spacing:0.05em;text-transform:uppercase">Credits</th>
                            <th class="px-6 py-3 text-right text-slate-400" style="font-size:11px;font-weight:700;letter-spacing:0.05em;text-transform:uppercase">Fee</th>
                        </tr>
                    </thead>
                    <tbody id="payment-rows">
                        <%-- Rows are populated by payment.js from sessionStorage['sims:enrolled'] --%>
                    </tbody>
                </table>
            </div>

            <%-- Summary totals --%>
            <div class="border-t border-slate-100 p-6 space-y-2">
                <div class="flex items-center justify-between">
                    <span class="text-slate-500" style="font-size:13.5px">Subtotal</span>
                    <span class="text-slate-900" style="font-size:13.5px;font-weight:600">RM <span id="pay-subtotal">0.00</span></span>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-slate-500" style="font-size:13.5px">Tax (6% SST)</span>
                    <span class="text-slate-900" style="font-size:13.5px;font-weight:600">RM <span id="pay-tax">0.00</span></span>
                </div>
                <div class="flex items-center justify-between pt-3 border-t border-slate-100">
                    <span class="text-slate-900" style="font-size:14px;font-weight:700">Total amount</span>
                    <span class="text-slate-900" style="font-size:18px;font-weight:700;letter-spacing:-0.005em">RM <span id="pay-total">0.00</span></span>
                </div>
            </div>
        </div>

        <%-- Right: Payment method + pay button --%>
        <aside class="rounded-2xl border border-slate-200 bg-white p-6">
            <h3 class="text-slate-900" style="font-size:15px;font-weight:600">Payment method</h3>

            <div class="mt-3 space-y-2">

                <%-- Credit / Debit Card (default) --%>
                <label class="flex w-full items-center gap-3 rounded-xl border border-[#e0162b] bg-[#e0162b]/5 ring-4 ring-[#e0162b]/10 px-3 py-3 cursor-pointer transition-all">
                    <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-[#e0162b] text-white">
                        <i data-lucide="credit-card" class="h-4 w-4"></i>
                    </span>
                    <span class="flex-1">
                        <span class="block text-slate-900" style="font-size:13px;font-weight:600">Credit / Debit Card</span>
                        <span class="block text-slate-500" style="font-size:11.5px">Visa, Mastercard, Amex</span>
                    </span>
                    <input type="radio" name="payment-method" value="card" checked class="sr-only" />
                    <span class="h-4 w-4 rounded-full border-2 border-[#e0162b] bg-[#e0162b]"></span>
                </label>

                <%-- FPX Online Banking --%>
                <label class="flex w-full items-center gap-3 rounded-xl border border-slate-200 hover:border-slate-300 px-3 py-3 cursor-pointer transition-all">
                    <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                        <i data-lucide="building-2" class="h-4 w-4"></i>
                    </span>
                    <span class="flex-1">
                        <span class="block text-slate-900" style="font-size:13px;font-weight:600">FPX Online Banking</span>
                        <span class="block text-slate-500" style="font-size:11.5px">Maybank, CIMB, Public Bank&hellip;</span>
                    </span>
                    <input type="radio" name="payment-method" value="bank" class="sr-only" />
                    <span class="h-4 w-4 rounded-full border-2 border-slate-300"></span>
                </label>

                <%-- E-Wallet --%>
                <label class="flex w-full items-center gap-3 rounded-xl border border-slate-200 hover:border-slate-300 px-3 py-3 cursor-pointer transition-all">
                    <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-100 text-slate-600">
                        <i data-lucide="smartphone" class="h-4 w-4"></i>
                    </span>
                    <span class="flex-1">
                        <span class="block text-slate-900" style="font-size:13px;font-weight:600">E-Wallet</span>
                        <span class="block text-slate-500" style="font-size:11.5px">Touch 'n Go, Boost, GrabPay</span>
                    </span>
                    <input type="radio" name="payment-method" value="ewallet" class="sr-only" />
                    <span class="h-4 w-4 rounded-full border-2 border-slate-300"></span>
                </label>

            </div>

            <%-- Method detail panels --%>
            <div class="mt-5">

                <%-- Card panel (visible by default) --%>
                <div data-method-panel="card">
                    <div class="space-y-3">
                        <div>
                            <label class="block text-slate-600 mb-1" style="font-size:12px;font-weight:600">Card number</label>
                            <input type="text" placeholder="1234 5678 9012 3456" maxlength="19"
                                   class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-slate-900 placeholder-slate-300 focus:outline-none focus:ring-2 focus:ring-[#e0162b]/30 focus:border-[#e0162b]"
                                   style="font-size:13.5px" />
                        </div>
                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label class="block text-slate-600 mb-1" style="font-size:12px;font-weight:600">Expiry</label>
                                <input type="text" placeholder="MM / YY" maxlength="7"
                                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-slate-900 placeholder-slate-300 focus:outline-none focus:ring-2 focus:ring-[#e0162b]/30 focus:border-[#e0162b]"
                                       style="font-size:13.5px" />
                            </div>
                            <div>
                                <label class="block text-slate-600 mb-1" style="font-size:12px;font-weight:600">CVV</label>
                                <input type="text" placeholder="&bull;&bull;&bull;" maxlength="4"
                                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-slate-900 placeholder-slate-300 focus:outline-none focus:ring-2 focus:ring-[#e0162b]/30 focus:border-[#e0162b]"
                                       style="font-size:13.5px" />
                            </div>
                        </div>
                        <div>
                            <label class="block text-slate-600 mb-1" style="font-size:12px;font-weight:600">Name on card</label>
                            <input type="text" placeholder="AISYAH YUSOFF"
                                   class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-slate-900 placeholder-slate-300 focus:outline-none focus:ring-2 focus:ring-[#e0162b]/30 focus:border-[#e0162b]"
                                   style="font-size:13.5px" />
                        </div>
                    </div>
                </div>

                <%-- Bank / FPX panel (hidden by default) --%>
                <div data-method-panel="bank" class="hidden">
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 space-y-2">
                        <p class="text-slate-900" style="font-size:13px;font-weight:600">FPX Online Banking</p>
                        <p class="text-slate-500" style="font-size:12.5px">You will be redirected to your bank's secure portal to complete the payment.</p>
                        <div class="mt-2">
                            <label class="block text-slate-600 mb-1" style="font-size:12px;font-weight:600">Select your bank</label>
                            <select class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-slate-900 bg-white focus:outline-none focus:ring-2 focus:ring-[#e0162b]/30 focus:border-[#e0162b]"
                                    style="font-size:13.5px">
                                <option value="">-- Choose a bank --</option>
                                <option value="maybank">Maybank2u</option>
                                <option value="cimb">CIMB Clicks</option>
                                <option value="publicbank">Public Bank</option>
                                <option value="rhb">RHB Now</option>
                                <option value="hongleong">Hong Leong Connect</option>
                                <option value="ambank">AmBank</option>
                            </select>
                        </div>
                    </div>
                </div>

                <%-- E-Wallet panel (hidden by default) --%>
                <div data-method-panel="ewallet" class="hidden">
                    <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 space-y-3">
                        <p class="text-slate-900" style="font-size:13px;font-weight:600">E-Wallet</p>
                        <p class="text-slate-500" style="font-size:12.5px">Scan the QR code or enter your mobile number to complete payment via your e-wallet app.</p>
                        <div>
                            <label class="block text-slate-600 mb-1" style="font-size:12px;font-weight:600">Select e-wallet</label>
                            <div class="grid grid-cols-3 gap-2">
                                <label class="flex flex-col items-center gap-1.5 rounded-xl border border-slate-200 bg-white p-3 cursor-pointer hover:border-[#e0162b] transition-all">
                                    <span class="text-slate-900" style="font-size:12px;font-weight:600">Touch 'n Go</span>
                                    <input type="radio" name="ewallet-provider" value="tng" class="sr-only" />
                                </label>
                                <label class="flex flex-col items-center gap-1.5 rounded-xl border border-slate-200 bg-white p-3 cursor-pointer hover:border-[#e0162b] transition-all">
                                    <span class="text-slate-900" style="font-size:12px;font-weight:600">Boost</span>
                                    <input type="radio" name="ewallet-provider" value="boost" class="sr-only" />
                                </label>
                                <label class="flex flex-col items-center gap-1.5 rounded-xl border border-slate-200 bg-white p-3 cursor-pointer hover:border-[#e0162b] transition-all">
                                    <span class="text-slate-900" style="font-size:12px;font-weight:600">GrabPay</span>
                                    <input type="radio" name="ewallet-provider" value="grabpay" class="sr-only" />
                                </label>
                            </div>
                        </div>
                        <div>
                            <label class="block text-slate-600 mb-1" style="font-size:12px;font-weight:600">Mobile number</label>
                            <input type="tel" placeholder="+60 12-345 6789"
                                   class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-slate-900 placeholder-slate-300 focus:outline-none focus:ring-2 focus:ring-[#e0162b]/30 focus:border-[#e0162b]"
                                   style="font-size:13.5px" />
                        </div>
                    </div>
                </div>

            </div>

            <%-- Divider --%>
            <div class="my-5 h-px bg-slate-100"></div>

            <%-- Total amount repeat --%>
            <div class="flex items-baseline justify-between">
                <span class="text-slate-500" style="font-size:12.5px;font-weight:500">Total amount</span>
                <span class="text-slate-900" style="font-size:24px;font-weight:700;letter-spacing:-0.01em">RM <span id="pay-total-aside">0.00</span></span>
            </div>

            <%-- Pay button --%>
            <asp:HiddenField ID="hfAmount" runat="server" />
            <asp:HiddenField ID="hfDescription" runat="server" />
            <asp:HiddenField ID="hfMethod" runat="server" />
            <asp:HiddenField ID="hfOfferingIds" runat="server" />
            <asp:HiddenField ID="hfPaymentToken" runat="server" />
            <asp:Button ID="btnPay" runat="server" OnClick="PayBtn_Click"
                OnClientClick="try{sessionStorage.removeItem('sims:enrolled');}catch(e){} this.disabled=true;this.value='Processing…';"
                UseSubmitBehavior="false"
                CssClass="mt-4 inline-flex w-full items-center justify-center gap-2 rounded-xl px-5 h-12 bg-[#e0162b] text-white hover:bg-[#a01020] shadow-[0_8px_20px_-8px_rgba(224,22,43,0.55)] transition-all"
                style="font-size:14px;font-weight:700"
                Text="Pay" />

            <%-- Refund policy note --%>
            <p class="mt-3 inline-flex items-center gap-1.5 text-slate-500" style="font-size:11.5px">
                <i data-lucide="alert-circle" class="h-3.5 w-3.5"></i>
                By paying you agree to INTI's refund policy.
            </p>
        </aside>

    </section>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/student/payment.js") %>"></script>
</asp:Content>
