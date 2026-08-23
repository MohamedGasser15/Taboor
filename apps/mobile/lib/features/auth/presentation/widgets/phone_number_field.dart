// features/auth/presentation/widgets/phone_number_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taboor/core/extensions/context_extensions.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';
import 'package:taboor/features/auth/data/country.dart';
import 'package:taboor/features/auth/data/country_data.dart';
import 'package:taboor/l10n/app_localizations.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.countryController,
    required this.phoneController,
    this.label,
    this.errorText,
    this.onChanged,
    this.onCountryChanged,
  });

  final ValueNotifier<Country> countryController;
  final TextEditingController phoneController;
  final String? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<Country>? onCountryChanged;

  void _pickCountry(BuildContext context) async {
    final selected = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CountrySheet(initial: countryController.value),
    );
    if (selected != null) {
      countryController.value = selected;
      onCountryChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.fieldLabel(
              color: AppColors.deepTeal,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ValueListenableBuilder<Country>(
          valueListenable: countryController,
          builder: (context, country, _) {
            return TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 15,
                color: AppColors.deepTeal,
              ),
              decoration: InputDecoration(
                hintText: l10n.phoneHint,
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
                prefixIcon: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _pickCountry(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            country.flag,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            country.dialCode,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepTeal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.gray500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                filled: true,
                fillColor: AppColors.paper,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.gray200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.teal, width: 1.8),
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
            );
          },
        ),
      ],
    );
  }
}

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.initial});

  final Country initial;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  late List<Country> _all;
  List<Country> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _all = await CountryData.load();
    _filtered = _all;
    if (mounted) setState(() => _loading = false);
  }

  void _onQuery(String value) {
    setState(() {
      final q = value.trim().toLowerCase();
      if (q.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all
            .where((c) =>
                c.nameEn.toLowerCase().contains(q) ||
                c.name.toLowerCase().contains(q) ||
                c.dialCode.contains(q))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return SafeArea(
      child: SizedBox(
        height: maxHeight,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Text(
                l10n.countrySelectTitle,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepTeal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: _onQuery,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  color: AppColors.deepTeal,
                ),
                decoration: InputDecoration(
                  hintText: l10n.countrySearchHint,
                  hintStyle: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: AppColors.gray400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.gray500,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.softTeal.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: AppColors.gray200, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: AppColors.teal, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.teal,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final c = _filtered[index];
                        final selected = c.code == widget.initial.code &&
                            c.dialCode == widget.initial.dialCode;
                        return ListTile(
                          leading: Text(
                            c.flag,
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(
                            context.isArabic ? c.name : c.nameEn,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.deepTeal,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                c.dialCode,
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray600,
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                  color: AppColors.teal,
                                ),
                              ],
                            ],
                          ),
                          onTap: () => Navigator.of(context).pop(c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}