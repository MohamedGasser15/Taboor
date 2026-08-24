// features/home/presentation/screens/all_services_screen.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/features/home/data/service_repository.dart';
import 'package:taboor/features/home/domain/service_place.dart';
import 'package:taboor/features/home/presentation/screens/service_details_screen.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// Lists every service with category filtering.
class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key, this.initialCategory});

  final ServiceCategory? initialCategory;

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  ServiceCategory? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  List<ServicePlace> get _services {
    final all = ServiceRepository.places;
    if (_category == null) return all;
    return all.where((p) => p.category == _category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final horizontal = AppResponsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.allServicesTitle),
            Text(
              l10n.allServicesSubtitle,
              style: AppTextStyles.label(
                color: AppColors.gray500,
                size: 12,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontal.left,
              vertical: 8,
            ),
            child: _FilterChips(
              selected: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
          ),
          Expanded(
            child: _services.isEmpty
                ? const _NoServices()
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      horizontal.left,
                      8,
                      horizontal.right,
                      24,
                    ),
                    itemCount: _services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _ServiceListTile(
                      place: _services[i],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceDetailsScreen(place: _services[i]),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});

  final ServiceCategory? selected;
  final ValueChanged<ServiceCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget chip({required Widget child, required bool active, VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.ink : AppColors.paper,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: active ? AppColors.ink : AppColors.gray200,
            ),
          ),
          child: child,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(
            child: Text(
              l10n.filterAll,
              style: AppTextStyles.body(
                color: selected == null ? AppColors.paper : AppColors.ink,
                weight: FontWeight.w600,
                size: 13,
              ),
            ),
            active: selected == null,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          chip(
            child: Text(
              l10n.categoryClinics,
              style: AppTextStyles.body(
                color: selected == ServiceCategory.clinics
                    ? AppColors.paper
                    : AppColors.ink,
                weight: FontWeight.w600,
                size: 13,
              ),
            ),
            active: selected == ServiceCategory.clinics,
            onTap: () => onChanged(ServiceCategory.clinics),
          ),
          const SizedBox(width: 8),
          chip(
            child: Text(
              l10n.categorySalons,
              style: AppTextStyles.body(
                color: selected == ServiceCategory.salons
                    ? AppColors.paper
                    : AppColors.ink,
                weight: FontWeight.w600,
                size: 13,
              ),
            ),
            active: selected == ServiceCategory.salons,
            onTap: () => onChanged(ServiceCategory.salons),
          ),
          const SizedBox(width: 8),
          chip(
            child: Text(
              l10n.categoryGarages,
              style: AppTextStyles.body(
                color: selected == ServiceCategory.garages
                    ? AppColors.paper
                    : AppColors.ink,
                weight: FontWeight.w600,
                size: 13,
              ),
            ),
            active: selected == ServiceCategory.garages,
            onTap: () => onChanged(ServiceCategory.garages),
          ),
          const SizedBox(width: 8),
          chip(
            child: Text(
              l10n.categoryOffices,
              style: AppTextStyles.body(
                color: selected == ServiceCategory.offices
                    ? AppColors.paper
                    : AppColors.ink,
                weight: FontWeight.w600,
                size: 13,
              ),
            ),
            active: selected == ServiceCategory.offices,
            onTap: () => onChanged(ServiceCategory.offices),
          ),
        ],
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  const _ServiceListTile({required this.place, required this.onTap});

  final ServicePlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final main = place.branches.first;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: place.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(place.icon, color: place.color, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading(size: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.groups_rounded,
                            size: 13, color: AppColors.gray500),
                        const SizedBox(width: 2),
                        Text(
                          l10n.peopleWaiting(place.totalWaiting),
                          style: AppTextStyles.body(
                            color: AppColors.gray600,
                            size: 12,
                          ),
                        ),
                        if (main.distanceKm != null) ...[
                          const SizedBox(width: 10),
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.gray500),
                          const SizedBox(width: 2),
                          Text(
                            l10n.distanceAway(main.distanceKm!),
                            style: AppTextStyles.body(
                              color: AppColors.gray600,
                              size: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.gray400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoServices extends StatelessWidget {
  const _NoServices();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context).allServicesTitle,
            style: AppTextStyles.body(color: AppColors.gray600, size: 14),
          ),
        ],
      ),
    );
  }
}