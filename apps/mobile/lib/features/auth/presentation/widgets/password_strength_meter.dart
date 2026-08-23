// features/auth/presentation/widgets/password_strength_meter.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/l10n/app_localizations.dart';

enum PasswordStrength {
  weak,
  medium,
  strong,
  veryStrong;

  Color get color => switch (this) {
        PasswordStrength.weak => AppColors.accentRed,
        PasswordStrength.medium => AppColors.amber,
        PasswordStrength.strong => AppColors.teal,
        PasswordStrength.veryStrong => AppColors.indigo,
      };

  int get level => switch (this) {
        PasswordStrength.weak => 1,
        PasswordStrength.medium => 2,
        PasswordStrength.strong => 3,
        PasswordStrength.veryStrong => 4,
      };
}

/// Computes password strength based on length, case, digits and symbols.
PasswordStrength passwordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.weak;

  var score = 0;
  if (password.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

  if (score <= 1) return PasswordStrength.weak;
  if (score == 2) return PasswordStrength.medium;
  if (score == 3) return PasswordStrength.strong;
  return PasswordStrength.veryStrong;
}

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final strength = passwordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(4, (index) {
                  final isFilled =
                      password.isNotEmpty && index < strength.level;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      height: 6,
                      margin: EdgeInsetsDirectional.only(
                        end: index < 3 ? 4 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isFilled ? strength.color : AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (password.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                switch (strength) {
                  PasswordStrength.weak => l10n.passwordWeakLabel,
                  PasswordStrength.medium => l10n.passwordMediumLabel,
                  PasswordStrength.strong => l10n.passwordStrongLabel,
                  PasswordStrength.veryStrong => l10n.passwordVeryStrongLabel,
                },
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: strength.color,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Small indicator shown under the confirm password field while typing.
class PasswordMatchIndicator extends StatelessWidget {
  const PasswordMatchIndicator({
    super.key,
    required this.password,
    required this.confirm,
  });

  final String password;
  final String confirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (confirm.isEmpty) return const SizedBox.shrink();

    final match = password == confirm;
    return Row(
      children: [
        Icon(
          match ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          size: 14,
          color: match ? AppColors.success : AppColors.accentRed,
        ),
        const SizedBox(width: 6),
        Text(
          match ? l10n.passwordMatchOk : l10n.passwordMismatch,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: match ? AppColors.success : AppColors.accentRed,
          ),
        ),
      ],
    );
  }
}