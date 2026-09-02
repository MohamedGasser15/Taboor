// features/home/presentation/screens/service_details_screen.dart
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:taboor/core/services/location_service.dart';
import 'package:taboor/core/services/message_service.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/features/home/domain/service_place.dart';
import 'package:taboor/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Vector map styles (see https://github.com/CartoDB/basemap-styles).
const String _kMapStyleExplore =
    'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json';

/// Full details of a service with branch selection.
///
/// Uses MapLibre (native native tiles + built-in user location dot) and OSRM
/// for driving directions, wrapped in a ride-hailing style bottom sheet.
class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key, required this.place});

  final ServicePlace place;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  int _selectedBranch = 0;
  bool _joining = false;
  bool _locating = false;
  MapLibreMapController? _controller;

  Position? _userPosition;

  ServicePlace get _place => widget.place;
  ServiceBranch get _branch => _place.branches[_selectedBranch];

  @override
  void initState() {
    super.initState();
    // Deliberately do NOT auto-locate: keep the map on the primary branch.
  }

  String _branchLabel(AppLocalizations l10n, String key) {
    return switch (key) {
      'branchMain' => l10n.branchMain,
      'branchDowntown' => l10n.branchDowntown,
      'branchNorth' => l10n.branchNorth,
      'branchAirport' => l10n.branchAirport,
      'branchWest' => l10n.branchWest,
      _ => key,
    };
  }

  void _select(int index) {
    setState(() => _selectedBranch = index);
    final b = _place.branches[index];
    if (b.lat != null && b.lng != null) {
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(b.lat!, b.lng!), 15),
      );
    }
  }

  Future<void> _joinQueue() async {
    if (_joining) return;
    setState(() => _joining = true);
    final l10n = AppLocalizations.of(context);

    // TODO: replace with the real queue-join API once available.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _joining = false);
    MessageService.showSuccess(
      context: context,
      message:
          '${_place.name} (${_branchLabel(l10n, _branch.label)}) — ${l10n.serviceJoinQueue}',
    );
  }

  Future<void> _locateMe({bool showMessage = true}) async {
    if (_locating) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _locating = true);

    Position? position;
    try {
      position = await LocationService.getCurrentPosition();
    } catch (_) {
      position = null;
    }
    if (!mounted) return;
    setState(() {
      _locating = false;
      _userPosition = position;
    });

    if (position == null) {
      if (showMessage) {
        MessageService.showWarning(
          context: context,
          message: l10n.mapLocationUnavailable,
        );
      }
      return;
    }

    // Centre on the user. (Maplibre draws the native blue dot itself.)
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        _branch.lat != null ? 14 : 16,
      ),
    );
  }

  Future<void> _openInGoogleMaps() async {
    final branch = _branch;
    if (branch.lat == null || branch.lng == null) return;

    // Full-precision coordinates (6 decimals) — always send numbers, never names.
    final lat = branch.lat!.toStringAsFixed(6);
    final lng = branch.lng!.toStringAsFixed(6);

    if (_isApplePlatform) {
      final uri = _userPosition != null
          ? Uri.parse(
              'https://maps.apple.com/?saddr='
              '${_userPosition!.latitude.toStringAsFixed(6)},'
              '${_userPosition!.longitude.toStringAsFixed(6)}'
              '&daddr=$lat,$lng&dirflg=d',
            )
          : Uri.parse(
              'https://maps.apple.com/?ll=$lat,$lng&q=$lat,$lng',
            );
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      return;
    }

    // Google Maps (Android / others).
    final uri = _userPosition != null
        ? Uri.parse(
            'https://www.google.com/maps/dir/?api=1&origin='
            '${_userPosition!.latitude.toStringAsFixed(6)},'
            '${_userPosition!.longitude.toStringAsFixed(6)}'
            '&destination=$lat,$lng'
            '&travelmode=driving',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
          );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  bool get _isApplePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  LatLng get _initialCenter {
    // Open on the primary (first) branch — not the average of everything.
    final primary = _place.branches.firstOrNull;
    if (primary?.lat == null || primary?.lng == null) {
      final any = _place.branches
          .where((b) => b.lat != null && b.lng != null)
          .firstOrNull;
      if (any != null) return LatLng(any.lat!, any.lng!);
      return const LatLng(30.0444, 31.2357);
    }
    return LatLng(primary!.lat!, primary.lng!);
  }
Future<void> _addBranchPins() async {
  final controller = _controller;
  if (controller == null) return;
  final l10n = AppLocalizations.of(context);

  for (var i = 0; i < _place.branches.length; i++) {
    final b = _place.branches[i];
    if (b.lat == null || b.lng == null) continue;

    final bytes = await _renderPinBytes(i + 1);
    await controller.addImage('branch_pin_$i', bytes);

    final branchName = _branchLabel(l10n, b.label);

    await controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(b.lat!, b.lng!),
        iconImage: 'branch_pin_$i',
        iconSize: 1.8,
        iconAnchor: 'bottom',
        
        // ===== النص عسى يمين الدبوس بمسافة قريبة جداً =====
        textField: branchName,
        textSize: 13.0,
        textColor: '#000000',
        textHaloColor: '#FFFFFF',
        textHaloWidth: 1.5,
        textAnchor: 'top', // يبدأ النص من يساره ممتداً لليمين
        textOffset: const Offset(0, -1), // إزاحة خفيفة بين النص والدبوس
        fontNames: ['Open Sans Bold', 'Arial Unicode MS Bold'],
      ),
    );
  }
}

  Future<Uint8List> _renderPinBytes(int number) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const double width = 110.0;
    const double height = 140.0;
    final pinColor = _place.color;

    // 1. الظل الأسفل (Shadow)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(width / 2, height - 12),
        width: 40.0,
        height: 12.0,
      ),
      shadowPaint,
    );

    const double circleRadius = 40.0;
    const Offset circleCenter = Offset(width / 2, circleRadius + 10);
    const double triangleHeight = 65.0;

    // 2. إنشاء المسارات الدائرية والمثلثة
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: circleCenter, radius: circleRadius));

    final trianglePath = Path()
      ..moveTo(circleCenter.dx - 36.5, circleCenter.dy + 15)
      ..lineTo(width / 2, circleCenter.dy + triangleHeight)
      ..lineTo(circleCenter.dx + 36.5, circleCenter.dy + 15)
      ..close();

    // دمج المسارين في شكل واحد ممتد لإلغاء أي خطوط تقاطع نهائياً
    final unifiedPinPath = Path.combine(
      PathOperation.union,
      circlePath,
      trianglePath,
    );

    // 3. رسم الدبوس المدمج قطعة واحدة
    final markerPaint = Paint()
      ..color = pinColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(unifiedPinPath, markerPaint);

    // 4. إطار ناعم خارجي فقط حول الشكل المدمج (اختياري للشكل الإحترافي)
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
    canvas.drawPath(unifiedPinPath, borderPaint);

    // 5. الدائرة البيضاء الداخلية (Badge)
    final whiteBadgePaint = Paint()
      ..color = AppColors.paper
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(circleCenter, 20.0, whiteBadgePaint);

    // 6. كتابة الرقم بلون الـ Teal
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: pinColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - textPainter.width / 2,
        circleCenter.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
  void _onUserLocationUpdated(UserLocation location) {
    if (mounted) {
      setState(() {
        _userPosition = Position(
          latitude: location.position.latitude,
          longitude: location.position.longitude,
          timestamp: DateTime.now(),
          accuracy: location.horizontalAccuracy ?? 0,
          altitude: location.altitude ?? 0,
          heading: location.heading?.trueHeading ?? 0,
          speed: location.speed ?? 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: location.horizontalAccuracy ?? 0,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final place = _place;
    final isTablet = AppResponsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.deepTeal,
      body: Stack(
        children: [
          // ===== Full-bleed MapLibre map with native user-location dot =====
          Positioned.fill(
            child: MapLibreMap(
              initialCameraPosition: CameraPosition(
                target: _initialCenter,
                zoom: 15.2,
              ),
              onMapCreated: (controller) => _controller = controller,
              onStyleLoadedCallback: _addBranchPins,
              styleString: _kMapStyleExplore,
              myLocationEnabled: true,
              myLocationRenderMode: MyLocationRenderMode.normal,
              // Keep the map centred on the branch; only show the blue dot
              // without auto-tracking the user's position.
              myLocationTrackingMode: MyLocationTrackingMode.none,
              onUserLocationUpdated: _onUserLocationUpdated,
              compassEnabled: true,
              logoEnabled: true,
            ),
          ),

          // Floating zoom controls (bottom-right, above the sheet).
          Positioned(
            right: 16,
            bottom: 320,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  _MapZoomButton(
                    icon: Icons.add_rounded,
                    onTap: () => _controller?.animateCamera(
                      CameraUpdate.zoomIn(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MapZoomButton(
                    icon: Icons.remove_rounded,
                    onTap: () => _controller?.animateCamera(
                      CameraUpdate.zoomOut(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MapZoomButton(
                    icon: _locating
                        ? Icons.linear_scale_rounded
                        : Icons.my_location_rounded,
                    isLoading: _locating,
                    onTap: _locateMe,
                  ),
                ],
              ),
            ),
          ),

          // Close button.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Material(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== Bottom sheet with branch cards =====
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.28,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.42],
            snapAnimationDuration: const Duration(milliseconds: 150),
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    // Soft neutral elevation; no colored tint.
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, -6),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(context).padding.bottom + 12,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.gray300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ===== Sheet header: service icon + name =====
                    Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: place.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  place.icon,
                                  color: place.color,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.name,
                                      style: AppTextStyles.heading(
                                        size: isTablet ? 22 : 18,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${l10n.serviceWaitingNow(place.totalWaiting)} • '
                                      '${place.branches.length} ${l10n.serviceBranches}',
                                      style: AppTextStyles.body(
                                        color: AppColors.gray600,
                                        size: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // ===== Choose a branch label + counter =====
                          Row(
                            children: [
                              Text(
                                l10n.serviceChooseBranch,
                                style: AppTextStyles.heading(size: 16),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.softTeal,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  '${_selectedBranch + 1} / '
                                  '${place.branches.length}',
                                  style: AppTextStyles.label(
                                    color: AppColors.teal,
                                    weight: FontWeight.w800,
                                    size: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < place.branches.length; i++) ...[
                            _BranchCard(
                              branch: place.branches[i],
                              index: i,
                              selected: i == _selectedBranch,
                              label:
                                  _branchLabel(l10n, place.branches[i].label),
                              accent: place.color,
                              userPosition: _userPosition,
                              isApple: _isApplePlatform,
                              onTap: () => _select(i),
                              onOpenMaps: _openInGoogleMaps,
                            ),
                            if (i < place.branches.length - 1)
                              const SizedBox(height: 8),
                          ],
                          if (place.about != null) ...[
                            const _SheetDivider(),
                            const SizedBox(height: 18),
                            Text(
                              l10n.serviceAbout,
                              style: AppTextStyles.heading(size: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              place.about!,
                              style: AppTextStyles.body(
                                color: AppColors.gray700,
                                size: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                          if (place.workingHours != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.softTeal.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.paper,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.schedule_rounded,
                                      color: AppColors.teal,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.serviceWorkingHours,
                                        style: AppTextStyles.label(
                                          color: AppColors.gray500,
                                          size: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        place.workingHours!,
                                        style: AppTextStyles.body(
                                          color: AppColors.ink,
                                          weight: FontWeight.w600,
                                          size: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _joining ? null : _joinQueue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                foregroundColor: AppColors.paper,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: _joining
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.paper,
                                      ),
                                    )
                                  : const Icon(Icons.add_rounded, size: 20),
                              label: Text(
                                '${l10n.serviceJoinQueue} '
                                '(${_branchLabel(l10n, _branch.label)})',
                                style: AppTextStyles.button(size: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}

/// A branch card inside the ride-hailing style bottom sheet.
class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.index,
    required this.selected,
    required this.label,
    required this.accent,
    required this.onTap,
    required this.onOpenMaps,
    this.userPosition,
    this.isApple = false,
  });

  final ServiceBranch branch;
  final int index;
  final bool selected;
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onOpenMaps;

  /// Current device position (null until "Locate me" is tapped).
  final Position? userPosition;

  /// True on iOS/macOS → show "Apple Maps" label and use Apple Maps scheme.
  final bool isApple;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasUser = userPosition != null;
    final dist = hasUser && branch.lat != null && branch.lng != null
        ? LocationService.distanceKm(
            userPosition!.latitude,
            userPosition!.longitude,
            branch.lat!,
            branch.lng!,
          )
        : null;
    final driveTime =
        dist != null ? LocationService.estimateDriveTime(dist) : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.04) : AppColors.paper,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent : AppColors.gray200.withValues(alpha: 0.8),
              width: selected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header: icon + name + status + radio =====
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected ? accent.withValues(alpha: 0.12) : AppColors.gray100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      index == 0
                          ? Icons.storefront_rounded
                          : Icons.store_mall_directory_rounded,
                      color: selected ? accent : AppColors.gray600,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(
                            color: AppColors.ink,
                            weight: FontWeight.w700,
                            size: 14.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: branch.isOpen
                                    ? AppColors.success
                                    : AppColors.gray400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              branch.isOpen
                                  ? l10n.serviceOpenNow
                                  : l10n.serviceClosed,
                              style: AppTextStyles.body(
                                color: branch.isOpen
                                    ? AppColors.success
                                    : AppColors.gray500,
                                size: 11.5,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: selected ? accent : AppColors.gray300,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Info chips: distance, waiting, drive time =====
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    text: branch.distanceKm != null
                        ? l10n.distanceAway(branch.distanceKm!)
                        : '',
                    visible: branch.distanceKm != null,
                  ),
                  _InfoChip(
                    icon: Icons.groups_outlined,
                    text: l10n.peopleWaiting(branch.waiting),
                    visible: true,
                  ),
                  if (dist != null)
                    _InfoChip(
                      icon: Icons.directions_car_filled_rounded,
                      text:
                          '${l10n.mapDistanceAway(dist.toStringAsFixed(1))} • '
                          '${l10n.mapDriveTime(driveTime!.inMinutes)}',
                      visible: true,
                      highlight: true,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Footer: waiting time + maps button =====
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? accent.withValues(alpha: 0.1) : AppColors.gray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.queueMinutes(branch.waiting * 4),
                          style: AppTextStyles.body(
                            color: selected ? accent : AppColors.ink,
                            weight: FontWeight.w800,
                            size: 15,
                          ),
                        ),
                        Text(
                          l10n.serviceEstWait,
                          style: AppTextStyles.label(
                            color: AppColors.gray500,
                            size: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (branch.lat != null && branch.lng != null)
                    GestureDetector(
                      onTap: onOpenMaps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.navigation_rounded,
                                color: AppColors.paper, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              isApple
                                  ? l10n.mapOpenInAppleMaps
                                  : l10n.mapOpenInGoogleMaps,
                              style: AppTextStyles.body(
                                color: AppColors.paper,
                                weight: FontWeight.w700,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
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

/// A light divider used to separate sheet sections.
class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.gray200,
    );
  }
}

/// Small pill used inside a branch card (distance / waiting / drive time).
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
    required this.visible,
    this.highlight = false,
  });

  final IconData icon;
  final String text;
  final bool visible;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    if (!visible || text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.teal.withValues(alpha: 0.12)
            : AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: highlight ? AppColors.teal : AppColors.gray600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(
                color: highlight ? AppColors.teal : AppColors.gray700,
                size: 11,
                weight: highlight ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A round floating map control button (zoom in / zoom out / recenter).
class _MapZoomButton extends StatelessWidget {
  const _MapZoomButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLoading ? null : onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.all(13),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.teal,
                  ),
                )
              : Icon(icon, color: AppColors.ink, size: 22),
        ),
      ),
    );
  }
}