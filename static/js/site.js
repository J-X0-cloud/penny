// Progressive enhancement for the server-rendered site. Every page works without it; this adds the
// interactive app preview and the household share switches.
(function () {
  "use strict";

  var SWIPE_THRESHOLD = 40;

  function initPreview(root) {
    var tabs = root.querySelectorAll(".pv-tab");
    var screens = root.querySelectorAll(".screen");
    var dots = root.querySelectorAll(".dotb");
    var phone = root.querySelector(".pv-phone");
    var count = screens.length;
    var current = 0;
    var touchX = null;

    function show(index) {
      current = ((index % count) + count) % count;
      tabs.forEach(function (tab, i) {
        tab.classList.toggle("on", i === current);
        tab.setAttribute("aria-pressed", String(i === current));
      });
      screens.forEach(function (screen, i) {
        screen.classList.toggle("on", i === current);
        screen.setAttribute("aria-hidden", String(i !== current));
      });
      dots.forEach(function (dot, i) {
        dot.classList.toggle("on", i === current);
      });
    }

    function indexOfScreen(key) {
      for (var i = 0; i < screens.length; i++) {
        if (screens[i].getAttribute("data-screen") === key) return i;
      }
      return current;
    }

    root.addEventListener("click", function (event) {
      var target = event.target.closest("button");
      if (!target || !root.contains(target)) return;
      if (target.hasAttribute("data-index")) show(Number(target.getAttribute("data-index")));
      else if (target.hasAttribute("data-step")) show(current + Number(target.getAttribute("data-step")));
      else if (target.hasAttribute("data-screen")) show(indexOfScreen(target.getAttribute("data-screen")));
    });

    document.addEventListener("keydown", function (event) {
      if (event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement) return;
      if (event.key === "ArrowRight") show(current + 1);
      if (event.key === "ArrowLeft") show(current - 1);
    });

    if (phone) {
      phone.addEventListener("touchstart", function (event) {
        touchX = event.touches[0] ? event.touches[0].clientX : null;
      }, { passive: true });
      phone.addEventListener("touchend", function (event) {
        var start = touchX;
        var end = event.changedTouches[0] ? event.changedTouches[0].clientX : null;
        touchX = null;
        if (start === null || end === null) return;
        var dx = end - start;
        if (Math.abs(dx) > SWIPE_THRESHOLD) show(current + (dx < 0 ? 1 : -1));
      });
    }
  }

  function initShareSwitches(root) {
    root.addEventListener("click", function (event) {
      var toggle = event.target.closest(".tog");
      if (!toggle || !root.contains(toggle)) return;
      var on = toggle.getAttribute("aria-checked") !== "true";
      toggle.setAttribute("aria-checked", String(on));
      toggle.classList.toggle("on", on);
      var label = toggle.parentElement.querySelector(".who");
      if (label) label.textContent = on ? "Shared" : label.getAttribute("data-private-label");
    });
  }

  function init() {
    document.querySelectorAll("[data-preview]").forEach(initPreview);
    document.querySelectorAll("[data-shared-accounts]").forEach(initShareSwitches);
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
