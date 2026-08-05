import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget shared: Search bar dengan dua mode:
/// - [readOnly] = true → hanya bisa di-tap (dipakai di Home)
/// - [readOnly] = false → bisa diketik (dipakai di Booking, DetailBooking)
///
/// Digunakan di: HomeWidget (readOnly), BookingWidget, DetailBookingWidget.
class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Cari Gedung Parkir',
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: readOnly
          ? GestureDetector(
              onTap: onTap,
              child: _buildStaticBar(),
            )
          : TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary, size: 20),
                filled: true,
                fillColor: AppColors.cardBg,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
            ),
    );
  }

  Widget _buildStaticBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Text(
            hintText,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
