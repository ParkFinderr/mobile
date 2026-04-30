import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Enum status slot parkir.
enum SlotStatus { alatRusak, kosong, terisi, terpesan, pemeliharaan }

extension SlotStatusExtension on SlotStatus {
  Color get color {
    switch (this) {
      case SlotStatus.alatRusak:
        return AppColors.red;
      case SlotStatus.kosong:
        return AppColors.green;
      case SlotStatus.terisi:
        return Colors.blue;
      case SlotStatus.terpesan:
        return Colors.orange;
      case SlotStatus.pemeliharaan:
        return Colors.purple;
    }
  }

  String get label {
    switch (this) {
      case SlotStatus.alatRusak:
        return 'Alat Rusak';
      case SlotStatus.kosong:
        return 'Kosong';
      case SlotStatus.terisi:
        return 'Terisi';
      case SlotStatus.terpesan:
        return 'Terpesan';
      case SlotStatus.pemeliharaan:
        return 'Pemeliharaan';
    }
  }

  IconData? get icon {
    switch (this) {
      case SlotStatus.terisi:
        return Icons.directions_car;
      case SlotStatus.kosong:
        return Icons.local_parking;
      case SlotStatus.terpesan:
        return Icons.bookmark;
      default:
        return null;
    }
  }
}

/// Data model satu slot parkir.
class ParkingSlotData {
  final String label;
  final SlotStatus status;

  const ParkingSlotData({required this.label, required this.status});
}

/// Widget feature-specific: Satu item slot parkir dengan warna status,
/// label slot, dan ikon kondisi.
///
/// Hanya digunakan di: DetailBookingWidget (via ParkingSlotMapWidget).
class ParkingSlotItemWidget extends StatelessWidget {
  final ParkingSlotData slot;
  final bool showIconOnLeft; // true = kolom kiri (ikon di kanan)

  const ParkingSlotItemWidget({
    super.key,
    required this.slot,
    this.showIconOnLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = slot.status.color;
    final icon = slot.status.icon;
    final showIcon = icon != null &&
        slot.status != SlotStatus.alatRusak &&
        slot.status != SlotStatus.pemeliharaan;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!showIconOnLeft && showIcon)
            Icon(icon, color: color, size: 22)
          else
            const SizedBox(width: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                slot.status.label,
                style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                slot.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
