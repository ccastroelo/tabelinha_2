import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabelinha/app.dart';
import 'package:tabelinha/data/cycle_repository.dart';
import 'package:tabelinha/l10n/app_localizations.dart';
import 'package:tabelinha/state/app_controller.dart';
import 'package:tabelinha/ui/home/calendar_card.dart';
import 'package:tabelinha/ui/home/month_grid.dart';
import 'package:tabelinha/ui/theme.dart';

import 'fake_reminder_service.dart';

/// Quarta, 21/10/2026 — dia 17 de um ciclo de 28 dias iniciado em 5/10.
final _now = DateTime(2026, 10, 21, 15, 30);

Map<String, Object> _configured() => {
      'termsAcceptedAt': '2026-01-01T10:00:00.000',
      'cycleStart': '2026-10-05',
      'cycleLength': 28,
      'periodLength': 5,
    };

Future<AppController> _controller([
  Map<String, Object> initial = const {},
  FakeReminderService? reminders,
]) async {
  SharedPreferences.setMockInitialValues(initial);
  return AppController(
    await CycleRepository.open(),
    now: () => _now,
    reminderService: reminders,
  );
}

/// Os textos conferidos aqui são os do português, então o idioma não pode depender da máquina.
void _inPortuguese(WidgetTester tester) {
  tester.platformDispatcher.localesTestValue = const [Locale('pt')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}

Future<void> _pump(WidgetTester tester, AppController controller) async {
  _inPortuguese(tester);
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(TabelinhaApp(controller: controller));
  await tester.pumpAndSettle();
}

/// O dia [day] do mês que o calendário está mostrando.
Finder _day(int day) => find.descendant(
      of: find.byType(CalendarCard),
      matching: find.text('$day'),
    );

/// Só as marcas dentro da grade; a legenda tem um coração próprio.
Finder get _hearts => find.descendant(
      of: find.byType(MonthGrid),
      matching: find.byIcon(Icons.favorite),
    );

Finder get _legend => find.descendant(
      of: find.byType(CycleLegend),
      matching: find.byIcon(Icons.favorite),
    );

void main() {
  group('guardar', () {
    test('marcar e desmarcar o mesmo dia', () async {
      final controller = await _controller();
      final day = DateTime.utc(2026, 10, 20);

      expect(controller.hasIntercourse(day), isFalse);
      await controller.toggleIntercourse(day);
      expect(controller.hasIntercourse(day), isTrue);
      await controller.toggleIntercourse(day);
      expect(controller.hasIntercourse(day), isFalse);
    });

    test('a hora do dia não cria um segundo dia', () async {
      final controller = await _controller();
      await controller.toggleIntercourse(DateTime(2026, 10, 20, 23, 50));

      expect(controller.hasIntercourse(DateTime(2026, 10, 20, 1, 5)), isTrue);
      expect(controller.intercourseDates, hasLength(1));
    });

    test('sobrevive a reiniciar o app', () async {
      final controller = await _controller(_configured());
      await controller.toggleIntercourse(DateTime.utc(2026, 10, 20));

      final reaberto = AppController(await CycleRepository.open(), now: () => _now);
      expect(reaberto.hasIntercourse(DateTime.utc(2026, 10, 20)), isTrue);
    });

    test('a lista guardada é ilegível sem quebrar o app', () async {
      SharedPreferences.setMockInitialValues({
        ..._configured(),
        'intercourseDates': <String>['2026-10-20', 'nao é data', ''],
      });
      final controller = AppController(await CycleRepository.open(), now: () => _now);

      expect(controller.intercourseDates, {DateTime.utc(2026, 10, 20)});
    });

    test('não mexe nos lembretes: nada aqui muda o calendário', () async {
      final reminders = FakeReminderService();
      final controller = await _controller(
        {..._configured(), 'remindersEnabled': true},
        reminders,
      );
      await controller.syncReminders();
      final antes = reminders.schedules.length;

      await controller.toggleIntercourse(DateTime.utc(2026, 10, 20));

      expect(reminders.schedules, hasLength(antes));
    });

    test('a previsão do ciclo não muda', () async {
      final controller = await _controller(_configured());
      final antes = controller.calculator.kindOf(DateTime.utc(2026, 10, 20));

      await controller.toggleIntercourse(DateTime.utc(2026, 10, 20));

      expect(controller.calculator.kindOf(DateTime.utc(2026, 10, 20)), antes);
      expect(controller.effectiveCycleLength, 28);
      expect(controller.records, isEmpty);
    });
  });

  group('calendário', () {
    testWidgets('tocar o dia abre a folha e o interruptor marca', (tester) async {
      final controller = await _controller(_configured());
      await _pump(tester, controller);

      expect(_hearts, findsNothing);

      await tester.tap(_day(20));
      await tester.pumpAndSettle();
      // A legenda do calendário também diz "Relação sexual": procura dentro da folha.
      expect(
        find.descendant(
          of: find.byType(SwitchListTile),
          matching: find.text('Relação sexual'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('20 de outubro de 2026'), findsOneWidget);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(controller.hasIntercourse(DateTime.utc(2026, 10, 20)), isTrue);

      // Fecha a folha: a marca tem de estar no calendário.
      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();
      expect(_hearts, findsOneWidget);
    });

    testWidgets('o dia marcado se anuncia para o leitor de tela', (tester) async {
      final controller = await _controller(_configured());
      await controller.toggleIntercourse(DateTime.utc(2026, 10, 20));
      await _pump(tester, controller);

      expect(
        find.bySemanticsLabel(RegExp(r'^20,.*Relação sexual')),
        findsOneWidget,
      );
    });

    testWidgets('a imagem de compartilhamento sai sem a marca e sem a legenda', (tester) async {
      final controller = await _controller(_configured());
      await controller.toggleIntercourse(DateTime.utc(2026, 10, 20));

      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      Widget card({required bool capturing}) => AppScope(
            controller: controller,
            child: MaterialApp(
              locale: const Locale('pt'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: buildTheme(Brightness.light),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: CalendarCard(captureKey: GlobalKey(), capturing: capturing),
                ),
              ),
            ),
          );

      await tester.pumpWidget(card(capturing: false));
      await tester.pumpAndSettle();
      expect(_hearts, findsOneWidget, reason: 'na tela a marca aparece');
      expect(_legend, findsOneWidget);

      await tester.pumpWidget(card(capturing: true));
      await tester.pumpAndSettle();
      expect(_hearts, findsNothing, reason: 'na captura não sai nada de relação sexual');
      expect(_legend, findsNothing);
      expect(find.text('Relação sexual'), findsNothing);
    });
  });
}
