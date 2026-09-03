import 'dart:js_interop';

@JS('troveyCanPromptInstall')
external bool _canPrompt();

@JS('troveyPromptInstall')
external JSPromise<JSAny?> _prompt();

@JS('troveyIsStandalone')
external bool _standalone();

@JS('troveyIsIos')
external bool _ios();

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
}
