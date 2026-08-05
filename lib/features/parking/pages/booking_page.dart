import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/booking_widget.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: BookingWidget()),
    );
  }
}
