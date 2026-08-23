import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taboor/core/services/session_manager.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/core/utils/shared_prefs.dart';
import 'package:taboor/features/auth/presentation/screens/login_screen.dart';
import 'package:taboor/features/home/presentation/screens/home_screen.dart';
import 'package:taboor/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:taboor/features/splash/presentation/widgets/taboor_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2000), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    if (SharedPrefs.isFirstTime) {
      _goTo(const OnboardingScreen());
      return;
    }

    final loggedIn = await SessionManager.restore();
    if (!mounted) return;

    if (loggedIn) {
      final user = await SessionManager.getUser();
      if (!mounted) return;
      _goTo(HomeScreen(userName: user?.fullName));
    } else {
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => screen,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _SplashGradient(),
          const _FloatingBackground(),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: TaboorLogo(scale: isTablet ? 1.2 : 0.85),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashGradient extends StatelessWidget {
  const _SplashGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.softTeal.withValues(alpha: 0.7),
              AppColors.background,
              AppColors.paper,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}

class _FloatingBackground extends StatefulWidget {
  const _FloatingBackground();

  @override
  State<_FloatingBackground> createState() => _FloatingBackgroundState();
}

class _FloatingBackgroundState extends State<_FloatingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Positioned.fill(
          child: Stack(
            children: [
              // دوائر ناعمة بعيدة عن المنتصف
              Transform.translate(
                offset: Offset(-60 + t * 80, -40 + t * 30),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.softTeal.withValues(alpha: 0.45),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(70 - t * 60, 60 - t * 40),
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(-20, 0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Transform.translate(
                    offset: const Offset(-20, 90),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amber.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}