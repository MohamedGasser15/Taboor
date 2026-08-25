// features/home/presentation/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taboor/core/services/message_service.dart';
import 'package:taboor/core/services/session_manager.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/core/utils/input_formatters.dart';
import 'package:taboor/features/auth/data/country.dart';
import 'package:taboor/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// Allows the customer to edit their account details.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ValueNotifier<Country> _country = ValueNotifier<Country>(Country.egypt);

  bool _loading = true;
  bool _saving = false;
  String? _nameError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionManager.getUser();
    if (!mounted) return;
    _nameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    final phone = user?.phoneNumber ?? '';
    if (phone.startsWith('+')) {
      final match = RegExp(r'^\+(\d+)[\s-]*(.*)$').firstMatch(phone);
      if (match != null) {
        _phoneController.text = match.group(2) ?? '';
      }
    } else {
      _phoneController.text = phone;
    }
    setState(() => _loading = false);
  }

  void _validate() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? l10n.fullNameRequired
          : null;
      _emailError = _emailController.text.trim().isEmpty
          ? l10n.emailRequired
          : (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(_emailController.text.trim())
              ? l10n.invalidEmail
              : null);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    _validate();
    if (_nameError != null || _emailError != null || !mounted) return;

    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);

    // TODO: wire to a real update-account endpoint once available.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _saving = false);
    MessageService.showSuccess(context: context, message: l10n.editProfileSaved);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final horizontal = AppResponsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.editProfile),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal.left,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      children: [
                        _FormField(
                          controller: _nameController,
                          label: l10n.fullNameLabel,
                          hint: l10n.fullNameHint,
                          icon: Icons.badge_outlined,
                          errorText: _nameError,
                          onChanged: (_) {
                            if (_nameError != null) setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: _emailController,
                          label: l10n.emailLabel,
                          hint: l10n.emailHint,
                          icon: Icons.mail_outline_rounded,
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: const [LatinOnlyFormatter()],
                          onChanged: (_) {
                            if (_emailError != null) setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        PhoneNumberField(
                          countryController: _country,
                          phoneController: _phoneController,
                          label: l10n.phoneLabel,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
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
                              l10n.editProfileSave,
                              style: AppTextStyles.button(size: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.errorText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.body(
            color: AppColors.deepTeal,
            weight: FontWeight.w500,
            size: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(color: AppColors.gray400, size: 14),
            errorText: errorText,
            prefixIcon: Icon(icon, color: AppColors.teal, size: 20),
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