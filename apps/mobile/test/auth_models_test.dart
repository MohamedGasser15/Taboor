import 'package:flutter_test/flutter_test.dart';
import 'package:taboor/features/auth/data/auth_models.dart';

void main() {
  group('Auth models', () {
    test('parse LoginResponse from JSON', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'user': {
            'id': 'abc',
            'fullName': 'محمد أحمد',
            'email': 'm@test.com',
            'phoneNumber': '01000000000',
            'preferredLanguage': 'ar',
            'role': 'User',
          },
          'token': 'access-token',
          'refreshToken': 'refresh-token',
          'refreshTokenExpiry': '2026-08-23T12:00:00Z',
          'isLockedOut': false,
          'isBlocked': false,
        },
      };

      final res = ApiResponse<LoginResponse>.fromJson(
        json,
        (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
      );

      expect(res.success, isTrue);
      expect(res.message, 'Login successful');
      expect(res.data, isNotNull);
      expect(res.data!.user!.fullName, 'محمد أحمد');
      expect(res.data!.user!.email, 'm@test.com');
      expect(res.data!.token, 'access-token');
      expect(res.data!.refreshToken, 'refresh-token');
      expect(res.data!.refreshTokenExpiry, isNotNull);
    });

    test('parse error ApiResponse', () {
      final json = {
        'success': false,
        'message': 'Invalid email or password.',
        'error': 'Invalid email or password.',
        'errors': [],
        'data': null,
      };

      final res = ApiResponse<LoginResponse>.fromJson(
        json,
        (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
      );

      expect(res.success, isFalse);
      expect(res.error, 'Invalid email or password.');
      expect(res.data, isNull);
    });

    test('parse ApiResponse with errors list', () {
      final json = {
        'success': false,
        'message': 'Validation failed',
        'errors': ['Email already exists', 'Phone number required'],
        'data': null,
      };

      final res = ApiResponse<void>.fromJson(json, (_) {});

      expect(res.success, isFalse);
      expect(res.errors, hasLength(2));
      expect(res.errors.first, 'Email already exists');
    });

    test('parse TokenResponse from JSON', () {
      final json = {
        'success': true,
        'data': {
          'accessToken': 'new-access',
          'refreshToken': 'new-refresh',
          'refreshTokenExpiry': '2026-08-30T12:00:00Z',
        },
      };

      final res = ApiResponse<TokenResponse>.fromJson(
        json,
        (data) => TokenResponse.fromJson(data as Map<String, dynamic>),
      );

      expect(res.success, isTrue);
      expect(res.data!.accessToken, 'new-access');
      expect(res.data!.refreshToken, 'new-refresh');
      expect(res.data!.refreshTokenExpiry, isNotNull);
    });
  });
}