// features/home/presentation/screens/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:taboor/core/constants/app_constants.dart';
import 'package:taboor/core/services/biometric_service.dart';
import 'package:taboor/core/services/locale_service.dart';
import 'package:taboor/core/services/message_service.dart';
import 'package:taboor/core/services/session_manager.dart';
import 'package:taboor/core/services/theme_service.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/features/auth/presentation/screens/login_screen.dart';
import 'package:taboor/features/home/presentation/screens/change_password_screen.dart';
import 'package:taboor/features/home/presentation/screens/edit_profile_screen.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// Customer profile / settings tab.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, this.userName});

  final String? userName;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? _fullName;
  String? _email;
  String? _phone;
  bool _loading = true;
  late bool _biometricEnabled;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionManager.getUser();
    final biometricEnabled = BiometricService.isEnabled;
    if (!mounted) return;
    setState(() {
      _fullName = user?.fullName;
      _email = user?.email;
      _phone = user?.phoneNumber;
      _biometricEnabled = biometricEnabled;
      _loading = false;
    });
  }

  Future<void> _onBiometricToggle(bool next) async {
    if (next) {
      final available = await BiometricService.isAvailable();
      if (!available) {
        if (mounted) {
          MessageService.showError(
            context: context,
            message: AppLocalizations.of(context).biometricUnavailable,
          );
        }
        return;
      }
      final ok = await BiometricService.enable();
      if (!mounted) return;
      if (!ok) {
        MessageService.showWarning(
          context: context,
          message: AppLocalizations.of(context).biometricAuthRequired,
        );
        return;
      }
      setState(() => _biometricEnabled = true);
      MessageService.showSuccess(
        context: context,
        message: AppLocalizations.of(context).biometricEnabled,
      );
    } else {
      await BiometricService.disable();
      if (!mounted) return;
      setState(() => _biometricEnabled = false);
      MessageService.showInfo(
        context: context,
        message: AppLocalizations.of(context).biometricDisabled,
      );
    }
  }

  void _pickTheme() {
    showModalBottomSheet<_ThemeChoice>(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _ThemeSheet(
        current: ThemeService.themeNotifier.value,
      ),
    ).then((choice) {
      if (choice == null || !mounted) return;
      ThemeService.saveThemeMode(choice.mode);
      setState(() {});
    });
  }

  void _pickLanguage() {
    showModalBottomSheet<_LocaleChoice>(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _LanguageSheet(
        current: LocaleService.currentLocale,
      ),
    ).then((choice) {
      if (choice == null) return;
      LocaleService.setLocale(choice.locale);
    });
  }

  void _openEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  void _openChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  Future<void> _confirmSignOut() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.profileSignOut, style: AppTextStyles.heading(size: 18)),
        content: Text(
          l10n.profileSignOutConfirm,
          style: AppTextStyles.body(color: AppColors.gray700, size: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.profileCancel,
              style: AppTextStyles.body(
                color: AppColors.gray600,
                weight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.profileSignOutOk,
              style: AppTextStyles.body(
                color: AppColors.error,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;

    await BiometricService.disable();
    await SessionManager.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final horizontal = AppResponsive.horizontalPadding(context);
    final name = _fullName ?? widget.userName;
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return SafeArea(
      top: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                horizontal.left,
                20 + topInset,
                horizontal.right,
                70,
              ),
              children: [
                _ProfileHeader(name: name, email: _email, phone: _phone),
                const SizedBox(height: 22),

                // ===== Account =====
                _SectionLabel(l10n.profileAccount),
                const SizedBox(height: 10),
                _AccountSummaryCard(
                  onTap: _openEditProfile,
                ),
                const SizedBox(height: 20),

                // ===== Appearance =====
                _SectionLabel(l10n.profileAppearance),
                const SizedBox(height: 10),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.palette_outlined,
                      title: l10n.profileTheme,
                      subtitle: _themeLabel(l10n),
                      onTap: _pickTheme,
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.translate_rounded,
                      title: l10n.appLanguage,
                      subtitle: LocaleService.isArabic
                          ? l10n.languageArabic
                          : l10n.languageEnglish,
                      onTap: _pickLanguage,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ===== Security =====
                _SectionLabel(l10n.profileSecurity),
                const SizedBox(height: 10),
                _SettingsGroup(
                  children: [
                    _SettingsSwitchTile(
                      icon: Icons.fingerprint_rounded,
                      title: l10n.profileBiometric,
                      subtitle: l10n.profileBiometricSubtitle,
                      value: _biometricEnabled,
                      onChanged: _onBiometricToggle,
                    ),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: l10n.profileChangePassword,
                      subtitle: l10n.profileChangePasswordSubtitle,
                      onTap: _openChangePassword,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ===== About =====
                _SectionLabel(l10n.profileAbout),
                const SizedBox(height: 10),
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: l10n.profileVersion,
                      subtitle: AppConstants.appVersion,
                      onTap: () {},
                    ),
                    _SettingsDivider(),
                    _SignOutTile(onTap: _confirmSignOut),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }

  String _themeLabel(AppLocalizations l10n) {
    if (Theme.of(context).brightness == Brightness.dark &&
        ThemeService.themeNotifier.value == ThemeMode.system) {
      return l10n.themeSystem;
    }
    return switch (ThemeService.themeNotifier.value) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };
  }
}

// ===== Header =====

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email, this.phone});

  final String? name;
  final String? email;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final nameValue = name ?? '';
    final hasName = nameValue.trim().isNotEmpty;
    final hasPhone = phone != null && phone!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with double ring to match app's softTeal/teal language
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.softTeal,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: hasName
                  ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _initials(nameValue),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.teal,
                              height: 1,
                              letterSpacing: 0.3,
                            ),
                          ),
                        )
                  : const Icon(Icons.person_rounded,
                      color: AppColors.teal, size: 34),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameValue.isEmpty
                      ? AppLocalizations.of(context).navProfile
                      : nameValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading(size: 19),
                ),
                const SizedBox(height: 8),
                if (email != null && email!.isNotEmpty)
                  _HeaderInfoRow(
                    icon: Icons.mail_outline_rounded,
                    text: email!,
                  ),
                if (email != null &&
                    email!.isNotEmpty &&
                    hasPhone)
                  const SizedBox(height: 6),
                if (hasPhone)
                  _HeaderInfoRow(
                    icon: Icons.phone_outlined,
                    text: phone!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return first.toUpperCase() + last.toUpperCase();
  }
}

