// Course detail page: tab switching and module accordion.
// All content is rendered server-side; this script only drives interactivity.
// Hooks in the markup:
//   [data-action="switch-tab"][data-tab][data-active]  – tab buttons (with a
//        child .tab-indicator); panes are [data-pane] (inactive ones are .hidden)
//   [data-action="toggle-module"][data-week]           – accordion header; its
//        sibling .module-items.hidden expands, its .module-chevron rotates
(function () {
    "use strict";

    var INACTIVE = "#64748b"; // slate-500 for inactive tabs

    function activeColor() {
        var root = document.getElementById("course-detail-root") || document.documentElement;
        var color = window.getComputedStyle(root).getPropertyValue("--course-accent").trim();
        return color || INACTIVE;
    }

    // ---- Tabs -------------------------------------------------------------
    // Colour is set inline rather than via Tailwind classes: the markup mixes
    // base and data-[active] variant classes, so inline style is the only
    // deterministic way to override colour regardless of the Play CDN output.
    function switchTab(tab) {
        Array.prototype.forEach.call(
            document.querySelectorAll("[data-pane]"),
            function (pane) {
                pane.classList.toggle("hidden", pane.getAttribute("data-pane") !== tab);
            }
        );
        Array.prototype.forEach.call(
            document.querySelectorAll('[data-action="switch-tab"]'),
            function (btn) {
                var active = btn.getAttribute("data-tab") === tab;
                btn.setAttribute("data-active", active ? "true" : "false");
                btn.style.color = active ? activeColor() : INACTIVE;
                var indicator = btn.querySelector(".tab-indicator");
                if (indicator) { indicator.classList.toggle("hidden", !active); }
            }
        );
    }

    // ---- Module accordion -------------------------------------------------
    function toggleModule(btn) {
        var li = btn.closest("li");
        if (!li) { return; }
        var items = li.querySelector(".module-items");
        var chevron = btn.querySelector(".module-chevron");
        if (!items) { return; }
        var open = items.classList.toggle("hidden") === false;
        if (chevron) { chevron.style.transform = open ? "rotate(90deg)" : ""; }
    }

    function openAssignmentMaterial(card) {
        var url = card.getAttribute("data-preview-url");
        if (url) { window.location.href = url; }
    }

    function init() {
        // Tabs
        Array.prototype.forEach.call(
            document.querySelectorAll('[data-action="switch-tab"]'),
            function (btn) {
                btn.addEventListener("click", function () {
                    switchTab(btn.getAttribute("data-tab"));
                });
            }
        );
        // Normalise to the default active tab (the one marked data-active="true",
        // falling back to "modules") so tab styling is consistent on load.
        var current = document.querySelector('[data-action="switch-tab"][data-active="true"]');
        switchTab(current ? current.getAttribute("data-tab") : "modules");

        // Module accordion
        Array.prototype.forEach.call(
            document.querySelectorAll('[data-action="toggle-module"]'),
            function (btn) {
                btn.addEventListener("click", function () { toggleModule(btn); });
            }
        );

        Array.prototype.forEach.call(
            document.querySelectorAll('[data-action="open-assignment-material"]'),
            function (card) {
                card.addEventListener("click", function (event) {
                    if (event.target.closest("a, button, input, textarea, select, summary, details, label")) {
                        return;
                    }
                    openAssignmentMaterial(card);
                });
                card.addEventListener("keydown", function (event) {
                    if (event.target !== card || (event.key !== "Enter" && event.key !== " ")) {
                        return;
                    }
                    event.preventDefault();
                    openAssignmentMaterial(card);
                });
            }
        );
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
