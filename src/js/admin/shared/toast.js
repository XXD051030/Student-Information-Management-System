(function () {
  function host() {
    var h = document.getElementById("toast-host");
    if (!h) {
      h = document.createElement("div");
      h.id = "toast-host";
      h.style.cssText = "position:fixed;top:16px;right:16px;z-index:80;display:flex;flex-direction:column;gap:8px";
      document.body.appendChild(h);
    }
    return h;
  }
  function desc(d) { return d && typeof d === "object" ? d.description : d; }
  function show(type, title, d) {
    var accent = type === "error" ? "#e0162b" : type === "info" ? "#0284c7" : "#059669";
    var el = document.createElement("div");
    el.style.cssText = "min-width:260px;max-width:360px;background:#fff;border:1px solid #e2e8f0;border-left:4px solid " + accent + ";border-radius:12px;box-shadow:0 10px 25px -10px rgba(15,23,42,.35);padding:12px 14px;opacity:0;transform:translateX(12px);transition:all .2s";
    var t = document.createElement("div");
    t.style.cssText = "font-size:13px;font-weight:700;color:#0f172a";
    t.textContent = title;
    el.appendChild(t);
    var dd = desc(d);
    if (dd) {
      var p = document.createElement("div");
      p.style.cssText = "font-size:12px;color:#64748b;margin-top:2px";
      p.textContent = dd;
      el.appendChild(p);
    }
    host().appendChild(el);
    requestAnimationFrame(function () { el.style.opacity = "1"; el.style.transform = "none"; });
    setTimeout(function () {
      el.style.opacity = "0"; el.style.transform = "translateX(12px)";
      setTimeout(function () { el.remove(); }, 220);
    }, 3200);
  }
  window.toast = {
    success: function (t, d) { show("success", t, d); },
    error: function (t, d) { show("error", t, d); },
    info: function (t, d) { show("info", t, d); }
  };
})();
