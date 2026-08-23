// core/services/session_manager.dart
import 'dart:convert';

import 'package:taboor/core/utils/jwt_decoder.dart';
import 'package:taboor/core/utils/shared_prefs.dart';
import 'package:taboor/features/auth/data/auth_api.dart';
import 'package:taboor/features/auth/data/auth_models.dart';

/// Manages the persisted auth session (token + refresh token + user).
class SessionManager {
  SessionManager._();
  static final _api = AuthApi();

  static Future<void> saveLogin(LoginResponse response) async {
    final token = response.token;
    final refresh = response.refreshToken;
    if (token != null) await SharedPrefs.setAuthToken(token);
    if (refresh != null) await SharedPrefs.setRefreshToken(refresh);
    if (response.user != null) {
      await SharedPrefs.setUserData(jsonEncode({
        'id': response.user!.id,
        'fullName': response.user!.fullName,
        'email': response.user!.email,
        'phoneNumber': response.user!.phoneNumber,
        'preferredLanguage': response.user!.preferredLanguage,
        'role': response.user!.role,
      }));
    }
  }

  static Future<User?> getUser() async {
    final raw = await SharedPrefs.getUserData();
    if (raw == null || raw.isEmpty) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Returns true when there is a usable session (access token present).
  static Future<bool> hasSession() async {
    final token = await SharedPrefs.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Tries to restore the session. Returns true when logged in.
  /// If the access token expired, attempts a refresh; if the refresh
  /// also fails the session is cleared.
  static Future<bool> restore() async {
    final token = await SharedPrefs.getAuthToken();
    final refresh = await SharedPrefs.getRefreshToken();

    if (token == null || token.isEmpty) {
      await SharedPrefs.clearAuth();
      return false;
    }

    if (!JwtDecoder.isExpired(token)) {
      return true;
    }

    // Token expired -> try refresh
    if (refresh != null && refresh.isNotEmpty) {
      final res = await _api.refreshToken(
        accessToken: token,
        refreshToken: refresh,
      );

      if (res.success && res.data?.accessToken.isNotEmpty == true) {
        await SharedPrefs.setAuthToken(res.data!.accessToken);
        await SharedPrefs.setRefreshToken(res.data!.refreshToken);
        return true;
      }
    }

    await SharedPrefs.clearAuth();
    return false;
  }

  static Future<void> logout() async {
    await SharedPrefs.clearAuth();
  }
}