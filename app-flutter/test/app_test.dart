import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabelinha/app.dart';
import 'package:tabelinha/core/cycle_calculator.dart';
import 'package:tabelinha/data/cycle_repository.dart';
import 'package:tabelinha/state/app_controller.dart';

/// Quarta, 21/10/2026 — dia 17 de um ciclo de 28 dias iniciado em 5/10.
final _now = DateTime(2026, 10, 21, 15, 30);

Future<AppController> _controller([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return AppController(await CycleRepository.open(), now: () => _now);
}

Map<String, Object> _configured() => {
      'termsAcceptedAt': '2026-01-01T10:00:00.000',
      'cycleStart': '2026-10-05',
      'cycleLength': 28,
      'periodLength': 5,
    };

/// Viewport de celular (390×844 dp por padrão); o padrão de teste é 800×600.
Future<void> _pump(
  WidgetTester tester,
  AppController controller, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  if (textScale != 1) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  await tester.pumpWidget(TabelinhaApp(controller: controller));
  await tester.pumpAndSettle();
}

/// Rola até [finder] ficar na tela e toca nele.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('termos', () {
    testWidgets('só libera a home depois de marcar "estou ciente"', (tester) async {
      final controller = await _controller();
      await _pump(tester, controller);

      expect(find.text('Attention'), findsOneWidget);
      FilledButton button() => tester.widget(find.byType(FilledButton));
      expect(button().onPressed, isNull);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(button().onPressed, isNotNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Attention'), findsNothing);
      expect(find.text('Let’s get started'), findsOneWidget);
      expect(controller.termsAccepted, isTrue);
    });

    testWidgets('quem já aceitou vai direto para a home', (tester) async {
      await _pump(tester, await _controller(_configured()));
      expect(find.text('Attention'), findsNothing);
    });
  });

  group('home', () {
    testWidgets('sem data de início pede a data em vez de marcar o calendário',
        (tester) async {
      await _pump(tester, await _controller({'termsAcceptedAt': '2026-01-01T10:00:00.000'}));
      expect(find.text('Let’s get started'), findsOneWidget);
      expect(find.text('Enter date'), findsOneWidget);
    });

    testWidgets('resume a situação de hoje e os próximos eventos', (tester) async {
      await _pump(tester, await _controller(_configured()));

      // Dia 17 (offset 16) cai na janela fértil: ovulação foi no dia 15.
      expect(find.text('Fertile period'), findsWidgets);
      expect(find.text('Day 17 of cycle'), findsOneWidget);
      // Próxima ovulação: 5/10 + 28 + 14 = 16/11 → 26 dias.
      expect(find.textContaining('in 26 days'), findsOneWidget);
      // Próxima menstruação: 5/10 + 56 = 2/11 → 12 dias.
      expect(find.textContaining('in 12 days'), findsOneWidget);
    });

    testWidgets('steppers alteram e persistem a duração do ciclo', (tester) async {
      final controller = await _controller(_configured());
      await _pump(tester, controller);

      await _tapVisible(tester, find.byTooltip('Increase: Cycle length'));

      expect(controller.settings.cycleLength, 29);
      expect(find.text('29 days'), findsOneWidget);
      final saved = await SharedPreferences.getInstance();
      expect(saved.getInt('cycleLength'), 29);
    });

    testWidgets('não passa dos limites', (tester) async {
      final controller = await _controller({..._configured(), 'periodLength': 9});
      await _pump(tester, controller);

      await tester.scrollUntilVisible(find.byTooltip('Increase: Period length'), 200);
      // O último "+" da tela é o da duração da menstruação (já no máximo, 9).
      final plus = find.widgetWithIcon(IconButton, Icons.add).last;
      expect(tester.widget<IconButton>(plus).onPressed, isNull);
    });
  });

  group('histórico', () {
    testWidgets('registrar o mês cria o registro uma única vez', (tester) async {
      final controller = await _controller(_configured());
      await _pump(tester, controller);

      Future<void> register() async {
        await _tapVisible(tester, find.text('Log this month’s period'));
      }

      await register();
      expect(find.text('Period saved to your records.'), findsOneWidget);
      expect(controller.records, hasLength(1));
      expect(controller.records.single.start, DateTime.utc(2026, 10, 5));
      expect(controller.records.single.end, DateTime.utc(2026, 10, 9));

      await tester.pump(const Duration(seconds: 5));
      await register();
      expect(find.text('This month was already in your records.'), findsOneWidget);
      expect(controller.records, hasLength(1));
    });

    testWidgets('lista vazia explica como registrar', (tester) async {
      await _pump(tester, await _controller(_configured()));
      await tester.tap(find.byTooltip('Records'));
      await tester.pumpAndSettle();
      expect(find.text('No records yet'), findsOneWidget);
    });

    testWidgets('cartão sem anotação convida a escrever e abre as anotações', (tester) async {
      final controller = await _controller(_configured());
      await controller.registerPeriods(
        [PeriodRange(DateTime.utc(2026, 10, 5), DateTime.utc(2026, 10, 9))],
      );
      await _pump(tester, controller);

      await tester.tap(find.byTooltip('Records'));
      await tester.pumpAndSettle();
      expect(find.text('Add a note'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('Add a note'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('anotação salva ao sair da tela e excluir pode ser desfeito',
        (tester) async {
      final controller = await _controller(_configured());
      await controller.registerPeriods(
        [PeriodRange(DateTime.utc(2026, 10, 5), DateTime.utc(2026, 10, 9))],
      );
      await _pump(tester, controller);

      await tester.tap(find.byTooltip('Records'));
      await tester.pumpAndSettle();
      expect(find.text('5 days'), findsOneWidget);

      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  dor leve  ');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(controller.records.single.note, 'dor leve');
      expect(find.text('dor leve'), findsOneWidget);
      // Com anotação, o rodapé mostra o texto no lugar do convite.
      expect(find.text('Add a note'), findsNothing);

      await tester.drag(find.text('October 2026'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(controller.records, isEmpty);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(controller.records, hasLength(1));
      expect(controller.records.single.note, 'dor leve');
    });
  });

  // Pior caso comum: celular pequeno (360×640 dp) com a fonte do sistema a 2,0×.
  // Um RenderFlex overflow vira exceção no teste, então basta percorrer as telas.
  group('layout com fonte ampliada em tela estreita', () {
    const narrow = Size(360, 640);

    // Sem isto o teste usa a fonte Ahem (glifos quadrados, bem mais largos que a real).
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final nunito = FontLoader('Nunito');
      for (final weight in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
        nunito.addFont(rootBundle.load('assets/fonts/Nunito-$weight.ttf'));
      }
      await nunito.load();
    });

    testWidgets('termos', (tester) async {
      await _pump(tester, await _controller(), size: narrow, textScale: 2);
      expect(find.text('Attention'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('home configurada, do banner aos ajustes', (tester) async {
      await _pump(tester, await _controller(_configured()), size: narrow, textScale: 2);
      expect(find.text('Fertile period'), findsWidgets);

      await tester.scrollUntilVisible(find.byTooltip('Increase: Period length'), 200);
      await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.textContaining('contraceptive'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('home sem data de início', (tester) async {
      await _pump(
        tester,
        await _controller({'termsAcceptedAt': '2026-01-01T10:00:00.000'}),
        size: narrow,
        textScale: 2,
      );
      expect(find.text('Enter date'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('histórico, anotação e ajuda', (tester) async {
      final controller = await _controller(_configured());
      await controller.registerPeriods(
        [PeriodRange(DateTime.utc(2026, 10, 5), DateTime.utc(2026, 10, 9))],
      );
      await _pump(tester, controller, size: narrow, textScale: 2);

      await tester.tap(find.byTooltip('Records'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('October 2026'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Help'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('persistência', () {
    test('ajustes e histórico sobrevivem a reiniciar o app', () async {
      final first = await _controller(_configured());
      await first.setCycleLength(30);
      await first.acceptTerms();
      await first.registerPeriods(
        [PeriodRange(DateTime.utc(2026, 10, 5), DateTime.utc(2026, 10, 9))],
      );
      await first.updateNote(first.records.single, 'nota');

      final second = AppController(await CycleRepository.open(), now: () => _now);
      expect(second.settings.cycleLength, 30);
      expect(second.settings.start, DateTime.utc(2026, 10, 5));
      expect(second.termsAccepted, isTrue);
      expect(second.records.single.note, 'nota');
    });

    test('histórico corrompido não derruba o app', () async {
      final controller = await _controller({'periodRecords': '{nao é json'});
      expect(controller.records, isEmpty);
    });

    test('valores fora dos limites são corrigidos ao carregar', () async {
      final controller = await _controller({'cycleLength': 500, 'periodLength': 0});
      expect(controller.settings.cycleLength, CycleSettings.maxCycleLength);
      expect(controller.settings.periodLength, CycleSettings.minPeriodLength);
    });
  });
}
