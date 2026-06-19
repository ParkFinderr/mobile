import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/pwa/pwa_update_service.dart';
import 'core/pwa/pwa_install_service.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    PwaUpdateService.instance.init();
    PwaInstallService.instance.init();
  }
  runApp(const MyApp());
}
