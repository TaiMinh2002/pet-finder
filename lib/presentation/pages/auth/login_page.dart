import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

// ─── Brand colors ────────────────────────────────────────────────────────────
class _C {
  static const bg          = Color(0xFFF7F5F2);
  static const headerDark  = Color(0xFF0D3D36);
  static const primary     = Color(0xFF1D9E75);
  static const primaryGlow = Color(0x521D9E75);
  static const fieldBg     = Color(0xFFFDFCFB);
  static const fieldBorder = Color(0xFFE8E0D8);
  static const labelText   = Color(0xFF5C4F44);
  static const hintText    = Color(0xFFC4B8AD);
  static const bodyText    = Color(0xFF1A1207);
  static const mutedText   = Color(0xFF8A7A6E);
  static const divider     = Color(0xFFEDE6DE);
  static const socialBg    = Color(0xFFFDFCFB);
  static const socialBorder= Color(0xFFE8E0D8);
  static const onlineDot   = Color(0xFF56D49A);
}

// ─── Entry point ─────────────────────────────────────────────────────────────
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

// ─── Main view ────────────────────────────────────────────────────────────────
class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass   = false;

  late final AnimationController _ctrl;
  late final Animation<double>   _headerFade;
  late final Animation<Offset>   _formSlide;
  late final Animation<double>   _formFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _headerFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _formFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    ));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<AuthBloc>().add(AuthSignInRequested(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) ctx.go('/map');
        if (state is AuthError) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            FadeTransition(
              opacity: _headerFade,
              child: const _Header(),
            ),

            // ── Form area ────────────────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _formFade,
                child: SlideTransition(
                  position: _formSlide,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          _FieldLabel(l.email.toUpperCase()),
                          const SizedBox(height: 6),
                          _PetTextField(
                            controller: _emailCtrl,
                            hint: l.emailHint,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: _IconEmail(),
                            validator: (v) {
                              if (v == null || v.isEmpty) return l.errorEmailRequired;
                              if (!v.contains('@'))       return l.errorEmailInvalid;
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Password
                          _FieldLabel(l.password.toUpperCase()),
                          const SizedBox(height: 6),
                          _PetTextField(
                            controller: _passCtrl,
                            hint: l.passwordHint,
                            obscureText: !_showPass,
                            prefixIcon: _IconLock(),
                            suffixIcon: _EyeButton(
                              visible: _showPass,
                              onTap: () => setState(() => _showPass = !_showPass),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return l.errorPasswordRequired;
                              if (v.length < 6)           return l.errorPasswordTooShort;
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                l.forgotPassword,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _C.primary,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // CTA
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (ctx, state) => _CtaButton(
                              label: l.signIn,
                              loading: state is AuthLoading,
                              onTap: () => _submit(ctx),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Divider
                          const _Divider(),

                          const SizedBox(height: 20),

                          // Social login
                          Row(
                            children: [
                              Expanded(child: _SocialButton(
                                label: 'Google',
                                icon: const _IconGoogle(),
                                onTap: () {},
                              )),
                              const SizedBox(width: 10),
                              Expanded(child: _SocialButton(
                                label: 'Facebook',
                                icon: const _IconFacebook(),
                                onTap: () {},
                              )),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Sign up row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l.noAccount,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _C.mutedText,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => context.go('/auth/register'),
                                child: Text(
                                  l.signUp,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _C.primary,
                                    fontFamily: 'Nunito',
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
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Stack(
      children: [
        // Dark teal background
        Container(
          color: _C.headerDark,
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo mark
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CustomPaint(painter: _PawLogoPainter()),
                  ),

                  const SizedBox(height: 28),

                  // Eyebrow label
                  Text(
                    l.loginHeaderEyebrow,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Colors.white.withValues(alpha: 0.45),
                      fontFamily: 'Nunito',
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Text(
                    l.loginHeaderTitle,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                      fontFamily: 'Nunito',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    l.loginHeaderSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.5,
                      fontFamily: 'Nunito',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Online badge
                  const _OnlineBadge(),
                ],
              ),
            ),
          ),
        ),

        // Decorative circles
        Positioned(
          top: -70,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.28),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Wave clipper at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              height: 32,
              color: _C.bg,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: _C.onlineDot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            l.loginOnlineMembers,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.75),
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wave Clipper ─────────────────────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper _) => false;
}

// ─── Paw logo painter ─────────────────────────────────────────────────────────
class _PawLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Main pad
    canvas.drawCircle(Offset(cx, cy + 4), 8.5, p);
    // Toes
    canvas.drawCircle(Offset(cx - 8, cy - 4), 5, p..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(Offset(cx + 8, cy - 4), 5, p);
    canvas.drawCircle(Offset(cx - 13, cy + 2), 4, p..color = Colors.white.withValues(alpha: 0.75));
    canvas.drawCircle(Offset(cx + 13, cy + 2), 4, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Field label ──────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _C.labelText,
        letterSpacing: 0.8,
        fontFamily: 'Nunito',
      ),
    );
  }
}

// ─── Pet Text Field ───────────────────────────────────────────────────────────
class _PetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _PetTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: _C.bodyText,
        fontFamily: 'Nunito',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _C.hintText,
          fontSize: 15,
          fontFamily: 'Nunito',
        ),
        filled: true,
        fillColor: _C.fieldBg,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 46, minHeight: 52),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.fieldBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.fieldBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.8),
        ),
      ),
    );
  }
}

