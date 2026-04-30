import 'package:flutter/material.dart';
import '../widget/animasi_scan_widget.dart';

class AnimasiScanPage extends StatelessWidget {
  const AnimasiScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A1225),
      body: SafeArea(child: AnimasiScanWidget()),
    );
  }
}
