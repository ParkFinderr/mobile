import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeScanWidget extends StatefulWidget {
  const WelcomeScanWidget({super.key});

  @override
  State<WelcomeScanWidget> createState() => _WelcomeScanWidgetState();
}

class _WelcomeScanWidgetState extends State<WelcomeScanWidget>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  // Animasi garis scan naik-turun
  late final AnimationController _scanLineCtrl;
  late final Animation<double> _scanLine;

  bool _hasScanned = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scanLine =
        CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _cameraCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _hasScanned = true);
    _cameraCtrl.stop();

    // Langsung navigate ke halaman hasil scan
    Navigator.pushReplacementNamed(context, AppRoutes.scanBerhasil);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final now = TimeOfDay.now();

    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Layer 1: Live camera feed ──────────────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraCtrl,
              onDetect: _onDetect,
            ),
          ),

          // ── Layer 2: Dark overlay (atas & bawah) ───────────────
          // Atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPad + 64,
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          // Bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 210 + bottomPad,
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          // Kiri
          Positioned(
            top: topPad + 64,
            bottom: 210 + bottomPad,
            left: 0,
            width: _sideMargin(context),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          // Kanan
          Positioned(
            top: topPad + 64,
            bottom: 210 + bottomPad,
            right: 0,
            width: _sideMargin(context),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          // ── Layer 3: Scan frame + animasi garis ────────────────
          Center(
            child: _ScanFrame(scanLine: _scanLine),
          ),

          // ── Layer 4: Bottom info panel ─────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xFF0B1A30),
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Diakses pada ${now.format(context)}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Silahkan Scan tiket parkir terlebih dahulu',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Tombol aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Toggle senter
                      _ActionButton(
                        icon: _torchOn
                            ? Icons.flashlight_off_rounded
                            : Icons.flashlight_on_rounded,
                        label: _torchOn ? 'Matikan' : 'Senter',
                        onTap: () {
                          _cameraCtrl.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                      ),
                      const SizedBox(width: 32),
                      // Ganti kamera depan/belakang
                      _ActionButton(
                        icon: Icons.cameraswitch_rounded,
                        label: 'Balik',
                        onTap: () => _cameraCtrl.switchCamera(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Layer 5: Tombol tutup / kembali ───────────────────
          Positioned(
            top: topPad + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),

          // ── Layer 6: Hint teks di atas frame ──────────────────
          Positioned(
            top: topPad + 72,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Arahkan kamera ke barcode tiket parkir',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _sideMargin(BuildContext context) {
    const frameSize = 240.0;
    return (MediaQuery.of(context).size.width - frameSize) / 2;
  }
}

// ─── Scan frame dengan corner bracket dan garis neon ───────────────────────
class _ScanFrame extends StatelessWidget {
  final Animation<double> scanLine;
  const _ScanFrame({required this.scanLine});

  @override
  Widget build(BuildContext context) {
    const frameSize = 240.0;
    const cornerLen = 30.0;
    const cornerWidth = 4.0;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        children: [
          // Corner brackets
          Positioned(top: 0, left: 0,
            child: _Corner(isLeft: true, isTop: true,
                len: cornerLen, width: cornerWidth)),
          Positioned(top: 0, right: 0,
            child: _Corner(isLeft: false, isTop: true,
                len: cornerLen, width: cornerWidth)),
          Positioned(bottom: 0, left: 0,
            child: _Corner(isLeft: true, isTop: false,
                len: cornerLen, width: cornerWidth)),
          Positioned(bottom: 0, right: 0,
            child: _Corner(isLeft: false, isTop: false,
                len: cornerLen, width: cornerWidth)),

          // Garis scan neon
          AnimatedBuilder(
            animation: scanLine,
            builder: (_, __) {
              return Positioned(
                top: scanLine.value * (frameSize - 3),
                left: 12,
                right: 12,
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accent.withOpacity(0.95),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool isLeft;
  final bool isTop;
  final double len;
  final double width;
  const _Corner({
    required this.isLeft,
    required this.isTop,
    required this.len,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
        painter: _CornerPainter(
          isLeft: isLeft,
          isTop: isTop,
          strokeWidth: width,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isLeft;
  final bool isTop;
  final double strokeWidth;
  final Color color;

  _CornerPainter({
    required this.isLeft,
    required this.isTop,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? size.width : -size.width;
    final dy = isTop ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
