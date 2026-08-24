// features/home/domain/service_place.dart
import 'package:flutter/material.dart';

/// A service category shown on the discovery feed.
enum ServiceCategory { clinics, salons, garages, offices }

/// A single branch of a service business.
class ServiceBranch {
  const ServiceBranch({
    required this.label,
    this.distanceKm,
    required this.waiting,
    required this.isOpen,
    this.address,
    this.lat,
    this.lng,
  });

  /// Localized branch label (e.g. "Main branch").
  final String label;
  final String? distanceKm;
  final int waiting;
  final bool isOpen;
  final String? address;

  /// Geo coordinates for the map view (Cairo, Egypt by default).
  final double? lat;
  final double? lng;
}

/// A business/service presented on the home feed.
class ServicePlace {
  const ServicePlace({
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
    required this.branches,
    this.about,
    this.workingHours,
    this.starRating = 4.5,
  });

  final String name;
  final IconData icon;
  final Color color;
  final ServiceCategory category;
  final List<ServiceBranch> branches;
  final String? about;
  final String? workingHours;
  final double starRating;

  int get totalWaiting =>
      branches.fold(0, (sum, b) => sum + b.waiting);
}