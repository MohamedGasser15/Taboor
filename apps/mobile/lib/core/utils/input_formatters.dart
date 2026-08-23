// core/utils/input_formatters.dart
import 'package:flutter/services.dart';

/// Blocks Arabic letters + Arabic-Indic digits from being typed.
/// Allows Latin letters, Latin digits and symbols.
class LatinOnlyFormatter extends TextInputFormatter {
  const LatinOnlyFormatter();

  static final RegExp _arabicRe = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!_arabicRe.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}