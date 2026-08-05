import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:mobile_front/features/scan/models/ticket_data.dart';
import '../widgets/scan_berhasil_widget.dart';

class ScanBerhasilPage extends StatelessWidget {
  final TicketData? ticketData;

  const ScanBerhasilPage({super.key, this.ticketData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScanBerhasilWidget(ticketData: ticketData),
    );
  }
}
