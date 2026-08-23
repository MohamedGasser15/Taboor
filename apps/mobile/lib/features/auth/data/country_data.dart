// features/auth/data/country_data.dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:taboor/features/auth/data/country.dart';

class CountryData {
  static List<Country>? _cached;

  static Future<List<Country>> load() async {
    if (_cached != null) return _cached!;

    final raw = await rootBundle.loadString('assets/json/countries.json');
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
    _cached = list;
    return list;
  }
}