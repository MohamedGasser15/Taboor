// core/constants/api_endpoints.dart
//
// Central place for every backend endpoint.
// All paths mirror the ASP.NET API (Taboor_API / AuthController).

class ApiEndpoints {
  ApiEndpoints._();

  /// Production API base URL.
  static const String baseUrl = 'https://taboorapi.runasp.net/api/';

  static const String _authRoot = 'Auth';

  // ===== Auth =====
  static const String login = '$_authRoot/Login';
  static const String register = '$_authRoot/Register';
  static const String sendCode = '$_authRoot/send-code';
  static const String verifyEmail = '$_authRoot/verify-email';
  static const String forgotPassword = '$_authRoot/forgot-password';
  static const String verifyResetCode = '$_authRoot/verify-reset-code';
  static const String resetPassword = '$_authRoot/reset-password';
  static const String refreshToken = '$_authRoot/refresh';
  static const String revokeToken = '$_authRoot/revoke';
  static const String externalLogin = '$_authRoot/ExternalLogin';
  static const String externalLoginCallback =
      '$_authRoot/ExternalLoginCallback';
  static const String externalLoginConfirmation =
      '$_authRoot/ExternalLoginConfirmation';
  static const String googleMobile = '$_authRoot/GoogleMobile';
  static const String facebookMobile = '$_authRoot/FacebookMobile';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}