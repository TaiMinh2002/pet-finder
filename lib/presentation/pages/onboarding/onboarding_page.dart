import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_finder/core/constants/app_constants.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:pet_finder/presentation/pages/onboarding/community_painter.dart';
import 'package:pet_finder/presentation/pages/onboarding/lost_dog_painter.dart';
import 'package:pet_finder/presentation/pages/onboarding/map_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_data.dart';
import 'particle.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  // ── Page state ───────────────────────────────────────────────
  int _currentPage = 0;
  final _pageCtrl = PageController();
  List<OnboardingData> _pages = [];

  // ── Float animation (continuous) ────────────────────────────
  late final AnimationController _floatCtrl;

  // ── Slide entrance animation ─────────────────────────────────
  late AnimationController _slideCtrl;
  late Animation<double> _slideOpacity;
  late Animation<Offset> _slidePos;

  // ── Particle system ──────────────────────────────────────────
  late final AnimationController _particleCtrl;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Float loop
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Particle ticker
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps tick
    )..addListener(_tickParticles)
      ..repeat();

    _buildSlideAnim();
    _slideCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = buildOnboardingPages(AppLocalizations.of(context));
  }

  // ── Slide animation ──────────────────────────────────────────
  void _buildSlideAnim() {
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slideOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut),
    );
    _slidePos = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
  }

  // ── Particle tick ─────────────────────────────────────────────
  void _tickParticles() {
    setState(() {
      for (final p in _particles) {
        p.update();
      }
      _particles.removeWhere((p) => p.isDead);
    });
  }

  void _spawnParticles(Color color) {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!mounted) return;
        setState(() {
          _particles.add(Particle.random(size, color));
        });
      });
    }
  }

  // ── Navigation ───────────────────────────────────────────────
  void _onPageChanged(int i) {
    _slideCtrl.dispose();
    setState(() => _currentPage = i);
    _buildSlideAnim();
    _slideCtrl.forward();
    if (_pages.isNotEmpty) _spawnParticles(_pages[i].color);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (mounted) context.go('/auth/login');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _floatCtrl.dispose();
    _slideCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: Stack(
        children: [
          // ── Animated background blobs ──────────────────────────
          _buildBlobs(page.color, size),

          // ── Particles ─────────────────────────────────────────
          ..._particles.map((p) => Positioned(
                left: p.position.dx - p.radius,
                top: p.position.dy - p.radius,
                child: Opacity(
                  opacity: p.opacity,
                  child: Container(
                    width: p.radius * 2,
                    height: p.radius * 2,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      _buildDots(page.color),
                      const Spacer(),
                      _buildSkipButton(l),
                    ],
                  ),
                ),

                // ── PageView ──────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageCtrl,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _buildSlide(_pages[i], l),
                  ),
                ),

                // ── CTA Button ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: _buildCtaButton(page.color, isLast, l),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Sub-widgets
  // ─────────────────────────────────────────────────────────────

  Widget _buildBlobs(Color color, Size size) {
    return Stack(
      children: [
        // Top-right blob
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          top: -80,
          right: _currentPage.isEven ? -60.0 : size.width * 0.3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(130),
            ),
          ),
        ),
        // Bottom-left blob
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          bottom: -50,
          left: _currentPage.isOdd ? -40.0 : size.width * 0.2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(95),
            ),
          ),
        ),
        // Small accent blob
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          top: 160,
          left: _currentPage == 1 ? -20 : -50,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDots(Color activeColor) {
    return Row(
      children: List.generate(_pages.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 7),
          width: isActive ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : const Color(0xFFD4C4B8),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildSkipButton(AppLocalizations l) {
    return GestureDetector(
      onTap: _finish,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Text(
          l.onboardingSkip,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9A8878),
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingData data, AppLocalizations l) {
    return FadeTransition(
      opacity: _slideOpacity,
      child: SlideTransition(
        position: _slidePos,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Illustration ───────────────────────────────────
              Expanded(
                flex: 5,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, __) => CustomPaint(
                      size: const Size(260, 280),
                      painter: _getPainter(data, l),
                    ),
                  ),
                ),
              ),

              // ── Text content ───────────────────────────────────
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Slide label
                    Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: data.color,
                        letterSpacing: 1.5,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1207),
                        height: 1.15,
                        letterSpacing: -0.5,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Subtitle
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7A6555),
                        height: 1.7,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCtaButton(Color color, bool isLast, AppLocalizations l) {
    return GestureDetector(
      onTap: _nextPage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.38),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                isLast ? l.onboardingGetStarted : l.onboardingNext,
                key: ValueKey(isLast),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Painter selector ─────────────────────────────────────────
  CustomPainter _getPainter(OnboardingData data, AppLocalizations l) {
    final t = _floatCtrl.value;
    switch (_pages.indexOf(data)) {
      case 0:
        return LostDogPainter(animValue: t);
      case 1:
        return MapPainter(animValue: t, l: l);
      case 2:
        return CommunityPainter(animValue: t, l: l);
      default:
        return LostDogPainter(animValue: t);
    }
  }
}
