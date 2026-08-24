// features/home/presentation/screens/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/features/home/presentation/screens/alerts_tab.dart';
import 'package:taboor/features/home/presentation/screens/home_tab.dart';
import 'package:taboor/features/home/presentation/screens/queue_tab.dart';
import 'package:taboor/features/home/presentation/screens/profile_tab.dart';
import 'package:taboor/l10n/app_localizations.dart';

/// Customer shell: wraps the main tabs in a floating translucent bottom bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.userName});

  final String? userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tabs = [
      HomeTab(userName: widget.userName),
      const QueueTab(),
      const AlertsTab(),
      ProfileTab(userName: widget.userName),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: _FadeIndexedStack(
              index: _index,
              children: tabs,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _TbNavBar(
              currentIndex: _index,
              onChanged: (i) => setState(() => _index = i),
              items: [
                _TbNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: l10n.navHome,
                ),
                _TbNavItem(
                  icon: Icons.confirmation_number_outlined,
                  activeIcon: Icons.confirmation_number_rounded,
                  label: l10n.navQueue,
                ),
                _TbNavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications_rounded,
                  label: l10n.navAlerts,
                ),
                _TbNavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: l10n.navProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TbNavItem {
  const _TbNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _FadeIndexedStack extends StatefulWidget {
  const _FadeIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(_FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: IndexedStack(index: widget.index, children: widget.children),
    );
  }
}

/// Floating translucent capsule-style bottom bar without SafeArea.
class _TbNavBar extends StatelessWidget {
  const _TbNavBar({
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<_TbNavItem> items;

  @override
  Widget build(BuildContext context) {
    const height = 66.0;

    return Container(
      height: height,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepTeal.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.paper.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;
                final isRtl = Directionality.of(context) == TextDirection.rtl;
                final step = 2 / (items.length - 1);
                final alignmentX =
                    (currentIndex * step - 1) * (isRtl ? -1 : 1);

                return Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment(alignmentX, 0),
                      child: Container(
                        width: itemWidth - 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppColors.softTeal,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: _TbNavButton(
                              item: items[i],
                              active: i == currentIndex,
                              onTap: () => onChanged(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TbNavButton extends StatelessWidget {
  const _TbNavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _TbNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        tween: Tween(end: active ? 1.0 : 0.0),
        builder: (context, t, _) {
          final iconColor = Color.lerp(AppColors.gray500, AppColors.teal, t);
          final labelColor = Color.lerp(AppColors.gray600, AppColors.ink, t);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Opacity(
                    opacity: 1 - t,
                    child: Icon(item.icon, size: 23, color: iconColor),
                  ),
                  Opacity(
                    opacity: t,
                    child: Icon(item.activeIcon, size: 23, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}