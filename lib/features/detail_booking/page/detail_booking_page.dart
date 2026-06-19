import 'package:flutter/material.dart';
import '../widget/detail_booking_widget.dart';

class DetailBookingPage extends StatelessWidget {
  final String areaId;

  const DetailBookingPage({super.key, required this.areaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1628),
      body: SafeArea(child: DetailBookingWidget(areaId: areaId)),
    );
  }
}
