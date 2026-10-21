import 'dart:convert';

import '../core/date_only.dart';
import 'period_record.dart';

/// O que o app iOS original (Objective-C) deixou no aparelho.
///
/// Quem monta o JSON é `LegacyDataReader`, em `ios/Runner/AppDelegate.swift`.
class LegacyData {
  const LegacyData({
    this.start,
    this.cycleLength,
    this.periodLength,
    this.termsAcceptedAt,
    this.records = const [],
  });

  final DateTime? start;
  final int? cycleLength;
  final int? periodLength;
  final DateTime? termsAcceptedAt;
  final List<PeriodRecord> records;

  bool get isEmpty =>
      start == null && cycleLength == null && periodLength == null && termsAcceptedAt == null && records.isEmpty;

  /// `null` se [json] não for um objeto JSON válido. Campos ruins são ignorados
  /// um a um: importar parte dos dados é melhor do que não importar nada.
  static LegacyData? tryParse(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;

    int? asInt(Object? v) => v is num ? v.toInt() : null;

    final records = <PeriodRecord>[];
    final rawRecords = decoded['records'];
    if (rawRecords is List) {
      for (final raw in rawRecords) {
        final record = PeriodRecord.fromJson(raw);
        if (record != null) records.add(record.copyWith(note: record.note.trim()));
      }
    }

    final start = decoded['start'];
    final terms = decoded['termsAcceptedAt'];
    return LegacyData(
      start: start is String ? tryParseIsoDate(start) : null,
      cycleLength: asInt(decoded['cycleLength']),
      periodLength: asInt(decoded['periodLength']),
      termsAcceptedAt: terms is String ? DateTime.tryParse(terms) : null,
      records: records,
    );
  }
}