// ─── Eye toggle button ────────────────────────────────────────────────────────
class _EyeButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;
  const _EyeButton({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: const Color(0xFF9A8878),
      ),
    );
  }
}

// ─── CTA Button ───────────────────────────────────────────────────────────────
class _CtaButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _CtaButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.loading ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _C.primaryGlow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                        fontFamily: 'Nunito',
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
      ),
    );
  }
}

// ─── Divider ───────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        const Expanded(child: Divider(color: _C.divider, thickness: 1)),
        const SizedBox(width: 12),
        Text(
          l.loginOrContinueWith,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _C.mutedText.withValues(alpha: 0.7),
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: _C.divider, thickness: 1)),
      ],
    );
  }
}

// ─── Social Button ────────────────────────────────────────────────────────────
class _SocialButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown:  (_) => setState(() => _hover = true),
      onTapUp:    (_) => setState(() => _hover = false),
      onTapCancel: () => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFFF5F0EB) : _C.socialBg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _C.socialBorder, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon,
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3A3028),
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Social icons (SVG via CustomPaint) ───────────────────────────────────────
class _IconGoogle extends StatelessWidget {
  const _IconGoogle();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(18, 18), painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 18;
    void fill(Color c, Path p) => canvas.drawPath(p, Paint()..color = c);

    fill(const Color(0xFF4285F4), Path()
      ..moveTo(17.1 * s, 9.2 * s)
      ..cubicTo(17.1 * s, 8.6 * s, 17 * s, 8 * s, 16.9 * s, 7.5 * s)
      ..lineTo(9 * s, 7.5 * s)
      ..lineTo(9 * s, 10.7 * s)
      ..lineTo(13.5 * s, 10.7 * s)
      ..cubicTo(13.3 * s, 11.7 * s, 12.7 * s, 12.6 * s, 11.8 * s, 13.2 * s)
      ..lineTo(11.8 * s, 15.2 * s)
      ..lineTo(14.5 * s, 15.2 * s)
      ..cubicTo(16.1 * s, 13.7 * s, 17.1 * s, 11.5 * s, 17.1 * s, 9.2 * s)
      ..close());

    fill(const Color(0xFF34A853), Path()
      ..moveTo(9 * s, 18 * s)
      ..cubicTo(11.3 * s, 18 * s, 13.2 * s, 17.3 * s, 14.6 * s, 16.2 * s)
      ..lineTo(11.8 * s, 14.2 * s)
      ..cubicTo(11 * s, 14.7 * s, 10.1 * s, 15 * s, 9 * s, 15 * s)
      ..cubicTo(6.8 * s, 15 * s, 4.9 * s, 13.5 * s, 4.2 * s, 11.5 * s)
      ..lineTo(1.5 * s, 11.5 * s)
      ..lineTo(1.5 * s, 13.6 * s)
      ..cubicTo(2.9 * s, 16.1 * s, 5.8 * s, 18 * s, 9 * s, 18 * s)
      ..close());

