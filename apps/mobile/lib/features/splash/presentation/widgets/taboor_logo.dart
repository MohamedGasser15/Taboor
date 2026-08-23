import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';

class TaboorLogo extends StatelessWidget {
  const TaboorLogo({
    super.key,
    this.scale = 1.0,
    this.showWordmark = true,
  });

  final double scale;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Transform.scale(
        scale: scale,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _LogoIcon(),

              if (showWordmark) ...[
                const SizedBox(width: 24),

                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'taboor',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.5,
                          height: 1,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2.5,
                          height: 1,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoIcon extends StatelessWidget {
  const _LogoIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        children: [
          // الخلفية البرتقالية
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),

          // المربع الأساسي
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: CustomPaint(
                  size: Size(100, 100),
                  painter: TbLogoPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TbLogoPainter extends CustomPainter {
  const TbLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final scaleX = size.width / 1024;
    final scaleY = size.height / 1024;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // نفس الـ SVG Path الأصلي
    final path = Path();

    // ---------------------------------------------------------
    // الجزء الأول
    // ---------------------------------------------------------
    path.moveTo(808, 537);
    path.lineTo(802, 525);
    path.lineTo(785, 502);
    path.lineTo(766, 487);
    path.lineTo(746, 477);
    path.lineTo(726, 471);
    path.lineTo(715, 471);
    path.lineTo(711, 469);
    path.lineTo(683, 471);
    path.lineTo(680, 473);
    path.lineTo(667, 475);
    path.lineTo(639, 489);
    path.lineTo(615, 511);
    path.lineTo(600, 532);
    path.lineTo(591, 541);
    path.lineTo(584, 552);
    path.lineTo(575, 561);
    path.lineTo(554, 590);
    path.lineTo(546, 598);
    path.lineTo(540, 608);
    path.lineTo(531, 617);
    path.lineTo(525, 627);
    path.lineTo(514, 638);
    path.lineTo(495, 639);
    path.lineTo(487, 643);
    path.lineTo(480, 650);
    path.lineTo(475, 661);
    path.lineTo(477, 674);
    path.lineTo(487, 686);
    path.lineTo(495, 690);
    path.lineTo(720, 690);
    path.lineTo(748, 682);
    path.lineTo(765, 673);
    path.lineTo(781, 660);
    path.lineTo(795, 645);
    path.lineTo(806, 626);
    path.lineTo(816, 591);
    path.lineTo(816, 569);
    path.lineTo(814, 566);
    path.lineTo(814, 557);
    path.close();

    // ---------------------------------------------------------
    // الجزء الداخلي العلوي
    // ---------------------------------------------------------
    path.moveTo(757, 552);
    path.lineTo(762, 570);
    path.lineTo(761, 598);
    path.lineTo(748, 620);
    path.lineTo(742, 626);
    path.lineTo(727, 635);
    path.lineTo(712, 639);
    path.lineTo(590, 639);
    path.lineTo(584, 637);
    path.lineTo(661, 539);
    path.lineTo(669, 531);
    path.lineTo(680, 525);
    path.lineTo(695, 520);
    path.lineTo(709, 520);
    path.lineTo(724, 524);
    path.lineTo(740, 533);
    path.close();

    // ---------------------------------------------------------
    // الجزء الرئيسي
    // ---------------------------------------------------------
    path.moveTo(540, 323);
    path.lineTo(527, 319);
    path.lineTo(288, 319);
    path.lineTo(285, 317);
    path.lineTo(276, 317);
    path.lineTo(273, 319);
    path.lineTo(257, 319);
    path.lineTo(254, 321);
    path.lineTo(249, 321);
    path.lineTo(231, 329);
    path.lineTo(214, 343);
    path.lineTo(205, 353);
    path.lineTo(195, 373);
    path.lineTo(195, 379);
    path.lineTo(191, 389);
    path.lineTo(191, 448);
    path.lineTo(199, 468);
    path.lineTo(207, 476);
    path.lineTo(215, 480);
    path.lineTo(227, 483);
    path.lineTo(281, 484);
    path.lineTo(281, 512);
    path.lineTo(283, 515);
    path.lineTo(281, 520);
    path.lineTo(281, 621);
    path.lineTo(287, 644);
    path.lineTo(293, 656);
    path.lineTo(311, 676);
    path.lineTo(340, 689);
    path.lineTo(353, 691);
    path.lineTo(374, 690);
    path.lineTo(388, 686);
    path.lineTo(405, 677);
    path.lineTo(423, 659);
    path.lineTo(432, 642);
    path.lineTo(436, 624);
    path.lineTo(436, 484);
    path.lineTo(481, 483);
    path.lineTo(492, 478);
    path.lineTo(500, 468);
    path.lineTo(502, 462);
    path.lineTo(502, 449);
    path.lineTo(496, 437);
    path.lineTo(484, 429);
    path.lineTo(450, 427);
    path.lineTo(447, 429);
    path.lineTo(425, 429);
    path.lineTo(414, 433);
    path.lineTo(405, 439);
    path.lineTo(391, 453);
    path.lineTo(381, 475);
    path.lineTo(381, 620);
    path.lineTo(377, 630);
    path.lineTo(370, 636);
    path.lineTo(364, 639);
    path.lineTo(355, 639);
    path.lineTo(343, 631);
    path.lineTo(336, 616);
    path.lineTo(336, 465);
    path.lineTo(340, 449);
    path.lineTo(349, 429);
    path.lineTo(345, 427);
    path.lineTo(246, 427);
    path.lineTo(244, 422);
    path.lineTo(244, 401);
    path.lineTo(249, 388);
    path.lineTo(259, 377);
    path.lineTo(271, 372);
    path.lineTo(514, 372);
    path.lineTo(522, 375);
    path.lineTo(532, 383);
    path.lineTo(538, 399);
    path.lineTo(539, 572);
    path.lineTo(583, 517);
    path.lineTo(592, 503);
    path.lineTo(592, 387);
    path.lineTo(590, 384);
    path.lineTo(590, 377);
    path.lineTo(578, 351);
    path.lineTo(562, 335);
    path.close();

    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}