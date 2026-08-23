import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/utils/app_responsive.dart';
import 'package:taboor/core/utils/shared_prefs.dart';
import 'package:taboor/features/onboarding/presentation/widgets/onboarding_illustrations.dart';
import 'package:taboor/features/onboarding/presentation/widgets/onboarding_page_data.dart';
import 'package:taboor/features/auth/presentation/screens/login_screen.dart';
import 'package:taboor/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isNavigating = false;

  List<OnboardingPageData> get _pages => [
        OnboardingPageData(
          type: OnboardingIllustrationType.ticket,
          title: AppLocalizations.of(context).onboardingOneTitle,
          subtitle: AppLocalizations.of(context).onboardingOneSubtitle,
          accent: AppColors.teal,
        ),
        OnboardingPageData(
          type: OnboardingIllustrationType.live,
          title: AppLocalizations.of(context).onboardingTwoTitle,
          subtitle: AppLocalizations.of(context).onboardingTwoSubtitle,
          accent: AppColors.amber,
        ),
        OnboardingPageData(
          type: OnboardingIllustrationType.alert,
          title: AppLocalizations.of(context).onboardingThreeTitle,
          subtitle: AppLocalizations.of(context).onboardingThreeSubtitle,
          accent: AppColors.indigo,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _nextPage() {
    return _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finishOnboarding() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await SharedPrefs.setFirstTime(false);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const _OnboardingBackground(),
            Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final data = _pages[index];
                      return _OnboardingPageView(
                        data: data,
                        isActive: index == _currentPage,
                        isTablet: isTablet,
                      );
                    },
                  ),
                ),
                _buildDotsIndicator(),
                _buildBottomActions(context, isTablet),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return const SizedBox(
      height: 44,
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? _pages[index].accent : AppColors.gray300,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, isTablet ? 32 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            width: double.infinity,
            child: _isLastPage
                ? _NextButton(isLast: true, onPressed: _finishOnboarding)
                : _NextButton(isLast: false, onPressed: _nextPage),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.isLast, required this.onPressed});

  final bool isLast;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isLast
            ? const LinearGradient(
                colors: [AppColors.deepTeal, AppColors.teal],
              )
            : const LinearGradient(
                colors: [AppColors.teal, AppColors.teal],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLast
                      ? AppLocalizations.of(context).startNow
                      : AppLocalizations.of(context).next,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.paper,
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.paper,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.data,
    required this.isActive,
    required this.isTablet,
  });

  final OnboardingPageData data;
  final bool isActive;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                offset: isActive ? Offset.zero : const Offset(0, 0.15),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  opacity: isActive ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OnboardingIllustration(type: data.type),
                  ),
                ),
              ),
              AnimatedSlide(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            offset: isActive ? Offset.zero : const Offset(0, 0.2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              opacity: isActive ? 1 : 0,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: isTablet ? 34 : 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepTeal,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: isTablet ? 18 : 15.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray600,
                      height: 1.8,
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 20),
                ],
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

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softTeal.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.indigo.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}