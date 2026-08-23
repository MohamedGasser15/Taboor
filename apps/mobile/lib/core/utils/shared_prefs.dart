// core/utils/shared_prefs.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _prefs;
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // First Time
  static bool get isFirstTime {
    return _prefs.getBool('isFirstTime') ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    await _prefs.setBool('isFirstTime', value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBoolValue(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getStringValue(String key) {
    return _prefs.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getIntValue(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setSecureString(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  static Future<String?> getSecureString(String key) async {
    return await _secure.read(key: key);
  }

  static Future<void> removeKey(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> removeSecureKey(String key) async {
    await _secure.delete(key: key);
  }

  // ===== Auth Session =====
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  static Future<void> setAuthToken(String token) async {
    await _secure.write(key: authTokenKey, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _secure.read(key: authTokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _secure.write(key: refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secure.read(key: refreshTokenKey);
  }

  static Future<void> setUserData(String json) async {
    await _secure.write(key: userDataKey, value: json);
  }

  static Future<String?> getUserData() async {
    return await _secure.read(key: userDataKey);
  }

  static Future<void> clearAuth() async {
    await _secure.delete(key: authTokenKey);
    await _secure.delete(key: refreshTokenKey);
    await _secure.delete(key: userDataKey);
  }
}