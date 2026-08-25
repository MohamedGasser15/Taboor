// features/auth/data/google_auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taboor/core/utils/shared_prefs.dart';

/// The Google OAuth client ids.
/// - Android client: used as the server client id.
/// - iOS client: used on Apple platforms.
const String kAndroidClientId =
    '619082841226-m5lfnuj0l17auih60cfj97iq96r6aik3.apps.googleusercontent.com';
const String kIosClientId =
    '619082841226-c65esvlhc7h2p9arqiq2jl00i6d1qsor.apps.googleusercontent.com';

/// Handles Google Sign-In and returns the id token for the backend.
class GoogleAuthService {
  GoogleAuthService._();

  static bool get _isApple =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    clientId: _isApple ? kIosClientId : null,
    serverClientId: _isApple ? kIosClientId : kAndroidClientId,
  );

  /// Performs Google Sign-In and returns the ID token, or null when the
  /// user cancels / the flow fails.
  static Future<String?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn
          .signIn()
          .timeout(const Duration(seconds: 30));
      if (account == null) return null;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      // Keep the google account freshly stored so logout stays in sync.
      if (idToken != null) {
        await SharedPrefs.setString('google_id_token', idToken);
      }
      return idToken;
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await SharedPrefs.removeKey('google_id_token');
    await _googleSignIn.disconnect();
  }

  /// True when the logged in session came from Google.
  static bool get isGoogleSession =>
      SharedPrefs.getStringValue('google_id_token') != null;
}