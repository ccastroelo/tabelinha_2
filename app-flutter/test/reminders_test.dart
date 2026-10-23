import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabelinha/core/cycle_calculator.dart';
import 'package:tabelinha/core/date_only.dart';
import 'package:tabelinha/core/reminders.dart';
import 'package:tabelinha/data/cycle_repository.dart';
import 'package:tabelinha/data/reminder_service.dart';
import 'package:tabelinha/state/app_controller.dart';

import 'fake_reminder_service.dart';

DateTime d(int year, int month, int day) => DateTime.utc(year, month, day);

void main() {
  // Sexta, 17/10/2026, 10h30. Ciclo de 28 dias com início em 5/10 e menstruação de 5 dias:
  // fértil de 15 a 23/10 (ovulação dia 19), próxima menstruação em 2/11.
  final now = DateTime(2026, 10, 17, 10, 30);
  final calculator = CycleCalculator(
    CycleSettings(start: d(2026, 10, 5), cycleLength: 28, periodLength: 5),
  );
  const on = ReminderSettings(enabled: true);

  String summary(PlannedReminder r) =>
      '${r.kind.name} ${r.event.month}/${r.event.day} → '
      '${r.at.month}/${r.at.day} ${r.at.hour}:${r.at.minute.toString().padLeft(2, '0')}';

  group('planReminders', () {
    test('lista os próximos avisos em ordem, cada um no seu dia e hora', () {
      final plan = planReminders(calculator: calculator, settings: on, now: now);

      expect(plan.take(5).map(summary), [
        // O início do período fértil (15/10) já passou; a ovulação (19/10) ainda não.
        'ovulation 10/19 → 10/19 9:00',
        // Menstruação de 2/11, avisada 2 dias antes.
        'period 11/2 → 10/31 9:00',
        'fertile 11/12 → 11/12 9:00',
        'ovulation 11/16 → 11/16 9:00',
        'period 11/30 → 11/28 9:00',
      ]);
    });

    test('sem lembretes ligados ou sem data de início não há aviso', () {
      expect(
        planReminders(calculator: calculator, settings: const ReminderSettings(), now: now),
        isEmpty,
      );
      expect(
        planReminders(
          calculator: const CycleCalculator(CycleSettings()),
          settings: on,
          now: now,
        ),
        isEmpty,
      );
    });

    test('cada aviso pode ser desligado', () {
      List<ReminderKind> kinds(ReminderSettings s) =>
          planReminders(calculator: calculator, settings: s, now: now)
              .map((r) => r.kind)
              .toSet()
              .toList()
            ..sort((a, b) => a.index.compareTo(b.index));

      expect(kinds(on.copyWith(period: false)), [ReminderKind.fertile, ReminderKind.ovulation]);
      expect(kinds(on.copyWith(fertile: false)), [ReminderKind.period, ReminderKind.ovulation]);
      expect(kinds(on.copyWith(ovulation: false)), [ReminderKind.period, ReminderKind.fertile]);
      expect(
        planReminders(
          calculator: calculator,
          settings: on.copyWith(period: false, fertile: false, ovulation: false),
          now: now,
        ),
        isEmpty,
      );
    });

    test('a antecedência só vale para a menstruação', () {
      final sameDay = planReminders(
        calculator: calculator,
        settings: on.copyWith(periodDaysBefore: 0),
        now: now,
      ).where((r) => r.kind == ReminderKind.period).first;
      expect(summary(sameDay), 'period 11/2 → 11/2 9:00');

      final weekBefore = planReminders(
        calculator: calculator,
        settings: on.copyWith(periodDaysBefore: 7),
        now: now,
      ).where((r) => r.kind == ReminderKind.period).first;
      expect(summary(weekBefore), 'period 11/2 → 10/26 9:00');
      expect(weekBefore.daysAhead, 7);

      // Ovulação e período fértil avisam sempre no dia.
      final others = planReminders(
        calculator: calculator,
        settings: on.copyWith(periodDaysBefore: 7),
        now: now,
      ).where((r) => r.kind != ReminderKind.period);
      expect(others.every((r) => r.daysAhead == 0), isTrue);
    });

    test('o horário escolhido vale para todos', () {
      final plan = planReminders(
        calculator: calculator,
        settings: on.copyWith(hour: 7, minute: 45),
        now: now,
      );
      expect(plan.every((r) => r.at.hour == 7 && r.at.minute == 45), isTrue);
    });

    test('só avisa o que ainda vai acontecer', () {
      // Às 10h do dia 19, o aviso de 9h da ovulação já passou.
      final plan = planReminders(
        calculator: calculator,
        settings: on,
        now: DateTime(2026, 10, 19, 10),
      );
      expect(plan.first.event, d(2026, 11, 2)); // a menstruação, e não a ovulação de hoje
      expect(plan.every((r) => r.at.isAfter(DateTime(2026, 10, 19, 10))), isTrue);

      // Às 8h do mesmo dia, ainda dá tempo.
      final early = planReminders(
        calculator: calculator,
        settings: on,
        now: DateTime(2026, 10, 19, 8),
      );
      expect(summary(early.first), 'ovulation 10/19 → 10/19 9:00');
    });

    test('respeita o horizonte e cabe no limite do iOS', () {
      final plan = planReminders(calculator: calculator, settings: on, now: now);
      final limit = dateOnly(now).addDays(reminderHorizonDays);
      expect(plan.every((r) => !dateOnly(r.at).isAfter(limit)), isTrue);
      expect(plan.length, lessThan(64));
      expect(plan.length, greaterThan(9)); // vários ciclos à frente

      // Mesmo no pior caso (ciclo curto, três avisos), cabe nos 64 agendados do iOS.
      final shortCycle = CycleCalculator(
        CycleSettings(start: d(2026, 10, 5), cycleLength: 21, periodLength: 5),
      );
      expect(
        planReminders(calculator: shortCycle, settings: on, now: now).length,
        lessThan(64),
      );
    });

    test('os números dos avisos são únicos, estáveis e cabem em 32 bits', () {
      final plan = planReminders(calculator: calculator, settings: on, now: now);
      expect(plan.map((r) => r.id).toSet(), hasLength(plan.length));
      expect(plan.every((r) => r.id > 0 && r.id < 1 << 31), isTrue);

      // O mesmo acontecimento tem o mesmo número, qualquer que seja o horário do aviso.
      final later = planReminders(
        calculator: calculator,
        settings: on.copyWith(hour: 21),
        now: now,
      );
      expect(later.map((r) => r.id), plan.map((r) => r.id));
    });

    test('segue a previsão do calendário, inclusive pelo histórico', () {
      // Três menstruações a 28 e 29 dias: a média é 29 e a próxima começa em 4/11.
      final history = CycleCalculator(
        CycleSettings(start: d(2026, 10, 6), cycleLength: 29),
        known: [
          PeriodRange(d(2026, 8, 10), d(2026, 8, 14)),
          PeriodRange(d(2026, 9, 7), d(2026, 9, 11)),
          PeriodRange(d(2026, 10, 6), d(2026, 10, 10)),
        ],
      );
      final period = planReminders(calculator: history, settings: on, now: now)
          .firstWhere((r) => r.kind == ReminderKind.period);
      expect(summary(period), 'period 11/4 → 11/2 9:00');
    });
  });

  group('ReminderSettings', () {
    test('copyWith respeita os limites', () {
      const s = ReminderSettings();
      expect(s.copyWith(hour: 30).hour, 23);
      expect(s.copyWith(hour: -1).hour, 0);
      expect(s.copyWith(minute: 99).minute, 59);
      expect(s.copyWith(periodDaysBefore: 20).periodDaysBefore, maxReminderDaysBefore);
      expect(s.copyWith(periodDaysBefore: -3).periodDaysBefore, 0);
    });

    test('começa desligado e com os três avisos ligados', () {
      const s = ReminderSettings();
      expect(s.enabled, isFalse);
      expect([s.period, s.fertile, s.ovulation], everyElement(isTrue));
    });
  });

  group('AppController e os lembretes', () {
    Future<(AppController, FakeReminderService)> setup({
      Locale locale = const Locale('en'),
      bool configured = true,
      Map<String, Object> extra = const {},
    }) async {
      SharedPreferences.setMockInitialValues({
        'termsAcceptedAt': '2026-01-01T10:00:00.000',
        if (configured) ...{'cycleStart': '2026-10-05', 'cycleLength': 28, 'periodLength': 5},
        ...extra,
      });
      final service = FakeReminderService();
      final controller = AppController(
        await CycleRepository.open(),
        now: () => now,
        reminderService: service,
        deviceLocale: () => locale,
      );
      return (controller, service);
    }

    test('nada é agendado enquanto os lembretes estão desligados', () async {
      final (controller, service) = await setup();
      await controller.syncReminders();
      expect(service.schedules, isEmpty);
      expect(service.permissionRequests, 0);
      expect(service.cancelCalls, 0);
    });

    test('ligar pede a permissão e agenda os avisos', () async {
      final (controller, service) = await setup();
      await controller.setRemindersEnabled(true);

      expect(service.permissionRequests, 1);
      expect(controller.reminders.enabled, isTrue);
      expect(controller.remindersBlocked, isFalse);
      expect(service.lastSchedule, isNotEmpty);
      expect(service.lastSchedule.first.at, DateTime(2026, 10, 19, 9));
    });

    test('permissão negada: continua desligado e avisa a tela', () async {
      final (controller, service) = await setup();
      service.grantOnRequest = false;
      service.allowed = false;

      await controller.setRemindersEnabled(true);

      expect(controller.reminders.enabled, isFalse);
      expect(controller.remindersBlocked, isTrue);
      expect(service.schedules, isEmpty);
    });

    test('um erro do plugin ao pedir a permissão não estoura: fica desligado e avisa a tela', () async {
      final (controller, service) = await setup();
      service.throwOnRequest = true;

      // Não pode lançar: quem chama é o toque no interruptor.
      await controller.setRemindersEnabled(true);

      expect(controller.reminders.enabled, isFalse);
      expect(controller.remindersBlocked, isTrue);
      expect(service.schedules, isEmpty);
    });

    test('mudar o ciclo, o histórico ou os avisos reagenda', () async {
      final (controller, service) = await setup();
      await controller.setRemindersEnabled(true);
      final first = service.schedules.length;

      await controller.setCycleLength(30);
      await controller.syncReminders();
      expect(service.schedules.length, greaterThan(first));
      // Com 30 dias, a próxima menstruação passa de 2/11 para 4/11 (aviso em 2/11).
      final period = service.lastSchedule.firstWhere((r) => r.title == 'Period coming up');
      expect(period.at, DateTime(2026, 11, 2, 9));

      final before = service.schedules.length;
      await controller.updateReminders(controller.reminders.copyWith(hour: 7, minute: 30));
      expect(service.schedules.length, greaterThan(before));
      expect(service.lastSchedule.every((r) => r.at.hour == 7 && r.at.minute == 30), isTrue);

      final beforeRecords = service.schedules.length;
      await controller.registerPeriods([
        PeriodRange(d(2026, 10, 5), d(2026, 10, 9)),
      ]);
      await controller.syncReminders();
      expect(service.schedules.length, greaterThan(beforeRecords));
    });

    test('desligar cancela tudo, e depois não agenda mais nada', () async {
      final (controller, service) = await setup();
      await controller.setRemindersEnabled(true);
      final scheduled = service.schedules.length;

      await controller.setRemindersEnabled(false);
      expect(service.cancelCalls, 1);
      expect(controller.reminders.enabled, isFalse);

      await controller.setCycleLength(30);
      await controller.syncReminders();
      expect(service.schedules.length, scheduled);
    });

    test('a permissão tirada nos ajustes do sistema vira aviso na tela', () async {
      final (controller, service) = await setup();
      await controller.setRemindersEnabled(true);

      service.allowed = false;
      await controller.syncReminders();
      expect(controller.remindersBlocked, isTrue);
      expect(service.cancelCalls, 1);

      // E, se a pessoa libera de novo, os avisos voltam sozinhos.
      service.allowed = true;
      final before = service.schedules.length;
      await controller.syncReminders();
      expect(controller.remindersBlocked, isFalse);
      expect(service.schedules.length, greaterThan(before));
    });

    test('updateReminders não liga nem desliga: isso passa pela permissão', () async {
      final (controller, service) = await setup();
      await controller.updateReminders(controller.reminders.copyWith(enabled: true));
      expect(controller.reminders.enabled, isFalse);
      expect(service.permissionRequests, 0);
    });

    test('o texto do aviso segue o idioma do aparelho', () async {
      final (pt, ptService) = await setup(locale: const Locale('pt'));
      await pt.setRemindersEnabled(true);
      final ptPeriod = ptService.lastSchedule.firstWhere((r) => r.title == 'Menstruação a caminho');
      expect(ptPeriod.body, 'Sua menstruação está prevista para daqui a 2 dias. É só uma estimativa.');
      expect(ptService.channelName, 'Lembretes do ciclo');

      final (es, esService) = await setup(locale: const Locale('es'));
      await es.setRemindersEnabled(true);
      expect(esService.lastSchedule.map((r) => r.title), contains('Menstruación en camino'));

      // Um idioma que o app não traduz cai no inglês.
      final (fr, frService) = await setup(locale: const Locale('fr'));
      await fr.setRemindersEnabled(true);
      expect(frService.lastSchedule.map((r) => r.title), contains('Period coming up'));
    });

    test('o texto da menstruação diz hoje, amanhã ou quantos dias faltam', () async {
      Future<String> body(int daysBefore) async {
        final (controller, service) = await setup();
        await controller.setRemindersEnabled(true);
        await controller.updateReminders(controller.reminders.copyWith(periodDaysBefore: daysBefore));
        return service.lastSchedule.firstWhere((r) => r.title == 'Period coming up').body;
      }

      expect(await body(0), 'Your period is expected today. It’s only an estimate.');
      expect(await body(1), 'Your period is expected tomorrow. It’s only an estimate.');
      expect(await body(3), 'Your period is expected in 3 days. It’s only an estimate.');
    });

    test('as escolhas sobrevivem a reiniciar o app', () async {
      final (controller, _) = await setup();
      await controller.setRemindersEnabled(true);
      await controller.updateReminders(
        controller.reminders.copyWith(hour: 21, minute: 15, periodDaysBefore: 4, fertile: false),
      );

      final second = AppController(
        await CycleRepository.open(),
        now: () => now,
        reminderService: FakeReminderService(),
      );
      final r = second.reminders;
      expect((r.enabled, r.hour, r.minute, r.periodDaysBefore), (true, 21, 15, 4));
      expect((r.period, r.fertile, r.ovulation), (true, false, true));
    });

    test('sem data de início, ligar não agenda nada, mas não dá erro', () async {
      final (controller, service) = await setup(configured: false);
      await controller.setRemindersEnabled(true);
      expect(controller.reminders.enabled, isTrue);
      expect(service.lastSchedule, isEmpty);
    });

    test('um erro do plugin não derruba o app', () async {
      final (controller, service) = await setup();
      await controller.setRemindersEnabled(true);
      service.allowed = true;
      // Um serviço que quebra não pode estourar na cara de quem mexe nos dados.
      final broken = _BrokenService();
      final c2 = AppController(
        await CycleRepository.open(),
        now: () => now,
        reminderService: broken,
      );
      await c2.syncReminders();
      await c2.setCycleLength(29);
      expect(c2.settings.cycleLength, 29);
    });
  });
}

class _BrokenService extends FakeReminderService {
  @override
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required String channelName,
    required String channelDescription,
  }) async =>
      throw StateError('plugin quebrou');
}
