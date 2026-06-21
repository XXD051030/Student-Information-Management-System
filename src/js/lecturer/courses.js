// Lecturer My Courses page: semester filter (all / a specific semester), search,
// pin, empty-state. Cards are rendered server-side; each <article> carries:
//   data-semester="2026-S2"    – the offering's semester (matched against the tab)
//   data-search="..."          – lowercased code/name for search
//   data-course-code="CODE"     – stable key for pinning
(function () {
    "use strict";

    var PIN_KEY = "lecturer.courses.pinned";
    var state = { semester: "all", pinnedOnly: false, query: "" };

    function cards() {
        return Array.prototype.slice.call(document.querySelectorAll("#course-grid [data-course-code]"));
    }

    function loadPins() {
        try { return JSON.parse(localStorage.getItem(PIN_KEY)) || []; }
        catch (e) { return []; }
    }

    function savePins(pins) {
        // Storage can throw in private mode or when the quota is exceeded; in that
        // case the pin is simply not persisted across reloads.
        try { localStorage.setItem(PIN_KEY, JSON.stringify(pins)); }
        catch (e) { /* storage unavailable */ }
    }

    function isPinned(code) {
        return loadPins().indexOf(code) !== -1;
    }

    function sortCards() {
        var grid = document.getElementById("course-grid");
        if (!grid) { return; }

        var pins = loadPins();
        cards()
            .sort(function (left, right) {
                var leftCode = left.getAttribute("data-course-code");
                var rightCode = right.getAttribute("data-course-code");
                var leftPinIndex = pins.indexOf(leftCode);
                var rightPinIndex = pins.indexOf(rightCode);
                var leftPinned = leftPinIndex !== -1;
                var rightPinned = rightPinIndex !== -1;

                if (leftPinned && !rightPinned) { return -1; }
                if (!leftPinned && rightPinned) { return 1; }
                if (leftPinned && rightPinned) { return leftPinIndex - rightPinIndex; }

                return Number(left.getAttribute("data-original-order")) -
                    Number(right.getAttribute("data-original-order"));
            })
            .forEach(function (card) {
                grid.appendChild(card);
            });
    }

    function applyFilters() {
        var q = state.query.trim().toLowerCase();
        var visible = 0;

        cards().forEach(function (card) {
            var matchesSemester = state.semester === "all" || card.getAttribute("data-semester") === state.semester;
            var matchesPinned = !state.pinnedOnly || isPinned(card.getAttribute("data-course-code"));
            var matchesQuery = q === "" || (card.getAttribute("data-search") || "").indexOf(q) !== -1;
            var show = matchesSemester && matchesPinned && matchesQuery;
            card.style.display = show ? "" : "none";
            if (show) { visible++; }
        });

        var noResults = document.getElementById("no-results");
        if (noResults) { noResults.classList.toggle("hidden", visible !== 0); }
    }

    function updatePinnedCount() {
        var el = document.getElementById("pinned-count");
        if (!el) { return; }
        var courseCodes = cards().map(function (card) {
            return card.getAttribute("data-course-code");
        });
        var count = loadPins().filter(function (code) {
            return courseCodes.indexOf(code) !== -1;
        }).length;
        el.textContent = String(count);
    }

    function paintPin(card) {
        var code = card.getAttribute("data-course-code");
        var btn = card.querySelector('[data-action="toggle-pin"]');
        if (!btn) { return; }
        // Inline style rather than a Tailwind arbitrary class: the Play CDN may not
        // generate styles for a class only ever added dynamically by JS.
        if (isPinned(code)) {
            btn.style.color = "#e0162b";
        } else {
            btn.style.removeProperty("color");
        }
    }

    function togglePin(code) {
        var pins = loadPins();
        var i = pins.indexOf(code);
        if (i === -1) { pins.push(code); } else { pins.splice(i, 1); }
        savePins(pins);
    }

    function activateFilterButton(clicked) {
        var buttons = document.querySelectorAll('[data-action="filter-semester"], [data-action="filter-pinned"]');
        Array.prototype.forEach.call(buttons, function (b) {
            var active = b === clicked;
            b.classList.toggle("bg-slate-900", active);
            b.classList.toggle("text-white", active);
            b.classList.toggle("border", !active);
            b.classList.toggle("border-slate-200", !active);
            b.classList.toggle("bg-white", !active);
            b.classList.toggle("text-slate-600", !active);
            b.classList.toggle("hover:border-slate-300", !active);
            b.classList.toggle("hover:text-slate-900", !active);
        });
    }

    function init() {
        cards().forEach(function (card, index) {
            card.setAttribute("data-original-order", String(index));
        });

        // Semester buttons
        Array.prototype.forEach.call(
            document.querySelectorAll('[data-action="filter-semester"]'),
            function (btn) {
                btn.addEventListener("click", function () {
                    state.semester = btn.getAttribute("data-semester") || "all";
                    state.pinnedOnly = false;
                    activateFilterButton(btn);
                    applyFilters();
                });
            }
        );

        var pinnedFilter = document.querySelector('[data-action="filter-pinned"]');
        if (pinnedFilter) {
            pinnedFilter.addEventListener("click", function () {
                state.semester = "all";
                state.pinnedOnly = true;
                activateFilterButton(pinnedFilter);
                applyFilters();
            });
        }

        // Search
        var search = document.getElementById("course-search");
        if (search) {
            search.addEventListener("input", function () {
                state.query = search.value || "";
                applyFilters();
            });
        }

        // Pin buttons
        cards().forEach(function (card) {
            paintPin(card);
            var btn = card.querySelector('[data-action="toggle-pin"]');
            if (btn) {
                btn.addEventListener("click", function () {
                    togglePin(card.getAttribute("data-course-code"));
                    paintPin(card);
                    sortCards();
                    updatePinnedCount();
                    applyFilters();
                });
            }
        });

        // Establish the default active filter button visually (all semesters).
        var allBtn = document.querySelector('[data-action="filter-semester"][data-semester="all"]');
        if (allBtn) { activateFilterButton(allBtn); }

        sortCards();
        updatePinnedCount();
        applyFilters();
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
