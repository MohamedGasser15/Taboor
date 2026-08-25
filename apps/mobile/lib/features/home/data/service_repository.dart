// features/home/data/service_repository.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/features/home/domain/service_place.dart';

/// Static in-memory catalog of services. Replace with the real backend later.
class ServiceRepository {
  ServiceRepository._();

  static final List<ServicePlace> places = _build();

  static List<ServicePlace> _build() {
    return [
      ServicePlace(
        name: 'Dr. Sara Dental Clinic',
        icon: Icons.medical_services_rounded,
        color: AppColors.teal,
        category: ServiceCategory.clinics,
        starRating: 4.8,
        about:
            'A modern dental clinic offering checkups, braces and whitening with a friendly queue system so you never wait long.',
        workingHours: '9:00 AM – 9:00 PM',
        branches: [
          ServiceBranch(
            label: 'branchMain',
            distanceKm: '0.8',
            waiting: 4,
            isOpen: true,
            lat: 30.0525,
            lng: 31.2408,
          ),
          ServiceBranch(
            label: 'branchDowntown',
            distanceKm: '1.9',
            waiting: 2,
            isOpen: true,
            lat: 30.0501,
            lng: 31.2426,
          ),
        ],
      ),
      ServicePlace(
        name: 'Cairo Fix Auto',
        icon: Icons.car_repair_rounded,
        color: AppColors.amber,
        category: ServiceCategory.garages,
        starRating: 4.2,
        about:
            'Rapid car maintenance and diagnostics. Book your slot, drop the keys, and pick the car when your turn arrives.',
        workingHours: '8:00 AM – 8:00 PM',
        branches: [
          ServiceBranch(
            label: 'branchMain',
            distanceKm: '1.5',
            waiting: 7,
            isOpen: true,
            lat: 30.0672,
            lng: 31.2358,
          ),
          ServiceBranch(
            label: 'branchNorth',
            distanceKm: '2.8',
            waiting: 5,
            isOpen: true,
            lat: 30.0894,
            lng: 31.2421,
          ),
          ServiceBranch(
            label: 'branchAirport',
            distanceKm: '6.2',
            waiting: 1,
            isOpen: false,
            lat: 30.1219,
            lng: 31.4056,
          ),
        ],
      ),
      ServicePlace(
        name: 'Mirror Salon',
        icon: Icons.content_cut_rounded,
        color: AppColors.indigo,
        category: ServiceCategory.salons,
        starRating: 4.6,
        about:
            'Hair, nails and skincare in a calm place. Check the live queue and arrive exactly on time.',
        workingHours: '10:00 AM – 11:00 PM',
        branches: [
          ServiceBranch(
            label: 'branchMain',
            distanceKm: '0.4',
            waiting: 2,
            isOpen: true,
            lat: 30.0584,
            lng: 31.2341,
          ),
          ServiceBranch(
            label: 'branchWest',
            distanceKm: '3.1',
            waiting: 3,
            isOpen: true,
            lat: 30.0375,
            lng: 31.2135,
          ),
        ],
      ),
      ServicePlace(
        name: 'New Cairo Eye Clinic',
        icon: Icons.visibility_rounded,
        color: AppColors.teal,
        category: ServiceCategory.clinics,
        starRating: 4.4,
        about: 'Eye examinations, glasses fitting and laser consultations.',
        workingHours: '9:00 AM – 7:00 PM',
        branches: [
          ServiceBranch(
            label: 'branchMain',
            distanceKm: '2.1',
            waiting: 1,
            isOpen: true,
            lat: 30.0187,
            lng: 31.4725,
          ),
        ],
      ),
      ServicePlace(
        name: 'Downtown Law Office',
        icon: Icons.business_outlined,
        color: AppColors.ink,
        category: ServiceCategory.offices,
        starRating: 4.1,
        about:
            'Notary services, contracts and legal consultations over a short and predictable queue.',
        workingHours: '10:00 AM – 6:00 PM',
        branches: [
          ServiceBranch(
            label: 'branchDowntown',
            distanceKm: '3.0',
            waiting: 3,
            isOpen: true,
            lat: 30.0477,
            lng: 31.2316,
          ),
        ],
      ),
      ServicePlace(
        name: 'Glow Beauty Salon',
        icon: Icons.face_retouching_natural_rounded,
        color: AppColors.indigo,
        category: ServiceCategory.salons,
        starRating: 4.7,
        about: 'Makeup, lashes and skincare packages for every occasion.',
        workingHours: '11:00 AM – 11:00 PM',
        branches: [
          ServiceBranch(
            label: 'branchMain',
            distanceKm: '1.2',
            waiting: 5,
            isOpen: true,
            lat: 30.0646,
            lng: 31.2601,
          ),
          ServiceBranch(
            label: 'branchWest',
            distanceKm: '4.0',
            waiting: 0,
            isOpen: false,
            lat: 30.0311,
            lng: 31.2037,
          ),
        ],
      ),
    ];
  }
}