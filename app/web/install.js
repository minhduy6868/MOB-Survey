(function () {
  window.__troveyInstall = {
    deferred: null,
    installed: false,
  };

  window.addEventListener('beforeinstallprompt', function (event) {
    event.preventDefault();
    window.__troveyInstall.deferred = event;
  });

  window.addEventListener('appinstalled', function () {
    window.__troveyInstall.installed = true;
    window.__troveyInstall.deferred = null;
  });

  window.troveyCanPromptInstall = function () {
    return Boolean(window.__troveyInstall.deferred);
  };

  window.troveyPromptInstall = function () {
    var event = window.__troveyInstall.deferred;
    if (!event) return Promise.resolve('unavailable');
    return event.prompt().then(function () {
      return event.userChoice;
    }).then(function (choice) {
      window.__troveyInstall.deferred = null;
      return choice && choice.outcome ? choice.outcome : 'dismissed';
    });
  };

  window.troveyIsStandalone = function () {
    var standalone = window.navigator.standalone === true;
    var display = window.matchMedia && window.matchMedia('(display-mode: standalone)').matches;
    return standalone || display;
  };

  window.troveyIsIos = function () {
    var ua = window.navigator.userAgent || '';
    var iOS = /iPad|iPhone|iPod/.test(ua);
    var iPadOs = window.navigator.platform === 'MacIntel' && window.navigator.maxTouchPoints > 1;
    return iOS || iPadOs;
  };
})();
