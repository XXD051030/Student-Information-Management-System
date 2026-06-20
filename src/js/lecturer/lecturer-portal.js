(function () {
    var activeMaterialType = "all";

    function applyMaterialFilters() {
        var search = document.querySelector("[data-filter-target='[data-material]']");
        var courseSelect = document.querySelector("[data-material-course-filter]");
        var query = search ? search.value.trim().toLowerCase() : "";
        var course = courseSelect ? courseSelect.value : "all";

        document.querySelectorAll("[data-material]").forEach(function (row) {
            var type = (row.getAttribute("data-material-category") || "").toLowerCase();
            var rowCourse = row.getAttribute("data-material-course") || "";
            var text = (row.getAttribute("data-filter-text") || row.textContent || "").toLowerCase();
            var typeMatch = activeMaterialType === "all" || type === activeMaterialType.toLowerCase();
            var courseMatch = course === "all" || rowCourse === course;
            var searchMatch = !query || text.indexOf(query) >= 0;
            row.style.display = typeMatch && courseMatch && searchMatch ? "" : "none";
        });
    }

    function selectMaterialTab(button) {
        activeMaterialType = button.getAttribute("data-material-tab") || "all";
        document.querySelectorAll("[data-material-tab]").forEach(function (tab) {
            tab.setAttribute("data-active", tab === button ? "true" : "false");
        });
        applyMaterialFilters();
    }

    function updateMaterialForm() {
        var typeSelect = document.querySelector("[data-material-type-select]");
        if (!typeSelect) return;

        var type = typeSelect.value;
        var lectureNotes = type === "Lecture Notes";
        var quiz = type === "Quiz";
        var requiresAssessmentDetails = type === "Assignment" || type === "Test";
        var dueInput = document.querySelector("[data-due-date-field] input");
        var weightInput = document.querySelector("[data-weight-field] input");
        var fileInput = document.querySelector("[data-file-field] input[type='file']");
        var description = document.querySelector("[data-material-description]");
        var requiredMark = document.querySelector("[data-description-required]");
        var fileRequiredMark = document.querySelector("[data-file-required]");
        var dueDateRequiredMark = document.querySelector("[data-due-date-required]");
        var weightRequiredMark = document.querySelector("[data-weight-required]");

        [dueInput, weightInput].forEach(function (input) {
            if (!input) return;
            input.disabled = lectureNotes;
            input.required = requiresAssessmentDetails;
            if (lectureNotes) input.value = "";
            var field = input.closest("label");
            if (field) field.classList.toggle("opacity-45", lectureNotes);
        });

        if (fileInput) {
            fileInput.disabled = quiz;
            if (quiz) fileInput.value = "";
            var fileField = fileInput.closest("label");
            if (fileField) fileField.classList.toggle("opacity-60", quiz);
        }

        if (description) {
            description.required = quiz;
            description.placeholder = quiz
                ? "Google Form quiz link"
                : "Short student-facing description";
        }
        if (requiredMark) requiredMark.classList.toggle("hidden", !quiz);
        if (fileRequiredMark) fileRequiredMark.classList.toggle("hidden", quiz);
        if (dueDateRequiredMark) dueDateRequiredMark.classList.toggle("hidden", !requiresAssessmentDetails);
        if (weightRequiredMark) weightRequiredMark.classList.toggle("hidden", !requiresAssessmentDetails);
    }

    document.addEventListener("click", function (event) {
        var tab = event.target.closest("[data-material-tab]");
        if (tab) {
            event.preventDefault();
            selectMaterialTab(tab);
            return;
        }

        var row = event.target.closest("[data-material-url]");
        if (!row || event.target.closest("a,button,input,select,textarea")) return;
        var url = row.getAttribute("data-material-url");
        if (url) window.location.href = url;
    });

    document.addEventListener("DOMContentLoaded", function () {
        var search = document.querySelector("[data-filter-target='[data-material]']");
        var courseSelect = document.querySelector("[data-material-course-filter]");
        var typeSelect = document.querySelector("[data-material-type-select]");
        if (search) search.addEventListener("input", applyMaterialFilters);
        if (courseSelect) courseSelect.addEventListener("change", applyMaterialFilters);
        if (typeSelect) typeSelect.addEventListener("change", updateMaterialForm);

        document.querySelectorAll("[data-material-url]").forEach(function (row) {
            row.setAttribute("tabindex", "0");
            row.setAttribute("role", "link");
            row.addEventListener("keydown", function (event) {
                if (event.key !== "Enter" && event.key !== " ") return;
                if (event.target.closest("a,button,input,select,textarea")) return;
                event.preventDefault();
                var url = row.getAttribute("data-material-url");
                if (url) window.location.href = url;
            });
        });
        applyMaterialFilters();
        updateMaterialForm();
    });
})();
﻿
