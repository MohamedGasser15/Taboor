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
import 'package:taboor/features/home/presentation/screens/qr_scanner_screen.dart';
import 'package:taboor/features/home/presentation/screens/service_details_screen.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// The customer discovery feed and real-time queue hub.
///
/// Features:
/// - Smart Location & Greeting Header
/// - Interactive Live Search & Category Filtering
/// - Real-Time Virtual Ticket Card with Smart Departure Alerts
/// - On-Site QR Scanner & Quick Actions (Fast Queues, Impact Stats)
/// - "Fast Queues Near You" Horizontal Highlights
/// - Local Business Feed with Live Waiting Counters
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, this.userName});

  final String? userName;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _location = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
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

  void _showQrScannerModal(bool isAr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.softTeal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.teal,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAr ? "مسح كود الفرع الذكي" : "Scan Branch QR Code",
              style: AppTextStyles.heading(size: 19),
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? "إذا كنت متواجداً الآن داخل الفرع، قم بمسح رمز الـ QR الموجود عند الاستقبال للانضمام للطابور فوراً وحفظ مكانك."
                  : "If you are currently inside the venue, scan the reception QR code to instantly join the real-time queue.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                color: AppColors.gray600,
                size: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QrScannerScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.paper,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: Text(
                  isAr ? "فتح الكاميرا للمسح" : "Open Camera",
                  style: AppTextStyles.button(size: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final name = widget.userName?.trim();
    final horizontal = AppResponsive.horizontalPadding(context);
    final topInset = MediaQuery.viewPaddingOf(context).top;

    // Filter places based on search query
    final allPlaces = ServiceRepository.places;
    final filteredPlaces = allPlaces.where((p) => p.matchesQuery(_searchQuery)).toList();

    // Places with fast queues (< 4 waiting)
    final fastPlaces = allPlaces.where((p) => p.totalWaiting <= 4).toList();

    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          // 1. Header (Greeting + User avatar + Location Chip)
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
                onQrTap: () => _showQrScannerModal(isAr),
              ),
            ),
          ),

          // 2. Search Bar & Quick Suggestion Pills
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              16,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _SearchBar(
                    controller: _searchController,
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                  if (_searchQuery.isEmpty) ...[
                    const SizedBox(height: 10),
                    _SearchSuggestionsRow(
                      isAr: isAr,
                      onSelect: (keyword) {
                        _searchController.text = keyword;
                        _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: keyword.length),
                        );
                        setState(() => _searchQuery = keyword);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 3. Hero Active Virtual Queue Ticket Card
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              18,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _LiveTicketCard(
                hasTicket: true,
                serviceName: isAr ? 'عيادة د. سارة للأسنان' : 'Dr. Sara Dental Clinic',
                branchName: isAr ? 'فرع وسط البلد' : 'Downtown Branch',
                ticketNumber: 'A-12',
                peopleAhead: 2,
                estimatedMinutes: 10,
                driveTimeMinutes: 7,
                isAr: isAr,
                onTap: () {
                  final dentalPlace = allPlaces.first;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailsScreen(place: dentalPlace),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Quick Action Highlights Bar (QR, Fast Queues, Impact Stat)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              16,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _QuickActionsRow(
                isAr: isAr,
                onScanQr: () => _showQrScannerModal(isAr),
                onFastQueuesTap: () => _openAll(null),
              ),
            ),
          ),

          // 5. Category Discovery Header
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
                    isAr ? "الخدمات والأنشطة" : "Browse Categories",
                    style: AppTextStyles.heading(size: 18),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.homeSeeAll,
                            style: AppTextStyles.body(
                              color: AppColors.teal,
                              weight: FontWeight.w700,
                              size: 13,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.teal,
                            size: 11,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Category Ultra-Lightweight Capsule Slider
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              10,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _CategoryPillChip(
                      icon: Icons.medical_services_rounded,
                      title: isAr ? "عيادات وأطباء" : "Clinics & Doctors",
                      color: AppColors.teal,
                      onTap: () => _openAll(ServiceCategory.clinics),
                    ),
                    const SizedBox(width: 8),
                    _CategoryPillChip(
                      icon: Icons.content_cut_rounded,
                      title: isAr ? "صالونات وتجميل" : "Salons & Barber",
                      color: AppColors.indigo,
                      onTap: () => _openAll(ServiceCategory.salons),
                    ),
                    const SizedBox(width: 8),
                    _CategoryPillChip(
                      icon: Icons.car_repair_rounded,
                      title: isAr ? "صيانة سيارات" : "Auto Repair",
                      color: AppColors.amber,
                      onTap: () => _openAll(ServiceCategory.garages),
                    ),
                    const SizedBox(width: 8),
                    _CategoryPillChip(
                      icon: Icons.business_outlined,
                      title: isAr ? "مصالح ومكاتب" : "Offices & Legal",
                      color: AppColors.ink,
                      onTap: () => _openAll(ServiceCategory.offices),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 7. "Fast Moving Queues" Live Highlights
          if (_searchQuery.isEmpty && fastPlaces.isNotEmpty) ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontal.left,
                24,
                horizontal.right,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? "طوابير سريعة الآن" : "Fast Queues Right Now",
                      style: AppTextStyles.heading(size: 17),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? "أقل من 10 د" : "< 10 min",
                            style: AppTextStyles.label(
                              color: AppColors.success,
                              weight: FontWeight.w700,
                              size: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontal.left,
                12,
                horizontal.right,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 142,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: fastPlaces.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => _FastQueueCard(
                      place: fastPlaces[i],
                      isAr: isAr,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 8. Main Discovery Section Header
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontal.left,
              24,
              horizontal.right,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    _searchQuery.isNotEmpty
                        ? (isAr ? "نتائج البحث" : "Search Results")
                        : l10n.homePopularNearYou,
                    style: AppTextStyles.heading(size: 18),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredPlaces.length} ${isAr ? "أماكن" : "places"}',
                    style: AppTextStyles.body(
                      color: AppColors.gray500,
                      size: 12.5,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 9. Main Businesses List
          if (filteredPlaces.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(32),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.gray400),
                      const SizedBox(height: 12),
                      Text(
                        isAr ? "لا توجد نتائج مطابقة لبحثك" : "No matching places found",
                        style: AppTextStyles.heading(size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontal.left,
                12,
                horizontal.right,
                80,
              ),
              sliver: SliverList.separated(
                itemCount: filteredPlaces.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _BusinessCard(place: filteredPlaces[i]),
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. Home Header
// ==========================================
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.userName,
    required this.location,
    required this.onQrTap,
  });

  final String greeting;
  final String? userName;
  final String location;
  final VoidCallback onQrTap;

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
        // User avatar with online status badge
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.teal, AppColors.deepTeal],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                initial,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.paper,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.paper, width: 2),
                ),
              ),
            ),
          ],
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
                  size: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading(size: 17),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _LocationChip(location: location),
        const SizedBox(width: 8),
        // QR Scanner Quick Launch
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onQrTap,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gray200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.teal,
              size: 20,
            ),
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
                  color: AppColors.teal, size: 15),
          const SizedBox(width: 4),
          Text(
            loading ? "..." : location,
            style: AppTextStyles.body(
              size: 12,
              weight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. Search Bar
// ==========================================
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isNotEmpty = controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body(
          color: AppColors.ink,
          weight: FontWeight.w500,
          size: 14.5,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).homeSearchHint,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gray500, size: 22),
          suffixIcon: isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.gray500, size: 18),
                  onPressed: onClear,
                )
              : Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.softTeal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.teal,
                    size: 18,
                  ),
                ),
          hintStyle: AppTextStyles.body(color: AppColors.gray400, size: 13.5),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.gray200.withValues(alpha: 0.6), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
          ),
        ),
      ),
    );
  }
}

