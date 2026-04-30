import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:ui';

const String _cdnBaseUrl = 'https://storage.googleapis.com/parkfinderbucket';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget>
    with SingleTickerProviderStateMixin {
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  final _noKendCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isDark = true;

  // Focus nodes untuk neon glow effect
  final _namaFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _telFocus = FocusNode();
  final _kendFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();

    // Rebuild on focus change untuk glow effect
    for (final fn in [
      _namaFocus, _emailFocus, _telFocus,
      _kendFocus, _passFocus, _confirmFocus
    ]) {
      fn.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _teleponCtrl.dispose();
    _noKendCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _namaFocus.dispose();
    _emailFocus.dispose();
    _telFocus.dispose();
    _kendFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _doRegister() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => const _SuccessSheet(),
    ).then((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    final imageUrl = _isDark
        ? '$_cdnBaseUrl/background/bg-wellcome-dark.png'
        : '$_cdnBaseUrl/background/bg-wellcome-light.png';

    final fallbackGradient = _isDark
        ? const LinearGradient(
            colors: [Color(0xFF2C3E6B), Color(0xFF0D1628)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFF87CEEB), Color(0xFFB0D9F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return SizedBox.expand(
      child: Stack(
        children: [
          // ── Layer 1: Background image full ─────────────────────
          Positioned.fill(
            child: Image.network(
              imageUrl,
              key: ValueKey(imageUrl),
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                    decoration: BoxDecoration(gradient: fallbackGradient));
              },
              errorBuilder: (_, __, ___) =>
                  Container(decoration: BoxDecoration(gradient: fallbackGradient)),
            ),
          ),

          // ── Layer 2: Dark overlay ringan ───────────────────────
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.30)),
          ),

          // ── Layer 3: Scrollable glassmorphism card ─────────────
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, topPad + 60, 20, 32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ── Header ──────────────────────────
                            const Text(
                              'ParkFinder',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Silahkan daftarkan akun anda',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.60),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Fields ───────────────────────────
                            _NeonField(
                              controller: _namaCtrl,
                              focusNode: _namaFocus,
                              hintText: 'Nama Pengguna',
                              glowColor: const Color(0xFF00E676), // green
                            ),
                            const SizedBox(height: 10),
                            _NeonField(
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              glowColor: const Color(0xFFFF5252), // red
                            ),
                            const SizedBox(height: 10),
                            _NeonField(
                              controller: _teleponCtrl,
                              focusNode: _telFocus,
                              hintText: 'Nomor Telpon',
                              keyboardType: TextInputType.phone,
                              glowColor: const Color(0xFF40C4FF), // cyan
                            ),
                            const SizedBox(height: 10),
                            _NeonField(
                              controller: _noKendCtrl,
                              focusNode: _kendFocus,
                              hintText: 'Nomor Kendaraan',
                              glowColor: const Color(0xFFFF5252), // red
                            ),
                            const SizedBox(height: 10),
                            _NeonField(
                              controller: _passCtrl,
                              focusNode: _passFocus,
                              hintText: 'Kata Sandi',
                              obscureText: _obscurePass,
                              glowColor: const Color(0xFF00E676), // green
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white60,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _NeonField(
                              controller: _confirmPassCtrl,
                              focusNode: _confirmFocus,
                              hintText: 'Ulang Kata Sandi',
                              obscureText: _obscureConfirm,
                              glowColor: const Color(0xFF00E676), // green
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white60,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // ── Daftar button ────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _doRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.black54,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Daftar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Login link ───────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sudah Punya Akun? Silahkan ',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.70),
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(
                                      context, AppRoutes.login),
                                  child: const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
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
                ),
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
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13),
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

/// Input field dengan neon glow effect saat fokus
class _NeonField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Color glowColor;

  const _NeonField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.glowColor,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.55),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.40), fontSize: 14),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white.withOpacity(0.09),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: glowColor.withOpacity(0.35),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: glowColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Bottom sheet sukses daftar — slide dari bawah ke atas
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessSheet extends StatefulWidget {
  const _SuccessSheet();

  @override
  State<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<_SuccessSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SlideTransition(
      position: _slide,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(28, 32, 28, 28 + bottomPad),
        decoration: const BoxDecoration(
          color: Color(0xFF0F2044),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),

            // Ikon centang — scale pop animation
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withOpacity(0.45),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Teks sukses
            const Text(
              'Selamat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Anda Berhasil Mendaftar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Silahkan Masuk
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: AppColors.accent.withOpacity(0.4),
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Silahkan Masuk',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

