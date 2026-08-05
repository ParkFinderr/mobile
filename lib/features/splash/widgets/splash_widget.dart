import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/pwa/pwa_install_service.dart';
import '../../../core/pwa/pwa_install_dialog.dart';
import 'package:mobile_front/features/profile/services/profile_service.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<Offset> _slideInAnimation;
  late final Animation<double> _fadeInAnimation;

  StreamSubscription? _installSubscription;
  bool _didCheckPwa = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _entryController.forward();
    _initPwaCheck();
  }

  @override
  void dispose() {
    _installSubscription?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  void _initPwaCheck() {
    if (kIsWeb) {
      _installSubscription =
          PwaInstallService.instance.onInstallAvailable.listen((_) {
        if (mounted) {
          _checkPwaInstall();
        }
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _checkPwaInstall();
        }
      });
    }
  }

  Future<void> _checkPwaInstall() async {
    if (_didCheckPwa) return;
    if (!kIsWeb) return;

    if (PwaInstallService.instance.isStandalone) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastDismiss = prefs.getInt('pwa_install_popup_last_dismiss');
    if (lastDismiss != null) {
      final lastDismissDate = DateTime.fromMillisecondsSinceEpoch(lastDismiss);
      final difference = DateTime.now().difference(lastDismissDate).inDays;
      if (difference < 7) {
        return;
      }
    }

    _didCheckPwa = true;

    final available =
        await PwaInstallService.instance.isInstallPromptAvailable();
    if (available) {
      if (mounted) {
        PwaInstallDialog.show(
          context,
          onDismiss: () {
            _goToHome();
          },
        );
      }
    } else {
      final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
      if (isIOS) {
        if (mounted) {
          PwaSafariInstallDialog.show(
            context,
            onDismiss: () {
              _goToHome();
            },
          );
        }
      }
    }
  }

  void _goToHome() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      final profile = await ProfileService().getProfile();
      if (profile != null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  Widget _buildLogo() {
    return Image.network(
      '${AppConfig.storageUrl}/logo.png',
      width: 250,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(
        'lib/assets/logo.png',
        width: 250,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.local_parking_rounded,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _slideInAnimation,
        child: Stack(
          children: [
            Center(
              child: _buildLogo(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Center(
                child: GestureDetector(
                  onTap: () => _goToHome(),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.accent,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