    fill(const Color(0xFFFBBC04), Path()
      ..moveTo(4.2 * s, 11.3 * s)
      ..cubicTo(3.9 * s, 10.5 * s, 3.8 * s, 9.8 * s, 3.8 * s, 9 * s)
      ..cubicTo(3.8 * s, 8.2 * s, 3.9 * s, 7.5 * s, 4.2 * s, 6.7 * s)
      ..lineTo(4.2 * s, 4.6 * s)
      ..lineTo(1.5 * s, 4.6 * s)
      ..cubicTo(0.8 * s, 5.9 * s, 0.5 * s, 7.4 * s, 0.5 * s, 9 * s)
      ..cubicTo(0.5 * s, 10.6 * s, 0.8 * s, 12.1 * s, 1.5 * s, 13.4 * s)
      ..lineTo(4.2 * s, 11.3 * s)
      ..close());

    fill(const Color(0xFFEA4335), Path()
      ..moveTo(9 * s, 3.8 * s)
      ..cubicTo(10.3 * s, 3.8 * s, 11.4 * s, 4.2 * s, 12.3 * s, 5.1 * s)
      ..lineTo(14.7 * s, 2.7 * s)
      ..cubicTo(13.2 * s, 0.9 * s, 11.3 * s, 0 * s, 9 * s, 0 * s)
      ..cubicTo(5.8 * s, 0 * s, 2.9 * s, 1.9 * s, 1.5 * s, 4.8 * s)
      ..lineTo(4.2 * s, 6.9 * s)
      ..cubicTo(4.9 * s, 5.1 * s, 6.8 * s, 3.8 * s, 9 * s, 3.8 * s)
      ..close());
  }

  @override
  bool shouldRepaint(_) => false;
}

class _IconFacebook extends StatelessWidget {
  const _IconFacebook();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(18, 18), painter: _FacebookPainter());
}

class _FacebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 18;
    final paint = Paint()..color = const Color(0xFF1877F2);
    final path = Path()
      ..moveTo(18 * s, 9 * s)
      ..cubicTo(18 * s, 4 * s, 14 * s, 0, 9 * s, 0)
      ..cubicTo(4 * s, 0, 0, 4 * s, 0, 9 * s)
      ..cubicTo(0, 13.5 * s, 3.3 * s, 17.2 * s, 7.5 * s, 17.9 * s)
      ..lineTo(7.5 * s, 11.6 * s)
      ..lineTo(5.2 * s, 11.6 * s)
      ..lineTo(5.2 * s, 9 * s)
      ..lineTo(7.5 * s, 9 * s)
      ..lineTo(7.5 * s, 7 * s)
      ..cubicTo(7.5 * s, 4.7 * s, 8.9 * s, 3.4 * s, 10.9 * s, 3.4 * s)
      ..cubicTo(11.9 * s, 3.4 * s, 12.9 * s, 3.6 * s, 12.9 * s, 3.6 * s)
      ..lineTo(12.9 * s, 5.8 * s)
      ..lineTo(11.7 * s, 5.8 * s)
      ..cubicTo(10.6 * s, 5.8 * s, 10.2 * s, 6.5 * s, 10.2 * s, 7.2 * s)
      ..lineTo(10.2 * s, 9 * s)
      ..lineTo(12.7 * s, 9 * s)
      ..lineTo(12.3 * s, 11.6 * s)
      ..lineTo(10.2 * s, 11.6 * s)
      ..lineTo(10.2 * s, 17.9 * s)
      ..cubicTo(14.7 * s, 17.2 * s, 18 * s, 13.5 * s, 18 * s, 9 * s)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Prefix icons ─────────────────────────────────────────────────────────────
class _IconEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Icon(
        Icons.email_outlined,
        size: 20,
        color: Color(0xFF9A8878),
      );
}

class _IconLock extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Icon(
        Icons.lock_outline_rounded,
        size: 20,
        color: Color(0xFF9A8878),
      );
}