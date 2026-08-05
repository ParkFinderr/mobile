import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/pwa/pwa_update_service.dart';
import 'core/pwa/pwa_install_service.dart';
import 'shared/styles/theme_provider.dart';

// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/parking/providers/parking_provider.dart';
import 'features/scan/providers/scan_provider.dart';
import 'features/history/providers/history_provider.dart';
import 'features/profile/providers/profile_provider.dart';

import 'core/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    PwaUpdateService.instance.init();
    PwaInstallService.instance.init();
  }
  runApp(const AppProviders());
}

/// AppProviders — Root MultiProvider yang menyuntikkan semua Provider ke tree.
///
/// Semua Provider didaftarkan di sini agar dapat diakses dari seluruh aplikasi.
/// Urutan pendaftaran disesuaikan dengan dependency antar-provider.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        // Auth — digunakan oleh semua feature (cek login status)
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),

        // Home — daftar area parkir & reservasi aktif
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(),
        ),

        // Parking — booking, slot, reservasi operations
        ChangeNotifierProvider<ParkingProvider>(
          create: (_) => ParkingProvider(),
        ),

        // Scan — verifikasi tiket QR
        ChangeNotifierProvider<ScanProvider>(
          create: (_) => ScanProvider(),
        ),

        // History — riwayat reservasi
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(),
        ),

        // Profile — profil user & kendaraan
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
      ],
      child: const MyApp(),
    );
  }
}
