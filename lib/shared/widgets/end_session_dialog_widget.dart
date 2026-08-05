import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget shared: Dialog konfirmasi untuk mengakhiri sesi parkir.
///
/// Digunakan di: HomeWidget.
/// Data kendaraan dan durasi di-inject via constructor.
class EndSessionDialogWidget extends StatelessWidget {
  final String vehiclePlate;
  final String parkingDuration;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const EndSessionDialogWidget({
    super.key,
    required this.vehiclePlate,
    required this.parkingDuration,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D6B6B), Color(0xFF1A2D5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Akhiri Sesi Parkir?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sesi parkir untuk kendaraan $vehiclePlate akan diakhiri.\n'
              'Total waktu parkir Anda adalah $parkingDuration.\n'
              'Apakah Anda yakin ingin keluar sekarang?',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Ya, Keluar Sekarang',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
