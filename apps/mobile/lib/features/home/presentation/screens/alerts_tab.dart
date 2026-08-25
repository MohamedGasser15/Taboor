// features/home/presentation/screens/alerts_tab.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// Customer smart alerts tab.
///
/// Placeholder listing push/WhatsApp/SMS alerts that get triggered by queue
/// velocity and client proximity (empty state for now).
class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.teal,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.alertsEmptyTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading(size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.alertsEmptySubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: AppColors.gray600, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}