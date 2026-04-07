import 'package:flutter/material.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/post_entity.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class StepPetInfo extends StatelessWidget {
  final AppLocalizations l;
  final PostType postType;
  final PetType petType;
  final TextEditingController nameCtrl, breedCtrl, colorCtrl, descCtrl;
  final DateTime lostDate;
  final ValueChanged<PostType> onPostTypeChanged;
  final ValueChanged<PetType> onPetTypeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onNext;

  const StepPetInfo({
    super.key,
    required this.l,
    required this.postType,
    required this.petType,
    required this.nameCtrl,
    required this.breedCtrl,
    required this.colorCtrl,
    required this.descCtrl,
    required this.lostDate,
    required this.onPostTypeChanged,
    required this.onPetTypeChanged,
    required this.onDateChanged,
    required this.onNext,
  });

  String _postTypeLabel(PostType t) {
    switch (t) {
      case PostType.lost:
        return l.postTypeLost;
      case PostType.found:
        return l.postTypeFound;
      case PostType.resolved:
        return l.postTypeResolved;
    }
  }

  String _petTypeLabel(PetType t) {
    switch (t) {
      case PetType.dog:
        return l.petTypeDog;
      case PetType.cat:
        return l.petTypeCat;
      case PetType.other:
        return l.petTypeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.selectPostType,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: PostType.values.map((t) {
                final selected = postType == t;
                final color = t == PostType.lost
                    ? AppColors.lost
                    : t == PostType.found
                        ? AppColors.found
                        : AppColors.resolved;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onPostTypeChanged(t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.15)
                            : AppColors.surfaceVariant,
                        border: Border.all(
                            color: selected ? color : AppColors.border,
                            width: selected ? 2 : 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            t == PostType.lost
                                ? Icons.search
                                : t == PostType.found
                                    ? Icons.check_circle_outline
                                    : Icons.favorite_outline,
                            color: selected ? color : AppColors.textHint,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _postTypeLabel(t),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected ? color : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(l.selectPetType,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: PetType.values.map((t) {
                final selected = petType == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onPetTypeChanged(t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryContainer
                            : AppColors.surfaceVariant,
                        border: Border.all(
                            color:
                                selected ? AppColors.primary : AppColors.border,
                            width: selected ? 2 : 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                              t == PetType.dog
                                  ? '🐕'
                                  : t == PetType.cat
                                      ? '🐈'
                                      : '🐾',
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            _petTypeLabel(t),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            AppTextField(
                label: l.petName, hint: l.petNameHint, controller: nameCtrl),
            const SizedBox(height: 16),
            AppTextField(
                label: l.breed, hint: l.breedHint, controller: breedCtrl),
            const SizedBox(height: 16),
            AppTextField(
                label: l.colorFeatures,
                hint: l.colorFeaturesHint,
                controller: colorCtrl),
            const SizedBox(height: 16),
            AppTextField(
              label: l.description,
              hint: l.descriptionHint,
              controller: descCtrl,
              maxLines: 4,
            ),
            const SizedBox(height: 28),
            AppButton(
                label: '${l.commonNext}: ${l.stepLocation} →',
                onPressed: onNext),
          ],
        ),
      ),
    );
  }
}