class _SearchSuggestionsRow extends StatelessWidget {
  const _SearchSuggestionsRow({
    required this.isAr,
    required this.onSelect,
  });

  final bool isAr;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final suggestions = isAr
        ? [
            (Icons.medical_services_rounded, 'عيادة أسنان', 'اسنان', AppColors.teal),
            (Icons.content_cut_rounded, 'صالون حلاقة', 'حلاقة', AppColors.indigo),
            (Icons.car_repair_rounded, 'صيانة سيارات', 'سيارات', AppColors.amber),
            (Icons.visibility_rounded, 'ليزك وعيون', 'عيون', AppColors.teal),
            (Icons.business_outlined, 'استشارة قانونية', 'قانون', AppColors.ink),
          ]
        : [
            (Icons.medical_services_rounded, 'Dental Clinic', 'dental', AppColors.teal),
            (Icons.content_cut_rounded, 'Barber & Salon', 'salon', AppColors.indigo),
            (Icons.car_repair_rounded, 'Car Repair', 'auto', AppColors.amber),
            (Icons.visibility_rounded, 'Eye Clinic', 'eye', AppColors.teal),
            (Icons.business_outlined, 'Legal Office', 'legal', AppColors.ink),
          ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions.map((s) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(s.$1, size: 14, color: s.$4),
              label: Text(
                s.$2,
                style: AppTextStyles.label(
                  color: AppColors.ink,
                  size: 11.5,
                  weight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.paper,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.gray200, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              onPressed: () => onSelect(s.$3),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==========================================
// 3. Hero Active Virtual Queue Ticket Card
// ==========================================
class _LiveTicketCard extends StatelessWidget {
  const _LiveTicketCard({
    required this.hasTicket,
    required this.serviceName,
    required this.branchName,
    required this.ticketNumber,
    required this.peopleAhead,
    required this.estimatedMinutes,
    required this.driveTimeMinutes,
    required this.isAr,
    required this.onTap,
  });

  final bool hasTicket;
  final String serviceName;
  final String branchName;
  final String ticketNumber;
  final int peopleAhead;
  final int estimatedMinutes;
  final int driveTimeMinutes;
  final bool isAr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.ink,
                Color(0xFF0F5A67),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.25),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Live Sync Status + Ticket Number
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.paper.withValues(alpha: 0.15),
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
                          isAr ? "طابور نشط ومباشر" : "Live Queue Active",
                          style: AppTextStyles.label(
                            color: AppColors.paper,
                            weight: FontWeight.w700,
                            size: 11.5,
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
                        isAr ? "رقم التذكرة" : "Ticket No.",
                        style: AppTextStyles.label(
                          color: AppColors.gray300,
                          size: 11,
                        ),
                      ),
                      Text(
                        ticketNumber,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.paper,
                          height: 1.1,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Venue and Branch info
              Text(
                serviceName,
                style: AppTextStyles.heading(
                  size: 17,
                  color: AppColors.paper,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                branchName,
                style: AppTextStyles.body(
                  color: AppColors.gray300,
                  size: 12.5,
                ),
              ),
              const SizedBox(height: 16),

              // Queue Dynamics Counter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? "$peopleAhead أفراد قبلك" : "$peopleAhead people ahead",
                            style: AppTextStyles.body(
                              size: 14,
                              weight: FontWeight.w800,
                              color: AppColors.paper,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAr ? "~$estimatedMinutes دقيقة انتظار" : "~$estimatedMinutes min wait",
                            style: AppTextStyles.label(
                              size: 11,
                              color: AppColors.gray300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Smart Travel Alert Pill
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car_filled_rounded,
                                  color: AppColors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                isAr ? "تحرك الآن!" : "Head out now!",
                                style: AppTextStyles.body(
                                  size: 13,
                                  weight: FontWeight.w800,
                                  color: AppColors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAr ? "المسافة $driveTimeMinutes د بالسيارة" : "$driveTimeMinutes min drive",
                            style: AppTextStyles.label(
                              size: 11,
                              color: AppColors.paper,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Visual Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 6,
                  backgroundColor: AppColors.paper.withValues(alpha: 0.18),
                  valueColor: const AlwaysStoppedAnimation(AppColors.amber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. Quick Actions Bar
// ==========================================
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.isAr,
    required this.onScanQr,
    required this.onFastQueuesTap,
  });

  final bool isAr;
  final VoidCallback onScanQr;
  final VoidCallback onFastQueuesTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Action 1: On-Site QR Scanner
        Expanded(
          child: _ActionPill(
            icon: Icons.qr_code_scanner_rounded,
            title: isAr ? "مسح كود الفرع" : "Scan QR Code",
            subtitle: isAr ? "للدخول الفوري" : "Walk-in join",
            accentColor: AppColors.teal,
            onTap: onScanQr,
          ),
        ),
        const SizedBox(width: 10),
        // Action 2: Time Saved Impact
        Expanded(
          child: _ActionPill(
            icon: Icons.hourglass_bottom_rounded,
            title: isAr ? "وفرت 4.5 س" : "Saved 4.5 hrs",
            subtitle: isAr ? "من وقت الانتظار" : "Total time saved",
            accentColor: AppColors.indigo,
            onTap: onFastQueuesTap,
          ),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        weight: FontWeight.w700,
                        size: 13,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label(
                        size: 10.5,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPillChip extends StatelessWidget {
  const _CategoryPillChip({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.gray200,
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body(
                  color: AppColors.ink,
                  weight: FontWeight.w700,
                  size: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. Fast Moving Queues Highlights Card
// ==========================================
class _FastQueueCard extends StatelessWidget {
  const _FastQueueCard({
    required this.place,
    required this.isAr,
  });

  final ServicePlace place;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final branch = place.branches.first;
    final estimatedMinutes = (place.totalWaiting * 3.5).round().clamp(2, 10);

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
          width: 250,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon + Name + Star & Distance
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: place.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(place.icon, color: place.color, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.localizedName(isAr),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading(size: 13.5),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: AppColors.amber),
                            const SizedBox(width: 2),
                            Text(
                              place.starRating.toStringAsFixed(1),
                              style: AppTextStyles.label(
                                size: 11,
                                color: AppColors.ink,
                                weight: FontWeight.w700,
                              ),
                            ),
                            if (branch.distanceKm != null) ...[
                              const SizedBox(width: 5),
                              Text("•", style: TextStyle(color: AppColors.gray400, fontSize: 8)),
                              const SizedBox(width: 5),
                              Text(
                                "${branch.distanceKm} ${isAr ? "كم" : "km"}",
                                style: AppTextStyles.label(
                                  size: 11,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom Row: Live wait pill + Action button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fast queue status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 13, color: AppColors.success),
                        const SizedBox(width: 2),
                        Text(
                          isAr ? "~$estimatedMinutes د • ${place.totalWaiting} قبلك" : "~$estimatedMinutes min • ${place.totalWaiting} ahead",
                          style: AppTextStyles.label(
                            size: 10.5,
                            color: AppColors.success,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Join CTA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isAr ? "احجز دورك" : "Join",
                          style: AppTextStyles.label(
                            size: 11,
                            color: AppColors.paper,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.paper,
                          size: 9,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. Business Listing Card
// ==========================================
class _BusinessCard extends StatelessWidget {
  const _BusinessCard({required this.place});

  final ServicePlace place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gray200.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: place.color.withValues(alpha: 0.08),
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
                      place.localizedName(isAr),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading(size: 15.5),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (mainBranch.distanceKm != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppColors.gray500,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                l10n.distanceAway(mainBranch.distanceKm!),
                                style: AppTextStyles.body(
                                  color: AppColors.gray600,
                                  size: 11.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "•",
                            style: TextStyle(
                              color: AppColors.gray400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                size: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  l10n.joinNow,
                  style: AppTextStyles.body(
                    color: AppColors.paper,
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