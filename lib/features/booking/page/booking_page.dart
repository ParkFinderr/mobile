import 'package:flutter/material.dart';
import '../widget/booking_widget.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1628),
      body: SafeArea(child: BookingWidget()),
    );
  }
}
