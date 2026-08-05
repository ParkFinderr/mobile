import 'package:flutter/material.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import 'package:mobile_front/features/scan/models/ticket_data.dart';
import '../../../core/storage/active_ticket_storage.dart';

const String _cdnBaseUrl = 'https://storage.googleapis.com/parkfinderbucket';

class ScanBerhasilWidget extends StatefulWidget {
  final TicketData? ticketData;

  const ScanBerhasilWidget({super.key, this.ticketData});

  @override
  State<ScanBerhasilWidget> createState() => _ScanBerhasilWidgetState();
}

class _ScanBerhasilWidgetState extends State<ScanBerhasilWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    if (widget.ticketData != null) {
      ActiveTicketStorage().save(widget.ticketData!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final now = TimeOfDay.now();

    final imageUrl = _isDark
        ? '$_cdnBaseUrl/background/bg-wellcome-dark.png'
        : '$_cdnBaseUrl/background/bg-wellcome-light.png';

    final fallback = _isDark
        ? const LinearGradient(
            colors: [Color(0xFF2C5C8A), Color(0xFF0D1628)],
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
          // ── Layer 1: Background image ──────────────────────────
          Positioned.fill(
            child: Image.network(
              imageUrl,
              key: ValueKey(imageUrl),
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.45),
              colorBlendMode: BlendMode.darken,
              loadingBuilder: (ctx, child, p) {
                if (p == null) return child;
                return Container(decoration: BoxDecoration(gradient: fallback));
              },
              errorBuilder: (_, __, ___) => Image.asset(
                'lib/assets/welcome/gedung_welcome.png',
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.45),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (_, __, ___) =>
                    Container(decoration: BoxDecoration(gradient: fallback)),
              ),
            ),
          ),

          // ── Layer 2: Main result card ──────────────────────────
          Positioned(
            top: topPad + 48,
            left: 16,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  color: AppColors.getCardBg(context).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.getBorderColor(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isDark ? 0.4 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Waktu akses
                    Text(
                      'Diakses pada ${now.format(context)}',
                      style: TextStyle(
                          color: AppColors.getTextSecondary(context), fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Judul
                    Text(
                      'Scan Berhasil',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tiket Parkir Anda telah diaktifkan',
                      style: TextStyle(
                          color: AppColors.getTextSecondary(context), fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // Ikon centang dengan scale pop
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withValues(alpha: 0.5),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 54),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Info tiket
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.getCardBg2(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.getBorderColor(context)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Kode Tiket:',
                            style: TextStyle(
                                color: AppColors.getTextSecondary(context), fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.ticketData?.ticketCode ??
                                'TXT-00000000-0000',
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Divider(
                              color: AppColors.getBorderColor(context), height: 1),
                          const SizedBox(height: 14),
                          Text(
                            'Status:',
                            style: TextStyle(
                                color: AppColors.getTextSecondary(context), fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.ticketData?.status == 'active'
                                      ? AppColors.green
                                      : const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.ticketData?.status == 'active'
                                    ? 'Aktif'
                                    : widget.ticketData?.status != null &&
                                            widget.ticketData!.status.isNotEmpty
                                        ? widget.ticketData!.status
                                        : 'Aktif',
                                style: TextStyle(
                                  color: widget.ticketData?.status == 'active'
                                      ? AppColors.green
                                      : const Color(0xFF2563EB),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
          ),

          // ── Layer 3: Bottom buttons ────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPad),
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lanjut Booking → Home
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Lanjut Booking',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pindai Ulang → kembali ke WelcomeScan
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.welcomeScan),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.getCardBg(context),
                        foregroundColor: AppColors.getTextPrimary(context),
                        side: BorderSide(color: AppColors.getBorderColor(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Pindai Ulang',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isDark ? 'Terang' : 'Gelap',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
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
