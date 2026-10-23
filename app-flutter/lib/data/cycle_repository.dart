import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/cycle_calculator.dart';
import '../core/date_only.dart';
import 'period_record.dart';

/// Persistência local. Tudo cabe em `shared_preferences`: três números, uma
/// data e uma lista curta de registros.
class CycleRepository {
  CycleRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kStart = 'cycleStart';
  static const _kCycleLength = 'cycleLength';
  static const _kPeriodLength = 'periodLength';
  static const _kAutoCycleLength = 'autoCycleLength';
  static const _kTermsAcceptedAt = 'termsAcceptedAt';
  static const _kRecords = 'periodRecords';
  static const _kLegacyImported = 'legacyImported';

  static Future<CycleRepository> open() async =>
      CycleRepository(await SharedPreferences.getInstance());

  CycleSettings loadSettings() {
    return const CycleSettings().copyWith(
      start: tryParseIsoDate(_prefs.getString(_kStart)),
      cycleLength: _prefs.getInt(_kCycleLength),
      periodLength: _prefs.getInt(_kPeriodLength),
      autoCycleLength: _prefs.getBool(_kAutoCycleLength),
    );
  }

  Future<void> saveSettings(CycleSettings settings) async {
    final start = settings.start;
    if (start != null) await _prefs.setString(_kStart, toIsoDate(start));
    await _prefs.setInt(_kCycleLength, settings.cycleLength);
    await _prefs.setInt(_kPeriodLength, settings.periodLength);
    await _prefs.setBool(_kAutoCycleLength, settings.autoCycleLength);
  }

  DateTime? loadTermsAcceptedAt() =>
      DateTime.tryParse(_prefs.getString(_kTermsAcceptedAt) ?? '');

  Future<void> saveTermsAcceptedAt(DateTime when) =>
      _prefs.setString(_kTermsAcceptedAt, when.toIso8601String());

  List<PeriodRecord> loadRecords() {
    final raw = _prefs.getString(_kRecords);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map(PeriodRecord.fromJson).whereType<PeriodRecord>().toList();
    } on FormatException catch (e) {
      debugPrint('Histórico ilegível, ignorando: $e');
      return [];
    }
  }

  bool get legacyImported => _prefs.getBool(_kLegacyImported) ?? false;

  Future<void> markLegacyImported() => _prefs.setBool(_kLegacyImported, true);

  Future<void> saveRecords(List<PeriodRecord> records) => _prefs.setString(
        _kRecords,
        jsonEncode(records.map((r) => r.toJson()).toList()),
      );
}
