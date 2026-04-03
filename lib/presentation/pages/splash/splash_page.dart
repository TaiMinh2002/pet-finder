import 'package:flutter/material.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Master sequencer
  late final AnimationController _seqCtrl;

  // Bubbles (background blobs floating)
  late final AnimationController _bubbleCtrl;

  // Paw prints stagger
  late final List<AnimationController> _pawCtrls;

  // Logo entrance + heartbeat
  late final AnimationController _logoCtrl;
  late final AnimationController _heartbeatCtrl;

  // Badge pop
  late final Animation<double> _badgeScale;

  // Content stagger (label, title, tagline, chips, dots)
  late final Animation<double> _labelOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _chipsOpacity;
  late final Animation<Offset> _chipsSlide;
  late final Animation<double> _dotsOpacity;

  // Logo spring
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Heartbeat
  late final Animation<double> _heartbeat;

  // Bubble float
  late final Animation<double> _bubble1;
  late final Animation<double> _bubble2;
  late final Animation<double> _bubble3;
  late final Animation<double> _bubble4;

  static const _pawPositions = [
    (left: 0.10, bottom: 0.18, angle: -0.26),
    (left: 0.22, bottom: 0.28, angle: -0.18),
    (left: 0.34, bottom: 0.38, angle: -0.09),
    (left: 0.46, bottom: 0.47, angle: 0.0),
    (left: 0.62, bottom: 0.53, angle: 0.17),
    (left: 0.76, bottom: 0.44, angle: 0.35),
  ];

  @override
  void initState() {
    super.initState();

    // ── Sequence controller 0-2400ms ──────────────────────────────────
    _seqCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // ── Bubble float (loops) ──────────────────────────────────────────
    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _bubble1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeInOut),
    );
    _bubble2 = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeInOut),
    );
    _bubble3 = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeInOut),
    );
    _bubble4 = Tween<double>(begin: 0.8, end: 0.2).animate(
      CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeInOut),
    );

    // ── Paw prints (6 individual controllers, staggered) ─────────────
    _pawCtrls = List.generate(
      6,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    // ── Logo spring in ────────────────────────────────────────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.35, curve: Curves.easeOut),
      ),
    );

    _badgeScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.45, 0.75, curve: Curves.elasticOut),
      ),
    );

    // ── Heartbeat (loops after logo is in) ───────────────────────────
    _heartbeatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _heartbeat = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.10), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 70),
    ]).animate(_heartbeatCtrl);

    // ── Content stagger ───────────────────────────────────────────────
    _labelOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.30, 0.45, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.35, 0.52, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.33, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.48, 0.62, curve: Curves.easeOut),
      ),
    );

    _chipsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.58, 0.72, curve: Curves.easeOut),
      ),
    );
    _chipsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.56, 0.74, curve: Curves.easeOutCubic),
      ),
    );

    _dotsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _seqCtrl,
        curve: const Interval(0.70, 0.82, curve: Curves.easeOut),
      ),
    );

    // ── Start the sequence ────────────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    // 0ms – start master seq
    _seqCtrl.forward();

    // 80ms – logo springs in
    await Future.delayed(const Duration(milliseconds: 80));
    _logoCtrl.forward();

    // 700ms – heartbeat begins
    await Future.delayed(const Duration(milliseconds: 620));
    _heartbeatCtrl.repeat();

    // 900ms–1500ms – paw prints trail in
    for (int i = 0; i < _pawCtrls.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _pawCtrls[i].forward();
    }

    // Wait for full animation + small hold
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) context.go('/map');
  }

  @override
  void dispose() {
    _seqCtrl.dispose();
    _bubbleCtrl.dispose();
    _logoCtrl.dispose();
    _heartbeatCtrl.dispose();
    for (final c in _pawCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _seqCtrl,
          _logoCtrl,
          _heartbeatCtrl,
          _bubbleCtrl,
          ..._pawCtrls,
        ]),
        builder: (_, __) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.warmBackground,
            ),
            child: Stack(
              children: [
                // ── Floating blobs ─────────────────────────────────────
                _FloatBlob(
                  x: -50 + _bubble1.value * 6,
                  y: -60 + _bubble1.value * 10,
                  size: 200,
                  color: AppColors.ctaLight.withValues(alpha: 0.15),
                  radius: 100,
                ),
                _FloatBlob(
                  x: size.width - 110 + _bubble2.value * 8,
                  y: 40 + _bubble2.value * 12,
                  size: 140,
                  color: AppColors.lost.withValues(alpha: 0.15),
                  radius: 70,
                ),
                _FloatBlob(
                  x: 10 + _bubble3.value * 4,
                  y: size.height - 160 + _bubble3.value * 10,
                  size: 110,
                  color: AppColors.primaryLight.withValues(alpha: 0.18),
                  radius: 55,
                ),
                _FloatBlob(
                  x: size.width - 80 + _bubble4.value * 6,
                  y: size.height - 90 + _bubble4.value * 8,
                  size: 160,
                  color: AppColors.found.withValues(alpha: 0.14),
                  radius: 80,
                ),

                // ── Paw prints trail ───────────────────────────────────
                ..._pawPositions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final pos = entry.value;
                  final anim = CurvedAnimation(
                    parent: _pawCtrls[i],
                    curve: Curves.elasticOut,
                  );
                  return Positioned(
                    left: size.width * pos.left,
                    bottom: size.height * pos.bottom,
                    child: Opacity(
                      opacity: (_pawCtrls[i].value * 0.22).clamp(0, 0.22),
                      child: Transform.rotate(
                        angle: pos.angle,
                        child: Transform.scale(
                          scale: anim.value,
                          child:
                              const Text('🐾', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                    ),
                  );
                }),

                // ── Main centered content ──────────────────────────────
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Welcome to" label
                      Opacity(
                        opacity: _labelOpacity.value,
                        child: Text(
                          l.splashWelcome.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.0,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Logo ─────────────────────────────────────────
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value * _heartbeat.value,
                          child: SizedBox(
                            width: 130,
                            height: 130,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Main logo container
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: AppColors.clayShadow(
                                      color: AppColors.primary,
                                      elevation: 1.5,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.pets_rounded,
                                      color: Colors.white,
                                      size: 64,
                                    ),
                                  ),
                                ),

                                // Badge
                                Positioned(
                                  bottom: -6,
                                  right: -6,
                                  child: Transform.scale(
                                    scale: _badgeScale.value,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.cta,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.cta
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.star_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── App name ──────────────────────────────────────
                      Opacity(
                        opacity: _titleOpacity.value,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Pet',
                                  style: TextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -2,
                                    color: AppColors.textPrimary,
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Finder',
                                  style: TextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -2,
                                    foreground: Paint()
                                      ..shader = const LinearGradient(
                                        colors: [
                                          Color(0xFFFF5DA2),
                                          Color(0xFFFF8C69),
                                        ],
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 200, 60),
                                      ),
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Tagline ───────────────────────────────────────
                      Opacity(
                        opacity: _taglineOpacity.value,
                        child: Text(
                          l.splashTagline,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Pet chips ─────────────────────────────────────
                      Opacity(
                        opacity: _chipsOpacity.value,
                        child: SlideTransition(
                          position: _chipsSlide,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PetChip(
                                emoji: '🐶',
                                label: l.splashDogs,
                                bg: AppColors.ctaContainer,
                                text: AppColors.ctaDark,
                                border: AppColors.ctaLight,
                              ),
                              const SizedBox(width: 10),
                              _PetChip(
                                emoji: '🐱',
                                label: l.splashCats,
                                bg: AppColors.lostContainer,
                                text: AppColors.lost,
                                border: AppColors.lost.withValues(alpha: 0.3),
                              ),
                              const SizedBox(width: 10),
                              _PetChip(
                                emoji: '🐦',
                                label: l.splashBirds,
                                bg: AppColors.primaryContainer,
                                text: AppColors.primaryDark,
                                border: AppColors.primaryLight,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 52),

                      // ── Bouncing dots loader ──────────────────────────
                      Opacity(
                        opacity: _dotsOpacity.value,
                        child: const _BouncingDots(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _FloatBlob extends StatelessWidget {
  final double x, y, size, radius;
  final Color color;

  const _FloatBlob({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) => Positioned(
        left: x,
        top: y,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
}

class _PetChip extends StatelessWidget {
  final String emoji, label;
  final Color bg, text, border;

  const _PetChip({
    required this.emoji,
    required this.label,
    required this.bg,
    required this.text,
    required this.border,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
          ],
        ),
      );
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  static const _colors = [
    AppColors.cta,
    AppColors.lost,
    AppColors.primary,
  ];

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true),
    );

    _anims = List.generate(
      3,
      (i) => Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: _ctrls[i], curve: Curves.easeInOut),
      ),
    );

    // Stagger
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _ctrls[1].forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrls[2].forward();
    });
    _ctrls[0].forward();
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(_ctrls),
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, _anims[i].value),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colors[i],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
