import 'dart:async';

class PwaInstallService {
  static final PwaInstallService instance = PwaInstallService._();
  PwaInstallService._();

  bool get isSupported => false;
  bool get isStandalone => false;
  
  Stream<void> get onInstallAvailable => const Stream.empty();

  void init() {}
  Future<bool> isInstallPromptAvailable() async => false;
  Future<String> triggerInstall() async => 'not-supported';
}
