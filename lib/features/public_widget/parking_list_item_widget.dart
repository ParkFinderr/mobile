import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Data model untuk satu item gedung parkir.
class ParkingItemData {
  final String name;
  final double occupancyPercent; // 0.0 – 100.0
  final String availableSlotLabel; // contoh: "4/5 Kosong"

  const ParkingItemData({
    required this.name,
    required this.occupancyPercent,
    required this.availableSlotLabel,
  });
}

/// Widget shared: Card item gedung parkir dengan nama, progress bar,
/// persentase kapasitas, dan label slot tersedia.
///
/// Digunakan di: HomeWidget, BookingWidget, AnimasiScanWidget (preview).
class ParkingListItemWidget extends StatelessWidget {
  final ParkingItemData item;
  final VoidCallback? onTap;

  const ParkingListItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: AppColors.accent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: item.occupancyPercent / 100,
                      backgroundColor: AppColors.borderColor,
                      color: AppColors.accent,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.occupancyPercent.toInt()}%',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.availableSlotLabel,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
