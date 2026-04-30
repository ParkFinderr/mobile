import 'package:flutter/material.dart';

import '../widget/splash_screen_widget.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SplashScreenWidget(),
      ),
    );
  }
}
