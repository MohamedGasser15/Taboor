// features/auth/data/auth_api.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:taboor/core/constants/api_endpoints.dart';
import 'package:taboor/features/auth/data/auth_models.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 25);

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Sends an OTP verification code to the given email (register flow).
  Future<ApiResponse<void>> sendCode(String email) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.sendCode),
            headers: _headers(),
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      return _parseEmpty(res);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  /// Sends a password-reset code to the given email (forgot password flow).
  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.forgotPassword),
            headers: _headers(),
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      return _parseEmpty(res);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  /// Verifies the password-reset code for the given email.
  Future<ApiResponse<void>> verifyResetCode(String email, String code) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.verifyResetCode),
            headers: _headers(),
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(_timeout);

      return _parseEmpty(res);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  /// Resets the user's password using a verified reset code.
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.resetPassword),
            headers: _headers(),
            body: jsonEncode({
              'email': email,
              'code': code,
              'newPassword': newPassword,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(_timeout);

      return _parseEmpty(res);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  /// Verifies the OTP code for the given email.
  Future<ApiResponse<void>> verifyEmail(String email, String code) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.verifyEmail),
            headers: _headers(),
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(_timeout);

      return _parseEmpty(res);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  /// Registers a new user (after email OTP verification).
  Future<ApiResponse<User>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.register),
            headers: _headers(),
            body: jsonEncode({
              'fullName': fullName,
              'email': email,
              'phoneNumber': phoneNumber,
              'password': password,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(_timeout);

      return _parse(res, User.fromJson);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  /// Signs in an existing user.
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.login),
            headers: _headers(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      return _parse(res, LoginResponse.fromJson);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  /// Exchanges an expired access token + refresh token for a new pair.
  Future<ApiResponse<TokenResponse>> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.refreshToken),
            headers: _headers(),
            body: jsonEncode({
              'accessToken': accessToken,
              'refreshToken': refreshToken,
            }),
          )
          .timeout(_timeout);

      return _parse(res, TokenResponse.fromJson);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  /// Revokes a refresh token for the authenticated user.
  Future<ApiResponse<void>> revokeToken(String refreshToken) async {
    try {
      final res = await _client
          .post(
            ApiEndpoints.uri(ApiEndpoints.revokeToken),
            headers: _headers(),
            body: jsonEncode(refreshToken),
          )
          .timeout(_timeout);

      return _parseEmpty(res);
    } on Exception {
      return const ApiResponse(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  ApiResponse<T> _parse<T>(
    http.Response res,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      json = {};
    }

    return ApiResponse<T>.fromJson(json, (data) {
      if (data is Map<String, dynamic>) return fromJson(data);
      return fromJson({});
    });
  }

  ApiResponse<void> _parseEmpty(http.Response res) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      json = {};
    }

    return ApiResponse<void>.fromJson(json, (_) {});
  }
}