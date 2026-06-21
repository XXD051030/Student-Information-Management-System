(function () {
    "use strict";

    document.addEventListener("click", function (event) {
        var editButton = event.target.closest("[data-module-edit-toggle]");
        if (editButton) {
            var editRow = editButton.closest("li");
            var editForm = editRow ? editRow.querySelector("[data-module-edit-form]") : null;
            if (editForm) editForm.classList.toggle("hidden");
            return;
        }

        var cancelButton = event.target.closest("[data-module-edit-cancel]");
        if (cancelButton) {
            var cancelForm = cancelButton.closest("[data-module-edit-form]");
            if (cancelForm) cancelForm.classList.add("hidden");
            return;
        }

        var button = event.target.closest("[data-course-module-toggle]");
        if (!button) return;
        var row = button.closest("li");
        var items = row ? row.querySelector("[data-course-module-items]") : null;
        var chevron = button.querySelector("[data-module-chevron]");
        if (!items) return;
        var open = items.classList.toggle("hidden") === false;
        if (chevron) chevron.style.transform = open ? "rotate(90deg)" : "";
    });
})();
