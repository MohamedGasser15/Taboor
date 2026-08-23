// core/services/locale_service.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/constants/app_constants.dart';
import 'package:taboor/core/utils/shared_prefs.dart';

class LocaleService {
  LocaleService._();

  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(_defaultLocale());

  static Locale _defaultLocale() {
    final saved = SharedPrefs.getStringValue(AppConstants.appLanguageKey);
    if (saved != null) {
      return Locale(saved);
    }
    return const Locale(AppConstants.arabic);
  }

  static Locale get currentLocale => localeNotifier.value;

  static bool get isArabic => currentLocale.languageCode == AppConstants.arabic;

  static Future<void> setLocale(Locale locale) async {
    if (localeNotifier.value == locale) return;
    localeNotifier.value = locale;
    await SharedPrefs.setString(
      AppConstants.appLanguageKey,
      locale.languageCode,
    );
  }

  static Future<void> toggle() async {
    final next = isArabic
        ? const Locale(AppConstants.english)
        : const Locale(AppConstants.arabic);
    await setLocale(next);
  }
}