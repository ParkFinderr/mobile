import 'package:flutter/material.dart';
import '../widget/detail_booking_widget.dart';

class DetailBookingPage extends StatelessWidget {
  const DetailBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1628),
      body: SafeArea(child: DetailBookingWidget()),
    );
  }
}
