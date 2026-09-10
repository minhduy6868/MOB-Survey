class InstallBridge {
  static bool get canPrompt => false;
  static bool get isStandalone => true;
  static bool get isIos => false;
  static bool get isNative => false;

  static Future<void> prompt() async {}

  static void openUrl(String url) {}

  static void downloadText(String filename, String text) {}

  static void onDrain(void Function() fn) {}

  static Future<String?> takePhoto() async => null;

  static Future<Map<String, dynamic>?> captureGps() async => null;

  static Future<void> requestPermissions() async {}

  static Future<void> notifySync(String title, String body) async {}
}
