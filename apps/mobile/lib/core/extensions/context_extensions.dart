// core/extensions/context_extensions.dart
import 'package:flutter/material.dart';

extension LocalizationExtension on BuildContext {
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}