// My Courses page: semester toggle (current/all), search, empty-state.
// Cards are rendered server-side; each <article> carries:
//   data-current="true|false"  – belongs to the current semester
//   data-search="..."          – lowercased code/name/lecturer for search
(function () {
    "use strict";

    var state = { semester: "current", query: "" };

    function cards() {
        return Array.prototype.slice.call(document.querySelectorAll("#course-grid [data-course-code]"));
    }

    function applyFilters() {
        var q = state.query.trim().toLowerCase();
        var visible = 0;

        cards().forEach(function (card) {
            var matchesSemester = state.semester === "all" || card.getAttribute("data-current") === "true";
            var matchesQuery = q === "" || (card.getAttribute("data-search") || "").indexOf(q) !== -1;
            var show = matchesSemester && matchesQuery;
            card.style.display = show ? "" : "none";
            if (show) { visible++; }
        });

        var noResults = document.getElementById("no-results");
        if (noResults) { noResults.classList.toggle("hidden", visible !== 0); }
    }

    function activateSemesterButton(clicked) {
        var buttons = document.querySelectorAll('[data-action="filter-semester"]');
        Array.prototype.forEach.call(buttons, function (b) {
            var active = b === clicked;
            b.classList.toggle("bg-slate-900", active);
            b.classList.toggle("text-white", active);
            b.classList.toggle("border", !active);
            b.classList.toggle("border-slate-200", !active);
            b.classList.toggle("bg-white", !active);
            b.classList.toggle("text-slate-600", !active);
        });
    }

    function init() {
        // Semester buttons
        Array.prototype.forEach.call(
            document.querySelectorAll('[data-action="filter-semester"]'),
            function (btn) {
                btn.addEventListener("click", function () {
                    state.semester = btn.getAttribute("data-semester") || "current";
                    activateSemesterButton(btn);
                    applyFilters();
                });
            }
        );

        // Search
        var search = document.getElementById("course-search");
        if (search) {
            search.addEventListener("input", function () {
                state.query = search.value || "";
                applyFilters();
            });
        }

        // Establish the default active filter button visually (current).
        var currentBtn = document.querySelector('[data-action="filter-semester"][data-semester="current"]');
        if (currentBtn) { activateSemesterButton(currentBtn); }

        applyFilters();
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
