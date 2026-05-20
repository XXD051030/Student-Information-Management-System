<%@ Page Language="C#" MasterPageFile="~/shared/DashboardLayout.master" AutoEventWireup="true" CodeBehind="courses.aspx.cs" Inherits="student_information_management_system.courses" Title="Courses - INTI Student Portal" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Header --%>
    <div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div>
            <p class="text-slate-500" style="font-size:13px;font-weight:500">BSc Computer Science</p>
            <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">My Courses</h1>
            <p class="mt-1 text-slate-500" style="font-size:14px">
                Browse all courses across your programme. Pin the ones you&#8217;d like quick access to from your dashboard.
            </p>
        </div>
        <div class="flex items-center gap-3">
            <div class="rounded-xl border border-slate-200 bg-white px-3 py-2">
                <div class="text-slate-500" style="font-size:11px;font-weight:500">Pinned</div>
                <div class="text-slate-900" style="font-size:16px;font-weight:700">
                    <span id="pinned-count">4</span><span class="text-slate-400"> / 18</span>
                </div>
            </div>
        </div>
    </div>

    <%-- Filters --%>
    <div class="mt-6 flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
        <div class="flex flex-wrap gap-2" id="semester-filters">
            <button data-action="filter-semester" data-semester="All semesters"
                class="rounded-full px-3.5 py-1.5 bg-slate-900 text-white transition-all"
                style="font-size:12.5px;font-weight:600">All semesters</button>
            <button data-action="filter-semester" data-semester="Y1 · Trimester 1"
                class="rounded-full px-3.5 py-1.5 border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:text-slate-900 transition-all"
                style="font-size:12.5px;font-weight:600">Y1 &middot; Trimester 1</button>
            <button data-action="filter-semester" data-semester="Y1 · Trimester 2"
                class="rounded-full px-3.5 py-1.5 border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:text-slate-900 transition-all"
                style="font-size:12.5px;font-weight:600">Y1 &middot; Trimester 2</button>
            <button data-action="filter-semester" data-semester="Y2 · Trimester 1"
                class="rounded-full px-3.5 py-1.5 border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:text-slate-900 transition-all"
                style="font-size:12.5px;font-weight:600">Y2 &middot; Trimester 1</button>
            <button data-action="filter-semester" data-semester="Y2 · Trimester 2"
                class="rounded-full px-3.5 py-1.5 border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:text-slate-900 transition-all"
                style="font-size:12.5px;font-weight:600">Y2 &middot; Trimester 2</button>
            <button data-action="filter-semester" data-semester="Y3 · Trimester 1"
                class="rounded-full px-3.5 py-1.5 border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:text-slate-900 transition-all"
                style="font-size:12.5px;font-weight:600">Y3 &middot; Trimester 1</button>
            <button data-action="filter-semester" data-semester="Y3 · Trimester 2"
                class="rounded-full px-3.5 py-1.5 border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:text-slate-900 transition-all"
                style="font-size:12.5px;font-weight:600">Y3 &middot; Trimester 2</button>
        </div>
        <div class="relative w-full lg:w-72">
            <i data-lucide="search" class="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400"></i>
            <input id="course-search" type="search" placeholder="Search by name or code&#8230;"
                class="h-10 w-full rounded-xl border border-slate-200 bg-white pl-10 pr-3 text-slate-900 placeholder:text-slate-400 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10"
                style="font-size:13px" />
        </div>
    </div>

    <%-- Course grid --%>
    <div class="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3" id="course-grid">

        <%-- ENG1001 — Completed --%>
        <article data-course-code="ENG1001"
            data-semester="Y1 · Trimester 1"
            data-search="eng1001 english for academic purposes ms. jenny wong"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#10b981"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#10b98115;color:#10b981">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="ENG1001" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">ENG1001</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="check-circle-2" class="h-3 w-3"></i> Completed
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">English for Academic Purposes</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Foundations of academic reading, writing, and critical thinking.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Ms. Jenny Wong</span>
                <span>3 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y1 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=ENG1001"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- MTH1001 — Completed --%>
        <article data-course-code="MTH1001"
            data-semester="Y1 · Trimester 1"
            data-search="mth1001 foundation mathematics dr. aravind p."
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#3b82f6"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#3b82f615;color:#3b82f6">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="MTH1001" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">MTH1001</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="check-circle-2" class="h-3 w-3"></i> Completed
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Foundation Mathematics</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Core algebra, functions, and an introduction to calculus.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Aravind P.</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y1 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=MTH1001"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC1101 — Completed --%>
        <article data-course-code="CSC1101"
            data-semester="Y1 · Trimester 1"
            data-search="csc1101 introduction to programming mr. daniel lee"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#e0162b"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#e0162b15;color:#e0162b">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC1101" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC1101</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="check-circle-2" class="h-3 w-3"></i> Completed
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Introduction to Programming</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Programming fundamentals using Python &#8212; variables, control flow, functions.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Mr. Daniel Lee</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y1 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=CSC1101"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC1102 — Completed --%>
        <article data-course-code="CSC1102"
            data-semester="Y1 · Trimester 2"
            data-search="csc1102 object-oriented programming ms. tan hui ying"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#e0162b"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#e0162b15;color:#e0162b">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC1102" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC1102</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="check-circle-2" class="h-3 w-3"></i> Completed
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Object-Oriented Programming</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">OOP principles in Java: classes, inheritance, polymorphism, design patterns.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Ms. Tan Hui Ying</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y1 &middot; Trimester 2</span>
                <a href="/student/academic/course-detail.aspx?code=CSC1102"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- MTH1002 — Completed --%>
        <article data-course-code="MTH1002"
            data-semester="Y1 · Trimester 2"
            data-search="mth1002 calculus & linear algebra dr. aravind p."
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#3b82f6"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#3b82f615;color:#3b82f6">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="MTH1002" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">MTH1002</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="check-circle-2" class="h-3 w-3"></i> Completed
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Calculus &amp; Linear Algebra</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Differential &amp; integral calculus with linear algebra foundations.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Aravind P.</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y1 &middot; Trimester 2</span>
                <a href="/student/academic/course-detail.aspx?code=MTH1002"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- PHY1001 — Completed --%>
        <article data-course-code="PHY1001"
            data-semester="Y1 · Trimester 2"
            data-search="phy1001 physics for computing dr. mei lin"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#a855f7"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#a855f715;color:#a855f7">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="PHY1001" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">PHY1001</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-emerald-50 text-emerald-700" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="check-circle-2" class="h-3 w-3"></i> Completed
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Physics for Computing</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Physical principles relevant to computing hardware and signals.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Mei Lin</span>
                <span>3 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y1 &middot; Trimester 2</span>
                <a href="/student/academic/course-detail.aspx?code=PHY1001"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC2103 — In progress --%>
        <article data-course-code="CSC2103"
            data-semester="Y2 · Trimester 1"
            data-search="csc2103 data structures & algorithms ms. tan hui ying"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#3b82f6"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#3b82f615;color:#3b82f6">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC2103" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2103</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020]" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="circle" class="h-3 w-3"></i> In progress
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Data Structures &amp; Algorithms</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Arrays, lists, trees, graphs, sorting, searching, and complexity analysis.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Ms. Tan Hui Ying</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y2 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=CSC2103"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC2104 — In progress --%>
        <article data-course-code="CSC2104"
            data-semester="Y2 · Trimester 1"
            data-search="csc2104 software engineering dr. lim wei han"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#e0162b"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#e0162b15;color:#e0162b">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC2104" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2104</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020]" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="circle" class="h-3 w-3"></i> In progress
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Software Engineering</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Software lifecycle, requirements, agile, testing, and team collaboration.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Lim Wei Han</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y2 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=CSC2104"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- MTH2101 — In progress --%>
        <article data-course-code="MTH2101"
            data-semester="Y2 · Trimester 1"
            data-search="mth2101 discrete mathematics dr. rajesh k."
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#f59e0b"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#f59e0b15;color:#f59e0b">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="MTH2101" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">MTH2101</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020]" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="circle" class="h-3 w-3"></i> In progress
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Discrete Mathematics</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Logic, sets, combinatorics, graph theory, proofs.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Rajesh K.</span>
                <span>3 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y2 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=MTH2101"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- ENG2001 — In progress --%>
        <article data-course-code="ENG2001"
            data-semester="Y2 · Trimester 1"
            data-search="eng2001 professional communication ms. sarah choo"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#10b981"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#10b98115;color:#10b981">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="ENG2001" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">ENG2001</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-[#e0162b]/10 text-[#a01020]" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="circle" class="h-3 w-3"></i> In progress
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Professional Communication</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Workplace communication, presentations, and report writing.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Ms. Sarah Choo</span>
                <span>2 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y2 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=ENG2001"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC2201 — Upcoming --%>
        <article data-course-code="CSC2201"
            data-semester="Y2 · Trimester 2"
            data-search="csc2201 database systems dr. lim wei han"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#0ea5e9"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#0ea5e915;color:#0ea5e9">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC2201" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2201</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="clock" class="h-3 w-3"></i> Upcoming
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Database Systems</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Relational design, SQL, transactions, normalization, and NoSQL basics.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Lim Wei Han</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y2 &middot; Trimester 2</span>
                <a href="/student/academic/course-detail.aspx?code=CSC2201"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC2202 — Upcoming --%>
        <article data-course-code="CSC2202"
            data-semester="Y2 · Trimester 2"
            data-search="csc2202 computer networks mr. daniel lee"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#6366f1"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#6366f115;color:#6366f1">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC2202" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2202</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="clock" class="h-3 w-3"></i> Upcoming
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Computer Networks</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">OSI/TCP-IP models, routing, transport, and application protocols.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Mr. Daniel Lee</span>
                <span>3 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y2 &middot; Trimester 2</span>
                <a href="/student/academic/course-detail.aspx?code=CSC2202"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC2203 — Upcoming --%>
        <article data-course-code="CSC2203"
            data-semester="Y2 · Trimester 2"
            data-search="csc2203 operating systems dr. mei lin"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#a855f7"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#a855f715;color:#a855f7">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC2203" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC2203</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="clock" class="h-3 w-3"></i> Upcoming
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Operating Systems</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Processes, threads, scheduling, memory, and file systems.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Mei Lin</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y2 &middot; Trimester 2</span>
                <a href="/student/academic/course-detail.aspx?code=CSC2203"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC3101 — Upcoming --%>
        <article data-course-code="CSC3101"
            data-semester="Y3 · Trimester 1"
            data-search="csc3101 web application development mr. daniel lee"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#e0162b"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#e0162b15;color:#e0162b">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC3101" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC3101</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="clock" class="h-3 w-3"></i> Upcoming
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Web Application Development</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Modern full-stack web development with React and Node.js.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Mr. Daniel Lee</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y3 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=CSC3101"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC3102 — Upcoming --%>
        <article data-course-code="CSC3102"
            data-semester="Y3 · Trimester 1"
            data-search="csc3102 artificial intelligence dr. aravind p."
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#f59e0b"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#f59e0b15;color:#f59e0b">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC3102" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC3102</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="clock" class="h-3 w-3"></i> Upcoming
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Artificial Intelligence</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Search, knowledge representation, machine learning fundamentals.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Aravind P.</span>
                <span>4 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y3 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=CSC3102"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC3103 — Upcoming --%>
        <article data-course-code="CSC3103"
            data-semester="Y3 · Trimester 1"
            data-search="csc3103 cybersecurity fundamentals dr. mei lin"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#0f766e"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#0f766e15;color:#0f766e">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC3103" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC3103</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="clock" class="h-3 w-3"></i> Upcoming
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Cybersecurity Fundamentals</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Threats, cryptography, network security, secure coding.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Dr. Mei Lin</span>
                <span>3 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y3 &middot; Trimester 1</span>
                <a href="/student/academic/course-detail.aspx?code=CSC3103"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC3201 — Upcoming --%>
        <article data-course-code="CSC3201"
            data-semester="Y3 · Trimester 2"
            data-search="csc3201 final year project i faculty supervisor"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#e0162b"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#e0162b15;color:#e0162b">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC3201" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC3201</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="clock" class="h-3 w-3"></i> Upcoming
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Final Year Project I</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Capstone project &#8212; proposal, research, and design phase.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Faculty Supervisor</span>
                <span>6 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y3 &middot; Trimester 2</span>
                <a href="/student/academic/course-detail.aspx?code=CSC3201"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

        <%-- CSC3202 — Upcoming --%>
        <article data-course-code="CSC3202"
            data-semester="Y3 · Trimester 2"
            data-search="csc3202 cloud computing mr. daniel lee"
            class="group relative flex flex-col rounded-2xl border border-slate-200 bg-white p-5 hover:border-slate-300 hover:shadow-sm transition-all">
            <span class="absolute top-0 left-5 right-5 h-1 rounded-b-full" style="background-color:#0ea5e9"></span>
            <div class="flex items-start justify-between">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl" style="background-color:#0ea5e915;color:#0ea5e9">
                    <i data-lucide="book-open" class="h-4 w-4"></i>
                </div>
                <button data-action="toggle-pin" data-code="CSC3202" aria-label="Toggle pin"
                    class="rounded-lg p-2 transition-all text-slate-400 hover:bg-slate-100 hover:text-slate-700">
                    <i data-lucide="pin" data-pinned-icon class="h-4 w-4"></i>
                </button>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <span class="rounded-md bg-slate-100 px-1.5 py-0.5 text-slate-600" style="font-size:10.5px;font-weight:600">CSC3202</span>
                <span class="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 bg-slate-100 text-slate-600" style="font-size:10.5px;font-weight:600">
                    <i data-lucide="clock" class="h-3 w-3"></i> Upcoming
                </span>
            </div>
            <h3 class="mt-2 text-slate-900" style="font-size:15.5px;font-weight:600;line-height:1.3">Cloud Computing</h3>
            <p class="mt-1.5 text-slate-500 line-clamp-2" style="font-size:12.5px;line-height:1.55">Cloud service models, AWS/Azure, containerization.</p>
            <div class="mt-4 flex items-center justify-between text-slate-500" style="font-size:12px">
                <span>Mr. Daniel Lee</span>
                <span>3 credits</span>
            </div>
            <div class="mt-4 border-t border-slate-100 pt-3 flex items-center justify-between">
                <span class="text-slate-500" style="font-size:11.5px;font-weight:500">Y3 &middot; Trimester 2</span>
                <a href="/student/academic/course-detail.aspx?code=CSC3202"
                    class="inline-flex items-center gap-1 text-[#e0162b] hover:text-[#a01020] transition-colors"
                    style="font-size:12.5px;font-weight:600">
                    Open course <i data-lucide="arrow-right" class="h-3.5 w-3.5"></i>
                </a>
            </div>
        </article>

    </div>

    <%-- Empty state (hidden by default; shown by JS when search yields no results) --%>
    <div id="no-results" class="hidden mt-10 rounded-2xl border border-dashed border-slate-300 bg-white p-12 text-center">
        <p class="text-slate-700" style="font-size:15px;font-weight:600">No courses match your filters</p>
        <p class="mt-1 text-slate-500" style="font-size:13px">Try a different semester or search term.</p>
    </div>

</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/courses/courses.js") %>"></script>
</asp:Content>
