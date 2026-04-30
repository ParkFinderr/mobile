import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget shared: Judul section dengan styling standar (teks accent + bold).
///
/// Digunakan di: HomeWidget (Gedung Parkir yang Tersedia), ProfilWidget.
class SectionTitleWidget extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const SectionTitleWidget({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
