import 'package:flutter_test/flutter_test.dart';
import 'package:taboor/features/auth/presentation/widgets/password_strength_meter.dart';

void main() {
  group('passwordStrength', () {
    test('empty is weak', () {
      expect(passwordStrength(''), PasswordStrength.weak);
    });

    test('short password is weak', () {
      expect(passwordStrength('a'), PasswordStrength.weak);
      expect(passwordStrength('abc'), PasswordStrength.weak);
    });

    test('long lowercase is weak', () {
      expect(passwordStrength('abcdefgh'), PasswordStrength.weak);
    });

    test('8 chars + uppercase is medium', () {
      expect(passwordStrength('Abcdefgh'), PasswordStrength.medium);
    });

    test('8 chars + uppercase + digit is strong', () {
      expect(passwordStrength('Abcdefg1'), PasswordStrength.strong);
    });

    test('8 chars + case + digit + symbol is very strong', () {
      expect(passwordStrength('Abcdefg1!'), PasswordStrength.veryStrong);
    });
  });
}