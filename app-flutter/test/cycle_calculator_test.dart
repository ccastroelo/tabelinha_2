import 'package:flutter_test/flutter_test.dart';
import 'package:tabelinha/core/cycle_calculator.dart';
import 'package:tabelinha/core/date_only.dart';

/// Tradução literal de `retornaStatusDaCelula:` do app Objective-C original
/// (0 = nada, 1 = menstruação, 3 = fértil, 9 = ovulação).
int legacyStatus(DateTime day, DateTime start, int cycle, int period) {
  var dias = day.daysSince(start);
  if (dias >= cycle) dias = dias % cycle;
  if (dias < 0) {
    dias = day.daysSince(start.addDays(-cycle));
  }
  var status = 0;
  if (dias >= 0 && dias < period) status = 1;
  if (dias >= cycle ~/ 2 - 4 && dias <= cycle ~/ 2 + 4) status = 3;
  if (dias == cycle ~/ 2) status = 9;
  return status;
}

DayKind legacyKind(int status) => switch (status) {
      1 => DayKind.menstruation,
      3 => DayKind.fertile,
      9 => DayKind.ovulation,
      _ => DayKind.none,
    };

void main() {
  final start = DateTime.utc(2026, 10, 5);

  CycleCalculator calc({int cycle = 28, int period = 5, DateTime? from}) =>
      CycleCalculator(
        CycleSettings(start: from ?? start, cycleLength: cycle, periodLength: period),
      );

  group('kindOf', () {
    test('ciclo padrão de 28 dias', () {
      final c = calc();
      expect(c.kindOf(start), DayKind.menstruation);
      expect(c.kindOf(start.addDays(4)), DayKind.menstruation);
      expect(c.kindOf(start.addDays(5)), DayKind.none);
      expect(c.kindOf(start.addDays(9)), DayKind.none);
      expect(c.kindOf(start.addDays(10)), DayKind.fertile);
      expect(c.kindOf(start.addDays(14)), DayKind.ovulation);
      expect(c.kindOf(start.addDays(18)), DayKind.fertile);
      expect(c.kindOf(start.addDays(19)), DayKind.none);
      expect(c.kindOf(start.addDays(28)), DayKind.menstruation);
    });

    test('sem data de início nada é marcado', () {
      const c = CycleCalculator(CycleSettings());
      expect(c.kindOf(DateTime.utc(2026, 1, 1)), DayKind.none);
      expect(c.dayOfCycle(DateTime.utc(2026, 1, 1)), isNull);
    });

    test('projeta o ciclo para trás da data de início', () {
      final c = calc();
      expect(c.kindOf(start.addDays(-28)), DayKind.menstruation);
      expect(c.kindOf(start.addDays(-14)), DayKind.ovulation);
      // O app original só projetava um ciclo para trás; aqui vale para qualquer data.
      expect(c.kindOf(start.addDays(-28 * 10)), DayKind.menstruation);
    });

    test('é idêntico ao algoritmo original para todas as combinações', () {
      for (var cycle = CycleSettings.minCycleLength;
          cycle <= CycleSettings.maxCycleLength;
          cycle++) {
        for (var period = CycleSettings.minPeriodLength;
            period <= CycleSettings.maxPeriodLength;
            period++) {
          final c = calc(cycle: cycle, period: period);
          // O original só enxergava até um ciclo antes do início.
          for (var offset = -cycle; offset <= cycle * 4; offset++) {
            final day = start.addDays(offset);
            expect(
              c.kindOf(day),
              legacyKind(legacyStatus(day, start, cycle, period)),
              reason: 'ciclo=$cycle menstruação=$period dia=$offset',
            );
          }
        }
      }
    });

    test('atravessa virada de horário de verão sem desviar', () {
      // 2026-11-01 é o fim do horário de verão nos EUA; em UTC nada muda.
      final c = calc(from: DateTime.utc(2026, 10, 25));
      expect(c.kindOf(DateTime.utc(2026, 11, 22)), DayKind.menstruation);
    });
  });

  group('dayOfCycle', () {
    test('começa em 1 e reinicia a cada ciclo', () {
      final c = calc();
      expect(c.dayOfCycle(start), 1);
      expect(c.dayOfCycle(start.addDays(27)), 28);
      expect(c.dayOfCycle(start.addDays(28)), 1);
      expect(c.dayOfCycle(start.addDays(-1)), 28);
    });
  });

  group('periodsStartingIn', () {
    test('lista menstruações que começam no mês, com fim calculado', () {
      final c = calc();
      final out = c.periodsStartingIn(2026, 10);
      expect(out, hasLength(1));
      expect(out.single.start, DateTime.utc(2026, 10, 5));
      expect(out.single.end, DateTime.utc(2026, 10, 9));
      expect(out.single.length, 5);
    });

    test('pode haver duas no mesmo mês', () {
      // Início em 1º de outubro, ciclo de 28 dias: 1/10 e 29/10.
      final c = calc(from: DateTime.utc(2026, 10, 1));
      final out = c.periodsStartingIn(2026, 10);
      expect(out.map((p) => p.start), [
        DateTime.utc(2026, 10, 1),
        DateTime.utc(2026, 10, 29),
      ]);
    });

    test('menstruação que começa no fim do mês termina no seguinte', () {
      final c = calc(from: DateTime.utc(2026, 10, 30));
      final out = c.periodsStartingIn(2026, 10);
      // 2/10 vem da projeção do ciclo para trás; 30/10 é o início informado.
      expect(out.map((p) => p.start), [
        DateTime.utc(2026, 10, 2),
        DateTime.utc(2026, 10, 30),
      ]);
      expect(out.last.end, DateTime.utc(2026, 11, 3));
      // E a cauda de novembro não conta como início de nada em novembro.
      expect(c.periodsStartingIn(2026, 11).single.start, DateTime.utc(2026, 11, 27));
    });

    test('vazio sem data de início', () {
      expect(const CycleCalculator(CycleSettings()).periodsStartingIn(2026, 10), isEmpty);
    });
  });

  group('próximos eventos', () {
    test('nextPeriodStart é estritamente depois da data', () {
      final c = calc();
      expect(c.nextPeriodStart(start), start.addDays(28));
      expect(c.nextPeriodStart(start.addDays(27)), start.addDays(28));
      expect(c.nextPeriodStart(start.addDays(-1)), start);
    });

    test('nextOvulation inclui a própria data', () {
      final c = calc();
      expect(c.nextOvulation(start.addDays(14)), start.addDays(14));
      expect(c.nextOvulation(start.addDays(15)), start.addDays(28 + 14));
      expect(c.nextOvulation(start), start.addDays(14));
    });
  });

  group('CycleSettings', () {
    test('copyWith respeita os limites', () {
      const s = CycleSettings();
      expect(s.copyWith(cycleLength: 2).cycleLength, CycleSettings.minCycleLength);
      expect(s.copyWith(cycleLength: 99).cycleLength, CycleSettings.maxCycleLength);
      expect(s.copyWith(periodLength: 0).periodLength, CycleSettings.minPeriodLength);
      expect(s.copyWith(periodLength: 20).periodLength, CycleSettings.maxPeriodLength);
    });
  });
}
