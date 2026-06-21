(function () {
    "use strict";

    document.addEventListener("click", function (event) {
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
