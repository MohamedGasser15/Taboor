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
}