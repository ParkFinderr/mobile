import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/styles/theme_provider.dart';
import '../providers/auth_provider.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  final _noKendCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _teleponCtrl.dispose();
    _noKendCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _doRegister() async {
    final name = _namaCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _teleponCtrl.text.trim();
    final vehicle = _noKendCtrl.text.trim();
    final password = _passCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog('Silakan lengkapi semua data wajib.');
      return;
    }

    if (password != confirm) {
      _showErrorDialog('Kata sandi dan konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      plateNumber: vehicle,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(
          result.errorMessage ?? 'Pendaftaran gagal. Silakan coba lagi.');
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
                'Pendaftaran Gagal',
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
      builder: (_) => const _RegisterSuccessSheet(),
    ).then((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
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
          padding: EdgeInsets.fromLTRB(20, topPad > 0 ? 12 : 20, 20, 24 + bottomPad),
          child: Column(
            children: [
              // Theme Toggle Icon
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

              const SizedBox(height: 4),

              // Title Header
              Text(
                'Daftar Akun',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF061E3D),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Lengkapi data diri Anda untuk mulai menggunakan layanan Smart Parking FT Unila.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

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
                    // Field 1: Nama Pengguna
                    _buildFormField(
                      label: 'Nama Pengguna',
                      controller: _namaCtrl,
                      hintText: 'Masukkan nama pengguna anda',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // Field 2: Email
                    _buildFormField(
                      label: 'Email',
                      controller: _emailCtrl,
                      hintText: 'Masukkan email anda',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // Field 3: No telepon
                    _buildFormField(
                      label: 'No telepon',
                      controller: _teleponCtrl,
                      hintText: 'Masukkan nomor telepon anda',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // Field 4: No Kendaraan
                    _buildFormField(
                      label: 'No Kendaraan',
                      controller: _noKendCtrl,
                      hintText: 'Masukkan nomor kendaraan anda',
                      icon: Icons.directions_car_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),

                    // Field 5: Kata Sandi
                    _buildFormField(
                      label: 'Kata Sandi',
                      controller: _passCtrl,
                      hintText: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePass,
                      isDark: isDark,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.remove_red_eye_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 6: Ulangi Kata Sandi
                    _buildFormField(
                      label: 'Ulangi Kata Sandi',
                      controller: _confirmPassCtrl,
                      hintText: '••••••••',
                      icon: Icons.lock_reset_rounded,
                      obscureText: _obscureConfirm,
                      isDark: isDark,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.remove_red_eye_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button: Daftar Sekarang ->
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _doRegister,
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
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Daftar Sekarang',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Footer Link inside card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          },
                          child: const Text(
                            'Masuk',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF94A3B8),
              size: 20,
            ),
            suffixIcon: suffixIcon,
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
      ],
    );
  }
}

class _RegisterSuccessSheet extends StatefulWidget {
  const _RegisterSuccessSheet();

  @override
  State<_RegisterSuccessSheet> createState() => _RegisterSuccessSheetState();
}

class _RegisterSuccessSheetState extends State<_RegisterSuccessSheet>
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
            'Anda Berhasil Mendaftar',
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
                'Silahkan Masuk',
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
