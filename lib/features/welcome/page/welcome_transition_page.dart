import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';

const String _cdnBaseUrl = 'https://storage.googleapis.com/parkfinderbucket';

/// Halaman transisi: hanya menampilkan BG image sebelum masuk Login
class WelcomeTransitionPage extends StatefulWidget {
  const WelcomeTransitionPage({super.key});

  @override
  State<WelcomeTransitionPage> createState() => _WelcomeTransitionPageState();
}

class _WelcomeTransitionPageState extends State<WelcomeTransitionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    // Setelah 1.2 detik, fade out lalu ke login
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _ctrl.reverse().then((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fade,
        child: SizedBox.expand(
          child: Image.network(
            '$_cdnBaseUrl/background/bg-wellcome-dark.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C3E6B), Color(0xFF0D1628)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
