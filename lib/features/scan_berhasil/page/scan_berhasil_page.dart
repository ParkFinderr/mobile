import 'package:flutter/material.dart';
import '../widget/scan_berhasil_widget.dart';

class ScanBerhasilPage extends StatelessWidget {
  const ScanBerhasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1628),
      body: ScanBerhasilWidget(),
    );
  }
}
