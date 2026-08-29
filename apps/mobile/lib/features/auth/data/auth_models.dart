// features/auth/data/auth_models.dart
import 'dart:convert';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final List<String> errors;
  final T? data;

  const ApiResponse({
    required this.success,
    this.message,
    this.error,
    this.errors = const [],
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String?,
      error: json['error'] as String?,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      data: json['data'] == null ? null : fromJson(json['data']),
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? preferredLanguage;
  final String role;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.preferredLanguage,
    this.role = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      role: json['role'] as String? ?? '',
    );
  }
}

class LoginResponse {
  final User? user;
  final String? token;
  final String? refreshToken;
  final DateTime? refreshTokenExpiry;
  final bool isLockedOut;
  final bool isBlocked;

  const LoginResponse({
    this.user,
    this.token,
    this.refreshToken,
    this.refreshTokenExpiry,
    this.isLockedOut = false,
    this.isBlocked = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: json['user'] == null ? null : User.fromJson(json['user']),
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      refreshTokenExpiry: json['refreshTokenExpiry'] == null
          ? null
          : DateTime.tryParse(json['refreshTokenExpiry'].toString()),
      isLockedOut: json['isLockedOut'] == true,
      isBlocked: json['isBlocked'] == true,
    );
  }
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final DateTime? refreshTokenExpiry;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.refreshTokenExpiry,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      refreshTokenExpiry: json['refreshTokenExpiry'] == null
          ? null
          : DateTime.tryParse(json['refreshTokenExpiry'].toString()),
    );
  }
}

class ExternalLoginResponse {
  final String? email;
  final bool isNewUser;
  final bool hasPassword;
  final String token;
  final String refreshToken;
  final DateTime? refreshTokenExpiry;
  final User? user;

  const ExternalLoginResponse({
    this.email,
    this.isNewUser = false,
    this.hasPassword = false,
    this.token = '',
    this.refreshToken = '',
    this.refreshTokenExpiry,
    this.user,
  });

  factory ExternalLoginResponse.fromJson(Map<String, dynamic> json) {
    return ExternalLoginResponse(
      email: json['email'] as String?,
      isNewUser: json['isNewUser'] == true,
      hasPassword: json['hasPassword'] == true,
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      refreshTokenExpiry: json['refreshTokenExpiry'] == null
          ? null
          : DateTime.tryParse(json['refreshTokenExpiry'].toString()),
      user: json['user'] == null ? null : User.fromJson(json['user']),
    );
  }

  /// Builds a usable [User] record even when the backend didn't include the
  /// full user object. Fills id/email from the JWT payload when available.
  User toUser() {
    final fromJson = user;
    if (fromJson != null) return fromJson;

    final payload = _decodeJwtPayload(token);
    return User(
      id: payload['sub']?.toString() ?? '',
      fullName: payload['name']?.toString() ?? '',
      email: email ?? payload['email']?.toString() ?? '',
      role: payload['role']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};
      final payloadPart =
          parts[1].replaceAll('-', '+').replaceAll('_', '/');
      final padded = payloadPart.padRight(
        payloadPart.length + ((4 - payloadPart.length % 4) % 4),
        '=',
      );
      final decoded = utf8.decode(base64.decode(padded));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}