// features/auth/presentation/widgets/otp_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taboor/core/themes/app_colors.dart';

/// OTP field built like Mahfazti: a hidden TextField holds the code and keeps
/// the keyboard stable, while 6 display boxes show each digit centered.
class SingleOtpField extends StatelessWidget {
  const SingleOtpField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onCompleted,
    this.length = 6,
    this.autoFocus = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCompleted;
  final int length;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Visible boxes that show the typed digits.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final text = value.text;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.ltr,
                children: List.generate(length, (index) {
                  final digit = index < text.length ? text[index] : '';
                  final filled = digit.isNotEmpty;
                  return GestureDetector(
                    onTap: () => focusNode?.requestFocus(),
                    child: Container(
                      width: 46,
                      height: 72,
                      margin: EdgeInsets.only(left: index > 0 ? 10 : 0),
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: filled ? AppColors.teal : AppColors.gray300,
                          width: filled ? 2 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepTeal.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          digit,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: filled
                                ? AppColors.deepTeal
                                : AppColors.gray400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Hidden input keeps the code + opens the keyboard once.
          Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autoFocus,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(length),
              ],
              onChanged: (value) {
                onChanged?.call(value);
                if (value.length == length) {
                  onCompleted?.call();
                }
              },
              textInputAction: TextInputAction.done,
              enableInteractiveSelection: true,
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}