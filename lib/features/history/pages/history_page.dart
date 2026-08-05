import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/history_widget.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: HistoryWidget()),
    );
  }
}
