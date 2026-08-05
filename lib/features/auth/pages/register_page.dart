import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/register_widget.dart';

/// RegisterPage — Wrapper halaman untuk RegisterWidget.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: RegisterWidget(),
    );
  }
}
