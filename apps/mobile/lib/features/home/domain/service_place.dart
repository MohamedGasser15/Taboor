// features/home/domain/service_place.dart
import 'package:flutter/material.dart';

/// A service category shown on the discovery feed.
enum ServiceCategory { clinics, salons, garages, offices }

/// A single branch of a service business.
class ServiceBranch {
  const ServiceBranch({
    required this.label,
    this.labelAr,
    this.distanceKm,
    required this.waiting,
    required this.isOpen,
    this.address,
    this.addressAr,
    this.lat,
    this.lng,
  });

  /// Localized branch label (e.g. "Main branch").
  final String label;
  final String? labelAr;
  final String? distanceKm;
  final int waiting;
  final bool isOpen;
  final String? address;
  final String? addressAr;

  /// Geo coordinates for the map view (Cairo, Egypt by default).
  final double? lat;
  final double? lng;

  String localizedLabel(bool isAr) => (isAr && labelAr != null) ? labelAr! : label;
  String? localizedAddress(bool isAr) => (isAr && addressAr != null) ? addressAr! : address;
}

/// A business/service presented on the home feed.
class ServicePlace {
  const ServicePlace({
    required this.name,
    this.nameAr,
    required this.icon,
    required this.color,
    required this.category,
    required this.branches,
    this.about,
    this.aboutAr,
    this.workingHours,
    this.starRating = 4.5,
    this.keywords = const [],
  });

  final String name;
  final String? nameAr;
  final IconData icon;
  final Color color;
  final ServiceCategory category;
  final List<ServiceBranch> branches;
  final String? about;
  final String? aboutAr;
  final String? workingHours;
  final double starRating;
  final List<String> keywords;

  int get totalWaiting =>
      branches.fold(0, (sum, b) => sum + b.waiting);

  String localizedName(bool isAr) => (isAr && nameAr != null) ? nameAr! : name;
  String? localizedAbout(bool isAr) => (isAr && aboutAr != null) ? aboutAr! : about;

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.trim().toLowerCase();
    if (name.toLowerCase().contains(q)) return true;
    if (nameAr != null && nameAr!.toLowerCase().contains(q)) return true;
    if (about != null && about!.toLowerCase().contains(q)) return true;
    if (aboutAr != null && aboutAr!.toLowerCase().contains(q)) return true;
    if (keywords.any((k) => k.toLowerCase().contains(q))) return true;
    if (branches.any((b) =>
        b.label.toLowerCase().contains(q) ||
        (b.labelAr != null && b.labelAr!.toLowerCase().contains(q)) ||
        (b.address != null && b.address!.toLowerCase().contains(q)) ||
        (b.addressAr != null && b.addressAr!.toLowerCase().contains(q)))) {
      return true;
    }
    return false;
  }
}