import 'package:flutter/material.dart';
import 'package:taboor/features/onboarding/presentation/widgets/onboarding_illustrations.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final OnboardingIllustrationType type;
  final String title;
  final String subtitle;
  final Color accent;
}