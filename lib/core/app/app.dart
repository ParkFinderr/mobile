import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pwa/pwa_update_service.dart';
import '../routes/app_routes.dart';
import '../routes/app_router.dart';
import '../../shared/styles/app_theme.dart';
import '../../shared/styles/theme_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'ParkFinder',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2.0,
        content: const Row(
          children: [
            Icon(Icons.system_update_rounded, color: Colors.white),
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
                color: Colors.white,
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
