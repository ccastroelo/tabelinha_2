import '../core/date_only.dart';

/// Uma menstruação guardada no histórico, com anotação opcional.
class PeriodRecord {
  const PeriodRecord({required this.start, required this.end, this.note = ''});

  final DateTime start;
  final DateTime end;
  final String note;

  /// A data de início identifica o registro: registrar o mesmo período duas
  /// vezes atualiza em vez de duplicar.
  String get id => toIsoDate(start);

  int get length => end.daysSince(start) + 1;

  PeriodRecord copyWith({DateTime? end, String? note}) =>
      PeriodRecord(start: start, end: end ?? this.end, note: note ?? this.note);

  Map<String, Object?> toJson() => {
        'start': toIsoDate(start),
        'end': toIsoDate(end),
        if (note.isNotEmpty) 'note': note,
      };

  /// `null` se o JSON estiver incompleto ou com datas inválidas.
  static PeriodRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    final rawStart = json['start'];
    final rawEnd = json['end'];
    final rawNote = json['note'];
    final start = rawStart is String ? tryParseIsoDate(rawStart) : null;
    final end = rawEnd is String ? tryParseIsoDate(rawEnd) : null;
    if (start == null || end == null || end.isBefore(start)) return null;
    return PeriodRecord(start: start, end: end, note: rawNote is String ? rawNote : '');
  }
}
