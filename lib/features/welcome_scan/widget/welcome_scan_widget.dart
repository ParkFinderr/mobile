import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';

const String _cdnBaseUrl = 'https://storage.googleapis.com/parkfinderbucket';

class WelcomeScanWidget extends StatefulWidget {
  const WelcomeScanWidget({super.key});

  @override
  State<WelcomeScanWidget> createState() => _WelcomeScanWidgetState();
}

class _WelcomeScanWidgetState extends State<WelcomeScanWidget>
    with SingleTickerProviderStateMixin {
  bool _isDark = true;

  // Animasi garis scan yang bergerak naik-turun
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanLine;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scanLine = CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final now = TimeOfDay.now();

    final imageUrl = _isDark
        ? '$_cdnBaseUrl/background/bg-wellcome-dark.png'
        : '$_cdnBaseUrl/background/bg-wellcome-light.png';

    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Layer 1: Background image ──────────────────────────
          Positioned.fill(
            child: Image.network(
              imageUrl,
              key: ValueKey(imageUrl),
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.15),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF87CEEB),
              ),
            ),
          ),

          // ── Layer 2: Scan frame + overlay di area tengah ───────
          Positioned(
            top: topPad + 60,
            left: 0,
            right: 0,
            bottom: 200,
            child: _ScanFrameArea(scanLine: _scanLine),
          ),

          // ── Layer 3: Bottom info panel ─────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B1A30),
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
              ),
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Waktu akses
                  Text(
                    'Diakses pada ${now.format(context)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Judul
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
                    'Silahkan Scan terlebih dahulu',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol aksi bawah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.manage_search_rounded,
                        label: 'Manual Cari',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.animasiScan),
                      ),
                      const SizedBox(width: 32),
                      _ActionButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Ambil Foto',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.scanBerhasil),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Layer 4: Theme toggle ──────────────────────────────
          Positioned(
            top: topPad + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => setState(() => _isDark = !_isDark),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isDark ? 'Terang' : 'Gelap',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _isDark ? Icons.wb_sunny : Icons.nightlight_round,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan frame + animasi garis ─────────────────────────────────────────────────
class _ScanFrameArea extends StatelessWidget {
  final Animation<double> scanLine;
  const _ScanFrameArea({required this.scanLine});

  @override
  Widget build(BuildContext context) {
    const frameSize = 220.0;
    const cornerLen = 28.0;
    const cornerWidth = 3.5;
    const cornerColor = Colors.white;

    return Center(
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          children: [
            // ── Corner brackets ──────────────────────────────────
            // Top-left
            Positioned(
              top: 0, left: 0,
              child: _Corner(h: true, v: true,
                  len: cornerLen, width: cornerWidth, color: cornerColor),
            ),
            // Top-right
            Positioned(
              top: 0, right: 0,
              child: _Corner(h: false, v: true,
                  len: cornerLen, width: cornerWidth, color: cornerColor),
            ),
            // Bottom-left
            Positioned(
              bottom: 0, left: 0,
              child: _Corner(h: true, v: false,
                  len: cornerLen, width: cornerWidth, color: cornerColor),
            ),
            // Bottom-right
            Positioned(
              bottom: 0, right: 0,
              child: _Corner(h: false, v: false,
                  len: cornerLen, width: cornerWidth, color: cornerColor),
            ),

            // ── Scan line animasi ────────────────────────────────
            AnimatedBuilder(
              animation: scanLine,
              builder: (_, __) {
                final top = scanLine.value * (frameSize - 3);
                return Positioned(
                  top: top,
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.accent.withOpacity(0.9),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.6),
                          blurRadius: 8,
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
      ),
    );
  }
}

/// Sudut bracket scanner
class _Corner extends StatelessWidget {
  final bool h; // true = left, false = right
  final bool v; // true = top, false = bottom
  final double len;
  final double width;
  final Color color;
  const _Corner({
    required this.h,
    required this.v,
    required this.len,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
        painter: _CornerPainter(
            isLeft: h, isTop: v, strokeWidth: width, color: color),
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

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint); // horizontal
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint); // vertical
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Tombol ikon kecil di bawah
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
              color: Colors.white.withOpacity(0.08),
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
