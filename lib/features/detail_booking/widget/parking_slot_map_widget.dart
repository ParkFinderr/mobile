import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'parking_slot_item_widget.dart';

/// Widget feature-specific: Peta slot parkir dua kolom (kiri & kanan)
/// dengan road divider di tengah.
///
/// Hanya digunakan di: DetailBookingWidget.
class ParkingSlotMapWidget extends StatelessWidget {
  final List<ParkingSlotData> leftSlots;
  final List<ParkingSlotData> rightSlots;

  const ParkingSlotMapWidget({
    super.key,
    required this.leftSlots,
    required this.rightSlots,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Kolom kiri
        Expanded(
          child: Column(
            children: leftSlots
                .map((slot) => ParkingSlotItemWidget(
                      slot: slot,
                      showIconOnLeft: true,
                    ))
                .toList(),
          ),
        ),
        // Road divider
        _RoadDividerWidget(rowCount: leftSlots.length),
        // Kolom kanan
        Expanded(
          child: Column(
            children: rightSlots
                .map((slot) => ParkingSlotItemWidget(
                      slot: slot,
                      showIconOnLeft: false,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Widget internal: Divider garis putus-putus yang menyimulasikan jalan.
class _RoadDividerWidget extends StatelessWidget {
  final int rowCount;

  const _RoadDividerWidget({required this.rowCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.borderColor,
      child: Column(
        children: List.generate(
          rowCount,
          (i) => Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 1,
            height: 14,
            color: i % 2 == 0
                ? AppColors.textSecondary
                : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
