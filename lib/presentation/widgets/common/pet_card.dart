import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/post_entity.dart';

/// Claymorphism pet card — horizontal layout, clay shadow, animated press.
class PetCard extends StatefulWidget {
  final PostEntity post;
  final VoidCallback? onTap;
  final bool compact;

  const PetCard({
    super.key,
    required this.post,
    this.onTap,
    this.compact = false,
  });

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      value: 1.0,
      lowerBound: 0.97,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.post.type) {
      case PostType.lost: return AppColors.lost;
      case PostType.found: return AppColors.found;
      case PostType.resolved: return AppColors.resolved;
    }
  }

  Color get _accentContainer {
    switch (widget.post.type) {
      case PostType.lost: return AppColors.lostContainer;
      case PostType.found: return AppColors.foundContainer;
      case PostType.resolved: return AppColors.resolvedContainer;
    }
  }

  String get _typeLabelText {
    switch (widget.post.type) {
      case PostType.lost: return 'MẤT';
      case PostType.found: return 'TÌM THẤY';
      case PostType.resolved: return 'ĐÃ GIẢI QUYẾT';
    }
  }

  IconData get _petIcon {
    switch (widget.post.petType) {
      case PetType.dog: return Icons.pets;
      case PetType.cat: return Icons.catching_pokemon;
      case PetType.other: return Icons.cruelty_free;
    }
  }

  String get _petLabel {
    switch (widget.post.petType) {
      case PetType.dog: return 'Chó';
      case PetType.cat: return 'Mèo';
      case PetType.other: return 'Thú cưng';
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ScaleTransition(
        scale: _ctrl,
        child: GestureDetector(
          onTapDown: (_) => _ctrl.reverse(),
          onTapUp: (_) {
            _ctrl.forward();
            widget.onTap?.call();
          },
          onTapCancel: () => _ctrl.forward(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: AppColors.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Row(
                children: [
                  // ── Left accent stripe ─────────────────────────────────
                  Container(
                    width: 5,
                    height: widget.compact ? 90 : 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_accentColor, _accentColor.withValues(alpha: 0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // ── Image / Icon ────────────────────────────────────────
                  Container(
                    width: widget.compact ? 90 : 110,
                    height: widget.compact ? 90 : 120,
                    color: _accentContainer,
                    child: post.hasImages
                        ? CachedNetworkImage(
                            imageUrl: post.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _PlaceholderIcon(
                                icon: _petIcon, color: _accentColor),
                            errorWidget: (_, __, ___) => _PlaceholderIcon(
                                icon: _petIcon, color: _accentColor),
                          )
                        : _PlaceholderIcon(
                            icon: _petIcon, color: _accentColor),
                  ),

                  // ── Content ─────────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Type badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _accentContainer,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: _accentColor.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _accentColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _typeLabelText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: _accentColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Pet type pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _petLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.petName ?? _petLabel,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (post.breed != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              post.breed!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13,
                                  color: AppColors.textHint),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  post.locationName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textHint,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.timeAgo(post.createdAt),
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textHint),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _PlaceholderIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, size: 40, color: color.withValues(alpha: 0.6)),
    );
  }
}
