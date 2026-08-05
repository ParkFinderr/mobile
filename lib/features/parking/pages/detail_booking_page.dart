import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/detail_booking_widget.dart';

class DetailBookingPage extends StatelessWidget {
  final String areaId;

  const DetailBookingPage({super.key, required this.areaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: DetailBookingWidget(areaId: areaId)),
    );
  }
}
