import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taboor/core/services/message_service.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/core/utils/input_formatters.dart';
import 'package:taboor/features/auth/data/auth_api.dart';
import 'package:taboor/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:taboor/features/splash/presentation/widgets/taboor_logo.dart';
import 'package:taboor/l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());
  final _authApi = AuthApi();

  int _currentStep = 0;
  bool _obscure = true;
  bool _confirmObscure = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _enteredOtp =>
      _otpControllers.map((c) => c.text).join();

  Future<void> _sendCode() async {
    if (_isLoading) return;
    final l10n = AppLocalizations.of(context);

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = l10n.emailRequired);
      return;
    }
    setState(() => _emailError = null);

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final res = await _authApi.forgotPassword(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!res.success) {
      MessageService.showWarning(
        context: context,
        message: res.error ?? l10n.networkError,
      );
      return;
    }

    MessageService.showSuccess(
      context: context,
      message: l10n.resetCodeSent,
    );
    setState(() => _currentStep = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpFocusNodes.first.requestFocus();
    });
  }

  Future<void> _verifyOtp() async {
    if (_isLoading) return;
    final l10n = AppLocalizations.of(context);

    final email = _emailController.text.trim();
    final code = _enteredOtp;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final res = await _authApi.verifyResetCode(email, code);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!res.success) {
      MessageService.showError(
        context: context,
        message: l10n.resetCodeInvalid,
      );
      return;
    }

    MessageService.showSuccess(
      context: context,
      message: l10n.resetCodeVerified,
    );
    setState(() => _currentStep = 2);
  }

  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }

  bool get _canResetPassword {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    return _isStrongPassword(password) && confirm == password;
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    final l10n = AppLocalizations.of(context);

    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    final passwordError = password.isEmpty
        ? l10n.passwordRequired
        : (!_isStrongPassword(password) ? l10n.passwordWeak : null);
    final confirmError = confirm.isEmpty
        ? l10n.passwordRequired
        : (confirm != password ? l10n.passwordMismatch : null);

    if (passwordError != null || confirmError != null) {
      setState(() {
        _passwordError = passwordError;
        _confirmPasswordError = confirmError;
      });
      return;
    }

    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
      _isLoading = true;
    });
    final res = await _authApi.resetPassword(
      email: _emailController.text.trim(),
      code: _enteredOtp,
      newPassword: password,
      confirmPassword: confirm,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!res.success) {
      MessageService.showError(
        context: context,
        message: res.error ?? l10n.networkError,
      );
      return;
    }

    MessageService.showSuccess(
      context: context,
      message: l10n.resetSuccess,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _ForgotGradient(),
          Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 60 : 24,
                    isTablet ? 8 : 0,
                    isTablet ? 60 : 24,
                    MediaQuery.of(context).viewPadding.bottom + 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height - 160,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_currentStep),
                        child: _buildActiveStep(isTablet),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStep(bool isTablet) {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep(isTablet);
      case 1:
        return _buildOtpStep(isTablet);
      default:
        return _buildPasswordStep(isTablet);
    }
  }

  Widget _buildTopBar() {
    final top = MediaQuery.of(context).padding.top + 8;
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: _StepIndicator(current: _currentStep),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: _goBack,
              tooltip: AppLocalizations.of(context).back,
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.deepTeal,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader({
    required String title,
    required String subtitle,
    required bool isTablet,
  }) {
    return Column(
      children: [
        Text(
          title,
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
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w400,
            color: AppColors.gray600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildEmailStep(bool isTablet) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: TaboorLogo(scale: 1.1, showWordmark: false),
        ),
        const SizedBox(height: 20),
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
        _buildStepHeader(
          title: AppLocalizations.of(context).forgotTitle,
          subtitle: AppLocalizations.of(context).forgotSubtitle,
          isTablet: isTablet,
        ),
        _StepField(
          controller: _emailController,
          label: AppLocalizations.of(context).emailLabel,
          hint: AppLocalizations.of(context).emailHint,
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          keyboardType: TextInputType.emailAddress,
          inputFormatters: const [LatinOnlyFormatter()],
          prefixIcon: const Icon(
            Icons.mail_outline_rounded,
            color: AppColors.teal,
            size: 20,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 56,
          child: _isLoading
              ? const _StepLoadingButton()
              : _StepButton(
                  text: AppLocalizations.of(context).sendCode,
                  onPressed: _sendCode,
                ),
        ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: AppColors.gray600,
              ),
              children: [
                TextSpan(text: '${AppLocalizations.of(context).rememberPassword} '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: Text(
                      AppLocalizations.of(context).loginButton,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepTeal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).let(
      (widget) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Transform.translate(
            offset: const Offset(0, -50),
            child: widget,
          ),
        ),
      ),
    );
  }

  Widget _buildOtpStep(bool isTablet) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.softTeal,
          ),
          child: const Center(
            child: Icon(
              Icons.mail_outline_rounded,
              color: AppColors.teal,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          AppLocalizations.of(context).otpTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: isTablet ? 30 : 26,
            fontWeight: FontWeight.w800,
            color: AppColors.deepTeal,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: isTablet ? 16 : 14.5,
              color: AppColors.gray500,
              height: 1.6,
            ),
            children: [
              TextSpan(
                text: AppLocalizations.of(context).otpDescription(
                      _emailController.text.trim().isEmpty
                          ? AppLocalizations.of(context).yourEmailFallback
                          : _emailController.text.trim(),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Directionality(
          textDirection: TextDirection.ltr,
          child: _OtpInput(
            controllers: _otpControllers,
            focusNodes: _otpFocusNodes,
            onChanged: (_) {
              setState(() {});
            },
            onCompleted: () {
              setState(() {});
              if (_enteredOtp.length == 6 && !_isLoading) {
                _verifyOtp();
              }
            },
          ),
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${AppLocalizations.of(context).resendPrompt} ',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                color: AppColors.gray400,
              ),
            ),
            GestureDetector(
              onTap: _sendCode,
              child: Text(
                AppLocalizations.of(context).resend,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        SizedBox(
          height: 56,
          child: _isLoading
              ? const _StepLoadingButton()
              : _StepButton(
                  text: AppLocalizations.of(context).verify,
                  onPressed: _enteredOtp.length == 6 ? _verifyOtp : null,
                ),
        ),
      ],
    ).let(
      (widget) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Transform.translate(
            offset: const Offset(0, -70),
            child: widget,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStep(bool isTablet) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildStepHeader(
          title: AppLocalizations.of(context).newPasswordTitle,
          subtitle: AppLocalizations.of(context).newPasswordSubtitle,
          isTablet: isTablet,
        ),
        _StepField(
          controller: _passwordController,
          label: AppLocalizations.of(context).newPasswordLabel,
          hint: AppLocalizations.of(context).passwordHint,
          obscure: _obscure,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
          },
          inputFormatters: const [LatinOnlyFormatter()],
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.teal,
            size: 20,
          ),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.gray500,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _passwordController,
              builder: (context, value, _) =>
                  PasswordStrengthMeter(password: value.text),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _StepField(
          controller: _confirmPasswordController,
          label: AppLocalizations.of(context).confirmPasswordLabel,
          hint: AppLocalizations.of(context).passwordHint,
          obscure: _confirmObscure,
          errorText: _confirmPasswordError,
          onChanged: (_) {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
          },
          inputFormatters: const [LatinOnlyFormatter()],
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.teal,
            size: 20,
          ),
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _confirmObscure = !_confirmObscure),
            icon: Icon(
              _confirmObscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.gray500,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _confirmPasswordController,
              builder: (context, value, _) => PasswordMatchIndicator(
                password: _passwordController.text,
                confirm: value.text,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 56,
          child: _isLoading
              ? const _StepLoadingButton()
              : AnimatedBuilder(
                  animation: Listenable.merge(
                    [_passwordController, _confirmPasswordController],
                  ),
                  builder: (context, _) => _StepButton(
                    text: AppLocalizations.of(context).savePassword,
                    onPressed: _canResetPassword ? _resetPassword : null,
                  ),
                ),
        ),
        const SizedBox(height: 16),
      ],
    ).let(
      (widget) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Transform.translate(
            offset: const Offset(0, -120),
            child: widget,
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index == current;
        final isDone = index < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.teal
                : isActive
                    ? AppColors.amber
                    : AppColors.gray300,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _OtpInput extends StatelessWidget {
  const _OtpInput({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onCompleted,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 54,
          height: 62,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.deepTeal,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: AppColors.paper,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: AppColors.gray300, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: AppColors.teal, width: 2),
              ),
            ),
            onChanged: (value) {
              onChanged(value);
              if (value.isNotEmpty && index < 5) {
                focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
              final filled = controllers
                  .map((c) => c.text)
                  .every((t) => t.isNotEmpty);
              if (filled) {
                onCompleted();
              }
            },
          ),
        );
      }),
    );
  }
}

class _StepField extends StatelessWidget {
  const _StepField({
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
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          obscureText: obscure,
          keyboardType: keyboardType,
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
              borderSide:
                  BorderSide(color: AppColors.accentRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Container(
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [AppColors.deepTeal, AppColors.teal],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(
              alpha: enabled ? 0.35 : 0.1,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: enabled ? Colors.transparent : AppColors.softTeal,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: enabled ? AppColors.paper : AppColors.teal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepLoadingButton extends StatelessWidget {
  const _StepLoadingButton();

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

class _ForgotGradient extends StatelessWidget {
  const _ForgotGradient();

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

extension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}