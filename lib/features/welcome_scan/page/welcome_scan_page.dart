import 'package:flutter/material.dart';
import '../widget/welcome_scan_widget.dart';

class WelcomeScanPage extends StatelessWidget {
  const WelcomeScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A1225),
      body: WelcomeScanWidget(),
    );
  }
}
