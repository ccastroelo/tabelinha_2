import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/cycle_calculator.dart';
import '../core/date_only.dart';
import '../core/reminders.dart';
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
  static const _kAppLockEnabled = 'appLockEnabled';
  static const _kRemindersEnabled = 'remindersEnabled';
  static const _kReminderHour = 'reminderHour';
  static const _kReminderMinute = 'reminderMinute';
  static const _kReminderDaysBefore = 'reminderDaysBefore';
  static const _kReminderPeriod = 'reminderPeriod';
  static const _kReminderFertile = 'reminderFertile';
  static const _kReminderOvulation = 'reminderOvulation';
  static const _kTermsAcceptedAt = 'termsAcceptedAt';
  static const _kRecords = 'periodRecords';
  static const _kIntercourse = 'intercourseDates';
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

  ReminderSettings loadReminderSettings() {
    return const ReminderSettings().copyWith(
      enabled: _prefs.getBool(_kRemindersEnabled),
      hour: _prefs.getInt(_kReminderHour),
      minute: _prefs.getInt(_kReminderMinute),
      periodDaysBefore: _prefs.getInt(_kReminderDaysBefore),
      period: _prefs.getBool(_kReminderPeriod),
      fertile: _prefs.getBool(_kReminderFertile),
      ovulation: _prefs.getBool(_kReminderOvulation),
    );
  }

  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await _prefs.setBool(_kRemindersEnabled, settings.enabled);
    await _prefs.setInt(_kReminderHour, settings.hour);
    await _prefs.setInt(_kReminderMinute, settings.minute);
    await _prefs.setInt(_kReminderDaysBefore, settings.periodDaysBefore);
    await _prefs.setBool(_kReminderPeriod, settings.period);
    await _prefs.setBool(_kReminderFertile, settings.fertile);
    await _prefs.setBool(_kReminderOvulation, settings.ovulation);
  }

  bool loadAppLockEnabled() => _prefs.getBool(_kAppLockEnabled) ?? false;

  Future<void> saveAppLockEnabled(bool enabled) => _prefs.setBool(_kAppLockEnabled, enabled);

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

  /// Os dias marcados com relação sexual, como datas de calendário. Ficam fora de
  /// [PeriodRecord] de propósito: não são uma menstruação, não entram no cálculo do ciclo
  /// e nenhum outro dado depende deles — guardar à parte deixa apagar só isso.
  Set<DateTime> loadIntercourseDates() {
    final raw = _prefs.getStringList(_kIntercourse);
    if (raw == null) return {};
    return raw.map(tryParseIsoDate).whereType<DateTime>().toSet();
  }

  Future<void> saveIntercourseDates(Set<DateTime> dates) {
    final sorted = dates.map(toIsoDate).toList()..sort();
    return _prefs.setStringList(_kIntercourse, sorted);
  }

  bool get legacyImported => _prefs.getBool(_kLegacyImported) ?? false;

  Future<void> markLegacyImported() => _prefs.setBool(_kLegacyImported, true);

  Future<void> saveRecords(List<PeriodRecord> records) => _prefs.setString(
        _kRecords,
        jsonEncode(records.map((r) => r.toJson()).toList()),
      );
}
