// ignore_for_file: uri_does_not_exist, avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

class PwaUpdateService {
  static final PwaUpdateService instance = PwaUpdateService._();
  PwaUpdateService._();

  final _updateController = StreamController<void>.broadcast();

  Stream<void> get onUpdateReady => _updateController.stream;

  void init() {
    html.window.addEventListener('pwa-update-ready', (event) {
      _updateController.add(null);
    });
    // Check if there is already a waiting service worker registered
    try {
      final sw = html.window.navigator.serviceWorker;
      // ignore: unnecessary_null_comparison
      if (sw != null) {
        sw.ready.then((registration) {
          // ignore: unnecessary_null_comparison
          if (registration != null) {
            final waiting = js_util.getProperty(registration, 'waiting');
            if (waiting != null) {
              _updateController.add(null);
            }
          }
        });
      }
    } catch (e) {
      print('SW waiting check error: $e');
    }
  }

  void checkForUpdate() {
    try {
      final sw = html.window.navigator.serviceWorker;
      // ignore: unnecessary_null_comparison
      if (sw != null) {
        sw.getRegistration().then((registration) {
          // ignore: unnecessary_null_comparison
          if (registration != null) {
            js_util.callMethod(registration, 'update', []);
          }
        });
      }
    } catch (e) {
      print('checkForUpdate error: $e');
    }
  }

  void performUpdate() {
    try {
      html.window.location.reload();
    } catch (e) {
      print('performUpdate error: $e');
    }
  }
}
