// ignore_for_file: uri_does_not_exist, avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

class PwaInstallService {
  static final PwaInstallService instance = PwaInstallService._();
  PwaInstallService._();

  final _installAvailableController = StreamController<void>.broadcast();
  Stream<void> get onInstallAvailable => _installAvailableController.stream;

  bool get isSupported => true;
  
  void init() {
    html.window.addEventListener('pwa-install-available', (event) {
      _installAvailableController.add(null);
    });
  }

  bool get isStandalone {
    try {
      final isStandaloneMode = html.window.matchMedia('(display-mode: standalone)').matches;
      final isSafariStandalone = js_util.getProperty(html.window.navigator, 'standalone') == true;
      return isStandaloneMode || isSafariStandalone;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isInstallPromptAvailable() async {
    try {
      final prompt = js_util.getProperty(html.window, 'deferredInstallPrompt');
      return prompt != null;
    } catch (_) {
      return false;
    }
  }

  Future<String> triggerInstall() async {
    try {
      if (js_util.hasProperty(html.window, 'triggerPWAInstall')) {
        final result = await js_util.promiseToFuture(
          js_util.callMethod(html.window, 'triggerPWAInstall', [])
        );
        return result.toString(); // 'accepted', 'dismissed', 'not-available'
      }
    } catch (e) {
      print('triggerInstall error: $e');
    }
    return 'not-available';
  }
}
