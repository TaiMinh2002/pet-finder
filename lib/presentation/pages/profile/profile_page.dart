import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../data/datasources/remote/auth_remote_datasource.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF7F5F2);
  static const headerDark = Color(0xFF0D3D36);
  static const primary = Color(0xFF1D9E75);
  static const onlineDot = Color(0xFF56D49A);
  static const lost = Color(0xFFFF6B6B);
  static const found = Color(0xFF4EAEFF);
  static const resolved = Color(0xFF56D49A);
  static const amber = Color(0xFFFF9500);
  static const cardBorder = Color(0xFFEDE6DE);
  static const bodyText = Color(0xFF1A1207);
  static const mutedText = Color(0xFF9A8878);
  static const labelText = Color(0xFF5C4F44);
  static const hintText = Color(0xFFC4B8AD);
  static const divider = Color(0xFFF0EAE3);
}

// ─── Entry ────────────────────────────────────────────────────────────────────
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authDs = sl<AuthRemoteDataSource>();
    final user = authDs.currentUser;
    final initial =
        (user?.name?.isNotEmpty == true ? user!.name![0] : 'U').toUpperCase();

    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthUnauthenticated) ctx.go('/auth/login');
      },
      child: Scaffold(
        backgroundColor: _C.bg,
        body: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _ProfileHeader(
                initial: initial,
                name: user?.name ?? 'Người dùng',
                email: user?.email ?? '',
                onEdit: () => context.push('/profile/edit'),
              ),
            ),

            // ── Stats banner ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _StatsBanner(l: l),
            ),

            // ── Body ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mission card
                    const SizedBox(height: 16),
                    const _MissionCard(),

                    // Pet section
                    const _SectionTitle('Thú cưng của tôi'),
                    const _PetRow(),

                    // Activity menu
                    const _SectionTitle('Hoạt động'),
                    _MenuGroup(items: [
                      _MenuItemData(
                        icon: Icons.article_outlined,
                        iconBg: const Color(0xFFFFE5E5),
                        iconColor: _C.lost,
                        label: l.myPosts,
                        subtitle: '3 bài đang hoạt động',
                        badge: '3',
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: Icons.check_circle_outline_rounded,
                        iconBg: const Color(0xFFE8FBF2),
                        iconColor: _C.primary,
                        label: l.filterResolved,
                        subtitle: '2 thú cưng về nhà',
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: Icons.star_outline_rounded,
                        iconBg: const Color(0xFFE0F0FF),
                        iconColor: _C.found,
                        label: 'Lượt giúp đỡ',
                        subtitle: 'Bạn đã chia sẻ 12 tin',
                        onTap: () {},
                      ),
                    ]),

                    // Account menu
                    const _SectionTitle('Tài khoản'),
                    _MenuGroup(items: [
                      _MenuItemData(
                        icon: Icons.person_outline_rounded,
                        iconBg: const Color(0xFFF5F0EB),
                        iconColor: _C.labelText,
                        label: l.editProfile,
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: Icons.settings_outlined,
                        iconBg: const Color(0xFFF5F0EB),
                        iconColor: _C.labelText,
                        label: l.settingsTitle,
                        onTap: () => context.push('/settings'),
                      ),
                      _MenuItemData(
                        icon: Icons.info_outline_rounded,
                        iconBg: const Color(0xFFF5F0EB),
                        iconColor: _C.labelText,
                        label: l.settingsAbout,
                        onTap: () {},
                      ),
                    ]),

                    // Sign out
                    const SizedBox(height: 16),
                    _MenuGroup(items: [
                      _MenuItemData(
                        icon: Icons.logout_rounded,
                        iconBg: const Color(0xFFFCEBEB),
                        iconColor: const Color(0xFFE24B4A),
                        label: l.signOut,
                        labelColor: const Color(0xFFE24B4A),
                        showArrow: false,
                        onTap: () => _showSignOutDialog(context, l),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppLocalizations l) {
    final authBloc = context.read<AuthBloc>();
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.signOut,
            style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
        content: Text(l.signOutConfirm,
            style: const TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(),
            child: Text(l.commonCancel,
                style: const TextStyle(
                    color: _C.mutedText,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dlg).pop();
              authBloc.add(const AuthSignOutRequested());
            },
            child: Text(l.signOut,
                style: const TextStyle(
                    color: Color(0xFFE24B4A),
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String initial;
  final String name;
  final String email;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.initial,
    required this.name,
    required this.email,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark background — SizedBox width: double.infinity đảm bảo full width
        SizedBox(
          width: double.infinity,
          child: Container(
            color: _C.headerDark,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Column(
                  // ── căn giữa toàn bộ nội dung ──
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    _Avatar(initial: initial),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Email
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Member pill — mainAxisSize.min giữ pill không bị giãn
                    _MemberPill(),

                    const SizedBox(height: 24),
                  ],
                ),
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
          top: 20,
          right: 20,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Edit button
        Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          right: 20,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: Colors.white, size: 17),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initial;
  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF56D49A), Color(0xFF1D9E75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1A4A3A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _C.onlineDot,
                shape: BoxShape.circle,
                border: Border.all(color: _C.headerDark, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Member Pill ──────────────────────────────────────────────────────────────
class _MemberPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _C.onlineDot.withValues(alpha: 0.15),
        border: Border.all(color: _C.onlineDot.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: _C.onlineDot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text(
            'Thành viên tích cực • 6 tháng',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _C.onlineDot,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Banner ─────────────────────────────────────────────────────────────
class _StatsBanner extends StatelessWidget {
  final AppLocalizations l;
  const _StatsBanner({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ── Bỏ margin ngang để full width, chỉ giữ margin dưới nếu cần ──
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(count: '3', label: l.myPosts, color: _C.lost),
          _StatDivider(),
          _StatItem(count: '2', label: l.filterResolved, color: _C.resolved),
          _StatDivider(),
          _StatItem(count: '1', label: l.filterFound, color: _C.found),
          _StatDivider(),
          _StatItem(
              count: '🏅',
              label: 'Điểm cộng đồng',
              color: _C.amber,
              isEmoji: true),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final bool isEmoji;

  const _StatItem({
    required this.count,
    required this.label,
    required this.color,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Column(
          children: [
            isEmoji
                ? Text(count, style: const TextStyle(fontSize: 22))
                : Text(
                    count,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'Nunito',
                    ),
                  ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _C.mutedText,
                fontFamily: 'Nunito',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: _C.cardBorder);
  }
}

// ─── Mission Card ─────────────────────────────────────────────────────────────
class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3D36), Color(0xFF1D6B56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _C.onlineDot.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎯  NHIỆM VỤ TUẦN NÀY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: 1,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Báo cáo 3 tin mất tích\ntrong khu vực của bạn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.35,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1 / 3,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(_C.onlineDot),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1/3 hoàn thành',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.55),
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const Text(
                    '34%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _C.onlineDot,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Pet Row ──────────────────────────────────────────────────────────────────
class _PetRow extends StatelessWidget {
  const _PetRow();

  // Dummy pet data — replace with real BLoC data
  static const _pets = [
    _PetData(emoji: '🐕', name: 'Milo', breed: 'Poodle'),
    _PetData(emoji: '🐈', name: 'Luna', breed: 'Anh lông ngắn'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._pets.map((p) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _PetCard(pet: p),
              )),
          _AddPetCard(),
        ],
      ),
    );
  }
}

class _PetData {
  final String emoji;
  final String name;
  final String breed;
  const _PetData(
      {required this.emoji, required this.name, required this.breed});
}

class _PetCard extends StatelessWidget {
  final _PetData pet;
  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.cardBorder, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(pet.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _C.bodyText,
              fontFamily: 'Nunito',
            ),
          ),
          Text(
            pet.breed,
            style: const TextStyle(
              fontSize: 9,
              color: _C.mutedText,
              fontFamily: 'Nunito',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AddPetCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFCFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _C.hintText,
            width: 1.5,
            // ignore: deprecated_member_use
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAE3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: _C.mutedText, size: 20),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thêm',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.mutedText,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: _C.mutedText,
          letterSpacing: 1,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

// ─── Menu Group ───────────────────────────────────────────────────────────────
class _MenuItemData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final String? badge;
  final Color? labelColor;
  final bool showArrow;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.badge,
    this.labelColor,
    this.showArrow = true,
    required this.onTap,
  });
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItemData> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.cardBorder, width: 1.5),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              if (i > 0)
                Divider(
                    height: 1,
                    thickness: 1,
                    color: _C.divider,
                    indent: 16,
                    endIndent: 16),
              _MenuRowItem(data: item),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuRowItem extends StatefulWidget {
  final _MenuItemData data;
  const _MenuRowItem({required this.data});

  @override
  State<_MenuRowItem> createState() => _MenuRowItemState();
}

class _MenuRowItemState extends State<_MenuRowItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: d.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed ? const Color(0xFFF8F5F2) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: d.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(d.icon, color: d.iconColor, size: 18),
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: d.labelColor ?? _C.bodyText,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  if (d.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      d.subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _C.mutedText,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Badge
            if (d.badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _C.lost,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  d.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Arrow
            if (d.showArrow)
              const Icon(Icons.chevron_right_rounded,
                  color: _C.hintText, size: 20),
          ],
        ),
      ),
    );
  }
}
