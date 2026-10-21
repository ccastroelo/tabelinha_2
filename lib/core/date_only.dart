/// Datas de calendário (sem hora) representadas como `DateTime` UTC à meia-noite.
///
/// Contar dias entre dois `DateTime` locais erra em dias de mudança de horário
/// de verão; em UTC a diferença é sempre um múltiplo exato de 24h.
DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

extension DateOnlyX on DateTime {
  DateTime addDays(int days) => DateTime.utc(year, month, day + days);

  /// Quantos dias de calendário separam [this] de [other] (positivo se [this] é depois).
  int daysSince(DateTime other) =>
      dateOnly(this).difference(dateOnly(other)).inDays;

  bool isSameDay(DateTime other) => daysSince(other) == 0;
}

/// Primeiro dia do mês de [d].
DateTime firstDayOfMonth(DateTime d) => DateTime.utc(d.year, d.month);

int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

/// Módulo que nunca é negativo (`-1 mod 28 == 27`).
int positiveMod(int value, int modulus) => ((value % modulus) + modulus) % modulus;

String toIsoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime? tryParseIsoDate(String? s) {
  if (s == null) return null;
  final parsed = DateTime.tryParse(s);
  return parsed == null ? null : dateOnly(parsed);
}
