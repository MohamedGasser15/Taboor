import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:taboor/features/splash/presentation/widgets/taboor_logo.dart';
import 'package:taboor/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final name = userName?.trim();
    final greeting = (name == null || name.isEmpty)
        ? AppLocalizations.of(context).homeTitle
        : '${AppLocalizations.of(context).welcomeBack} $name';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TaboorLogo(scale: 0.6),
            const SizedBox(height: 36),
            Text(
              greeting,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.deepTeal,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).homeSoon,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: AppColors.paper,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: Text(
                    AppLocalizations.of(context).homeCta,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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