class _HeaderInfoRow extends StatelessWidget {
  const _HeaderInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.softTeal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.teal),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(
              color: AppColors.gray700,
              size: 13,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final subtitle = isArabic
        ? 'حدث اسمك وبريدك ورقم هاتفك'
        : 'Update your name, email and phone';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.teal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.editProfile,
                      style: AppTextStyles.body(
                        color: AppColors.ink,
                        weight: FontWeight.w700,
                        size: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        color: AppColors.gray600,
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.teal,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Shared UI =====

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Text(
        text,
        style: AppTextStyles.label(
          color: AppColors.gray600,
          size: 13,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.softTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.teal, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body(
                      color: AppColors.ink,
                      weight: FontWeight.w600,
                      size: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                        color: AppColors.gray600,
                        size: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.gray400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.softTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body(
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                    size: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                    color: AppColors.gray600,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.teal,
            activeThumbColor: AppColors.paper,
            inactiveThumbColor: AppColors.gray400,
            inactiveTrackColor: AppColors.gray300,
          ),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 14,
      color: AppColors.gray200,
    );
  }
}

class _SignOutTile extends StatelessWidget {
  const _SignOutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.profileSignOut,
              style: AppTextStyles.body(
                color: AppColors.error,
                weight: FontWeight.w700,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Bottom sheets =====

class _ThemeChoice {
  const _ThemeChoice(this.mode);
  final ThemeMode mode;
}

class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet({required this.current});

  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (ThemeMode.system, Icons.brightness_auto_rounded, l10n.themeSystem),
      (ThemeMode.light, Icons.light_mode_outlined, l10n.themeLight),
      (ThemeMode.dark, Icons.dark_mode_outlined, l10n.themeDark),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.profileTheme, style: AppTextStyles.heading(size: 18)),
            const SizedBox(height: 16),
            for (final (mode, icon, label) in options)
              _SheetOption(
                icon: icon,
                label: label,
                selected: current == mode,
                onTap: () =>
                    Navigator.of(context).pop(_ThemeChoice(mode)),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocaleChoice {
  const _LocaleChoice(this.locale);
  final Locale locale;
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current});

  final Locale current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (
        const Locale(AppConstants.arabic),
        l10n.languageArabic,
      ),
      (
        const Locale(AppConstants.english),
        l10n.languageEnglish,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appLanguage, style: AppTextStyles.heading(size: 18)),
            const SizedBox(height: 16),
            for (final (locale, label) in options)
              _SheetOption(
                icon: locale.languageCode == AppConstants.arabic
                    ? Icons.translate_rounded
                    : Icons.language_rounded,
                label: label,
                selected: current.languageCode == locale.languageCode,
                onTap: () => Navigator.of(context).pop(_LocaleChoice(locale)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.softTeal : AppColors.paper,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.teal : AppColors.gray200,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.teal : AppColors.gray600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body(
                    color: selected ? AppColors.ink : AppColors.gray700,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    size: 15,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.teal, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}