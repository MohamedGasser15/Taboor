// features/home/presentation/screens/alerts_tab.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// Customer smart alerts tab.
///
/// Lists seeded push/WhatsApp/SMS alerts triggered by queue velocity and
/// client proximity. Grouped by day, newest first.
class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  List<AppAlert> get _seededAlerts => [
        _alert(
          type: AlertType.join,
          time: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        _alert(
          type: AlertType.open,
          time: DateTime.now().subtract(const Duration(minutes: 55)),
        ),
        _alert(
          type: AlertType.turn,
          time: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        _alert(
          type: AlertType.turn,
          time: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        _alert(
          type: AlertType.go,
          time: DateTime.now().subtract(const Duration(hours: 26)),
        ),
        _alert(
          type: AlertType.thanks,
          time: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

  AppAlert _alert({
    required AlertType type,
    required DateTime time,
  }) {
    final service = switch (type) {
      AlertType.join => 'Dr. Sara Dental Clinic',
      AlertType.open => 'Mirror Salon',
      AlertType.turn => 'Cairo Fix Auto',
      AlertType.go => 'Mirror Salon',
      AlertType.thanks => 'Dr. Sara Dental Clinic',
    };
    return AppAlert(
      type: type,
      service: service,
      number: 'A-12',
      time: time,
      read: time.isBefore(DateTime.now().subtract(const Duration(hours: 12))),
    );
  }

  final dismissed = <AppAlert>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final newCount = _seededAlerts.where((a) => !a.read).length;

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 0),
            child: Row(
              children: [
                Text(
                  l10n.navAlerts,
                  style: AppTextStyles.heading(size: 24),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$newCount ${l10n.alertNewBadge}',
                    style: AppTextStyles.label(
                      color: AppColors.teal,
                      weight: FontWeight.w800,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _AlertsList(
              alerts: _seededAlerts,
              onDismiss: (alert) => setState(() => dismissed.add(alert)),
            ),
          ),
        ],
      ),
    );
  }
}

enum AlertType { join, open, turn, go, thanks }

extension on AlertType {
  IconData get icon => switch (this) {
        AlertType.join => Icons.confirmation_number_rounded,
        AlertType.open => Icons.storefront_rounded,
        AlertType.turn => Icons.hourglass_top_rounded,
        AlertType.go => Icons.directions_walk_rounded,
        AlertType.thanks => Icons.favorite_rounded,
      };
}

class AppAlert {
  const AppAlert({
    required this.type,
    required this.service,
    required this.number,
    required this.time,
    this.read = false,
  });

  final AlertType type;
  final String service;
  final String number;
  final DateTime time;
  final bool read;
}

class _AlertsList extends StatelessWidget {
  const _AlertsList({required this.alerts, required this.onDismiss});

  final List<AppAlert> alerts;
  final ValueChanged<AppAlert> onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visible = alerts.where((a) => !a.read).toList();

    if (visible.isEmpty) {
      return _EmptyState(l10n: l10n);
    }

    final today = DateTime.now();
    final groups = <String, List<AppAlert>>{};
    for (final a in visible) {
      final sameDay = DateTime(a.time.year, a.time.month, a.time.day) ==
          DateTime(today.year, today.month, today.day);
      final sameYesterday =
          DateTime(a.time.year, a.time.month, a.time.day) ==
              DateTime(today.year, today.month, today.day - 1);
      final key = sameDay
          ? l10n.alertToday
          : sameYesterday
              ? l10n.alertYesterday
              : l10n.alertOlder;
      groups.putIfAbsent(key, () => []).add(a);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: EdgeInsets.only(
              top: entry.key == l10n.alertToday ? 4 : 18,
              bottom: 8,
            ),
            child: Text(
              entry.key,
              style: AppTextStyles.label(
                color: AppColors.gray500,
                size: 12,
                weight: FontWeight.w800,
              ),
            ),
          ),
          for (final alert in entry.value)
            _AlertCard(
              alert: alert,
              onDismiss: () => onDismiss(alert),
            ),
        ],
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.onDismiss});

  final AppAlert alert;
  final VoidCallback onDismiss;

  String _relativeTime(AppLocalizations l10n, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.alertJustNow;
    if (diff.inMinutes < 60) return l10n.alertMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.alertHoursAgo(diff.inHours);
    return l10n.alertHoursAgo(diff.inHours);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = switch (alert.type) {
      AlertType.join => AppColors.teal,
      AlertType.open => AppColors.success,
      AlertType.turn => AppColors.gray500,
      AlertType.go => AppColors.amber,
      AlertType.thanks => const Color(0xFFE57373),
    };

    final body = switch (alert.type) {
      AlertType.join => l10n.alertQueueJoinBody(alert.number, alert.service),
      AlertType.open => l10n.alertQueueOpenBody(alert.service),
      AlertType.turn => l10n.alertTurnStartedBody(alert.service),
      AlertType.go => l10n.alertTimeToGoBody(alert.service),
      AlertType.thanks => l10n.alertThankYouBody(alert.service),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(alert.type.icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _localizedTitle(l10n, alert),
                        style: AppTextStyles.body(
                          color: AppColors.ink,
                          weight: FontWeight.w700,
                          size: 14,
                        ),
                      ),
                    ),
                    Text(
                      _relativeTime(l10n, alert.time),
                      style: AppTextStyles.label(
                        color: AppColors.gray500,
                        size: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTextStyles.body(
                    color: AppColors.gray600,
                    size: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizedTitle(AppLocalizations l10n, AppAlert alert) {
    return switch (alert.type) {
      AlertType.join => l10n.alertQueueJoin,
      AlertType.open => l10n.alertQueueOpen,
      AlertType.turn => l10n.alertTurnStarted,
      AlertType.go => l10n.alertTimeToGo,
      AlertType.thanks => l10n.alertThankYou,
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.teal,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.alertNoAlertsTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.alertNoAlertsBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.gray600, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}