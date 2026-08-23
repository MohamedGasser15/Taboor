import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/l10n/app_localizations.dart';

class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({super.key, required this.type});

  final OnboardingIllustrationType type;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

enum OnboardingIllustrationType { ticket, live, alert }

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case OnboardingIllustrationType.ticket:
        return _TicketIllustration(controller: _controller);
      case OnboardingIllustrationType.live:
        return _LiveTrackingIllustration(controller: _controller);
      case OnboardingIllustrationType.alert:
        return _AlertIllustration(controller: _controller);
    }
  }
}

class _GradientBackdrop extends StatelessWidget {
  const _GradientBackdrop({required this.size, required this.colors, this.child});

  final Size size;
  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(size.height * 0.18),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TicketIllustration extends StatelessWidget {
  const _TicketIllustration({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        return Transform.rotate(
          angle: -0.05 + t * 0.1,
          child: SizedBox(
            width: 240,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(16 - t * 8, 10),
                  child: _GradientBackdrop(
                    size: const Size(150, 190),
                    colors: [AppColors.indigo, AppColors.teal],
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        color: Color(0x99FFFDF8),
                        size: 92,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-10 + t * 6, -14),
                  child: Container(
                    width: 168,
                    height: 208,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepTeal.withValues(alpha: 0.22),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.deepTeal, AppColors.teal],
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).appTitle,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppColors.gray300,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.paper,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, 1),
                                child: Icon(
                                  Icons.content_cut_rounded,
                                  color: AppColors.gray400,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppLocalizations.of(context).ticketNumberLabel,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '07',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepTeal,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.deepTeal, AppColors.teal],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(context).ticketSitRelax,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.paper,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            14,
                            (i) => Container(
                              width: (i % 3 == 0) ? 3 : 1,
                              height: 12,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.gray600,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveTrackingIllustration extends StatelessWidget {
  const _LiveTrackingIllustration({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        return SizedBox(
          width: 250,
          height: 235,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.5 + t * 0.3,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.indigo.withValues(alpha: 0.4),
                        AppColors.indigo.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // عداد الرقم
              Transform.scale(
                scale: 0.97 + t * 0.04,
                child: Container(
                  width: 176,
                  height: 176,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.paper,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.indigo.withValues(alpha: 0.2),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _ArcPainter(progress: 1 - t),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.teal,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context).liveAhead,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        _LiveCounter(value: t),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softTeal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.trending_down_rounded,
                                color: AppColors.teal,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context).liveTurnNear,
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _LiveCounter extends StatelessWidget {
  const _LiveCounter({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Text(
      (6 - (value * 5)).round().toString().padLeft(2, '0'),
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 58,
        fontWeight: FontWeight.w800,
        color: AppColors.deepTeal,
        height: 1,
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(
      center: center,
      radius: size.shortestSide / 2 - 8,
    );

    final track = Paint()
      ..color = AppColors.softTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    canvas.drawCircle(center, size.shortestSide / 2 - 8, track);

    final arc = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, -math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _AlertIllustration extends StatelessWidget {
  const _AlertIllustration({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        return SizedBox(
          width: 250,
          height: 235,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: t,
                    color: AppColors.indigo.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // الجرس
              Transform.translate(
                offset: Offset(24 - t * 6, 18 - t * 4),
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment(-0.4, -0.4),
                      end: Alignment(1, 1),
                      colors: [AppColors.deepTeal, AppColors.teal],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.35),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.paper,
                        size: 54,
                      ),
                      Positioned(
                        top: 14,
                        right: 24,
                        child: Transform.scale(
                          scale: 1 + t * 0.25,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: AppColors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.deepTeal,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // بطاقة الإشعار
              Transform.translate(
                offset: Offset(
                  -24 + t * 14,
                  0,
                ),
                child: Container(
                  width: 176,
                  height: 124,
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepTeal.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 20,
                        bottom: 20,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: AppColors.amber,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.deepTeal,
                                        AppColors.teal,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.paper,
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context).appTitle,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepTeal,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  AppLocalizations.of(context).alertNow,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              AppLocalizations.of(context).alertLeaveTitle,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.deepTeal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context).alertOnlyTwo,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide / 2 - 8;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..isAntiAlias = true
      ..color = color.withValues(alpha: (1 - progress) * 0.9);

    canvas.drawCircle(center, maxRadius * (0.5 + progress * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}