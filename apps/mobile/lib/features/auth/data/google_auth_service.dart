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
    final debugTag = 'GOOGLE_SIGN_IN';
    debugPrint('[$debugTag] starting sign-in (apple=$_isApple)');
    try {
      // Always show the account picker — clear any previously signed-in
      // Google session before starting a fresh sign-in.
      await _googleSignIn.signOut();

      final account = await _googleSignIn
          .signIn()
          .timeout(const Duration(seconds: 30));
      if (account == null) {
        debugPrint('[$debugTag] account returned null -> user cancelled');
        return null;
      }
      debugPrint('[$debugTag] account = ${account.email} '
          '(${account.displayName ?? 'no-name'})');

      final auth = await account.authentication;
      final idToken = auth.idToken;
      debugPrint('[$debugTag] got idToken? ${idToken != null}'
          ' length=${idToken?.length ?? 0}');
      if (idToken == null) {
        debugPrint('[$debugTag] FAILED: idToken is null '
            '(likely clientId/serverClientId misconfigured)');
        return null;
      }
      // Keep the google account freshly stored so logout stays in sync.
      await SharedPrefs.setString('google_id_token', idToken);
      // Remember the display name + email so the profile shows them even
      // though the backend response doesn't include a full user object.
      await SharedPrefs.setString(
        'google_display_name',
        account.displayName ?? '',
      );
      await SharedPrefs.setString('google_email', account.email);
      return idToken;
    } catch (e, st) {
      debugPrint('[$debugTag] ERROR: $e\n$st');
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

  /// The display name / email saved from the last Google sign-in.
  static String get savedDisplayName =>
      SharedPrefs.getStringValue('google_display_name') ?? '';
  static String get savedEmail =>
      SharedPrefs.getStringValue('google_email') ?? '';
}