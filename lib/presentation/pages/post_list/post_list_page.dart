import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/post_entity.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/pet_card.dart';
import '../../widgets/common/shimmer_card.dart';

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
      if (_tabCtrl.indexIsChanging) {
        final types = [null, PostType.lost, PostType.found];
        _setFilter(types[_tabCtrl.index]);
      }
    });
    context.read<PostBloc>().add(const PostsLoadRequested());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _setFilter(PostType? type) {
    context.read<PostBloc>().add(PostFilterChanged(filterType: type));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ─────────────────────────────────────────────
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.tabPosts,
                                style: Theme.of(context).textTheme.headlineLarge),
                            Text(
                              l.postListSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: AppColors.primary, size: 22),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Search bar ─────────────────────────────────────────
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded,
                              size: 20, color: AppColors.textHint),
                          hintText: l.commonSearch,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Tab filter bar ─────────────────────────────────────
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TabBar(
                        controller: _tabCtrl,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: AppColors.clayShadow(
                              color: AppColors.primary, elevation: 0.6),
                        ),
                        indicatorPadding: const EdgeInsets.all(4),
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: [
                          Tab(text: l.filterAll),
                          Tab(text: l.filterLost),
                          Tab(text: l.filterFound),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading) {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: 4,
                itemBuilder: (_, __) => const ShimmerCard(),
              );
            }
            if (state is PostError) {
              return EmptyState(
                title: l.commonError,
                subtitle: state.message,
                icon: Icons.error_outline_rounded,
                actionLabel: l.commonRetry,
                onAction: () => context
                    .read<PostBloc>()
                    .add(const PostsLoadRequested()),
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
              return _StaggeredList(posts: state.posts);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Staggered fade-slide-up list animation
class _StaggeredList extends StatefulWidget {
  final List<PostEntity> posts;
  const _StaggeredList({required this.posts});
  @override
  State<_StaggeredList> createState() => __StaggeredListState();
}

class __StaggeredListState extends State<_StaggeredList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.posts.length * 60),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: widget.posts.length,
      itemBuilder: (context, i) {
        // Stagger: each card starts 60ms after the previous
        final start = (i * 0.06).clamp(0.0, 0.8);
        final end = (start + 0.3).clamp(0.0, 1.0);
        final opacity = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => FadeTransition(
            opacity: opacity,
            child: SlideTransition(position: slide, child: child),
          ),
          child: PetCard(
            post: widget.posts[i],
            onTap: () => GoRouter.of(context).push('/posts/${widget.posts[i].id}'),
          ),
        );
      },
    );
  }
}
