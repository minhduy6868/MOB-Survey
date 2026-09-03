import 'dart:js_interop';

@JS('troveyCanPromptInstall')
external bool _canPrompt();

@JS('troveyPromptInstall')
external JSPromise<JSAny?> _prompt();

@JS('troveyIsStandalone')
external bool _standalone();

@JS('troveyIsIos')
external bool _ios();

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
