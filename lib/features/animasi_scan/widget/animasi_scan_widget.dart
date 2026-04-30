import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'scan_preview_container_widget.dart';
import 'scan_step_info_widget.dart';
import 'scan_step_indicator_widget.dart';
import '../../public_widget/primary_button_widget.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _ScanStep {
  final String title;
  final String desc;
  const _ScanStep({required this.title, required this.desc});
}

// ─── Composer Widget ──────────────────────────────────────────────────────────

/// AnimasiScanWidget: Composer untuk halaman tutorial scan.
///
/// Tanggung jawab:
/// - Mengelola state [_currentStep] dan [AnimationController]
/// - Menyusun widget-widget kecil (ScanPreviewContainer, StepInfo, dll.)
/// - Menangani navigasi ke halamanScan
class AnimasiScanWidget extends StatefulWidget {
  const AnimasiScanWidget({super.key});

  @override
  State<AnimasiScanWidget> createState() => _AnimasiScanWidgetState();
}

class _AnimasiScanWidgetState extends State<AnimasiScanWidget>
    with SingleTickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────
  late AnimationController _ctrl;
  late Animation<double> _scanAnim;
  int _currentStep = 0;

  // ── Data (akan digantikan ViewModel di fase berikutnya) ──────────────────
  static const _steps = [
    _ScanStep(
      title: 'Langkah 1',
      desc: 'Gunakan kolom pencarian untuk menemukan gedung parkir, '
          'dan klik gedung parkir teratas untuk melihat area parkir secara detail',
    ),
    _ScanStep(
      title: 'Langkah 2',
      desc: 'Pilih lantai dan slot parkir yang tersedia, lalu lakukan '
          'booking untuk mengamankan tempat parkir Anda',
    ),
    _ScanStep(
      title: 'Langkah 3',
      desc: 'Scan tiket parkir Anda saat tiba di lokasi untuk mengaktifkan sesi parkir',
    ),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Handlers ───────────────────────────────────────────────────────────────
  void _onNext() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      Navigator.pushNamed(context, AppRoutes.halamanScan);
    }
  }

  // ── Build (Composer) ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLastStep = _currentStep == _steps.length - 1;

    return Column(
      children: [
        // ① Preview area
        Expanded(
          flex: 5,
          child: ScanPreviewContainerWidget(
            scanAnimation: _scanAnim,
            currentStep: _currentStep,
          ),
        ),

        // ② Info step
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: ScanStepInfoWidget(
            title: step.title,
            description: step.desc,
          ),
        ),

        const SizedBox(height: 24),

        // ③ Dot indicator
        ScanStepIndicatorWidget(
          totalSteps: _steps.length,
          currentStep: _currentStep,
        ),

        const SizedBox(height: 20),

        // ④ Tombol aksi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PrimaryButtonWidget(
            label: isLastStep ? 'Mulai Scan' : 'Selanjutnya',
            onTap: _onNext,
          ),
        ),

        const SizedBox(height: 8),

        // ⑤ Page indicator line
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
