// Lecturer My Courses page: semester filter (all / a specific semester), search,
// pin, empty-state. Cards are rendered server-side; each <article> carries:
//   data-semester="2026-S2"    – the offering's semester (matched against the tab)
//   data-search="..."          – lowercased code/name for search
//   data-course-code="CODE"     – stable key for pinning
(function () {
    "use strict";

    var PIN_KEY = "lecturer.courses.pinned";
    var state = { academicYear: "all", semester: "all", pinnedOnly: false, query: "" };

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
            var matchesYear = state.academicYear === "all" || card.getAttribute("data-academic-year") === state.academicYear;
            var matchesSemester = state.semester === "all" || card.getAttribute("data-semester") === state.semester;
            var matchesPinned = !state.pinnedOnly || isPinned(card.getAttribute("data-course-code"));
            var matchesQuery = q === "" || (card.getAttribute("data-search") || "").indexOf(q) !== -1;
            var show = matchesYear && matchesSemester && matchesPinned && matchesQuery;
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
        var buttons = document.querySelectorAll('[data-action="filter-all"], [data-action="filter-pinned"]');
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

    function distinctCardValues(attribute, year) {
        var values = [];
        cards().forEach(function (card) {
            if (year && card.getAttribute("data-academic-year") !== year) return;
            var value = card.getAttribute(attribute) || "";
            if (value && values.indexOf(value) === -1) values.push(value);
        });
        return values;
    }

    function sessionValues(field, year) {
        var values = [];
        (window.lecturerAcademicSessions || []).forEach(function (term) {
            if (year && term.year !== year) return;
            var value = term[field] || "";
            if (value && values.indexOf(value) === -1) values.push(value);
        });
        return values;
    }

    function academicYearLabel(value) {
        return value;
    }

    function semesterLabel(value) {
        return /^\d+$/.test(value) ? "Semester " + value : value;
    }

    function populateYearFilter() {
        var select = document.getElementById("academic-year-filter");
        if (!select) return;
        var years = sessionValues("year");
        distinctCardValues("data-academic-year").forEach(function (year) {
            if (years.indexOf(year) === -1) years.push(year);
        });
        years.sort(function (left, right) {
            return String(left).localeCompare(
                String(right),
                undefined,
                { numeric: true, sensitivity: "base" }
            );
        });
        years.forEach(function (year) {
            var option = document.createElement("option");
            option.value = year;
            option.textContent = academicYearLabel(year);
            select.appendChild(option);
        });
    }

    function populateSemesterFilter(year) {
        var select = document.getElementById("semester-filter");
        if (!select) return;
        select.innerHTML = "";
        var first = document.createElement("option");
        first.value = "all";
        first.textContent = year === "all" ? "Choose year first" : "All semesters";
        select.appendChild(first);
        select.disabled = year === "all";
        if (select.disabled) return;
        var semesters = sessionValues("semester", year);
        distinctCardValues("data-semester", year).forEach(function (semester) {
            if (semesters.indexOf(semester) === -1) semesters.push(semester);
        });
        semesters.sort(function (left, right) {
            return semesterLabel(left).localeCompare(
                semesterLabel(right),
                undefined,
                { numeric: true, sensitivity: "base" }
            );
        });
        semesters.forEach(function (semester) {
            var option = document.createElement("option");
            option.value = semester;
            option.textContent = semesterLabel(semester);
            select.appendChild(option);
        });
    }

    function init() {
        cards().forEach(function (card, index) {
            card.setAttribute("data-original-order", String(index));
        });

        populateYearFilter();
        populateSemesterFilter("all");

        var yearFilter = document.getElementById("academic-year-filter");
        var semesterFilter = document.getElementById("semester-filter");
        var allFilter = document.querySelector('[data-action="filter-all"]');
        if (yearFilter) {
            yearFilter.addEventListener("change", function () {
                state.academicYear = yearFilter.value || "all";
                state.semester = "all";
                state.pinnedOnly = false;
                populateSemesterFilter(state.academicYear);
                activateFilterButton(state.academicYear === "all" ? allFilter : null);
                applyFilters();
            });
        }
        if (semesterFilter) {
            semesterFilter.addEventListener("change", function () {
                state.semester = semesterFilter.value || "all";
                state.pinnedOnly = false;
                activateFilterButton(null);
                applyFilters();
            });
        }
        if (allFilter) {
            allFilter.addEventListener("click", function () {
                state.academicYear = "all";
                state.semester = "all";
                state.pinnedOnly = false;
                if (yearFilter) yearFilter.value = "all";
                populateSemesterFilter("all");
                activateFilterButton(allFilter);
                applyFilters();
            });
        }

        var pinnedFilter = document.querySelector('[data-action="filter-pinned"]');
        if (pinnedFilter) {
            pinnedFilter.addEventListener("click", function () {
                state.academicYear = "all";
                state.semester = "all";
                state.pinnedOnly = true;
                if (yearFilter) yearFilter.value = "all";
                populateSemesterFilter("all");
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

        // Establish the default active filter button visually.
        var allBtn = document.querySelector('[data-action="filter-all"]');
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
