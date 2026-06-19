import 'package:flutter/material.dart';
import '../../welcome_scan/service/scan_service.dart';
import '../widget/scan_berhasil_widget.dart';

class ScanBerhasilPage extends StatelessWidget {
  final TicketData? ticketData;

  const ScanBerhasilPage({super.key, this.ticketData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1628),
      body: ScanBerhasilWidget(ticketData: ticketData),
    );
  }
}
