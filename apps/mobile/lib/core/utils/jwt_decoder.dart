// core/utils/jwt_decoder.dart
import 'dart:convert';

/// Minimal JWT payload decoder (no signature validation).
class JwtDecoder {
  static DateTime? getExpiry(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;

    final payloadPart = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    final padded = payloadPart.padRight(
      payloadPart.length + ((4 - payloadPart.length % 4) % 4),
      '=',
    );

    try {
      final decoded = utf8.decode(base64.decode(padded));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = json['exp'];
      if (exp is int) return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      if (exp is String) return DateTime.tryParse(exp);
      return null;
    } catch (_) {
      return null;
    }
  }

  static bool isExpired(String? token, {DateTime? now}) {
    final expiry = getExpiry(token);
    if (expiry == null) return false;
    return expiry.isBefore(now ?? DateTime.now());
  }
}