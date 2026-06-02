(function () {
  function controllers() { return document.querySelectorAll("[data-table]"); }

  function setup(root) {
    var pageSize = parseInt(root.getAttribute("data-page-size") || "6", 10);
    var page = 1;
    var rows = Array.prototype.slice.call(root.querySelectorAll("[data-row]"));
    var search = root.querySelector("[data-table-search]");
    var filters = Array.prototype.slice.call(root.querySelectorAll("[data-table-filter]"));
    var chipGroups = Array.prototype.slice.call(root.querySelectorAll("[data-table-chip]"));
    var chipState = {};
    var clearBtn = root.querySelector("[data-table-clear]");
    var emptyRow = root.querySelector("[data-table-empty]");
    var info = root.querySelector("[data-table-info]");
    var pager = root.querySelector("[data-table-pager]");

    function matches(r) {
      var q = (search && search.value.trim().toLowerCase()) || "";
      if (q && (r.getAttribute("data-search") || "").toLowerCase().indexOf(q) === -1) return false;
      for (var i = 0; i < filters.length; i++) {
        var key = filters[i].getAttribute("data-table-filter");
        var val = filters[i].value;
        if (val && r.getAttribute("data-" + key) !== val) return false;
      }
      for (var k in chipState) {
        var cv = chipState[k];
        if (cv && cv !== "All" && r.getAttribute("data-" + k) !== cv) return false;
      }
      return true;
    }

    function render() {
      var visible = rows.filter(matches);
      var pageCount = Math.max(1, Math.ceil(visible.length / pageSize));
      if (page > pageCount) page = 1;
      rows.forEach(function (r) { r.style.display = "none"; });
      var start = (page - 1) * pageSize;
      visible.slice(start, start + pageSize).forEach(function (r) { r.style.display = ""; });
      if (emptyRow) emptyRow.style.display = visible.length === 0 ? "" : "none";
      if (info) info.textContent = visible.length === 0 ? "0 results"
        : "Showing " + (start + 1) + "–" + Math.min(start + pageSize, visible.length) + " of " + visible.length;
      if (pager) {
        pager.innerHTML = "";
        function btn(label, disabled, active, onClick) {
          var b = document.createElement("button");
          b.type = "button"; b.textContent = label;
          b.className = "rounded-md border px-2.5 py-1 " + (active
            ? "border-[#e0162b]/30 bg-[#e0162b]/10 text-[#a01020] font-semibold"
            : "border-slate-200 hover:bg-slate-50") + (disabled ? " opacity-40 cursor-not-allowed" : "");
          b.style.fontSize = "12.5px";
          if (!disabled && onClick) b.addEventListener("click", onClick);
          pager.appendChild(b);
        }
        btn("Prev", page === 1, false, function () { page--; render(); });
        for (var p = 1; p <= pageCount; p++) (function (p) { btn(String(p), false, p === page, function () { page = p; render(); }); })(p);
        btn("Next", page === pageCount, false, function () { page++; render(); });
      }
    }

    chipGroups.forEach(function (g) {
      var key = g.getAttribute("data-table-chip");
      var activeBtn = g.querySelector("[data-chip][data-active='true']") || g.querySelector("[data-chip]");
      chipState[key] = activeBtn ? activeBtn.getAttribute("data-chip") : "";
      g.addEventListener("click", function (e) {
        var b = e.target.closest("[data-chip]");
        if (!b) return;
        g.querySelectorAll("[data-chip]").forEach(function (x) { x.setAttribute("data-active", x === b ? "true" : "false"); });
        chipState[key] = b.getAttribute("data-chip");
        page = 1; render();
      });
    });

    if (search) search.addEventListener("input", function () { page = 1; render(); });
    filters.forEach(function (f) { f.addEventListener("change", function () { page = 1; render(); }); });
    if (clearBtn) clearBtn.addEventListener("click", function () {
      if (search) search.value = "";
      filters.forEach(function (f) { f.value = ""; });
      chipGroups.forEach(function (g) {
        var key = g.getAttribute("data-table-chip");
        var btns = g.querySelectorAll("[data-chip]");
        btns.forEach(function (x, i) { x.setAttribute("data-active", i === 0 ? "true" : "false"); });
        if (btns[0]) chipState[key] = btns[0].getAttribute("data-chip");
      });
      page = 1; render();
    });
    render();
  }

  document.addEventListener("DOMContentLoaded", function () { controllers().forEach(setup); });
})();
