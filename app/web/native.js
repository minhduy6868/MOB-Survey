(function () {
  function plugins() {
    return window.Capacitor && window.Capacitor.Plugins ? window.Capacitor.Plugins : null;
  }

  window.troveyIsNative = function () {
    try {
      return Boolean(window.Capacitor && window.Capacitor.isNativePlatform && window.Capacitor.isNativePlatform());
    } catch (_) {
      return false;
    }
  };

  window.troveyRequestPermissions = async function () {
    var pack = plugins();
    if (!window.troveyIsNative() || !pack) return 'skip';
    if (pack.Camera && pack.Camera.requestPermissions) {
      await pack.Camera.requestPermissions({ permissions: ['camera', 'photos'] });
    }
    if (pack.Geolocation && pack.Geolocation.requestPermissions) {
      await pack.Geolocation.requestPermissions();
    }
    if (pack.LocalNotifications && pack.LocalNotifications.requestPermissions) {
      await pack.LocalNotifications.requestPermissions();
    }
    return 'ok';
  };

  window.troveyTakePhoto = async function () {
    var pack = plugins();
    if (!window.troveyIsNative() || !pack || !pack.Camera) return null;
    await window.troveyRequestPermissions();
    var photo = await pack.Camera.getPhoto({
      resultType: 'base64',
      source: 'CAMERA',
      quality: 70,
      width: 1280,
    });
    var data = photo && photo.base64String ? photo.base64String : '';
    if (!data) return null;
    if (pack.Filesystem) {
      try {
        await pack.Filesystem.writeFile({
          path: 'photos/field-' + Date.now() + '.jpg',
          data: data,
          directory: 'DATA',
          recursive: true,
        });
      } catch (_) {
        /* photo still returns to Hive */
      }
    }
    return data;
  };

  window.troveyGetGps = async function () {
    var pack = plugins();
    if (!window.troveyIsNative() || !pack || !pack.Geolocation) return null;
    await window.troveyRequestPermissions();
    var pos = await pack.Geolocation.getCurrentPosition({ enableHighAccuracy: true, timeout: 15000 });
    if (!pos || !pos.coords) return null;
    return JSON.stringify({
      lat: pos.coords.latitude,
      lng: pos.coords.longitude,
      accuracy: pos.coords.accuracy,
      at: new Date().toISOString(),
    });
  };

  window.troveyNotifySync = async function (title, body) {
    var pack = plugins();
    if (!window.troveyIsNative() || !pack || !pack.LocalNotifications) return 'skip';
    await window.troveyRequestPermissions();
    await pack.LocalNotifications.schedule({
      notifications: [
        {
          id: Date.now() % 100000,
          title: title || 'Trovey',
          body: body || '',
        },
      ],
    });
    return 'ok';
  };

  function bootPermissions() {
    window.troveyRequestPermissions().catch(function () {});
  }

  if (document.readyState === 'complete') bootPermissions();
  else window.addEventListener('load', bootPermissions);
})();
