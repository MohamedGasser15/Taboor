// features/home/presentation/screens/queue_tab.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// Customer's live queue tab.
///
/// Shows a live counter + progress bar when the user has an active ticket,
/// otherwise an empty state guiding them to browse nearby services.
class QueueTab extends StatelessWidget {
  const QueueTab({super.key});

  /// Whether the customer currently holds an active ticket.
  final _hasActiveTicket = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: _hasActiveTicket
          ? _LiveStatus(l10n: l10n)
          : _EmptyQueue(l10n: l10n),
    );
  }
}

class _LiveStatus extends StatelessWidget {
  const _LiveStatus({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 24),
      children: [
        // ===== Header =====
        Row(
          children: [
            Text(
              l10n.navQueue,
              style: AppTextStyles.heading(size: 24),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppColors.success, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    l10n.queueNowServing,
                    style: AppTextStyles.label(
                      color: AppColors.success,
                      weight: FontWeight.w700,
                      size: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ===== رقم التذكرة الكبير =====
        Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepTeal.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.ticketNumberLabel,
                  style: AppTextStyles.label(
                    color: AppColors.paper,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'A-12',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 60,
                  fontWeight: FontWeight.w800,
                  color: AppColors.paper,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ===== العنوان: "بيستقبل دلوقتي" =====
        Text(
          l10n.queueNowServing,
          style: AppTextStyles.heading(size: 16),
        ),
        const SizedBox(height: 10),

        // ===== العداد المباشر =====
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.queuePeopleAhead(2),
                          style: AppTextStyles.heading(size: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${l10n.queueEstimate}: ${l10n.queueMinutes(10)}',
                          style: AppTextStyles.body(
                            color: AppColors.gray600,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.ticketNumberLabel,
                        style: AppTextStyles.label(
                          color: AppColors.gray500,
                          size: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'A-07',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.68,
                  minHeight: 8,
                  backgroundColor: AppColors.softTeal,
                  valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ===== نبذة "دورك قرب" =====
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.softTeal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded,
                    color: AppColors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${l10n.alertLeaveTitle} — ${l10n.alertOnlyTwo}',
                  style: AppTextStyles.body(
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue({required this.l10n});

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
              child: const Icon(
                Icons.confirmation_number_outlined,
                color: AppColors.teal,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.queueEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.queueEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.gray600, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}