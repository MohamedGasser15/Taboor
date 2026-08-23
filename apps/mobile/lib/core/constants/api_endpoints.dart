// core/constants/api_endpoints.dart
//
// All backend endpoints mirror the ASP.NET API (Taboor_API).
// Controllers found: AuthController -> api/Auth

class ApiEndpoints {
  ApiEndpoints._();

  /// Production API base URL (hosted on ASP.NET).
  static const String baseUrl = 'https://taboorapi.runasp.net';

  // ===== Auth =====
  static const String login = '/api/Auth/Login';
  static const String register = '/api/Auth/Register';
  static const String sendCode = '/api/Auth/send-code';
  static const String verifyEmail = '/api/Auth/verify-email';
  static const String forgotPassword = '/api/Auth/forgot-password';
  static const String verifyResetCode = '/api/Auth/verify-reset-code';
  static const String resetPassword = '/api/Auth/reset-password';
  static const String refreshToken = '/api/Auth/refresh';
  static const String revokeToken = '/api/Auth/revoke';
  static const String externalLogin = '/api/Auth/ExternalLogin';
  static const String externalLoginCallback = '/api/Auth/ExternalLoginCallback';
  static const String externalLoginConfirmation =
      '/api/Auth/ExternalLoginConfirmation';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}