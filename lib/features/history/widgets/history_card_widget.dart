import 'package:flutter/material.dart';
import '../../../shared/styles/app_colors.dart';

class HistoryCardWidget extends StatelessWidget {
  final String dari;
  final String tglDari;
  final String hingga;
  final String tglHingga;
  final String slotParkir;
  final String idTiket;
  final String kendaraan;
  final String status;

  const HistoryCardWidget({
    super.key,
    required this.dari,
    required this.tglDari,
    required this.hingga,
    required this.tglHingga,
    required this.slotParkir,
    required this.idTiket,
    required this.kendaraan,
    required this.status,
  });

  Widget _buildStatusBadge() {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'selesai':
      case 'active':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        label = 'Selesai';
        break;
      case 'cancelled':
      case 'dibatalkan':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'Dibatalkan';
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = status.isNotEmpty ? status : 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final cardBg2 = AppColors.getCardBg2(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final borderColor = AppColors.getBorderColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.apartment_rounded,
                    color: Color(0xFF1D4ED8),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slotParkir.split('\n').first,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          '$tglDari • $dari',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 16),

          // Bottom Duration Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DURASI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '2j 15m',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.directions_car_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      kendaraan,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
