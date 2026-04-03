import 'package:flutter/material.dart';
import 'package:pet_finder/l10n/app_localizations.dart';

class OnboardingData {
  final String label;
  final String title;
  final String subtitle;
  final Color color;

  const OnboardingData({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

/// Colors used for each onboarding page (static, no i18n needed)
const List<Color> onboardingColors = [
  Color(0xFFFF6B6B),
  Color(0xFF4EAEFF),
  Color(0xFF56D49A),
];

/// Build localized onboarding pages at runtime
List<OnboardingData> buildOnboardingPages(AppLocalizations l) => [
  OnboardingData(
    label: l.onboardingLabel1,
    title: l.onboardingTitle1Data,
    subtitle: l.onboardingSubtitle1Data,
    color: onboardingColors[0],
  ),
  OnboardingData(
    label: l.onboardingLabel2,
    title: l.onboardingTitle2Data,
    subtitle: l.onboardingSubtitle2Data,
    color: onboardingColors[1],
  ),
  OnboardingData(
    label: l.onboardingLabel3,
    title: l.onboardingTitle3Data,
    subtitle: l.onboardingSubtitle3Data,
    color: onboardingColors[2],
  ),
];
