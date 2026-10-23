import 'date_only.dart';

enum DayKind { none, menstruation, fertile, ovulation }

/// Meia-janela fértil em dias, para cada lado do dia de ovulação: 4, ou seja,
/// uma janela de 9 dias. É o valor do app original (Objective-C); o texto de
/// ajuda (`helpBody` nos ARBs) cita o mesmo número, então mude os dois juntos.
const fertileHalfWindow = 4;

/// Quantos dos últimos ciclos entram na média. Mais que isso e um ciclo de
/// meses atrás ainda pesaria no que a pessoa vive hoje.
const estimateMaxCycles = 6;

/// Menos ciclos que isto não dá média: com um só, qualquer atraso vira "o novo normal".
/// Dois ciclos pedem três menstruações no histórico.
const estimateMinCycles = 2;

class CycleSettings {
  const CycleSettings({
    this.start,
    this.cycleLength = defaultCycleLength,
    this.periodLength = defaultPeriodLength,
    this.autoCycleLength = true,
  });

  static const minCycleLength = 8;
  static const maxCycleLength = 55;
  static const defaultCycleLength = 28;
  static const minPeriodLength = 1;
  static const maxPeriodLength = 9;
  static const defaultPeriodLength = 5;

  /// Primeiro dia da menstruação de referência. `null` até a usuária informar.
  final DateTime? start;

  /// Duração definida à mão. Vale quando [autoCycleLength] está desligado e, ligado,
  /// enquanto não há histórico para calcular a média.
  final int cycleLength;
  final int periodLength;

  /// Usa o histórico: datas reais dos ciclos já vividos e, para o futuro, a média dos
  /// últimos ciclos no lugar de [cycleLength]. Desligado, vale a duração fixa de sempre.
  final bool autoCycleLength;

  CycleSettings copyWith({
    DateTime? start,
    int? cycleLength,
    int? periodLength,
    bool? autoCycleLength,
  }) {
    return CycleSettings(
      start: start ?? this.start,
      cycleLength: (cycleLength ?? this.cycleLength)
          .clamp(minCycleLength, maxCycleLength),
      periodLength: (periodLength ?? this.periodLength)
          .clamp(minPeriodLength, maxPeriodLength),
      autoCycleLength: autoCycleLength ?? this.autoCycleLength,
    );
  }
}

class PeriodRange {
  const PeriodRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get length => end.daysSince(start) + 1;
}

/// Duração média do ciclo calculada a partir do histórico.
class CycleEstimate {
  const CycleEstimate({required this.cycleLength, required this.cycles});

  /// Média arredondada, em dias.
  final int cycleLength;

  /// Quantos ciclos entraram na conta.
  final int cycles;
}

/// Menstruações que a pessoa de fato viveu, em ordem e sem repetir o mesmo episódio.
///
/// Entram o início de referência ([reference], que ela mesma informa e atualiza a cada
/// ciclo) e os registros do histórico que já começaram ([today] inclusive). Os registros
/// futuros ficam de fora: foram projetados pelo app e ainda não aconteceram.
///
/// Datas a menos de [CycleSettings.minCycleLength] dias uma da outra são a mesma
/// menstruação com a data corrigida, e não duas. Fica a de referência, que é a mais
/// recente que a pessoa informou; sem ela, a mais tardia. No mesmo dia vale o registro,
/// que tem o fim real da menstruação.
List<PeriodRange> knownPeriods({
  required DateTime? reference,
  required int periodLength,
  required Iterable<PeriodRange> records,
  required DateTime today,
}) {
  final items = <(PeriodRange, bool)>[
    for (final r in records)
      if (!r.start.isAfter(today)) (r, false),
    if (reference != null) (PeriodRange(reference, reference.addDays(periodLength - 1)), true),
  ]..sort((a, b) => a.$1.start.compareTo(b.$1.start));

  final out = <PeriodRange>[];
  var referenceWon = false;
  for (final (range, isReference) in items) {
    final sameEpisode = out.isNotEmpty &&
        range.start.daysSince(out.last.start) < CycleSettings.minCycleLength;
    if (!sameEpisode) {
      out.add(range);
      referenceWon = isReference;
    } else if (range.start.isSameDay(out.last.start)) {
      if (!isReference) out.last = range;
      referenceWon = referenceWon || isReference;
    } else if (isReference) {
      out.last = range;
      referenceWon = true;
    } else if (!referenceWon) {
      out.last = range;
    }
  }
  return out;
}

