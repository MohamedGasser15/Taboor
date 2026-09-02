// features/home/presentation/screens/all_services_screen.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/features/home/data/service_repository.dart';
import 'package:taboor/features/home/domain/service_place.dart';
import 'package:taboor/features/home/presentation/screens/service_details_screen.dart';
import 'package:taboor/l10n/app_localizations.dart';

enum ServiceSortFilter {
  all,
  nearest,
  fastestQueue,
  topRated,
  openNow,
}

/// Rich dedicated screen listing businesses by category with search, sorting, and live queue statistics.
class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key, this.initialCategory});

  final ServiceCategory? initialCategory;

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  late ServiceCategory? _category;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ServiceSortFilter _sortFilter = ServiceSortFilter.all;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _searchController.addListener(() {
      final q = _searchController.text.trim().toLowerCase();
      if (q != _searchQuery) {
        setState(() => _searchQuery = q);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServicePlace> get _filteredServices {
    final all = ServiceRepository.places;
    var list = all.where((p) {
      final matchesCategory = _category == null || p.category == _category;
      final matchesSearch = p.matchesQuery(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    // Apply quick filters & sorting
    switch (_sortFilter) {
      case ServiceSortFilter.nearest:
        list.sort((a, b) {
          final distA = double.tryParse(a.branches.first.distanceKm ?? '999') ?? 999;
          final distB = double.tryParse(b.branches.first.distanceKm ?? '999') ?? 999;
          return distA.compareTo(distB);
        });
        break;
      case ServiceSortFilter.fastestQueue:
        list.sort((a, b) => a.totalWaiting.compareTo(b.totalWaiting));
        break;
      case ServiceSortFilter.topRated:
        list.sort((a, b) => b.starRating.compareTo(a.starRating));
        break;
      case ServiceSortFilter.openNow:
        list = list.where((p) => p.branches.any((b) => b.isOpen)).toList();
        break;
      case ServiceSortFilter.all:
        break;
    }

    return list;
  }

  String _categoryTitle(AppLocalizations l10n, bool isAr) {
    if (_category == null) return l10n.allServicesTitle;
    return switch (_category!) {
      ServiceCategory.clinics => isAr ? "العيادات والمراكز الطبية" : "Clinics & Medical Centers",
      ServiceCategory.salons => isAr ? "صالونات الحلاقة والتجميل" : "Salons & Spas",
      ServiceCategory.garages => isAr ? "مراكز صيانة السيارات" : "Auto Repair & Garages",
      ServiceCategory.offices => isAr ? "المصالح الحكومية والمكاتب" : "Offices & Administrative",
    };
  }

  String _categorySubtitle(AppLocalizations l10n, bool isAr) {
    if (_category == null) return l10n.allServicesSubtitle;
    return switch (_category!) {
      ServiceCategory.clinics => isAr ? "احجز دورك مسبقاً وتجنب زحمة الانتظار" : "Book remotely & avoid clinic waiting rooms",
      ServiceCategory.salons => isAr ? "احجز حلاقتك أو موعدك بدون انتظار" : "Reserve your spot without physical queues",
      ServiceCategory.garages => isAr ? "صيانة سيارتك في موعدها الدقيق" : "Fast car service without delays",
      ServiceCategory.offices => isAr ? "أنجز معاملاتك بسرعة وسهولة" : "Government & administrative queue booking",
    };
  }

  Color get _categoryThemeColor {
    if (_category == null) return AppColors.teal;
    return switch (_category!) {
      ServiceCategory.clinics => AppColors.teal,
      ServiceCategory.salons => AppColors.indigo,
      ServiceCategory.garages => AppColors.amber,
      ServiceCategory.offices => AppColors.ink,
    };
  }

  IconData get _categoryThemeIcon {
    if (_category == null) return Icons.grid_view_rounded;
    return switch (_category!) {
      ServiceCategory.clinics => Icons.medical_services_rounded,
      ServiceCategory.salons => Icons.content_cut_rounded,
      ServiceCategory.garages => Icons.car_repair_rounded,
      ServiceCategory.offices => Icons.business_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final horizontal = AppResponsive.horizontalPadding(context);
    final services = _filteredServices;
    final themeColor = _categoryThemeColor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.gray100,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.ink,
                size: 17,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _categoryTitle(l10n, isAr),
              style: AppTextStyles.heading(size: 17),
            ),
            Text(
              _categorySubtitle(l10n, isAr),
              style: AppTextStyles.label(
                color: AppColors.gray500,
                size: 11,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Section Header / Category Banner & Search
          Container(
            color: AppColors.paper,
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              12,
              horizontal.right,
              14,
            ),
            child: Column(
              children: [
                // Category Highlight Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_categoryThemeIcon, color: themeColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr
                                  ? "تتبع مباشر وحجز فوري من البيت"
                                  : "Live queue tracking & remote booking",
                              style: AppTextStyles.body(
                                color: AppColors.ink,
                                weight: FontWeight.w700,
                                size: 12.5,
                              ),
                            ),
                            Text(
                              isAr
                                  ? "وفّر وقتك وسجل مكانك بالطابور بضغطة واحدة"
                                  : "Save your spot and arrive right when it's your turn",
                              style: AppTextStyles.label(
                                color: AppColors.gray600,
                                size: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Search Bar within this screen
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.body(size: 13.5),
                    decoration: InputDecoration(
                      hintText: isAr
                          ? "ابحث بالاسم أو الفرع أو المنطقة..."
                          : "Search by place name or branch...",
                      hintStyle: AppTextStyles.body(color: AppColors.gray400, size: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray400, size: 19),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 17, color: AppColors.gray400),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Category Selector Pill Tabs
          Container(
            color: AppColors.paper,
            padding: const EdgeInsets.only(bottom: 12),
            child: _CategoryPillTabs(
              selected: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
          ),

          // 3. Quick Sort & Filter Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontal.left,
              vertical: 8,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(color: AppColors.gray200, width: 0.6),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SortFilterChip(
                    label: isAr ? "الكل (${services.length})" : "All (${services.length})",
                    icon: Icons.list_rounded,
                    isActive: _sortFilter == ServiceSortFilter.all,
                    onTap: () => setState(() => _sortFilter = ServiceSortFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _SortFilterChip(
                    label: isAr ? "الأقرب إليك" : "Nearest",
                    icon: Icons.near_me_rounded,
                    isActive: _sortFilter == ServiceSortFilter.nearest,
                    onTap: () => setState(() => _sortFilter = ServiceSortFilter.nearest),
                  ),
                  const SizedBox(width: 8),
                  _SortFilterChip(
                    label: isAr ? "طابور سريع" : "Fastest Queue",
                    icon: Icons.bolt_rounded,
                    isActive: _sortFilter == ServiceSortFilter.fastestQueue,
                    onTap: () => setState(() => _sortFilter = ServiceSortFilter.fastestQueue),
                  ),
                  const SizedBox(width: 8),
                  _SortFilterChip(
                    label: isAr ? "الأعلى تقييماً" : "Top Rated",
                    icon: Icons.star_rounded,
                    isActive: _sortFilter == ServiceSortFilter.topRated,
                    onTap: () => setState(() => _sortFilter = ServiceSortFilter.topRated),
                  ),
                  const SizedBox(width: 8),
                  _SortFilterChip(
                    label: isAr ? "مفتوح الآن" : "Open Now",
                    icon: Icons.access_time_filled_rounded,
                    isActive: _sortFilter == ServiceSortFilter.openNow,
                    onTap: () => setState(() => _sortFilter = ServiceSortFilter.openNow),
                  ),
                ],
              ),
            ),
          ),

          // 4. Main Service Cards List
          Expanded(
            child: services.isEmpty
                ? _NoServices(
                    isAr: isAr,
                    onReset: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _sortFilter = ServiceSortFilter.all;
                        _category = null;
                      });
                    },
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      horizontal.left,
                      12,
                      horizontal.right,
                      32,
                    ),
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ServiceCardItem(
                      place: services[i],
                      isAr: isAr,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailsScreen(place: services[i]),
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

class _CategoryPillTabs extends StatelessWidget {
  const _CategoryPillTabs({
    required this.selected,
    required this.onChanged,
  });

  final ServiceCategory? selected;
  final ValueChanged<ServiceCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget chip({
      required String title,
      required IconData icon,
      required bool active,
      required VoidCallback onTap,
      Color? activeColor,
    }) {
      final color = activeColor ?? AppColors.ink;

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: active ? color : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? color : AppColors.gray200,
              width: 1.2,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: active ? AppColors.paper : AppColors.gray600,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: AppTextStyles.body(
                  color: active ? AppColors.paper : AppColors.ink,
                  weight: active ? FontWeight.w700 : FontWeight.w500,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          chip(
            title: l10n.filterAll,
            icon: Icons.grid_view_rounded,
            active: selected == null,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          chip(
            title: l10n.categoryClinics,
            icon: Icons.local_hospital_outlined,
            active: selected == ServiceCategory.clinics,
            activeColor: AppColors.teal,
            onTap: () => onChanged(ServiceCategory.clinics),
          ),
          const SizedBox(width: 8),
          chip(
            title: l10n.categorySalons,
            icon: Icons.content_cut_rounded,
            active: selected == ServiceCategory.salons,
            activeColor: AppColors.indigo,
            onTap: () => onChanged(ServiceCategory.salons),
          ),
          const SizedBox(width: 8),
          chip(
            title: l10n.categoryGarages,
            icon: Icons.car_repair_rounded,
            active: selected == ServiceCategory.garages,
            activeColor: AppColors.amber,
            onTap: () => onChanged(ServiceCategory.garages),
          ),
          const SizedBox(width: 8),
          chip(
            title: l10n.categoryOffices,
            icon: Icons.business_outlined,
            active: selected == ServiceCategory.offices,
            activeColor: AppColors.ink,
            onTap: () => onChanged(ServiceCategory.offices),
          ),
        ],
      ),
    );
  }
}

class _SortFilterChip extends StatelessWidget {
  const _SortFilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.ink : AppColors.paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.ink : AppColors.gray300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isActive ? AppColors.paper : AppColors.gray600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.label(
                color: isActive ? AppColors.paper : AppColors.gray700,
                weight: isActive ? FontWeight.w700 : FontWeight.w500,
                size: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCardItem extends StatelessWidget {
  const _ServiceCardItem({
    required this.place,
    required this.isAr,
    required this.onTap,
  });

  final ServicePlace place;
  final bool isAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final main = place.branches.first;
    final estimatedMinutes = (place.totalWaiting * 4).clamp(3, 90);
    final isOpen = place.branches.any((b) => b.isOpen);

    // Density badge styling
    final isFast = place.totalWaiting <= 3;
    final isModerate = place.totalWaiting > 3 && place.totalWaiting <= 6;
    final densityColor = isFast
        ? AppColors.success
        : (isModerate ? AppColors.amber : const Color(0xFFE11D48));

    final densityLabel = isFast
        ? (isAr ? "طابور سريع" : "Fast Queue")
        : (isModerate ? (isAr ? "طابور معتدل" : "Moderate") : (isAr ? "طابور نشط" : "Busy"));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Icon, Name, Star Rating, Verified)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: place.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: place.color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(place.icon, color: place.color, size: 26),
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
                                  place.localizedName(isAr),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading(size: 15.5),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.teal,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              // Star rating
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                              const SizedBox(width: 2),
                              Text(
                                place.starRating.toStringAsFixed(1),
                                style: AppTextStyles.label(
                                  color: AppColors.ink,
                                  weight: FontWeight.w700,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "•",
                                style: TextStyle(color: AppColors.gray400, fontSize: 10),
                              ),
                              const SizedBox(width: 6),
                              // Open / Closed
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isOpen ? AppColors.success : AppColors.gray400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOpen
                                    ? (isAr ? "مفتوح الآن" : "Open now")
                                    : (isAr ? "مغلق" : "Closed"),
                                style: AppTextStyles.label(
                                  color: isOpen ? AppColors.success : AppColors.gray500,
                                  weight: FontWeight.w600,
                                  size: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Address & Branch Count
                Text(
                  '${place.branches.length} ${isAr ? "فروع متاحة" : "branches"} • ${main.localizedAddress(isAr) ?? ""}',
                  style: AppTextStyles.body(
                    color: AppColors.gray600,
                    size: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.gray100),
                const SizedBox(height: 12),

                // Bottom Real-time Queue Indicator & CTA
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    // Queue Density Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: densityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_alt_rounded, size: 13, color: densityColor),
                          const SizedBox(width: 4),
                          Text(
                            '$densityLabel: ${l10n.peopleWaiting(place.totalWaiting)}',
                            style: AppTextStyles.label(
                              color: densityColor,
                              weight: FontWeight.w700,
                              size: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Wait Time
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 13, color: AppColors.gray500),
                        const SizedBox(width: 3),
                        Text(
                          '~$estimatedMinutes ${isAr ? "د" : "min"}',
                          style: AppTextStyles.label(
                            color: AppColors.gray600,
                            weight: FontWeight.w600,
                            size: 11.5,
                          ),
                        ),
                      ],
                    ),

                    // Distance and CTA Arrow
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (main.distanceKm != null) ...[
                          const Icon(Icons.near_me_rounded, size: 12, color: AppColors.teal),
                          const SizedBox(width: 3),
                          Text(
                            l10n.distanceAway(main.distanceKm!),
                            style: AppTextStyles.body(
                              color: AppColors.teal,
                              weight: FontWeight.w700,
                              size: 11.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.softTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.teal,
                            size: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoServices extends StatelessWidget {
  const _NoServices({
    required this.isAr,
    required this.onReset,
  });

  final bool isAr;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAr ? "لا توجد نتائج مطابقة للبحث" : "No matching services found",
              style: AppTextStyles.heading(size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? "جرب تغيير كلمات البحث أو إعادة ضبط الفلاتر لعرض الخدمات المتاحة"
                  : "Try different search terms or reset filters to see available services",
              textAlign: TextAlign.center,
              style: AppTextStyles.body(color: AppColors.gray500, size: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: AppColors.paper,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isAr ? "إعادة ضبط وعرض الكل" : "Reset & Show All",
                style: AppTextStyles.button(size: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}