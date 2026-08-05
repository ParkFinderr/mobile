import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/splash_widget.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SplashScreenWidget(),
      ),
    );
  }
}
