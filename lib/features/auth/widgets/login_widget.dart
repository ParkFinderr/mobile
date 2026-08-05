import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/styles/theme_provider.dart';
import '../../../core/config/app_config.dart';
import '../providers/auth_provider.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _doLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Silakan lengkapi email dan kata sandi Anda.');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.login(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(result.errorMessage ??
          'Login gagal. Periksa kembali email dan kata sandi Anda.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F203C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Akses Ditolak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03192E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Mengerti',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => const _LoginSuccessSheet(),
    ).then((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, topPad > 0 ? 12 : 24, 20, 24 + bottomPad),
          child: Column(
            children: [
              // Theme Toggle Icon at Top Right
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isDark ? Colors.amber : const Color(0xFF475569),
                  ),
                  onPressed: () {
                    context.read<ThemeProvider>().toggleTheme(!isDark);
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Logo Badge
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.network(
                  '${AppConfig.storageUrl}/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'lib/assets/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.local_parking_rounded,
                      color: Color(0xFF03192E),
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header Titles
              Text(
                'Smart Parking FT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF061E3D),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Silakan masuk ke akun Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Main White Card Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardBgDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: isDark
                      ? Border.all(color: AppColors.borderColorDark)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1 Label: Nama Pengguna/Email
                    Text(
                      'Nama Pengguna/Email',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Input 1
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukan Email anda',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.cardBg2Dark : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF03192E),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Field 2 Label Header Row (Kata Sandi & Lupa Sandi?)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kata Sandi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan hubungi admin untuk reset kata sandi.'),
                              ),
                            );
                          },
                          child: const Text(
                            'Lupa Sandi?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC2410C), // Orange accent
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Input 2: Password
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.remove_red_eye_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF94A3B8),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePass = !_obscurePass);
                          },
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.cardBg2Dark : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF03192E),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // MASUK Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03192E),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF03192E).withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'MASUK',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Divider(
                      color: isDark ? AppColors.borderColorDark : const Color(0xFFF1F5F9),
                      thickness: 1,
                    ),

                    const SizedBox(height: 16),

                    // Footer Link inside card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC2410C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Bottom Footer (Outside Card)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dikelola oleh ParkFinder Developer',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginSuccessSheet extends StatefulWidget {
  const _LoginSuccessSheet();

  @override
  State<_LoginSuccessSheet> createState() => _LoginSuccessSheetState();
}

class _LoginSuccessSheetState extends State<_LoginSuccessSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.elasticOut,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28, 28, 28, 24 + bottomPad),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Selamat',
            style: TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda Berhasil Masuk',
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lanjutkan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
