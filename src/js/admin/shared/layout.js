(function () {
  function setMenu(open) {
    var aside = document.getElementById("mobile-menu");
    var backdrop = document.getElementById("mobile-menu-backdrop");
    var v = open ? "true" : "false";
    if (aside) aside.setAttribute("data-open", v);
    if (backdrop) backdrop.setAttribute("data-open", v);
  }
  document.addEventListener("click", function (e) {
    var t = e.target.closest("[data-action]");
    if (t) {
      var a = t.getAttribute("data-action");
      if (a === "toggle-menu" || a === "open-menu") setMenu(true);
      if (a === "close-menu") setMenu(false);
      return;
    }
    if (e.target.id === "mobile-menu-backdrop") setMenu(false);
  });
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") setMenu(false); });
  document.addEventListener("DOMContentLoaded", function () {
    var file = (location.pathname.split("/").pop() || "dashboard.aspx").toLowerCase();
    if (!file) file = "dashboard.aspx";
    document.querySelectorAll("[data-nav-link]").forEach(function (l) {
      if (l.getAttribute("data-nav-link").toLowerCase() === file) l.setAttribute("data-active", "true");
    });
  });
})();
