// features/home/presentation/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/services/message_service.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/core/utils/input_formatters.dart';
import 'package:taboor/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:taboor/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// Lets the customer change their password (old + new + confirm).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _oldObscure = true;
  bool _newObscure = true;
  bool _confirmObscure = true;
  bool _saving = false;
  String? _oldError;
  String? _newError;
  String? _confirmError;

  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }

  bool get _canSubmit {
    return _oldController.text.isNotEmpty &&
        _isStrongPassword(_newController.text) &&
        _confirmController.text == _newController.text;
  }

  void _validate() {
    final l10n = AppLocalizations.of(context);
    final old = _oldController.text;
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    setState(() {
      _oldError = old.isEmpty ? l10n.passwordRequired : null;
      _newError = _isStrongPassword(newPassword) ? null : l10n.passwordWeak;
      _confirmError = confirm == newPassword ? null : l10n.passwordMismatch;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    _validate();
    if (_oldError != null || _newError != null || _confirmError != null) {
      return;
    }

    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);

    // TODO: wire to a real change-password endpoint once available.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _saving = false);
    MessageService.showSuccess(
      context: context,
      message: l10n.changePasswordDone,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final horizontal = AppResponsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profileChangePassword),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal.left,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileChangePasswordSubtitle,
                style: AppTextStyles.body(
                  color: AppColors.gray600,
                  size: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _PasswordField(
                controller: _oldController,
                label: l10n.oldPasswordLabel,
                hint: l10n.oldPasswordHint,
                obscure: _oldObscure,
                errorText: _oldError,
                onToggleVisibility: () =>
                    setState(() => _oldObscure = !_oldObscure),
                onChanged: (_) {
                  if (_oldError != null) setState(() {});
                },
              ),
              const SizedBox(height: 18),
              _PasswordField(
                controller: _newController,
                label: l10n.newPasswordLabel2,
                hint: l10n.passwordHint,
                obscure: _newObscure,
                errorText: _newError,
                onToggleVisibility: () =>
                    setState(() => _newObscure = !_newObscure),
                onChanged: (_) {
                  if (_newError != null) setState(() {});
                },
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _newController,
                builder: (context, value, _) =>
                    PasswordStrengthMeter(password: value.text),
              ),
              const SizedBox(height: 18),
              _PasswordField(
                controller: _confirmController,
                label: l10n.confirmPasswordLabel,
                hint: l10n.passwordHint,
                obscure: _confirmObscure,
                errorText: _confirmError,
                onToggleVisibility: () =>
                    setState(() => _confirmObscure = !_confirmObscure),
                onChanged: (_) {
                  if (_confirmError != null) setState(() {});
                },
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _confirmController,
                builder: (context, value, _) => Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: PasswordMatchIndicator(
                    password: _newController.text,
                    confirm: value.text,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : (_canSubmit ? _save : _validate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: AppColors.paper,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.paper,
                          ),
                        )
                      : Text(
                          l10n.savePassword,
                          style: AppTextStyles.button(size: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Forgot password link -> reset flow.
              Center(
                child: GestureDetector(
                  onTap: _saving
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                  child: Text(
                    l10n.forgotPasswordHere,
                    style: AppTextStyles.body(
                      color: AppColors.teal,
                      weight: FontWeight.w700,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggleVisibility,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggleVisibility;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.fieldLabel(color: AppColors.deepTeal),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscure,
          inputFormatters: const [LatinOnlyFormatter()],
          style: AppTextStyles.body(
            color: AppColors.deepTeal,
            weight: FontWeight.w500,
            size: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(color: AppColors.gray400, size: 14),
            errorText: errorText,
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.lock_outline_rounded,
                  color: AppColors.teal, size: 20),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.gray500,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.gray200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.teal, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.accentRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.accentRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}