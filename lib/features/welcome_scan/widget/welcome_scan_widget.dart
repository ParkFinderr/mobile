import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/active_ticket_storage.dart';
import '../../access/service/access_service.dart';
import '../service/scan_service.dart';

class WelcomeScanWidget extends StatefulWidget {
  const WelcomeScanWidget({super.key});

  @override
  State<WelcomeScanWidget> createState() => _WelcomeScanWidgetState();
}

class _WelcomeScanWidgetState extends State<WelcomeScanWidget>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _cameraCtrl;
  final _ticketCodeCtrl = TextEditingController();

  late final AnimationController _scanLineCtrl;
  late final Animation<double> _scanLine;

  bool _hasScanned = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _torchOn = false;
  bool _useCamera = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _useCamera = false;
    } else {
      try {
        _cameraCtrl = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
          torchEnabled: false,
        );
      } catch (_) {
        _useCamera = false;
      }
    }
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scanLine =
        CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ticketCodeCtrl.dispose();
    _scanLineCtrl.dispose();
    _cameraCtrl?.dispose();
    super.dispose();
  }

  Future<void> _verifyManualCode() async {
    final code = _ticketCodeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan kode tiket terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final scanService = ScanService();
    final result = await scanService.verifyTicket(code);

    if (!mounted) return;

    if (result != null) {
      final accessService = AccessService();
      final activeTicket = await accessService.getActiveTicket();
      final ticketData = activeTicket ?? result;
      await ActiveTicketStorage().save(ticketData);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.scanBerhasil,
        arguments: ticketData,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tiket tidak valid. Silakan periksa kembali kode tiket Anda.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned || _isLoading) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      _hasScanned = true;
      _isLoading = true;
      _errorMessage = null;
    });
    _cameraCtrl?.stop();

    final qrCode = barcode.rawValue!;
    final scanService = ScanService();
    final result = await scanService.verifyTicket(qrCode);

    if (!mounted) return;

    if (result != null) {
      final accessService = AccessService();
      final activeTicket = await accessService.getActiveTicket();
      final ticketData = activeTicket ?? result;
      await ActiveTicketStorage().save(ticketData);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.scanBerhasil,
        arguments: ticketData,
      );
    } else {
      setState(() {
        _isLoading = false;
        _hasScanned = false;
        _errorMessage = 'Tiket tidak valid. Silakan pindai ulang.';
      });
      _cameraCtrl?.start();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_useCamera || _cameraCtrl == null) {
      return _buildManualLayout(context);
    }

    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final now = TimeOfDay.now();

    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Layer 1: Live camera feed ──────────────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraCtrl!,
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
            height: 265 + bottomPad,
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          // Kiri
          Positioned(
            top: topPad + 64,
            bottom: 265 + bottomPad,
            left: 0,
            width: _sideMargin(context),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          // Kanan
          Positioned(
            top: topPad + 64,
            bottom: 265 + bottomPad,
            right: 0,
            width: _sideMargin(context),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          // ── Layer 3: Scan frame + animasi garis ────────────────
          Center(
            child: _ScanFrame(scanLine: _scanLine),
          ),

          // ── Layer 4: Loading overlay ────────────────────────────
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            ),

          // ── Layer 5: Bottom info panel ─────────────────────────
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
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Langkah 1: Scan tiket yang diperoleh dari gerbang masuk.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Langkah 2: Setelah tiket berhasil diverifikasi, Anda dapat melakukan booking slot parkir.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
                          _cameraCtrl?.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                      ),
                      const SizedBox(width: 32),
                      // Ganti kamera depan/belakang
                      _ActionButton(
                        icon: Icons.cameraswitch_rounded,
                        label: 'Balik',
                        onTap: () => _cameraCtrl?.switchCamera(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _useCamera = false),
                    child: const Text(
                      'Masukkan Kode Manual',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Layer 6: Tombol tutup / kembali ───────────────────
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

          // ── Layer 7: Hint teks di atas frame ──────────────────
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

  Widget _buildManualLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header/App bar manual
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Verifikasi Tiket',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 40),

              // Orbiting elements / QR Icon fallback
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.cardBg2,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Verifikasi Tiket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Kamera tidak tersedia. Silakan masukkan kode tiket parkir Anda secara manual untuk melanjutkan booking.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Step Guidance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF132136).withOpacity(0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF00D2FF).withOpacity(0.25),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF00D2FF),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Langkah Aktivasi Sesi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00D2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Masukkan kode tiket yang diperoleh dari gerbang masuk ke kolom di bawah.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00D2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '2',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Setelah tiket berhasil diverifikasi, Anda dapat melakukan booking slot parkir.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Input Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kode Tiket Parkir',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ticketCodeCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Contoh: TCK-12345',
                        hintStyle:
                            const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.cardBg2,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyManualCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Verifikasi Tiket',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() => _useCamera = true);
                  _initCamera();
                },
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Gunakan Kamera'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initCamera() {
    if (_cameraCtrl != null) return;
    try {
      _cameraCtrl = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    } catch (_) {
      _useCamera = false;
    }
    if (mounted) setState(() {});
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
