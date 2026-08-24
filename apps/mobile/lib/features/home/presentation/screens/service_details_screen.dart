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
    // Auto-locate on entry so the user sees their blue dot right away.
    WidgetsBinding.instance.addPostFrameCallback((_) => _locateMe());
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
    final withCoords =
        _place.branches.where((b) => b.lat != null && b.lng != null).toList();
    if (withCoords.isEmpty) return const LatLng(30.0444, 31.2357);
    final lat = withCoords.map((b) => b.lat!).reduce((a, b) => a + b) /
        withCoords.length;
    final lng = withCoords.map((b) => b.lng!).reduce((a, b) => a + b) /
        withCoords.length;
    return LatLng(lat, lng);
  }

  Future<void> _addBranchPins() async {
    final controller = _controller;
    if (controller == null) return;

    // Numbered branch pins.
    for (var i = 0; i < _place.branches.length; i++) {
      final b = _place.branches[i];
      if (b.lat == null || b.lng == null) continue;

      // Render a small numbered circle as a PNG so the symbol shows a pin.
      final bytes = await _renderPinBytes(i + 1);
      await controller.addImage('branch_pin_$i', bytes);

      await controller.addSymbol(
        SymbolOptions(
          geometry: LatLng(b.lat!, b.lng!),
          iconImage: 'branch_pin_$i',
          iconSize: 0.32,
          iconAnchor: 'center',
        ),
      );
    }
  }

  Future<Uint8List> _renderPinBytes(int number) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 64.0;
    final color = _place.color;

    // Outer white ring.
    canvas.drawCircle(
      const Offset(32, 32),
      30,
      Paint()..color = Colors.white,
    );
    // Filled colored circle.
    canvas.drawCircle(
      const Offset(32, 32),
      26,
      Paint()..color = color,
    );
    // Number.
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(32 - textPainter.width / 2, 32 - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
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
                zoom: 13,
              ),
              onMapCreated: (controller) => _controller = controller,
              onStyleLoadedCallback: _addBranchPins,
              styleString: _kMapStyleExplore,
              myLocationEnabled: true,
              myLocationRenderMode: MyLocationRenderMode.normal,
              myLocationTrackingMode: MyLocationTrackingMode.tracking,
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
            snapSizes: const [0.42, 0.62, 0.85],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepTeal,
                      blurRadius: 30,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.gray300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          18,
                          20,
                          MediaQuery.of(context).padding.bottom + 12,
                        ),
                        children: [
                          Text(
                            place.name,
                            style: AppTextStyles.heading(
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.serviceWaitingNow(place.totalWaiting)} • '
                            '${place.branches.length} ${l10n.serviceBranches}',
                            style: AppTextStyles.body(
                              color: AppColors.gray600,
                              size: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.serviceChooseBranch,
                            style: AppTextStyles.heading(size: 16),
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
                            const SizedBox(height: 20),
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
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded,
                                    color: AppColors.teal, size: 18),
                                const SizedBox(width: 8),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.08) : AppColors.gray100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent : AppColors.gray200,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header: icon + name + status + radio =====
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected ? accent : AppColors.softTeal,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      index == 0
                          ? Icons.storefront_rounded
                          : Icons.store_mall_directory_rounded,
                      color: selected ? AppColors.paper : accent,
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
                            size: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              branch.isOpen
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 13,
                              color: branch.isOpen
                                  ? AppColors.success
                                  : AppColors.gray400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              branch.isOpen
                                  ? l10n.serviceOpenNow
                                  : l10n.serviceClosed,
                              style: AppTextStyles.body(
                                color: branch.isOpen
                                    ? AppColors.success
                                    : AppColors.gray500,
                                size: 12,
                                weight: FontWeight.w500,
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
              const SizedBox(height: 10),

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
                    icon: Icons.groups_rounded,
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
              const SizedBox(height: 10),

              // ===== Footer: waiting time + maps button =====
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.queueMinutes(branch.waiting * 4),
                          style: AppTextStyles.body(
                            color: accent,
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
                          horizontal: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.teal.withValues(alpha: 0.1)
            : AppColors.paper,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: highlight ? AppColors.teal : AppColors.gray200,
          width: highlight ? 1.2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: highlight ? AppColors.teal : AppColors.gray500),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(
                color: highlight ? AppColors.teal : AppColors.gray600,
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