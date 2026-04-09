import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/post_entity.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/shimmer_card.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF7F5F2);
  static const primary = Color(0xFF1D9E75);
  static const lost = Color(0xFFFF6B6B);
  static const found = Color(0xFF4EAEFF);
  static const resolved = Color(0xFF56D49A);
  static const cardBorder = Color(0xFFEDE6DE);
  static const bodyText = Color(0xFF1A1207);
  static const mutedText = Color(0xFF9A8878);
  static const hintText = Color(0xFFC4B8AD);
  static const labelText = Color(0xFF5C4F44);

  static Color forType(PostType t) => switch (t) {
        PostType.lost => lost,
        PostType.found => found,
        PostType.resolved => resolved,
      };

  static List<Color> gradientForType(PostType t) => switch (t) {
        PostType.lost => [const Color(0xFFFFE0E0), const Color(0xFFFFC8C8)],
        PostType.found => [const Color(0xFFE0F0FF), const Color(0xFFCCE4FF)],
        PostType.resolved => [const Color(0xFFE8FBF2), const Color(0xFFC8F5E0)],
      };
}

// ─── Entry ────────────────────────────────────────────────────────────────────
class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) return;
      final types = [null, PostType.lost, PostType.found];
      final t = types[_tabCtrl.index];
      context.read<PostBloc>().add(PostFilterChanged(filterType: t));
    });
    context.read<PostBloc>().add(const PostsLoadRequested());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _C.bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: BlocBuilder<PostBloc, PostState>(
                builder: (ctx, state) {
                  int allCount = 0;
                  int lostCount = 0;
                  int foundCount = 0;
                  if (state is PostsLoaded) {
                    // Use allPosts (unfiltered) for correct tab counts
                    final all = state.allPosts;
                    allCount = all.length;
                    lostCount =
                        all.where((p) => p.type == PostType.lost).length;
                    foundCount =
                        all.where((p) => p.type == PostType.found).length;
                  }
                  return _Header(
                    l: l,
                    tabCtrl: _tabCtrl,
                    searchCtrl: _searchCtrl,
                    allCount: allCount,
                    lostCount: lostCount,
                    foundCount: foundCount,
                  );
                },
              ),
            ),
          ),
        ],
        body: BlocBuilder<PostBloc, PostState>(
          builder: (ctx, state) {
            if (state is PostLoading) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                itemCount: 4,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: ShimmerCard(),
                ),
              );
            }
            if (state is PostError) {
              return EmptyState(
                title: l.commonError,
                subtitle: state.message,
                icon: Icons.error_outline_rounded,
                actionLabel: l.commonRetry,
                onAction: () =>
                    context.read<PostBloc>().add(const PostsLoadRequested()),
              );
            }
            if (state is PostsLoaded) {
              if (state.posts.isEmpty) {
                return EmptyState(
                  title: l.emptyPosts,
                  subtitle: l.emptyPostsHint,
                  icon: Icons.pets_rounded,
                );
              }
              return _Body(posts: state.posts);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final AppLocalizations l;
  final TabController tabCtrl;
  final TextEditingController searchCtrl;
  final int allCount;
  final int lostCount;
  final int foundCount;

  const _Header({
    required this.l,
    required this.tabCtrl,
    required this.searchCtrl,
    required this.allCount,
    required this.lostCount,
    required this.foundCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🐾  CỘNG ĐỒNG',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.mutedText,
                        letterSpacing: 1.5,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.tabPosts,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: _C.bodyText,
                        height: 1.1,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      l.postListSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.mutedText,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Filter button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _C.cardBorder, width: 1.5),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: _C.primary, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Search bar ───────────────────────────────────────────
          _SearchBar(controller: searchCtrl, l: l),

          const SizedBox(height: 12),

          // ── Tab bar ──────────────────────────────────────────────
          _TabBar(
            controller: tabCtrl,
            l: l,
            allCount: allCount,
            lostCount: lostCount,
            foundCount: foundCount,
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l;

  const _SearchBar({required this.controller, required this.l});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        color: _C.bodyText,
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: l.commonSearch,
        hintStyle: const TextStyle(
          color: _C.hintText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        // ── Prefix icon ───────────────────────────────────────────────
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 8),
          child: Icon(Icons.search_rounded, size: 20, color: _C.hintText),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // ── Suffix icon ──────────────────────────────────────────────
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAE3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.mic_none_rounded,
              size: 16,
              color: _C.mutedText,
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // ── Layout ───────────────────────────────────────────────────
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        // ── Border ───────────────────────────────────────────────────
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _C.cardBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _C.cardBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _C.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final TabController controller;
  final AppLocalizations l;
  final int allCount;
  final int lostCount;
  final int foundCount;

  const _TabBar({
    required this.controller,
    required this.l,
    required this.allCount,
    required this.lostCount,
    required this.foundCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TabChip(
            label: l.filterAll,
            count: allCount,
            index: 0,
            controller: controller,
            activeColor: _C.primary,
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: l.filterLost,
            count: lostCount,
            index: 1,
            controller: controller,
            activeColor: _C.lost,
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: l.filterFound,
            count: foundCount,
            index: 2,
            controller: controller,
            activeColor: _C.found,
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final int index;
  final TabController controller;
  final Color activeColor;

  const _TabChip({
    required this.label,
    required this.count,
    required this.index,
    required this.controller,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final active = controller.index == index;
        return GestureDetector(
          onTap: () => controller.animateTo(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? activeColor : _C.cardBorder,
                width: 1.5,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                          color: activeColor.withValues(alpha: 0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : _C.labelText,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.25)
                        : activeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final List<PostEntity> posts;

  const _Body({required this.posts});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        // ── Stats strip ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _StatsStrip(posts: posts, l: l),
          ),
        ),

        // ── Urgent horizontal section ─────────────────────────────────

        // ── All posts ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: _SectionRow(
              label: '📋  Gần đây',
              action: 'Sắp xếp ↕',
              onAction: () {},
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _StaggeredItem(
              index: i,
              total: posts.length,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _PostCard(
                  post: posts[i],
                  onTap: () => GoRouter.of(ctx).push('/posts/${posts[i].id}'),
                ),
              ),
            ),
            childCount: posts.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

// ─── Staggered item ───────────────────────────────────────────────────────────
class _StaggeredItem extends StatefulWidget {
  final int index;
  final int total;
  final Widget child;

  const _StaggeredItem({
    required this.index,
    required this.total,
    required this.child,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final delay = (widget.index * 55).clamp(0, 400);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── Stats Strip ─────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final List<PostEntity> posts;
  final AppLocalizations l;

  const _StatsStrip({required this.posts, required this.l});

  @override
  Widget build(BuildContext context) {
    final lostCount = posts.where((p) => p.type == PostType.lost).length;
    final foundCount = posts.where((p) => p.type == PostType.found).length;
    final resolvedCount =
        posts.where((p) => p.type == PostType.resolved).length;

    return Row(
      children: [
        _StatPill(
          num: lostCount,
          label: l.filterLost,
          iconColor: _C.lost,
          iconBg: const Color(0xFFFFE5E5),
          icon: Icons.location_on_rounded,
        ),
        const SizedBox(width: 8),
        _StatPill(
          num: foundCount,
          label: l.filterFound,
          iconColor: _C.found,
          iconBg: const Color(0xFFE0F0FF),
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(width: 8),
        _StatPill(
          num: resolvedCount,
          label: 'Tuần này',
          iconColor: _C.resolved,
          iconBg: const Color(0xFFE8FBF2),
          icon: Icons.star_outline_rounded,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final int num;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final IconData icon;

  const _StatPill({
    required this.num,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.cardBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Fix: don't stretch beyond content
          children: [
            Container(
              width: 32,
              height: 32,
              // Fix: shrink icon box if needed
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 6),
            Flexible(
              // Fix: allow text column to shrink
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    // Fix: scale down number if too wide
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$num',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: iconColor,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  FittedBox(
                    // Fix: scale down label if too wide
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.mutedText,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Row ──────────────────────────────────────────────────────────────
class _SectionRow extends StatelessWidget {
  final String label;
  final String action;
  final VoidCallback onAction;

  const _SectionRow({
    required this.label,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _C.mutedText,
            letterSpacing: 1,
            fontFamily: 'Nunito',
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _C.primary,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Urgent Card ──────────────────────────────────────────────────────────────
class _UrgentCard extends StatefulWidget {
  final PostEntity post;
  const _UrgentCard({required this.post});

  @override
  State<_UrgentCard> createState() => _UrgentCardState();
}

class _UrgentCardState extends State<_UrgentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String get _petEmoji => switch (widget.post.petType) {
        PetType.dog => '🐕',
        PetType.cat => '🐈',
        PetType.other => '🐾',
      };

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final color = _C.forType(post.type);

    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/posts/${post.id}'),
      child: Container(
        width: 152,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.cardBorder, width: 1.5),
          color: Colors.white,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            // Image area – fixed height
            SizedBox(
              height: 112,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _C.gradientForType(post.type),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child:
                          Text(_petEmoji, style: const TextStyle(fontSize: 52)),
                    ),
                    // Type badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _typeLabel(post.type),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                    // Urgent pulse dot
                    if (post.type == PostType.lost)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) => Transform.scale(
                            scale: 0.85 + _pulse.value * 0.3,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _C.lost,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info – use Expanded so it fills remaining space without overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.petName ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _C.bodyText,
                        fontFamily: 'Nunito',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 10, color: _C.hintText),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            post.locationName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _C.mutedText,
                              fontFamily: 'Nunito',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(post.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: _C.hintText,
                        fontFamily: 'Nunito',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(PostType t) => switch (t) {
        PostType.lost => 'Mất tích',
        PostType.found => 'Tìm thấy',
        PostType.resolved => 'Đã giải quyết',
      };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}

// ─── Post Card (vertical list) ────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final PostEntity post;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onTap});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _pressed = false;

  String get _petEmoji => switch (widget.post.petType) {
        PetType.dog => '🐕',
        PetType.cat => '🐈',
        PetType.other => '🐾',
      };

  String _typeLabel(PostType t) => switch (t) {
        PostType.lost => 'Mất tích',
        PostType.found => 'Tìm thấy',
        PostType.resolved => 'Đã giải quyết',
      };

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    _C.forType(post.type);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.cardBorder, width: 1.5),
          ),
          child: Row(
            children: [
              // ── Left image ──────────────────────────────────────────
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 90,
                  height: 110,
                  child: post.images.isNotEmpty
                      ? Image.network(
                          post.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildEmojiPlaceholder(post),
                        )
                      : _buildEmojiPlaceholder(post),
                ),
              ),

              // ── Right content ───────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              post.petName ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _C.bodyText,
                                height: 1.25,
                                fontFamily: 'Nunito',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(post.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              color: _C.hintText,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        post.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _C.mutedText,
                          fontFamily: 'Nunito',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 11, color: _C.hintText),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              post.locationName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _C.mutedText,
                                fontFamily: 'Nunito',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // Tags
                      Wrap(
                        spacing: 5,
                        children: _buildTags(post),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for emoji placeholder tile
  Widget _buildEmojiPlaceholder(PostEntity post) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _C.gradientForType(post.type),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(_petEmoji, style: const TextStyle(fontSize: 38)),
          Positioned(
            bottom: 7,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _C.forType(post.type),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _typeLabel(post.type),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTags(PostEntity post) {
    final tags = <Widget>[];

    if (post.type == PostType.resolved) {
      tags.add(_Tag(
          label: '✓ Giải quyết',
          bg: const Color(0xFFE8FBF2),
          fg: const Color(0xFF0D6E4A)));
    }
    // Fix: use post.images instead of post.imageUrls
    if (post.images.isNotEmpty) {
      tags.add(const _Tag(
          label: 'Có ảnh', bg: Color(0xFFE0F0FF), fg: Color(0xFF1460A0)));
    }
    return tags;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}p';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Tag({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}
