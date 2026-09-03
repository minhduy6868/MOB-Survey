class InstallBridge {
  static bool get canPrompt => false;
  static bool get isStandalone => true;
  static bool get isIos => false;

  static Future<void> prompt() async {}

  static void openUrl(String url) {}

  static void downloadText(String filename, String text) {}

  static void onDrain(void Function() fn) {}
}
