import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget feature-specific: Card item riwayat parkir menampilkan
/// waktu dari/hingga, slot parkir, ID tiket, dan plat kendaraan.
///
/// Hanya digunakan di: HistoryWidget.
class HistoryCardWidget extends StatelessWidget {
  final String dari;
  final String tglDari;
  final String hingga;
  final String tglHingga;
  final String slotParkir;
  final String idTiket;
  final String kendaraan;

  const HistoryCardWidget({
    super.key,
    required this.dari,
    required this.tglDari,
    required this.hingga,
    required this.tglHingga,
    required this.slotParkir,
    required this.idTiket,
    required this.kendaraan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kiri: Dari & Hingga
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dari',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                  Text(
                    dari,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(tglDari,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                  const SizedBox(height: 8),
                  const Text('Hingga',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                  Text(
                    hingga,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(tglHingga,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                ],
              ),
              const Spacer(),
              // Kanan: Slot & ID Tiket
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Slot Parkir',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                  Text(
                    slotParkir,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  const Text('ID Tiket',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 10)),
                  Text(
                    idTiket,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 8),
          // Bawah: plat kendaraan
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.directions_car_outlined,
                  color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                kendaraan,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
