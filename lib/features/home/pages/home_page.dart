import 'package:flutter/material.dart';
import '../widgets/home_widget.dart';
import '../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: HomeWidget()),
    );
  }
}