/// Média dos últimos ciclos, a partir das datas de início de menstruações já vividas.
///
/// Só contam intervalos que podem ser um ciclo (de [CycleSettings.minCycleLength] a
/// [CycleSettings.maxCycleLength] dias): um buraco de meses sem registro não é um ciclo
/// de 90 dias. Usa os [estimateMaxCycles] mais recentes e exige [estimateMinCycles].
CycleEstimate? estimateCycleLength(Iterable<DateTime> starts, {required DateTime today}) {
  final sorted = starts.where((s) => !s.isAfter(today)).toList()..sort();

  final intervals = <int>[];
  for (var i = 1; i < sorted.length; i++) {
    final days = sorted[i].daysSince(sorted[i - 1]);
    if (days >= CycleSettings.minCycleLength && days <= CycleSettings.maxCycleLength) {
      intervals.add(days);
    }
  }
  if (intervals.length < estimateMinCycles) return null;

  final recent = intervals.length > estimateMaxCycles
      ? intervals.sublist(intervals.length - estimateMaxCycles)
      : intervals;
  final mean = recent.reduce((a, b) => a + b) / recent.length;
  return CycleEstimate(
    cycleLength: mean.round().clamp(CycleSettings.minCycleLength, CycleSettings.maxCycleLength),
    cycles: recent.length,
  );
}

/// Onde uma data cai no ciclo: início do ciclo, posição (0-based), duração e
/// quantos dias de menstruação.
typedef _Position = ({DateTime start, int offset, int length, int period});

/// Cálculo puro do ciclo: sem Flutter, sem armazenamento, fácil de testar.
///
/// Sem [known], projeta um único ciclo de [CycleSettings.cycleLength] dias a partir do
/// início de referência, para trás e para frente (o algoritmo do app original).
/// Com [known], os ciclos já vividos usam as datas reais (a duração de cada um é a
/// distância até o início seguinte) e só o que vem depois do último início, ou antes do
/// primeiro, é projetado com `settings.cycleLength`.
class CycleCalculator {
  const CycleCalculator(this.settings, {this.known = const []});

  /// `settings.cycleLength` é a duração usada nas projeções (a média, quando há).
  final CycleSettings settings;

  /// Menstruações vividas, de [knownPeriods]: em ordem, sem datas coladas.
  final List<PeriodRange> known;

  bool get isConfigured => settings.start != null;

  /// Posição de [date] dentro do ciclo, projetando para trás e para frente.
  _Position? _locate(DateTime date) {
    if (settings.start == null) return null;
    final cycle = settings.cycleLength;

    _Position projected(DateTime from, int period) {
      final offset = positiveMod(date.daysSince(from), cycle);
      final start = date.addDays(-offset);
      return (start: start, offset: offset, length: cycle, period: period);
    }

    if (known.isEmpty) return projected(settings.start!, settings.periodLength);

    var index = -1;
    for (var i = 0; i < known.length && !known[i].start.isAfter(date); i++) {
      index = i;
    }
    if (index == -1) return projected(known.first.start, settings.periodLength);

    final current = known[index];
    if (index + 1 < known.length) {
      final length = known[index + 1].start.daysSince(current.start);
      // Um intervalo longo demais é um buraco sem registro, não um ciclo: projeta.
      if (length <= CycleSettings.maxCycleLength) {
        return (
          start: current.start,
          offset: date.daysSince(current.start),
          length: length,
          period: current.length,
        );
      }
    }
    final position = projected(current.start, settings.periodLength);
    return position.start.isSameDay(current.start)
        ? (start: position.start, offset: position.offset, length: cycle, period: current.length)
        : position;
  }

  /// Dia do ciclo (1 = primeiro dia da menstruação).
  int? dayOfCycle(DateTime date) {
    final position = _locate(date);
    return position == null ? null : position.offset + 1;
  }

  DayKind kindOf(DateTime date) {
    final position = _locate(date);
    if (position == null) return DayKind.none;

    final ovulation = position.length ~/ 2;
    var kind = DayKind.none;
    if (position.offset < position.period) kind = DayKind.menstruation;
    if ((position.offset - ovulation).abs() <= fertileHalfWindow) kind = DayKind.fertile;
    if (position.offset == ovulation) kind = DayKind.ovulation;
    return kind;
  }

  /// Menstruações que *começam* no mês — o fim é início + duração − 1, podendo
  /// cair no mês seguinte.
  List<PeriodRange> periodsStartingIn(int year, int month) {
    final ranges = <PeriodRange>[];
    for (var day = 1; day <= daysInMonth(year, month); day++) {
      final date = DateTime.utc(year, month, day);
      final position = _locate(date);
      if (position == null) return const [];
      if (position.offset == 0) {
        ranges.add(PeriodRange(date, date.addDays(position.period - 1)));
      }
    }
    return ranges;
  }

  /// Início da próxima menstruação, estritamente depois de [date].
  DateTime? nextPeriodStart(DateTime date) {
    final position = _locate(date);
    if (position == null) return null;

    var next = date.addDays(position.length - position.offset);
    // Num buraco longo, um início conhecido pode chegar antes do ciclo projetado acabar.
    for (final period in known) {
      if (period.start.isAfter(date)) {
        if (period.start.isBefore(next)) next = period.start;
        break;
      }
    }
    return next;
  }

  /// Próximo dia de ovulação, a partir de [date] (inclusive).
  DateTime? nextOvulation(DateTime date) {
    final position = _locate(date);
    if (position == null) return null;

    final thisCycle = position.start.addDays(position.length ~/ 2);
    if (!thisCycle.isBefore(date)) return thisCycle;

    final next = nextPeriodStart(date)!;
    return next.addDays(_locate(next)!.length ~/ 2);
  }
}
