import 'package:flutter/material.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/post_entity.dart';

class PostTypeBadge extends StatelessWidget {
  final PostType type;
  const PostTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label(l),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color get _bg {
    switch (type) {
      case PostType.lost: return AppColors.lostContainer;
      case PostType.found: return AppColors.foundContainer;
      case PostType.resolved: return AppColors.resolvedContainer;
    }
  }

  Color get _color {
    switch (type) {
      case PostType.lost: return AppColors.lost;
      case PostType.found: return AppColors.found;
      case PostType.resolved: return AppColors.resolved;
    }
  }

  String _label(AppLocalizations l) {
    switch (type) {
      case PostType.lost: return l.postTypeLost.toUpperCase();
      case PostType.found: return l.postTypeFound.toUpperCase();
      case PostType.resolved: return l.postTypeResolved.toUpperCase();
    }
  }
}
