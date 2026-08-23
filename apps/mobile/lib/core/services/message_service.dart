// core/services/message_service.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taboor/core/extensions/context_extensions.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';

enum MessageType { success, error, info, warning }

class MessageService {
  static OverlayEntry? _currentEntry;

  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    _show(context: context, message: message, type: MessageType.success);
  }

  static void showError({
    required BuildContext context,
    required String message,
  }) {
    _show(context: context, message: message, type: MessageType.error);
  }

  static void showInfo({
    required BuildContext context,
    required String message,
  }) {
    _show(context: context, message: message, type: MessageType.info);
  }

  static void showWarning({
    required BuildContext context,
    required String message,
  }) {
    _show(context: context, message: message, type: MessageType.warning);
  }

  static void _show({
    required BuildContext context,
    required String message,
    required MessageType type,
  }) {
    _dismiss();

    final overlay = Overlay.of(context);
    final isArabic = context.isArabic;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) => _MessageWidget(
        message: message,
        type: type,
        isRtl: isArabic,
        onDismiss: _dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void _dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class MessageStyle {
  const MessageStyle({
    required this.accent,
    required this.background,
    required this.icon,
  });

  final Color accent;
  final Color background;
  final IconData icon;

  static MessageStyle of(MessageType type) => switch (type) {
        MessageType.success => const MessageStyle(
            accent: AppColors.teal,
            background: AppColors.softTeal,
            icon: Icons.check_circle_rounded,
          ),
        MessageType.error => const MessageStyle(
            accent: AppColors.error,
            background: AppColors.error,
            icon: Icons.error_rounded,
          ),
        MessageType.info => const MessageStyle(
            accent: AppColors.indigo,
            background: Color(0xFFEEF0FB),
            icon: Icons.info_rounded,
          ),
        MessageType.warning => const MessageStyle(
            accent: AppColors.amber,
            background: Color(0xFFFFF4E5),
            icon: Icons.warning_amber_rounded,
          ),
      };
}

class _MessageWidget extends StatefulWidget {
  final String message;
  final MessageType type;
  final bool isRtl;
  final VoidCallback onDismiss;

  const _MessageWidget({
    required this.message,
    required this.type,
    required this.isRtl,
    required this.onDismiss,
  });

  @override
  State<_MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<_MessageWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _autoDismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) _handleDismiss();
    });
  }

  Future<void> _handleDismiss() async {
    _autoDismissTimer?.cancel();
    if (mounted) {
      await _controller.reverse();
    }
    widget.onDismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = MessageStyle.of(widget.type);
    final isError = widget.type == MessageType.error;
    final topPadding = MediaQuery.of(context).viewPadding.top + 12;

    return Positioned(
      top: topPadding,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Directionality(
              textDirection:
                  widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: GestureDetector(
                onTap: _handleDismiss,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isError ? style.background : AppColors.paper,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: isError
                            ? style.accent.withValues(alpha: 0.35)
                            : AppColors.deepTeal.withValues(alpha: 0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isError
                              ? Colors.white.withValues(alpha: 0.18)
                              : style.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          style.icon,
                          color: isError ? Colors.white : style.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: AppTextStyles.body(
                            color: isError ? Colors.white : AppColors.deepTeal,
                            size: 14,
                            weight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleDismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isError
                                ? Colors.white.withValues(alpha: 0.18)
                                : AppColors.gray100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: isError ? Colors.white : AppColors.gray600,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}