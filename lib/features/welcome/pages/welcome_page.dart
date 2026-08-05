import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/welcome_widget.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: WelcomeWidget(),
    );
  }
}
