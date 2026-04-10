import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

// ─── Brand colors (shared với LoginPage) ─────────────────────────────────────
class _C {
  static const bg = Color(0xFFF7F5F2);
  static const headerDark = Color(0xFF0D3D36);
  static const primary = Color(0xFF1D9E75);
  static const primaryGlow = Color(0x521D9E75);
  static const fieldBg = Color(0xFFFDFCFB);
  static const fieldBorder = Color(0xFFE8E0D8);
  static const labelText = Color(0xFF5C4F44);
  static const hintText = Color(0xFFC4B8AD);
  static const bodyText = Color(0xFF1A1207);
  static const mutedText = Color(0xFF8A7A6E);
  static const onlineDot = Color(0xFF56D49A);
}

// ─── Entry point ─────────────────────────────────────────────────────────────
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const _RegisterView();
}

// ─── Main view ────────────────────────────────────────────────────────────────
class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showPass = false;
  bool _showConfirm = false;
  int _passStrength = 0; // 0-4

  late final AnimationController _ctrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _formSlide;
  late final Animation<double> _formFade;

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
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    ));
    _ctrl.forward();

    _passCtrl.addListener(_updateStrength);
  }

  void _updateStrength() {
    final v = _passCtrl.text;
    int score = 0;
    if (v.length >= 6) score++;
    if (v.length >= 10) score++;
    if (RegExp(r'[A-Z0-9]').hasMatch(v)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
    if (_passStrength != score) setState(() => _passStrength = score);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<AuthBloc>().add(AuthSignUpRequested(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          name: _nameCtrl.text.trim(),
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
              child: _Header(onBack: () => context.go('/auth/login')),
            ),

            // ── Form ─────────────────────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _formFade,
                child: SlideTransition(
                  position: _formSlide,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Full name ──────────────────────────────────
                          _FieldLabel(l.fullName.toUpperCase()),
                          const SizedBox(height: 5),
                          _PetTextField(
                            controller: _nameCtrl,
                            hint: l.fullNameHint,
                            prefixIcon: const Icon(Icons.person_outline_rounded,
                                size: 18, color: Color(0xFF9A8878)),
                            validator: (v) => (v?.isEmpty ?? true)
                                ? l.errorNameRequired
                                : null,
                          ),

                          const SizedBox(height: 14),

                          // ── Email ──────────────────────────────────────
                          _FieldLabel(l.email.toUpperCase()),
                          const SizedBox(height: 5),
                          _PetTextField(
                            controller: _emailCtrl,
                            hint: l.emailHint,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined,
                                size: 18, color: Color(0xFF9A8878)),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return l.errorEmailRequired;
                              }
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(v)) {
                                return l.errorEmailInvalid;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // ── Password ───────────────────────────────────
                          _FieldLabel(l.password.toUpperCase()),
                          const SizedBox(height: 5),
                          _PetTextField(
                            controller: _passCtrl,
                            hint: l.passwordHint,
                            obscureText: !_showPass,
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                size: 18, color: Color(0xFF9A8878)),
                            suffixIcon: _EyeButton(
                              visible: _showPass,
                              onTap: () =>
                                  setState(() => _showPass = !_showPass),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return l.errorPasswordRequired;
                              }
                              if (v.length < 6) return l.errorPasswordTooShort;
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          _PasswordStrengthBar(strength: _passStrength),

                          const SizedBox(height: 14),

                          // ── Confirm password ───────────────────────────
                          _FieldLabel(l.confirmPassword.toUpperCase()),
                          const SizedBox(height: 5),
                          _PetTextField(
                            controller: _confirmCtrl,
                            hint: l.confirmPasswordHint,
                            obscureText: !_showConfirm,
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                size: 18, color: Color(0xFF9A8878)),
                            suffixIcon: _EyeButton(
                              visible: _showConfirm,
                              onTap: () =>
                                  setState(() => _showConfirm = !_showConfirm),
                            ),
                            validator: (v) => v != _passCtrl.text
                                ? l.errorPasswordMismatch
                                : null,
                          ),

                          const SizedBox(height: 20),

                          // ── Terms text ─────────────────────────────────
                          const _TermsText(),

                          const SizedBox(height: 20),

                          // ── CTA ────────────────────────────────────────
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (ctx, state) => _CtaButton(
                              label: l.signUp,
                              loading: state is AuthLoading,
                              onTap: () => _submit(ctx),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Sign in row ────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l.hasAccount,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _C.mutedText,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => context.go('/auth/login'),
                                child: Text(
                                  l.signIn,
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
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: _C.headerDark,
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Step pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: _C.onlineDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TẠO TÀI KHOẢN MỚI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.65),
                            letterSpacing: 0.5,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  const Text(
                    'Tham gia cùng\ncộng đồng 🐾',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.18,
                      fontFamily: 'Nunito',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Cùng nhau tìm lại những người\nbạn lông xù đã thất lạc',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.5,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Decorative circles
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 28,
          right: 20,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Wave clipper
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _WaveClipper(),
            child: Container(height: 32, color: _C.bg),
          ),
        ),
      ],
    );
  }
}

// ─── Wave clipper ─────────────────────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width * 0.25, 0, size.width * 0.5, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.75, size.height, size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
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
            const BoxConstraints(minWidth: 44, minHeight: 50),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _C.fieldBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _C.fieldBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _C.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.8),
        ),
      ),
    );
  }
}

// ─── Eye toggle ───────────────────────────────────────────────────────────────
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
        size: 19,
        color: const Color(0xFF9A8878),
      ),
    );
  }
}

// ─── Password strength bar ────────────────────────────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0-4

  const _PasswordStrengthBar({required this.strength});

  Color _segColor(int index) {
    if (index >= strength) return const Color(0xFFE8E0D8);
    return switch (strength) {
      1 => const Color(0xFFE24B4A),
      2 => const Color(0xFFEF9F27),
      3 => const Color(0xFF4EAEFF),
      _ => const Color(0xFF56D49A),
    };
  }

  String get _label => switch (strength) {
        0 => '',
        1 => 'Yếu',
        2 => 'Trung bình',
        3 => 'Tốt',
        _ => 'Mạnh',
      };

  Color get _labelColor => switch (strength) {
        1 => const Color(0xFFE24B4A),
        2 => const Color(0xFFEF9F27),
        3 => const Color(0xFF4EAEFF),
        4 => const Color(0xFF56D49A),
        _ => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: _segColor(i + 1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        if (strength > 0) ...[
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _label,
              key: ValueKey(strength),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _labelColor,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Terms text ───────────────────────────────────────────────────────────────
class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: _C.mutedText,
            height: 1.6,
            fontFamily: 'Nunito',
          ),
          children: [
            const TextSpan(text: 'Bằng cách đăng ký, bạn đồng ý với\n'),
            TextSpan(
              text: 'Điều khoản dịch vụ',
              style: const TextStyle(
                color: _C.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(text: ' và '),
            TextSpan(
              text: 'Chính sách bảo mật',
              style: const TextStyle(
                color: _C.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
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
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.loading ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 54,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_downward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}
