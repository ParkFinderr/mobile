import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../public_widget/parking_list_item_widget.dart';

/// Widget feature-specific: Konten preview mock UI di dalam
/// scan preview container (step 1 – menampilkan daftar gedung parkir).
///
/// Hanya digunakan di: AnimasiScanPage.
class ScanPreviewContentWidget extends StatelessWidget {
  static const _previewItems = [
    ParkingItemData(
      name: 'Jurusan Teknik Elektro Universitas Lampung',
      occupancyPercent: 78,
      availableSlotLabel: '4/5 Kosong',
    ),
    ParkingItemData(
      name: 'Mall Boemi Kedaton',
      occupancyPercent: 81,
      availableSlotLabel: '635/1384 Kosong',
    ),
    ParkingItemData(
      name: 'Lampung City Mall',
      occupancyPercent: 81,
      availableSlotLabel: '635/1384 Kosong',
    ),
  ];

  const ScanPreviewContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1628),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Search bar mock (static, non-interactive)
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.cardBg2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.search, color: AppColors.textSecondary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Cari Gedung Parkir',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gedung Parkir yang Tersedia',
            style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Mini preview list — tanpa onTap karena ini hanya mockup
          ..._previewItems.map(
            (item) => _MiniParkingPreviewItem(item: item),
          ),
        ],
      ),
    );
  }
}

/// Item mini khusus untuk preview (ukuran lebih kecil dari ParkingListItemWidget).
class _MiniParkingPreviewItem extends StatelessWidget {
  final ParkingItemData item;

  const _MiniParkingPreviewItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: item.occupancyPercent / 100,
                  backgroundColor: AppColors.borderColor,
                  color: AppColors.accent,
                  minHeight: 3,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.occupancyPercent.toInt()}%',
            style:
                const TextStyle(color: AppColors.accent, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
