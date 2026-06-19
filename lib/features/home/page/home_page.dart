import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/home_widget.dart';
import '../../../core/theme/app_colors.dart';

const String _cdn = 'https://storage.googleapis.com/parkfinderbucket';
const String _kTutorialSeen = 'tutorial_seen';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeen = prefs.getBool(_kTutorialSeen) ?? false;
    if (!mounted) return;
    if (!alreadySeen) {
      _showTutorial();
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (_) => _TutorialDialog(
        onDone: () async {
          // Simpan flag agar tidak muncul lagi
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_kTutorialSeen, true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1628),
      body: SafeArea(child: HomeWidget()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tutorial Dialog Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _TutorialStep {
  final String imageUrl;
  final String title;
  final String desc;

  const _TutorialStep({
    required this.imageUrl,
    required this.title,
    required this.desc,
  });
}

class _TutorialDialog extends StatefulWidget {
  final VoidCallback? onDone;
  const _TutorialDialog({this.onDone});

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late final PageController _pageCtrl;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  static final List<_TutorialStep> _steps = [
    _TutorialStep(
      imageUrl: '$_cdn/foto/wel-tutor.png',
      title: '3 Langkah Mudah\nAmankan Parkir Anda',
      desc: 'Tidak perlu repot, cukup ikuti langkah ini untuk mendapatkan '
          'tempat parkir sebelum Anda tiba.',
    ),
    _TutorialStep(
      imageUrl: '$_cdn/foto/tutor1.png',
      title: 'Langkah 1',
      desc: 'Gunakan kolom pencarian untuk menemukan gedung parkir, '
          'dan klik gedung parkir teratas untuk melihat area parkir secara detail',
    ),
    _TutorialStep(
      imageUrl: '$_cdn/foto/tutor2.png',
      title: 'Langkah 2',
      desc: 'Pilih lantai dan nomor slot yang masih kosong. '
          'Ketuk "Pesan Sekarang" untuk mengunci tempat tersebut agar tidak diambil orang lain.',
    ),
    _TutorialStep(
      imageUrl: '$_cdn/foto/tutor3.png',
      title: 'Langkah 3',
      desc: 'Ikuti Panduan menuju slot nya dan ketika sudah sampai di lokasi parkir, '
          'anda bisa tekan tombol saya sudah sampai untuk konfirmasi.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      widget.onDone?.call();
      Navigator.pop(context);
    }
  }

  void _skip() {
    widget.onDone?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: size.height * 0.08,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D2040),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.15),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image area ────────────────────────────────────
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: size.height * 0.32,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _steps.length,
                    itemBuilder: (_, i) => Image.network(
                      _steps[i].imageUrl,
                      key: ValueKey(_steps[i].imageUrl),
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFF0D2040),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF132136),
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.white38, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _steps.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _currentStep ? 22 : 7,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _currentStep
                                ? AppColors.accent
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        step.title,
                        key: ValueKey(step.title),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        step.desc,
                        key: ValueKey(step.desc),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.60),
                          fontSize: 13,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selanjutnya / Mulai button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: AppColors.accent.withOpacity(0.35)),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLast ? 'Mulai' : 'Selanjutnya',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Lewati Tutorial button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white60,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white12),
                          ),
                        ),
                        child: const Text(
                          'Lewati Tutorial',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
