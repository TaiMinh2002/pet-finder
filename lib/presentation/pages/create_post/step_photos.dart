import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_button.dart';

class StepPhotos extends StatelessWidget {
  final AppLocalizations l;
  final List<String> imagePaths;
  final List<String> imageUrls;
  final VoidCallback onPickImages;
  final VoidCallback onNext;

  const StepPhotos({
    super.key,
    required this.l,
    required this.imagePaths,
    required this.imageUrls,
    required this.onPickImages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.addPhotos, style: Theme.of(context).textTheme.titleLarge),
            Text(l.addPhotosHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            if (imagePaths.isEmpty)
              GestureDetector(
                onTap: onPickImages,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary,
                        style: BorderStyle.solid,
                        width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 48, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(l.addPhotos,
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imagePaths
                    .map((path) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.image,
                                  color: AppColors.textHint),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            if (imagePaths.isNotEmpty)
              OutlinedButton.icon(
                onPressed: onPickImages,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l.addPhotos),
              ),
            if (imageUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.cloud_done,
                      color: AppColors.found, size: 16),
                  const SizedBox(width: 6),
                  Text(l.photosUploaded(imageUrls.length),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.found)),
                ],
              ),
            ],
            const Spacer(),
            AppButton(
                label: '${l.commonNext}: ${l.stepContact} →',
                onPressed: onNext),
          ],
        ),
      ),
    );
  }
}
