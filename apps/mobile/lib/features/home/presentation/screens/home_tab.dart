// features/home/presentation/screens/home_tab.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taboor/core/services/location_service.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/features/home/data/service_repository.dart';
import 'package:taboor/features/home/domain/service_place.dart';
import 'package:taboor/features/home/presentation/screens/all_services_screen.dart';
import 'package:taboor/features/home/presentation/screens/service_details_screen.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// The customer discovery feed.
///
/// Shows a greeting + location, a search bar, the user's live ticket (if any),
/// service categories, and nearby businesses.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, this.userName});

  final String? userName;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _location = '';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  /// Gets the real device position and resolves it to a city/area name.
  Future<void> _fetchLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position == null || !mounted) {
      if (mounted) setState(() => _location = '');
      return;
    }

    try {
      final res = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=${position.latitude}&lon=${position.longitude}'
          '&format=json'
          '&accept-language=${Localizations.localeOf(context).languageCode}',
        ),
        headers: {'User-Agent': 'TaboorApp/1.0'},
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      final name = address?['city'] ??
          address?['town'] ??
          address?['village'] ??
          address?['suburb'] ??
          address?['county'];
      if (!mounted) return;
      setState(() => _location = name?.toString() ?? '');
    } catch (_) {
      if (mounted) setState(() => _location = '');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGoodMorning;
    if (hour < 18) return l10n.homeGoodAfternoon;
    return l10n.homeGoodEvening;
  }

  void _openAll(ServiceCategory? category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllServicesScreen(initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = widget.userName?.trim();
    final horizontal = AppResponsive.horizontalPadding(context);
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              18 + topInset,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _HomeHeader(
                greeting: _greeting(l10n),
                userName: name,
                location: _location,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              16,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(child: _SearchBar(controller: _searchController)),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              22,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _LiveTicketCard(
                hasTicket: true,
                ticketNumber: 'A-12',
                peopleAhead: 3,
                estimatedMinutes: 15,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              22,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    l10n.homeNearby,
                    style: AppTextStyles.heading(size: 20),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _openAll(null),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Text(
                        l10n.homeSeeAll,
                        style: AppTextStyles.body(
                          color: AppColors.teal,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              14,
              horizontal.right,
              8,
            ),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryCard(
                      icon: Icons.local_hospital_outlined,
                      label: CategoryLabel.clinics,
                      color: AppColors.teal,
                      onTap: () => _openAll(ServiceCategory.clinics),
                    ),
                    const SizedBox(width: 12),
                    _CategoryCard(
                      icon: Icons.content_cut_rounded,
                      label: CategoryLabel.salons,
                      color: AppColors.indigo,
                      onTap: () => _openAll(ServiceCategory.salons),
                    ),
                    const SizedBox(width: 12),
                    _CategoryCard(
                      icon: Icons.car_repair_rounded,
                      label: CategoryLabel.garages,
                      color: AppColors.amber,
                      onTap: () => _openAll(ServiceCategory.garages),
                    ),
                    const SizedBox(width: 12),
                    _CategoryCard(
                      icon: Icons.business_outlined,
                      label: CategoryLabel.offices,
                      color: AppColors.ink,
                      onTap: () => _openAll(ServiceCategory.offices),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              20,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.homePopularNearYou,
                style: AppTextStyles.heading(size: 20),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              14,
              horizontal.right,
              70,
            ),
            sliver: SliverList.separated(
              itemCount: _placeholders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _BusinessCard(place: _placeholders[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.userName,
    required this.location,
  });

  final String greeting;
  final String? userName;
  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayName = (userName == null || userName!.isEmpty)
        ? l10n.navProfile
        : userName!;
    final initial = displayName.trim().isEmpty
        ? '؟'
        : displayName.trim().characters.first.toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // User avatar: first letter on a soft gradient — clean, not a hospital.
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.teal, AppColors.deepTeal],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            initial,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.paper,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyles.label(
                  color: AppColors.gray600,
                  size: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading(size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _LocationChip(location: location),
      ],
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final loading = location.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          loading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.teal,
                  ),
                )
              : const Icon(Icons.location_on_outlined,
                  color: AppColors.teal, size: 16),
          const SizedBox(width: 4),
          Text(
            location,
            style: AppTextStyles.body(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).homeSearchHint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray500),
        suffixIcon: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.softTeal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: AppColors.teal,
            size: 20,
          ),
        ),
        hintStyle: AppTextStyles.body(color: AppColors.gray500, size: 14),
      ),
    );
  }
}

class _LiveTicketCard extends StatelessWidget {
  const _LiveTicketCard({
    required this.hasTicket,
    required this.ticketNumber,
    required this.peopleAhead,
    required this.estimatedMinutes,
  });

  final bool hasTicket;
  final String ticketNumber;
  final int peopleAhead;
  final int estimatedMinutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = hasTicket ? AppColors.ink : AppColors.teal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasTicket ? AppColors.ink : AppColors.paper,
        borderRadius: BorderRadius.circular(24),
        border: hasTicket ? null : Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepTeal.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: !hasTicket
          ? Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.softTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.playlist_add_rounded,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeNoTicket,
                        style: AppTextStyles.heading(size: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.homeJoinQueue,
                        style: AppTextStyles.body(
                          color: AppColors.teal,
                          weight: FontWeight.w600,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.teal,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.homeLiveTicket,
                            style: AppTextStyles.label(
                              color: AppColors.paper,
                              weight: FontWeight.w700,
                              size: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.ticketNumberLabel,
                          style: AppTextStyles.label(
                            color: AppColors.gray400,
                            size: 12,
                          ),
                        ),
                        Text(
                          ticketNumber,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.paper,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.queuePeopleAhead(peopleAhead),
                            style: AppTextStyles.heading(
                              size: 20,
                              color: AppColors.paper,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.queueEstimate}: ${l10n.queueMinutes(estimatedMinutes)}',
                            style: AppTextStyles.body(
                              color: AppColors.gray400,
                              size: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 6,
                    backgroundColor: AppColors.paper.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.amber),
                  ),
                ),
              ],
            ),
    );
  }
}

enum CategoryLabel { clinics, salons, garages, offices }

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final CategoryLabel label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (label) {
      CategoryLabel.clinics => l10n.categoryClinics,
      CategoryLabel.salons => l10n.categorySalons,
      CategoryLabel.garages => l10n.categoryGarages,
      CategoryLabel.offices => l10n.categoryOffices,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                text,
                style: AppTextStyles.label(
                  color: AppColors.ink,
                  weight: FontWeight.w600,
                  size: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _placeholders = ServiceRepository.places;
class _BusinessCard extends StatelessWidget {
  const _BusinessCard({required this.place});

  final ServicePlace place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mainBranch = place.branches.first;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ServiceDetailsScreen(place: place),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: place.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(place.icon, color: place.color, size: 26),
              ),
              const SizedBox(width: 14),
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
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          mainBranch.distanceKm != null
                              ? l10n.distanceAway(mainBranch.distanceKm!)
                              : '',
                          style: AppTextStyles.body(
                            color: AppColors.gray600,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.groups_rounded,
                          size: 13,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          l10n.peopleWaiting(place.totalWaiting),
                          style: AppTextStyles.body(
                            color: AppColors.gray600,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.joinNow,
                  style: AppTextStyles.body(
                    color: AppColors.ink,
                    weight: FontWeight.w700,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}