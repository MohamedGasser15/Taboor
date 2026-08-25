import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taboor/core/services/locale_service.dart';
import 'package:taboor/core/services/message_service.dart';
import 'package:taboor/core/services/session_manager.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/core/utils/input_formatters.dart';
import 'package:taboor/features/auth/data/auth_api.dart';
import 'package:taboor/features/auth/data/auth_models.dart';
import 'package:taboor/features/auth/data/google_auth_service.dart';
import 'package:taboor/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:taboor/features/auth/presentation/screens/register_screen.dart';
import 'package:taboor/features/home/presentation/screens/home_screen.dart';
import 'package:taboor/features/splash/presentation/widgets/taboor_logo.dart';
import 'package:taboor/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApi = AuthApi();
  bool _obscure = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleObscure() {
    setState(() => _obscure = !_obscure);
  }

  Future<void> _login() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailError = email.isEmpty ? l10n.emailRequired : null;
    final passwordError = password.isEmpty ? l10n.passwordRequired : null;

    if (emailError != null || passwordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
      });
      return;
    }

    setState(() {
      _emailError = null;
      _passwordError = null;
      _isLoading = true;
    });
    final res = await _authApi.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!res.success || res.data?.token == null) {
      setState(() {
        _emailError = l10n.invalidCredentials;
      });
      MessageService.showError(
        context: context,
        message: l10n.invalidCredentials,
      );
      return;
    }

    MessageService.showSuccess(
      context: context,
      message: l10n.loginSuccess,
    );
    await SessionManager.saveLogin(res.data!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            HomeScreen(userName: res.data?.user?.fullName),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _googleLogin() async {
    if (_isLoading) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);

    final idToken = await GoogleAuthService.signInWithGoogle();
    if (!mounted) return;

    if (idToken == null) {
      setState(() => _isLoading = false);
      return; // User cancelled.
    }

    // Send the ID token to our backend.
    final res = await _authApi.externalLogin(idToken);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!res.success || res.data?.token.isEmpty != false) {
      MessageService.showError(
        context: context,
        message: res.error ?? l10n.genericRequestError,
      );
      return;
    }

    MessageService.showSuccess(
      context: context,
      message: l10n.loginSuccess,
    );
    await SessionManager.saveLogin(LoginResponse(
      token: res.data?.token,
      refreshToken: res.data?.refreshToken,
    ));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

void _clearErrors() {
  if (_emailError != null || _passwordError != null) {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }
}

@override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _LoginGradient(),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 60 : 24,
              vertical: isTablet ? 100 : 80,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 48,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      const SizedBox(height: 8),
                      Align(
                        child: TaboorLogo(scale: 1, showWordmark: false),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.amber,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.amber.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.loginWelcomeTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: isTablet ? 30 : 25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginWelcomeSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),
                      _LoginField(
                        controller: _emailController,
                        label: l10n.emailLabel,
                        hint: l10n.emailHint,
                        errorText: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) _clearErrors();
                        },
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: const [LatinOnlyFormatter()],
                        prefixIcon: const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.teal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LoginField(
                        controller: _passwordController,
                        label: l10n.passwordLabel,
                        hint: l10n.passwordHint,
                        obscure: _obscure,
                        errorText: _passwordError,
                        onChanged: (_) {
                          if (_passwordError != null) _clearErrors();
                        },
                        inputFormatters: const [LatinOnlyFormatter()],
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.teal,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _toggleObscure,
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.gray500,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    _smoothSlideRoute(
                                      const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                          ),
                          child: Text(
                            l10n.forgotPassword,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 56,
                        child: _isLoading
                            ? const _LoginLoadingButton()
                            : _LoginButton(text: l10n.loginButton, onPressed: _login),
                      ),
                      const SizedBox(height: 20),
                      _OrDivider(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              iconColor: Colors.red.shade400,
                              label: 'Google',
                              onPressed: _isLoading ? null : _googleLogin,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.facebook_rounded,
                              iconColor: const Color(0xFF1877F2),
                              label: 'Facebook',
                              onPressed: _isLoading ? null : () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.noAccountYet,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: AppColors.gray600,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      _smoothSlideRoute(
                                        const RegisterScreen(),
                                      ),
                                    );
                                  },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 32),
                            ),
                            child: Text(
                              l10n.createAccount,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _LanguageToggle(),
          ),
        ],
      ),
    );
  }
}

class _LoginGradient extends StatelessWidget {
  const _LoginGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.softTeal.withValues(alpha: 0.6),
              AppColors.background,
              AppColors.paper,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.deepTeal,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            color: AppColors.deepTeal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: AppColors.gray400,
            ),
            errorText: errorText,
            errorStyle: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: prefixIcon,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.paper,
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
              borderSide: BorderSide(
                color: AppColors.accentRed,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepTeal, AppColors.teal],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.paper,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginLoadingButton extends StatelessWidget {
  const _LoginLoadingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepTeal, AppColors.teal],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.paper,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconColor = AppColors.teal,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.deepTeal,
          side: BorderSide(color: AppColors.gray200, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.gray200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            AppLocalizations.of(context).or,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.gray200, thickness: 1)),
      ],
    );
  }
}

Route<T> _smoothSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      );
    },
  );
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final isArabic = LocaleService.isArabic;
    return Material(
      color: AppColors.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.gray200, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: LocaleService.toggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 18,
                color: AppColors.teal,
              ),
              const SizedBox(width: 6),
              Text(
                isArabic ? 'EN' : 'عربي',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}