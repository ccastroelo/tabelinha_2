import 'package:flutter_test/flutter_test.dart';
import 'package:tabelinha/core/cycle_calculator.dart';
import 'package:tabelinha/core/date_only.dart';

DateTime d(int year, int month, int day) => DateTime.utc(year, month, day);

PeriodRange range(DateTime start, [int length = 5]) =>
    PeriodRange(start, start.addDays(length - 1));

void main() {
  final today = d(2026, 10, 23);

  group('estimateCycleLength', () {
    test('sem três menstruações não há média', () {
      expect(estimateCycleLength([], today: today), isNull);
      expect(estimateCycleLength([d(2026, 9, 7)], today: today), isNull);
      // Dois inícios dão um ciclo só, e um ciclo só não é média.
      expect(estimateCycleLength([d(2026, 9, 7), d(2026, 10, 5)], today: today), isNull);
    });

    test('média arredondada dos intervalos', () {
      // 28 e 29 dias: 28,5 arredonda para 29.
      final estimate = estimateCycleLength(
        [d(2026, 8, 10), d(2026, 9, 7), d(2026, 10, 6)],
        today: today,
      );
      expect(estimate!.cycleLength, 29);
      expect(estimate.cycles, 2);
    });

    test('a ordem em que os inícios chegam não importa', () {
      final estimate = estimateCycleLength(
        [d(2026, 10, 6), d(2026, 8, 10), d(2026, 9, 7)],
        today: today,
      );
      expect(estimate!.cycleLength, 29);
    });

    test('usa só os seis ciclos mais recentes', () {
      // Dois ciclos antigos de 40 dias e seis de 28: os de 40 ficam de fora.
      var start = d(2026, 1, 1);
      final starts = [start];
      for (final days in [40, 40, 28, 28, 28, 28, 28, 28]) {
        start = start.addDays(days);
        starts.add(start);
      }
      final estimate = estimateCycleLength(starts, today: start);
      expect(estimate!.cycleLength, 28);
      expect(estimate.cycles, estimateMaxCycles);
    });

    test('um buraco sem registro não vira um ciclo de meses', () {
      final estimate = estimateCycleLength(
        [d(2026, 1, 1), d(2026, 1, 29), d(2026, 5, 1), d(2026, 5, 29)],
        today: today,
      );
      // 1/1→29/1 (28), 29/1→1/5 (92, descartado), 1/5→29/5 (28).
      expect(estimate!.cycleLength, 28);
      expect(estimate.cycles, 2);
    });

    test('começos que ainda não aconteceram não entram', () {
      final estimate = estimateCycleLength(
        [d(2026, 8, 10), d(2026, 9, 7), d(2026, 10, 6), d(2026, 12, 1)],
        today: today,
      );
      expect(estimate!.cycles, 2);
      expect(estimate.cycleLength, 29);
    });

    test('o resultado respeita os limites do app', () {
      expect(
        estimateCycleLength(
          [d(2026, 1, 1), d(2026, 1, 9), d(2026, 1, 17)],
          today: today,
        )!
            .cycleLength,
        CycleSettings.minCycleLength,
      );
    });
  });

  group('knownPeriods', () {
    List<PeriodRange> known({
      DateTime? reference,
      List<PeriodRange> records = const [],
      int periodLength = 5,
    }) =>
        knownPeriods(
          reference: reference,
          periodLength: periodLength,
          records: records,
          today: today,
        );

    test('junta a referência e os registros, em ordem', () {
      final out = known(
        reference: d(2026, 10, 5),
        records: [range(d(2026, 9, 7)), range(d(2026, 8, 10))],
      );
      expect(out.map((p) => p.start), [d(2026, 8, 10), d(2026, 9, 7), d(2026, 10, 5)]);
    });

    test('registros que ainda não começaram ficam de fora', () {
      final out = known(
        reference: d(2026, 10, 5),
        records: [range(d(2026, 11, 2))],
      );
      expect(out.map((p) => p.start), [d(2026, 10, 5)]);
    });

    test('datas coladas são a mesma menstruação: sem referência, vale a mais tardia', () {
      final out = known(records: [range(d(2026, 9, 7)), range(d(2026, 9, 9))]);
      expect(out.single.start, d(2026, 9, 9));
    });

    test('datas coladas: a referência, que a pessoa acabou de informar, vence', () {
      final out = known(
        reference: d(2026, 10, 3),
        records: [range(d(2026, 10, 5))],
      );
      expect(out.single.start, d(2026, 10, 3));
      expect(out.single.length, 5);
    });

    test('no mesmo dia vale o registro, que tem o fim real', () {
      final out = known(
        reference: d(2026, 10, 5),
        records: [range(d(2026, 10, 5), 7)],
        periodLength: 5,
      );
      expect(out.single.length, 7);
    });

    test('ciclos curtos de verdade não são fundidos', () {
      // 8 dias é o menor ciclo que o app aceita.
      final out = known(records: [range(d(2026, 9, 1)), range(d(2026, 9, 9))]);
      expect(out, hasLength(2));
    });

    test('sem referência nem registros, nada', () {
      expect(known(), isEmpty);
    });
  });

  group('calculadora com ciclos conhecidos', () {
    // Ago 10 (6 dias) → Set 7 (28 dias) → Out 6 (29 dias). A média é 29 e o último
    // início conhecido é 6/10.
    final aug = range(d(2026, 8, 10), 6);
    final sep = range(d(2026, 9, 7));
    final oct = range(d(2026, 10, 6));

    CycleCalculator calc({List<PeriodRange>? known, int cycle = 29}) => CycleCalculator(
          CycleSettings(start: d(2026, 10, 6), cycleLength: cycle),
          known: known ?? [aug, sep, oct],
        );

    test('ciclos vividos usam a duração real de cada um', () {
      final c = calc();
      // Ago 10 → Set 7 durou 28 dias: ovulação no 14º dia depois do início.
      expect(c.kindOf(d(2026, 8, 24)), DayKind.ovulation);
      // Set 7 → Out 6 durou 29 dias: a ovulação também cai 14 dias depois.
      expect(c.kindOf(d(2026, 9, 21)), DayKind.ovulation);
      expect(c.dayOfCycle(d(2026, 9, 7)), 1);
      expect(c.dayOfCycle(d(2026, 10, 5)), 29);
    });

    test('a menstruação de um ciclo vivido tem a duração registrada', () {
      final c = calc();
      // Agosto foi registrado com 6 dias.
      expect(c.kindOf(d(2026, 8, 15)), DayKind.menstruation);
      expect(c.kindOf(d(2026, 8, 16)), DayKind.none);
      // Setembro, com 5.
      expect(c.kindOf(d(2026, 9, 11)), DayKind.menstruation);
      expect(c.kindOf(d(2026, 9, 12)), DayKind.none);
    });

    test('depois do último início projeta com a média', () {
      final c = calc();
      expect(c.nextPeriodStart(d(2026, 10, 23)), d(2026, 11, 4)); // 6/10 + 29
      expect(c.kindOf(d(2026, 11, 4)), DayKind.menstruation);
      expect(c.kindOf(d(2026, 11, 3)), DayKind.none); // último dia do ciclo de 29
      // Janela fértil do ciclo atual: 6/10 + 10 até 6/10 + 18.
      expect(c.kindOf(d(2026, 10, 15)), DayKind.none);
      expect(c.kindOf(d(2026, 10, 16)), DayKind.fertile);
      expect(c.kindOf(d(2026, 10, 24)), DayKind.fertile);
      expect(c.kindOf(d(2026, 10, 25)), DayKind.none);
      // Ovulação do ciclo atual: 6/10 + 14 = 20/10.
      expect(c.kindOf(d(2026, 10, 20)), DayKind.ovulation);
      expect(c.nextOvulation(d(2026, 10, 20)), d(2026, 10, 20));
      // Já passou: a próxima é a do ciclo seguinte, 4/11 + 14.
      expect(c.nextOvulation(d(2026, 10, 23)), d(2026, 11, 18));
    });

    test('a janela fértil continua sendo de 9 dias', () {
      final c = calc();
      final fertile = [
        for (var i = 0; i < 29; i++)
          if (c.kindOf(d(2026, 10, 6).addDays(i)) != DayKind.none &&
              c.kindOf(d(2026, 10, 6).addDays(i)) != DayKind.menstruation)
            i,
      ];
      // Ovulação no 14º dia, quatro dias para cada lado.
      expect(fertile.first, 14 - fertileHalfWindow);
      expect(fertile.last, 14 + fertileHalfWindow);
      expect(fertile, hasLength(2 * fertileHalfWindow + 1));
    });

    test('antes do primeiro início conhecido projeta para trás com a média', () {
      final c = calc();
      // 10/8 - 29 = 12/7.
      expect(c.kindOf(d(2026, 7, 12)), DayKind.menstruation);
      expect(c.dayOfCycle(d(2026, 7, 11)), 29);
    });

    test('lista as menstruações do mês com as datas reais', () {
      final c = calc();
      final september = c.periodsStartingIn(2026, 9);
      expect(september.single.start, d(2026, 9, 7));
      expect(september.single.end, d(2026, 9, 11));
      expect(c.periodsStartingIn(2026, 8).single.length, 6);
      // Novembro é projeção: 4/11 (6/10 + 29), com a duração definida.
      expect(c.periodsStartingIn(2026, 11).single.start, d(2026, 11, 4));
    });

    test('um intervalo longo demais é buraco, não ciclo: projeta com a média', () {
      final c = CycleCalculator(
        CycleSettings(start: d(2026, 6, 1), cycleLength: 28),
        known: [range(d(2026, 1, 1)), range(d(2026, 6, 1))],
      );
      // Entre 1/1 e 1/6 (151 dias) vale a projeção de 28 dias, não um "ciclo" de 151.
      expect(c.dayOfCycle(d(2026, 1, 29)), 1);
      expect(c.nextPeriodStart(d(2026, 1, 2)), d(2026, 1, 29));
      // Perto do fim do buraco, o início conhecido (1/6) chega antes do projetado.
      expect(c.nextPeriodStart(d(2026, 5, 30)), d(2026, 6, 1));
    });

    test('ciclos regulares dão o mesmo calendário do modelo antigo', () {
      // Início de referência e registros todos a 28 dias: usar o histórico não pode
      // mudar nada em relação a projetar um ciclo só.
      final settings = CycleSettings(start: d(2026, 10, 5), cycleLength: 28);
      final old = CycleCalculator(settings);
      final withKnown = CycleCalculator(
        settings,
        known: [
          for (var i = -3; i <= 0; i++) range(d(2026, 10, 5).addDays(28 * i)),
        ],
      );

      for (var offset = -28 * 8; offset <= 28 * 6; offset++) {
        final day = d(2026, 10, 5).addDays(offset);
        expect(withKnown.kindOf(day), old.kindOf(day), reason: 'dia $offset');
        expect(withKnown.dayOfCycle(day), old.dayOfCycle(day), reason: 'dia $offset');
        expect(withKnown.nextPeriodStart(day), old.nextPeriodStart(day), reason: 'dia $offset');
        expect(withKnown.nextOvulation(day), old.nextOvulation(day), reason: 'dia $offset');
      }
      for (var month = 1; month <= 12; month++) {
        expect(
          withKnown.periodsStartingIn(2026, month).map((p) => (p.start, p.end)).toList(),
          old.periodsStartingIn(2026, month).map((p) => (p.start, p.end)).toList(),
          reason: 'mês $month',
        );
      }
    });

    test('sem data de início nada é marcado, mesmo com histórico', () {
      final c = CycleCalculator(const CycleSettings(), known: [sep]);
      expect(c.kindOf(d(2026, 9, 8)), DayKind.none);
      expect(c.nextPeriodStart(d(2026, 9, 8)), isNull);
      expect(c.periodsStartingIn(2026, 9), isEmpty);
    });
  });
}
