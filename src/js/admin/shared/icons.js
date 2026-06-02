(function () {
  function render() {
    if (window.lucide && typeof window.lucide.createIcons === "function") {
      window.lucide.createIcons();
    }
  }
  window.renderIcons = render;
  document.addEventListener("DOMContentLoaded", render);
})();
