// features/home/presentation/screens/queue_tab.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/core/utils/app_responsive.dart';
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
    final horizontal = AppResponsive.horizontalPadding(context);
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(top: 24 + topInset),
        child: _hasActiveTicket
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal.left,
                ),
                child: _LiveStatus(l10n: l10n),
              )
            : _EmptyQueue(l10n: l10n),
      ),
    );
  }
}

class _LiveStatus extends StatelessWidget {
  const _LiveStatus({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          l10n.navQueue,
          style: AppTextStyles.heading(size: 22),
        ),
        const SizedBox(height: 20),
        // رقم التذكرة الكبير
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
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
                  horizontal: 12,
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
              const SizedBox(height: 12),
              const Text(
                'A-12',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: AppColors.paper,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // العداد المباشر
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
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.queueNowServing,
                    style: AppTextStyles.body(
                      color: AppColors.gray600,
                      weight: FontWeight.w500,
                      size: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.queuePeopleAhead(2),
                          style: AppTextStyles.heading(size: 24),
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
                  const Text(
                    'A-07',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                    ),
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
        // نبذة عن "دورك قرب"
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.softTeal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_rounded,
                  color: AppColors.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.alertLeaveTitle,
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