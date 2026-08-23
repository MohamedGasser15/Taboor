// features/auth/data/country.dart
class Country {
  const Country({
    required this.name,
    required this.nameEn,
    required this.dialCode,
    required this.code,
  });

  final String name;
  final String nameEn;
  final String dialCode;
  final String code;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      dialCode: json['dial_code'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }

  String get flag {
    // Converts ISO country code (e.g. "EG") into regional indicator emoji.
    final upper = code.toUpperCase();
    final buf = StringBuffer();
    for (var i = 0; i < upper.length; i++) {
      buf.writeCharCode(0x1F1E6 + (upper.codeUnitAt(i) - 0x41));
    }
    return buf.toString();
  }

  static Country get egypt => const Country(
        name: 'مصر',
        nameEn: 'Egypt',
        dialCode: '+20',
        code: 'EG',
      );
}