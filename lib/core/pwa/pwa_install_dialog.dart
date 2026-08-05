import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pwa_install_service.dart';

class PwaInstallDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const PwaInstallDialog({super.key, required this.onDismiss});

  static void show(BuildContext context, {required VoidCallback onDismiss}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierDismissible: false,
      builder: (_) => PwaInstallDialog(onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF132136).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo or Icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1628),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D2FF),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D2FF).withValues(alpha: 0.25),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Color(0xFF00D2FF),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Install ParkFinder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Untuk pengalaman terbaik, install ParkFinder ke perangkat Anda.\n\nNikmati akses lebih cepat, pengalaman seperti aplikasi native, dan kemudahan penggunaan tanpa membuka browser setiap saat.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final prefs = await SharedPreferences.getInstance();
                          final now = DateTime.now().millisecondsSinceEpoch;
                          await prefs.setInt(
                              'pwa_install_popup_last_dismiss', now);
                          onDismiss();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Lanjut ke Login',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final result =
                              await PwaInstallService.instance.triggerInstall();
                          if (context.mounted) {
                            if (result == 'accepted') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Terima kasih telah menginstal ParkFinder!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                          onDismiss();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D2FF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Install Sekarang',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PwaSafariInstallDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const PwaSafariInstallDialog({super.key, required this.onDismiss});

  static void show(BuildContext context, {required VoidCallback onDismiss}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierDismissible: false,
      builder: (_) => PwaSafariInstallDialog(onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF132136).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D2FF).withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1628),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D2FF),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D2FF).withValues(alpha: 0.25),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.ios_share_rounded,
                    color: Color(0xFF00D2FF),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Install ParkFinder di iOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ParkFinder dapat dipasang di layar utama perangkat iOS Anda melalui Safari:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.ios_share_rounded,
                              color: Color(0xFF00D2FF), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '1. Tekan tombol Share (Bagikan) di bagian bawah layar Safari.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.add_box_outlined,
                              color: Color(0xFF00D2FF), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '2. Pilih "Add to Home Screen" (Tambahkan ke Layar Utama).',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.add_rounded,
                              color: Color(0xFF00D2FF), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '3. Tekan "Add" (Tambah) di pojok kanan atas.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      final now = DateTime.now().millisecondsSinceEpoch;
                      await prefs.setInt('pwa_install_popup_last_dismiss', now);
                      onDismiss();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D2FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lanjut ke Login',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
