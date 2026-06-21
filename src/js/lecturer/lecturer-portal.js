(function () {
    var activeMaterialType = "all";
    var MATERIAL_VIEW_KEY = "lecturer.materials.view";

    function normalized(value) {
        return String(value || "")
            .replace(/\u00a0/g, " ")
            .trim()
            .toLowerCase();
    }

    function saveMaterialView() {
        var search = document.querySelector("[data-filter-target='[data-material]']");
        var courseSelect = document.querySelector("[data-material-course-filter]");
        try {
            sessionStorage.setItem(MATERIAL_VIEW_KEY, JSON.stringify({
                type: activeMaterialType,
                course: courseSelect ? courseSelect.value : "all",
                search: search ? search.value : ""
            }));
        } catch (error) {
            // The filters still work normally when browser storage is unavailable.
        }
    }

    function restoreMaterialView() {
        try {
            var saved = JSON.parse(sessionStorage.getItem(MATERIAL_VIEW_KEY) || "{}");
            var search = document.querySelector("[data-filter-target='[data-material]']");
            var courseSelect = document.querySelector("[data-material-course-filter]");
            var savedTab = document.querySelector(
                '[data-material-tab="' + String(saved.type || "all").replace(/"/g, '\\"') + '"]'
            );

            if (courseSelect && saved.course &&
                Array.prototype.some.call(courseSelect.options, function (option) {
                    return option.value === saved.course;
                })) {
                courseSelect.value = saved.course;
            }
            if (search && typeof saved.search === "string") search.value = saved.search;
            if (savedTab) {
                activeMaterialType = savedTab.getAttribute("data-material-tab") || "all";
                document.querySelectorAll("[data-material-tab]").forEach(function (tab) {
                    tab.setAttribute("data-active", tab === savedTab ? "true" : "false");
                });
            }
        } catch (error) {
            activeMaterialType = "all";
        }
    }

    function updateMaterialCounts() {
        var courseSelect = document.querySelector("[data-material-course-filter]");
        var course = courseSelect ? courseSelect.value : "all";
        var counts = { all: 0 };

        document.querySelectorAll("[data-material]").forEach(function (row) {
            var rowCourse = row.getAttribute("data-material-course") || "";
            if (normalized(course) !== "all" && normalized(rowCourse) !== normalized(course)) return;
            var type = row.getAttribute("data-material-category") || "";
            counts.all += 1;
            counts[type] = (counts[type] || 0) + 1;
        });

        document.querySelectorAll("[data-material-tab]").forEach(function (tab) {
            var type = tab.getAttribute("data-material-tab") || "all";
            var count = tab.querySelector(".material-tab-count");
            if (count) count.textContent = String(counts[type] || 0);
        });
    }

    function applyMaterialFilters() {
        var search = document.querySelector("[data-filter-target='[data-material]']");
        var courseSelect = document.querySelector("[data-material-course-filter]");
        var query = search ? search.value.trim().toLowerCase() : "";
        var course = courseSelect ? courseSelect.value : "all";

        document.querySelectorAll("[data-material]").forEach(function (row) {
            var type = normalized(row.getAttribute("data-material-category"));
            var rowCourse = row.getAttribute("data-material-course") || "";
            var text = (row.getAttribute("data-filter-text") || row.textContent || "").toLowerCase();
            var typeMatch = normalized(activeMaterialType) === "all" || type === normalized(activeMaterialType);
            var courseMatch = normalized(course) === "all" || normalized(rowCourse) === normalized(course);
            var searchMatch = !query || text.indexOf(query) >= 0;
            row.style.display = typeMatch && courseMatch && searchMatch ? "" : "none";
        });
        updateMaterialCounts();
    }

    function selectMaterialTab(button) {
        activeMaterialType = button.getAttribute("data-material-tab") || "all";
        document.querySelectorAll("[data-material-tab]").forEach(function (tab) {
            tab.setAttribute("data-active", tab === button ? "true" : "false");
        });
        syncPublishTypeToTab();
        saveMaterialView();
        applyMaterialFilters();
    }

    function syncPublishTypeToTab() {
        var typeSelect = document.querySelector("[data-material-type-select]");
        if (!typeSelect) return;
        var desiredType = activeMaterialType === "all" ? "Assignment" : activeMaterialType;
        var exists = Array.prototype.some.call(typeSelect.options, function (option) {
            return option.value === desiredType;
        });
        if (exists) typeSelect.value = desiredType;
        updateMaterialForm();
    }

    function syncPublishCourseToFilter() {
        var filter = document.querySelector("[data-material-course-filter]");
        var publishCourse = document.querySelector("[data-material-course-select]");
        if (!filter || !publishCourse || normalized(filter.value) === "all") return;

        var matchingOption = Array.prototype.find.call(publishCourse.options, function (option) {
            return normalized(option.textContent) === normalized(filter.value);
        });
        if (matchingOption) publishCourse.value = matchingOption.value;
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
        var weekField = document.querySelector("[data-week-field]");
        var weekSelect = document.querySelector("[data-material-week-select]");

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
        if (weekField) weekField.classList.toggle("hidden", !lectureNotes);
        if (weekSelect) {
            weekSelect.disabled = !lectureNotes;
            weekSelect.required = lectureNotes;
        }
    }

    async function deleteMaterial(button) {
        var materialId = Number(button.getAttribute("data-delete-material"));
        if (!materialId || !window.confirm("Delete this material?")) return;

        button.disabled = true;
        button.classList.add("opacity-50");
        try {
            var response = await fetch(window.location.pathname + "/DeleteMaterial", {
                method: "POST",
                credentials: "same-origin",
                headers: { "Content-Type": "application/json; charset=utf-8" },
                body: JSON.stringify({ materialId: materialId })
            });
            if (!response.ok) throw new Error("The material server could not be reached.");
            var body = await response.json();
            var result = body && Object.prototype.hasOwnProperty.call(body, "d") ? body.d : body;
            if (!result || !result.success) {
                throw new Error(result && result.message ? result.message : "Material could not be deleted.");
            }

            var row = button.closest("[data-material]");
            if (row) row.remove();
            applyMaterialFilters();
        } catch (error) {
            window.alert(error.message || "Material could not be deleted.");
            button.disabled = false;
            button.classList.remove("opacity-50");
        }
    }

    function showMaterialStatus(message, success) {
        var status = document.querySelector("[data-material-client-status]");
        if (!status) return;
        status.textContent = message || "";
        status.classList.toggle("hidden", !message);
        status.classList.toggle("border-emerald-200", !!success);
        status.classList.toggle("bg-emerald-50", !!success);
        status.classList.toggle("text-emerald-800", !!success);
        status.classList.toggle("border-amber-200", !success);
        status.classList.toggle("bg-amber-50", !success);
        status.classList.toggle("text-amber-800", !success);
        if (message) {
            status.scrollIntoView({ behavior: "smooth", block: "start" });
        }
    }

    function showRequiredError(message, field) {
        showMaterialStatus(message, false);
        if (field) {
            field.focus();
            field.classList.add("border-[#e0162b]", "ring-1", "ring-[#e0162b]/30");
            var clearError = function () {
                field.classList.remove("border-[#e0162b]", "ring-1", "ring-[#e0162b]/30");
                field.removeEventListener("input", clearError);
                field.removeEventListener("change", clearError);
            };
            field.addEventListener("input", clearError);
            field.addEventListener("change", clearError);
        }
        return false;
    }

    function validateMaterialPublish() {
        var typeSelect = document.querySelector("[data-material-type-select]");
        var title = document.querySelector("[data-material-title]");
        var description = document.querySelector("[data-material-description]");
        var dueDate = document.querySelector("[data-material-due-date]");
        var weight = document.querySelector("[data-material-weight]");
        var week = document.querySelector("[data-material-week-select]");
        var file = document.querySelector("[data-material-file]");
        var type = typeSelect ? typeSelect.value : "";
        var requiresAssessment = type === "Assignment" || type === "Test";
        var lectureNotes = type === "Lecture Notes";
        var quiz = type === "Quiz";

        if (title && !title.value.trim()) {
            return showRequiredError("Title is required.", title);
        }
        if (title) title.setCustomValidity("");
        if (lectureNotes && week && !week.value) {
            return showRequiredError("Week is required for lecture notes.", week);
        }
        if (week) week.setCustomValidity("");
        if (requiresAssessment && dueDate && !dueDate.value) {
            return showRequiredError("Due date is required for assignments and tests.", dueDate);
        }
        if (dueDate) dueDate.setCustomValidity("");
        if (requiresAssessment && weight && !weight.value) {
            return showRequiredError("Course weight is required for assignments and tests.", weight);
        }
        if (requiresAssessment && weight && Number(weight.value) <= 0) {
            return showRequiredError("Course weight for assignments and tests must be greater than 0%.", weight);
        }
        if (weight) weight.setCustomValidity("");
        if (quiz && description && !description.value.trim()) {
            return showRequiredError("Google Forms quiz link is required.", description);
        }
        if (quiz && description) {
            try {
                var quizUrl = new URL(description.value.trim());
                var host = quizUrl.hostname.toLowerCase().replace(/\.$/, "");
                var googleForm = host === "forms.gle" ||
                    (host === "docs.google.com" && quizUrl.pathname.toLowerCase().indexOf("/forms/") === 0);
                if (!googleForm) {
                    return showRequiredError(
                        "Quiz links must use Google Forms. Please paste a forms.gle or docs.google.com/forms sharing link.",
                        description
                    );
                }
            } catch (error) {
                return showRequiredError(
                    "Quiz links must use Google Forms. Please paste a valid Google Forms sharing link.",
                    description
                );
            }
        }
        if (description) description.setCustomValidity("");
        if (!quiz && file && (!file.files || !file.files.length)) {
            return showRequiredError("Please choose a file to upload.", file);
        }
        if (file) file.setCustomValidity("");
        return true;
    }

    async function insertPublishedMaterial(materialId) {
        var response = await fetch(window.location.pathname, {
            credentials: "same-origin",
            cache: "no-store"
        });
        if (!response.ok) return;
        var html = await response.text();
        var documentCopy = new DOMParser().parseFromString(html, "text/html");
        var freshRow = documentCopy.querySelector('[data-material-id="' + materialId + '"]');
        var list = document.querySelector("[data-material-list]");
        if (!freshRow || !list) return;
        var imported = document.importNode(freshRow, true);
        imported.setAttribute("tabindex", "0");
        imported.setAttribute("role", "link");
        list.insertBefore(imported, list.firstChild);
        if (window.lucide) window.lucide.createIcons();
    }

    async function publishMaterial(button) {
        if (!validateMaterialPublish()) return;

        var course = document.querySelector("[data-material-course-select]");
        var type = document.querySelector("[data-material-type-select]");
        var title = document.querySelector("[data-material-title]");
        var description = document.querySelector("[data-material-description]");
        var dueDate = document.querySelector("[data-material-due-date]");
        var weight = document.querySelector("[data-material-weight]");
        var week = document.querySelector("[data-material-week-select]");
        var file = document.querySelector("[data-material-file]");
        var label = button.querySelector("[data-publish-label]");
        var formData = new FormData();
        formData.append("offeringId", course ? course.value : "");
        formData.append("materialType", type ? type.value : "");
        formData.append("title", title ? title.value : "");
        formData.append("description", description ? description.value : "");
        formData.append("dueDate", dueDate ? dueDate.value : "");
        formData.append("weight", weight ? weight.value : "");
        formData.append("week", week ? week.value : "");
        if (file && file.files && file.files.length) formData.append("file", file.files[0]);

        button.classList.add("pointer-events-none", "opacity-60");
        button.setAttribute("aria-disabled", "true");
        if (label) label.textContent = "Publishing...";
        showMaterialStatus("", false);

        try {
            var endpoint = new URL("material_publish.ashx", window.location.href);
            var response = await fetch(endpoint.href, {
                method: "POST",
                credentials: "same-origin",
                body: formData
            });
            if (!response.ok) throw new Error("The material server could not be reached.");
            var result = await response.json();
            if (!result || !result.success) {
                throw new Error(result && result.message ? result.message : "Material could not be published.");
            }

            await insertPublishedMaterial(result.materialId);
            if (title) title.value = "";
            if (description) description.value = "";
            if (dueDate) dueDate.value = "";
            if (weight) weight.value = "";
            if (file) file.value = "";
            applyMaterialFilters();
            showMaterialStatus(result.message, true);
        } catch (error) {
            showMaterialStatus(error.message || "Material could not be published.", false);
        } finally {
            button.classList.remove("pointer-events-none", "opacity-60");
            button.removeAttribute("aria-disabled");
            if (label) label.textContent = "Publish material";
        }
    }

    document.addEventListener("click", function (event) {
        var tab = event.target.closest("[data-material-tab]");
        if (tab) {
            event.preventDefault();
            selectMaterialTab(tab);
            return;
        }

        var deleteButton = event.target.closest("[data-delete-material]");
        if (deleteButton) {
            event.preventDefault();
            event.stopPropagation();
            deleteMaterial(deleteButton);
            return;
        }

        var publishButton = event.target.closest("[data-publish-material]");
        if (publishButton) {
            event.preventDefault();
            publishMaterial(publishButton);
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
        if (search) search.addEventListener("input", function () {
            saveMaterialView();
            applyMaterialFilters();
        });
        if (courseSelect) courseSelect.addEventListener("change", function () {
            syncPublishCourseToFilter();
            saveMaterialView();
            applyMaterialFilters();
        });
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
        restoreMaterialView();
        syncPublishCourseToFilter();
        syncPublishTypeToTab();
        applyMaterialFilters();
        updateMaterialForm();
    });
})();
﻿
