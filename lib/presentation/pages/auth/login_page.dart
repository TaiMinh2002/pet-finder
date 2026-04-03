import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => sl<AuthBloc>(), child: const _LoginView());
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();
  @override
  State<_LoginView> createState() => __LoginViewState();
}

class __LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  late final AnimationController _ctrl;
  late final Animation<double> _headerAnim;
  late final Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _headerAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1, curve: Curves.easeOut)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignInRequested(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go('/map');
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Teal decorative header block ─────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _headerAnim,
                builder: (_, __) => Opacity(
                  opacity: _headerAnim.value,
                  child: Container(
                    height: size.height * 0.38,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D5A4E), Color(0xFF14796A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(40, 30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo mark
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.pets,
                                  color: Colors.white, size: 30),
                            ),
                            const Spacer(),
                            Text(
                              'Xin chào,\ntrở lại nào! 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.loginSubtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Form card ─────────────────────────────────────────────────
            Positioned(
              top: size.height * 0.32,
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _formSlide,
                builder: (_, child) => FadeTransition(
                  opacity: _headerAnim,
                  child: SlideTransition(position: _formSlide, child: child),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(
                          color: AppColors.borderLight, width: 1.5),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.signIn,
                              style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 24),
                          AppTextField(
                            label: l.email,
                            hint: l.emailHint,
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon:
                                const Icon(Icons.email_outlined, size: 20),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return l.errorEmailRequired;
                              }
                              if (!v.contains('@')) return l.errorEmailInvalid;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: l.password,
                            hint: l.passwordHint,
                            controller: _passCtrl,
                            obscureText: !_showPass,
                            prefixIcon:
                                const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () =>
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary),
                              child: Text(l.forgotPassword),
                            ),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) => AppButton(
                              label: l.signIn,
                              loading: state is AuthLoading,
                              onPressed: () => _submit(context),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l.noAccount,
                                  style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => context.go('/auth/register'),
                                child: Text(
                                  l.signUp,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
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
