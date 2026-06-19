import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/pwa/pwa_update_service.dart';
import 'app_routes.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      useInheritedMediaQuery: true,
      title: 'ParkFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Color(0xFF8BA3BC)),
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D2FF),
          secondary: Color(0xFF00D2FF),
          surface: Color(0xFF132136),
          background: Color(0xFF0D1628),
          error: Color(0xFFEF5350),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1628),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1628),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF00D2FF);
            }
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF00D2FF).withOpacity(0.4);
            }
            return Colors.grey.withOpacity(0.3);
          }),
        ),
      ),
      initialRoute: AppRoutes.splashScreen,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        return UpdateListenerWrapper(child: child ?? const SizedBox());
      },
    );
  }
}

class UpdateListenerWrapper extends StatefulWidget {
  final Widget child;
  const UpdateListenerWrapper({super.key, required this.child});

  @override
  State<UpdateListenerWrapper> createState() => _UpdateListenerWrapperState();
}

class _UpdateListenerWrapperState extends State<UpdateListenerWrapper> {
  StreamSubscription? _subscription;
  bool _hasShownBanner = false;

  @override
  void initState() {
    super.initState();
    _subscription = PwaUpdateService.instance.onUpdateReady.listen((_) {
      _showUpdateBanner();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showUpdateBanner() {
    if (_hasShownBanner) return;
    setState(() {
      _hasShownBanner = true;
    });

    scaffoldMessengerKey.currentState?.showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF0D1628),
        elevation: 2.0,
        content: Row(
          children: const [
            Icon(Icons.system_update_rounded, color: Color(0xFF00D2FF)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Versi baru tersedia. Klik untuk memperbarui.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              scaffoldMessengerKey.currentState?.clearMaterialBanners();
              PwaUpdateService.instance.performUpdate();
            },
            child: const Text(
              'PERBARUI',
              style: TextStyle(
                color: Color(0xFF00D2FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

