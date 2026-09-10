import 'dart:convert';
import 'dart:js_interop';

@JS('troveyCanPromptInstall')
external bool _canPrompt();

@JS('troveyPromptInstall')
external JSPromise<JSAny?> _prompt();

@JS('troveyIsStandalone')
external bool _standalone();

@JS('troveyIsIos')
external bool _ios();

@JS('troveyIsNative')
external bool _native();

@JS('troveyTakePhoto')
external JSPromise<JSAny?> _takePhoto();

@JS('troveyGetGps')
external JSPromise<JSAny?> _getGps();

@JS('troveyNotifySync')
external JSPromise<JSAny?> _notifySync(JSString title, JSString body);

@JS('troveyRequestPermissions')
external JSPromise<JSAny?> _requestPermissions();

@JS('troveyDownloadText')
external void _download(JSString filename, JSString text);

@JS('__troveyOnDrain')
external set _onDrain(JSFunction? fn);

@JS('troveyOpenUrl')
external void _openUrl(JSString url);

class InstallBridge {
  static bool get canPrompt {
    try {
      return _canPrompt();
    } catch (_) {
      return false;
    }
  }

  static bool get isStandalone {
    try {
      return _standalone();
    } catch (_) {
      return false;
    }
  }

  static bool get isIos {
    try {
      return _ios();
    } catch (_) {
      return false;
    }
  }

  static bool get isNative {
    try {
      return _native();
    } catch (_) {
      return false;
    }
  }

  static Future<String?> takePhoto() async {
    if (!isNative) return null;
    try {
      final result = await _takePhoto().toDart;
      if (result == null) return null;
      final text = result.dartify();
      if (text is String && text.isNotEmpty) return text;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> captureGps() async {
    if (!isNative) return null;
    try {
      final result = await _getGps().toDart;
      if (result == null) return null;
      final text = result.dartify();
      if (text is! String || text.isEmpty) return null;
      return Map<String, dynamic>.from(jsonDecode(text) as Map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> requestPermissions() async {
    if (!isNative) return;
    try {
      await _requestPermissions().toDart;
    } catch (_) {
      /* user denied or plugin missing */
    }
  }

  static Future<void> notifySync(String title, String body) async {
    if (!isNative) return;
    try {
      await _notifySync(title.toJS, body.toJS).toDart;
    } catch (_) {
      /* notification permission denied */
    }
  }

  static Future<void> prompt() async {
    try {
      await _prompt().toDart;
    } catch (_) {
      /* browser declined or unavailable */
    }
  }

  static void openUrl(String url) {
    try {
      _openUrl(url.toJS);
    } catch (_) {
      /* missing helper */
    }
  }

  static void downloadText(String filename, String text) {
    try {
      _download(filename.toJS, text.toJS);
    } catch (_) {
      /* missing helper */
    }
  }

  static void onDrain(void Function() fn) {
    try {
      _onDrain = fn.toJS;
    } catch (_) {
      /* service worker messages unavailable */
    }
  }
}
