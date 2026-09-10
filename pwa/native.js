(function () {
  function cap() {
    return window.Capacitor || null;
  }

  function plugins() {
    var c = cap();
    return c && c.Plugins ? c.Plugins : null;
  }

  function plugin(name) {
    var pack = plugins();
    if (pack && pack[name]) return pack[name];
    var c = cap();
    if (c && typeof c.registerPlugin === 'function') {
      try { return c.registerPlugin(name); } catch (_) {}
    }
    return null;
  }

  window.troveyIsNative = function () {
    try {
      var c = cap();
      return Boolean(c && c.isNativePlatform && c.isNativePlatform());
    } catch (_) {
      return false;
    }
  };

  window.troveyIsIos = function () {
    var ua = window.navigator.userAgent || '';
    var iOS = /iPad|iPhone|iPod/.test(ua);
    var iPadOs = window.navigator.platform === 'MacIntel' && window.navigator.maxTouchPoints > 1;
    return iOS || iPadOs;
  };

  window.troveyIsStandalone = function () {
    var standalone = window.navigator.standalone === true;
    var display = window.matchMedia && window.matchMedia('(display-mode: standalone)').matches;
    return standalone || display || window.troveyIsNative();
  };

  window.troveyWaitNative = function (ms) {
    return new Promise(function (resolve) {
      var start = Date.now();
      (function tick() {
        if (window.troveyIsNative() && (plugin('Camera') || plugin('Geolocation') || plugin('LocalNotifications'))) {
          resolve(true);
          return;
        }
        if (Date.now() - start > (ms || 2500)) {
          resolve(window.troveyIsNative());
          return;
        }
        setTimeout(tick, 60);
      })();
    });
  };

  function granted(value) {
    return value === 'granted' || value === 'limited';
  }

  function queryWeb(name) {
    if (!navigator.permissions || !navigator.permissions.query) return Promise.resolve('prompt');
    return navigator.permissions.query({ name: name }).then(function (s) {
      return s.state || 'prompt';
    }).catch(function () { return 'prompt'; });
  }

  window.troveyPermissionState = async function () {
    await window.troveyWaitNative(400);
    var camera = 'prompt';
    var geo = 'prompt';
    var notify = window.Notification ? Notification.permission : 'prompt';
    var files = 'granted';
    if (window.troveyIsNative()) {
      try {
        var cam = plugin('Camera');
        if (cam && cam.checkPermissions) {
          var c = await cam.checkPermissions();
          camera = granted(c.camera) || granted(c.photos) ? 'granted' : (c.camera || 'prompt');
        }
      } catch (_) {}
      try {
        var loc = plugin('Geolocation');
        if (loc && loc.checkPermissions) {
          var g = await loc.checkPermissions();
          geo = granted(g.location) || granted(g.coarseLocation) ? 'granted' : (g.location || 'prompt');
        }
      } catch (_) {}
      try {
        var note = plugin('LocalNotifications');
        if (note && note.checkPermissions) {
          var n = await note.checkPermissions();
          notify = granted(n.display) ? 'granted' : (n.display || 'prompt');
        }
      } catch (_) {}
      try {
        var fs = plugin('Filesystem');
        if (fs && fs.checkPermissions) {
          var f = await fs.checkPermissions();
          files = granted(f.publicStorage) ? 'granted' : (f.publicStorage || 'granted');
        } else {
          files = 'granted';
        }
      } catch (_) {
        files = 'granted';
      }
      return { camera: camera, geo: geo, notify: notify, files: files, native: true };
    }
    camera = await queryWeb('camera');
    geo = await queryWeb('geolocation');
    return { camera: camera, geo: geo, notify: notify, files: 'granted', native: false };
  };

  window.troveyRequestOne = async function (kind) {
    if (window.troveyIsNative()) await window.troveyWaitNative(1200);
    if (window.troveyIsNative()) {
      if (kind === 'camera') {
        var cam = plugin('Camera');
        if (cam && cam.requestPermissions) {
          await cam.requestPermissions({ permissions: ['camera', 'photos'] });
        }
      } else if (kind === 'geo') {
        var loc = plugin('Geolocation');
        if (loc && loc.requestPermissions) await loc.requestPermissions();
      } else if (kind === 'notify') {
        var note = plugin('LocalNotifications');
        if (note && note.requestPermissions) await note.requestPermissions();
      } else if (kind === 'files') {
        var fs = plugin('Filesystem');
        if (fs && fs.requestPermissions) await fs.requestPermissions();
      }
      return window.troveyPermissionState();
    }
    if (kind === 'geo' && navigator.geolocation) {
      await new Promise(function (resolve) {
        navigator.geolocation.getCurrentPosition(function () { resolve(); }, function () { resolve(); }, { timeout: 8000 });
      });
    }
    if (kind === 'camera' && navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      try {
        var stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
        stream.getTracks().forEach(function (t) { t.stop(); });
      } catch (_) {}
    }
    if (kind === 'notify' && window.Notification) {
      try { await Notification.requestPermission(); } catch (_) {}
    }
    return window.troveyPermissionState();
  };

  window.troveyRequestPermissions = async function () {
    await window.troveyRequestOne('camera');
    await window.troveyRequestOne('geo');
    await window.troveyRequestOne('notify');
    await window.troveyRequestOne('files');
    return window.troveyPermissionState();
  };

  window.troveyTakePhoto = async function () {
    if (window.troveyIsNative()) await window.troveyWaitNative(1200);
    var cam = plugin('Camera');
    if (window.troveyIsNative() && cam) {
      await window.troveyRequestOne('camera');
      var photo = await cam.getPhoto({
        resultType: 'base64',
        source: 'CAMERA',
        quality: 70,
        width: 1280,
      });
      var data = photo && photo.base64String ? photo.base64String : '';
      var fs = plugin('Filesystem');
      if (data && fs && fs.writeFile) {
        try {
          await fs.writeFile({
            path: 'photos/field-' + Date.now() + '.jpg',
            data: data,
            directory: 'DATA',
            recursive: true,
          });
        } catch (_) {}
      }
      return data || null;
    }
    await window.troveyRequestOne('camera');
    return null;
  };

  window.troveyGetGps = async function () {
    if (window.troveyIsNative()) await window.troveyWaitNative(1200);
    var loc = plugin('Geolocation');
    if (window.troveyIsNative() && loc) {
      await window.troveyRequestOne('geo');
      var pos = await loc.getCurrentPosition({ enableHighAccuracy: true, timeout: 15000 });
      if (!pos || !pos.coords) return null;
      return {
        lat: pos.coords.latitude,
        lng: pos.coords.longitude,
        accuracy: pos.coords.accuracy,
        at: new Date().toISOString(),
      };
    }
    if (!navigator.geolocation) return null;
    await window.troveyRequestOne('geo');
    return new Promise(function (resolve) {
      navigator.geolocation.getCurrentPosition(
        function (pos) {
          resolve({
            lat: pos.coords.latitude,
            lng: pos.coords.longitude,
            accuracy: pos.coords.accuracy,
            at: new Date().toISOString(),
          });
        },
        function () { resolve(null); },
        { enableHighAccuracy: true, timeout: 15000 },
      );
    });
  };

  window.troveyNotifySync = async function (title, body) {
    if (window.troveyIsNative()) await window.troveyWaitNative(800);
    var note = plugin('LocalNotifications');
    if (window.troveyIsNative() && note) {
      await window.troveyRequestOne('notify');
      await note.schedule({
        notifications: [{ id: Date.now() % 100000, title: title || 'Trovey', body: body || '' }],
      });
      return 'ok';
    }
    if (window.Notification && Notification.permission !== 'granted') {
      try { await Notification.requestPermission(); } catch (_) {}
    }
    if (window.Notification && Notification.permission === 'granted') {
      new Notification(title || 'Trovey', { body: body || '', icon: '/icons/Icon-192.png' });
    }
    return 'ok';
  };
})();
