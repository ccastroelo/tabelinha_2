import 'date_only.dart';

enum DayKind { none, menstruation, fertile, ovulation }

/// Meia-janela fértil em dias, para cada lado do dia de ovulação: 4, ou seja,
/// uma janela de 9 dias. É o valor do app original (Objective-C); o texto de
/// ajuda (`helpBody` nos ARBs) cita o mesmo número, então mude os dois juntos.
const fertileHalfWindow = 4;

class CycleSettings {
  const CycleSettings({
    this.start,
    this.cycleLength = defaultCycleLength,
    this.periodLength = defaultPeriodLength,
  });

  static const minCycleLength = 8;
  static const maxCycleLength = 55;
  static const defaultCycleLength = 28;
  static const minPeriodLength = 1;
  static const maxPeriodLength = 9;
  static const defaultPeriodLength = 5;

  /// Primeiro dia da menstruação de referência. `null` até a usuária informar.
  final DateTime? start;
  final int cycleLength;
  final int periodLength;

  CycleSettings copyWith({DateTime? start, int? cycleLength, int? periodLength}) {
    return CycleSettings(
      start: start ?? this.start,
      cycleLength: (cycleLength ?? this.cycleLength)
          .clamp(minCycleLength, maxCycleLength),
      periodLength: (periodLength ?? this.periodLength)
          .clamp(minPeriodLength, maxPeriodLength),
    );
  }
}

class PeriodRange {
  const PeriodRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get length => end.daysSince(start) + 1;
}

/// Cálculo puro do ciclo: sem Flutter, sem armazenamento, fácil de testar.
class CycleCalculator {
  const CycleCalculator(this.settings);

  final CycleSettings settings;

  bool get isConfigured => settings.start != null;

  int get _ovulationOffset => settings.cycleLength ~/ 2;

  /// Posição (0-based) de [date] dentro do ciclo, projetando para trás e para frente.
  int? _offsetOf(DateTime date) {
    final start = settings.start;
    if (start == null) return null;
    return positiveMod(date.daysSince(start), settings.cycleLength);
  }

  /// Dia do ciclo (1 = primeiro dia da menstruação).
  int? dayOfCycle(DateTime date) {
    final offset = _offsetOf(date);
    return offset == null ? null : offset + 1;
  }

  DayKind kindOf(DateTime date) {
    final offset = _offsetOf(date);
    if (offset == null) return DayKind.none;

    var kind = DayKind.none;
    if (offset < settings.periodLength) kind = DayKind.menstruation;
    if ((offset - _ovulationOffset).abs() <= fertileHalfWindow) {
      kind = DayKind.fertile;
    }
    if (offset == _ovulationOffset) kind = DayKind.ovulation;
    return kind;
  }

  /// Menstruações que *começam* no mês — o fim é início + duração − 1, podendo
  /// cair no mês seguinte.
  List<PeriodRange> periodsStartingIn(int year, int month) {
    final first = DateTime.utc(year, month);
    final offset = _offsetOf(first);
    if (offset == null) return const [];

    final last = DateTime.utc(year, month, daysInMonth(year, month));
    final cycle = settings.cycleLength;
    var start = offset == 0 ? first : first.addDays(cycle - offset);

    final ranges = <PeriodRange>[];
    while (!start.isAfter(last)) {
      ranges.add(PeriodRange(start, start.addDays(settings.periodLength - 1)));
      start = start.addDays(cycle);
    }
    return ranges;
  }

  /// Início da próxima menstruação, estritamente depois de [date].
  DateTime? nextPeriodStart(DateTime date) {
    final offset = _offsetOf(date);
    return offset == null ? null : date.addDays(settings.cycleLength - offset);
  }

  /// Próximo dia de ovulação, a partir de [date] (inclusive).
  DateTime? nextOvulation(DateTime date) {
    final offset = _offsetOf(date);
    if (offset == null) return null;
    final wait = positiveMod(_ovulationOffset - offset, settings.cycleLength);
    return date.addDays(wait);
  }
}
