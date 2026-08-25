// core/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:taboor/core/utils/shared_prefs.dart';

/// Manages biometric unlock (Face ID / fingerprint) preference + auth flows.
class BiometricService {
  BiometricService._();
  static const String _enabledKey = 'biometric_enabled';
  static final LocalAuthentication _auth = LocalAuthentication();

  /// True when the OS-level biometric unlock pref is on.
  static bool get isEnabled => SharedPrefs.getBoolValue(_enabledKey) == true;

  /// Whether this device has any biometrics configured (fingerprint/FaceID).
  static Future<bool> isAvailable() async {
    final isCapable = await _auth.canCheckBiometrics;
    final enrolled = await _auth.getAvailableBiometrics();
    return isCapable || enrolled.isNotEmpty;
  }

  /// Prompts the user for a biometric + stores the preference.
  static Future<bool> enable() async {
    final ok = await _auth.authenticate(
      localizedReason: 'Taboor',
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
    if (ok) {
      await SharedPrefs.setBool(_enabledKey, true);
    }
    return ok;
  }

  static Future<void> disable() async {
    await SharedPrefs.setBool(_enabledKey, false);
  }

  /// Verifies the user's identity when reopening the app.
  static Future<bool> authenticateToUnlock() async {
    if (!isEnabled || !await isAvailable()) return true;
    return _auth.authenticate(
      localizedReason: 'Taboor',
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
  }
}