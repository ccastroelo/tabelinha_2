import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabelinha/app.dart';
import 'package:tabelinha/data/cycle_repository.dart';
import 'package:tabelinha/state/app_controller.dart';
import 'package:tabelinha/state/app_lock.dart';
import 'package:tabelinha/ui/lock/app_lock_gate.dart';

import 'fake_authenticator.dart';

/// Quarta, 21/10/2026: dia 17 do ciclo, no período fértil.
final _now = DateTime(2026, 10, 21, 15, 30);

const _lockedText = 'The app is locked. Confirm it’s you to see your calendar.';
const _openReason = 'Confirm it’s you to open the app.';

typedef _Rig = ({AppLock lock, FakeAuthenticator auth, AppController controller});

void main() {
  late DateTime clock;
  late FakeAuthenticator auth;

  setUp(() {
    clock = _now;
    auth = FakeAuthenticator();
  });

  Future<_Rig> setup({bool lockEnabled = false, bool locked = true}) async {
    SharedPreferences.setMockInitialValues({
      'termsAcceptedAt': '2026-01-01T10:00:00.000',
      'cycleStart': '2026-10-05',
      'cycleLength': 28,
      'periodLength': 5,
      if (lockEnabled) 'appLockEnabled': true,
    });
    final repository = await CycleRepository.open();
    return (
      lock: AppLock(repository: repository, authenticator: auth, now: () => clock),
      auth: auth,
      controller: AppController(repository, now: () => _now),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    _Rig rig, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    if (textScale != 1) {
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }
    await tester.pumpWidget(TabelinhaApp(controller: rig.controller, lock: rig.lock));
    await tester.pumpAndSettle();
  }

  /// Algo que só existe na home, para saber se o app está à vista.
  final homeVisible = find.text('Fertile period');

  group('tela de bloqueio', () {
    testWidgets('sem o bloqueio ligado o app abre direto e não pede nada', (tester) async {
      final rig = await setup();
      await pump(tester, rig);

      expect(homeVisible, findsWidgets);
      expect(find.text(_lockedText), findsNothing);
      expect(auth.reasons, isEmpty);
    });

    testWidgets('ligado, o app abre trancado e pede a identificação sozinho', (tester) async {
      final rig = await setup(lockEnabled: true);
      final hold = Completer<bool>();
      auth.hold = hold;
      await pump(tester, rig);

      // Enquanto a tela do sistema está aberta, o app inteiro está escondido.
      expect(find.text(_lockedText), findsOneWidget);
      expect(homeVisible, findsNothing);
      expect(find.byType(LockScreen), findsOneWidget);
      expect(auth.reasons, [_openReason]);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

      hold.complete(true);
      await tester.pumpAndSettle();

      expect(find.byType(LockScreen), findsNothing);
      expect(homeVisible, findsWidgets);
    });

    testWidgets('quem cancela vê a mensagem e tenta de novo pelo botão', (tester) async {
      final rig = await setup(lockEnabled: true);
      auth.accept = false;
      await pump(tester, rig);

      expect(find.text('Couldn’t confirm. Try again.'), findsOneWidget);
      expect(homeVisible, findsNothing);
      // Não repete sozinho: a tela do sistema não reaparece em laço.
      expect(auth.reasons, hasLength(1));

      auth.accept = true;
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      expect(auth.reasons, hasLength(2));
      expect(find.byType(LockScreen), findsNothing);
      expect(homeVisible, findsWidgets);
    });

    testWidgets('o app escondido não chega a leitores de tela nem a toques', (tester) async {
      final semantics = tester.ensureSemantics();
      final rig = await setup(lockEnabled: true);
      auth.accept = false;
      await pump(tester, rig);

      // Trancado: nada da home entra na árvore de semântica nem recebe toque.
      final homeLabel = find.bySemanticsLabel(RegExp('Fertile period'));
      expect(homeLabel, findsNothing);
      expect(find.byTooltip('Records'), findsNothing);
      // E a tela de bloqueio, sim, está lá para o leitor de tela.
      expect(find.bySemanticsLabel(RegExp('The app is locked')), findsOneWidget);

      // Controle: depois de destrancar, a mesma busca acha a home (o teste não passa vazio).
      auth.accept = true;
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      expect(homeLabel, findsWidgets);

      // O teste exige liberar a semântica antes de terminar (o tearDown chega tarde).
      semantics.dispose();
    });

    testWidgets('aparelho sem bloqueio de tela: o app abre e o bloqueio se desliga', (tester) async {
      final rig = await setup(lockEnabled: true);
      auth.supported = false;
      await pump(tester, rig);

      expect(find.byType(LockScreen), findsNothing);
      expect(homeVisible, findsWidgets);
      expect(rig.lock.enabled, isFalse);
      expect(auth.reasons, isEmpty);

      await tester.scrollUntilVisible(
        find.text('The lock was turned off because the device no longer has a screen lock.'),
        200,
      );
    });

    testWidgets('a tela de bloqueio cabe em fonte 2,0× num celular pequeno', (tester) async {
      final rig = await setup(lockEnabled: true);
      auth.accept = false;
      await pump(tester, rig, size: const Size(360, 640), textScale: 2);

      expect(find.byType(LockScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ao sair e voltar para o app', () {
    Future<void> unlocked(WidgetTester tester, _Rig rig) async {
      await pump(tester, rig);
      expect(find.byType(LockScreen), findsNothing);
    }

    testWidgets('a capa de privacidade aparece enquanto o app não está na frente', (tester) async {
      final rig = await setup(lockEnabled: true);
      await unlocked(tester, rig);
      expect(find.byType(PrivacyCover), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byType(PrivacyCover), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.byType(PrivacyCover), findsNothing);
      // Foi só uma espiada: não trancou.
      expect(find.byType(LockScreen), findsNothing);
    });

    testWidgets('sem o bloqueio ligado não há capa', (tester) async {
      final rig = await setup();
      await unlocked(tester, rig);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byType(PrivacyCover), findsNothing);
    });

    testWidgets('voltar depois da carência tranca e pede a identificação de novo', (tester) async {
      final rig = await setup(lockEnabled: true);
      await unlocked(tester, rig);
      expect(auth.reasons, hasLength(1));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      clock = clock.add(lockGracePeriod);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // O fake aceita na hora, então já passou pela tela de bloqueio e voltou ao app.
      expect(auth.reasons, hasLength(2));
      expect(find.byType(LockScreen), findsNothing);
      expect(homeVisible, findsWidgets);
    });

    testWidgets('voltar logo em seguida não pede nada', (tester) async {
      final rig = await setup(lockEnabled: true);
      await unlocked(tester, rig);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      clock = clock.add(const Duration(seconds: 5));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(auth.reasons, hasLength(1));
      expect(homeVisible, findsWidgets);
    });

    testWidgets('voltar depois da carência, com a tela do sistema cancelada, fica na tela de bloqueio',
        (tester) async {
      final rig = await setup(lockEnabled: true);
      await unlocked(tester, rig);

      auth.accept = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      clock = clock.add(const Duration(minutes: 5));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.byType(LockScreen), findsOneWidget);
      expect(homeVisible, findsNothing);
    });
  });

  group('cartão "Bloqueio do app"', () {
    final tile = find.widgetWithText(SwitchListTile, 'App lock');
    bool isOn(WidgetTester tester) => tester.widget<SwitchListTile>(tile).value;

    Future<void> show(WidgetTester tester) async {
      await tester.scrollUntilVisible(tile, 200);
      await tester.pumpAndSettle();
    }

    testWidgets('começa desligado, com a explicação', (tester) async {
      final rig = await setup();
      await pump(tester, rig);
      await show(tester);

      expect(isOn(tester), isFalse);
      expect(find.text('Ask for your fingerprint, face or device code to open the app.'), findsOneWidget);
    });

    testWidgets('ligar pede para se identificar e liga', (tester) async {
      final rig = await setup();
      await pump(tester, rig);
      await show(tester);

      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(auth.reasons, ['Confirm it’s you to turn the lock on.']);
      expect(rig.lock.enabled, isTrue);
      expect(isOn(tester), isTrue);
      expect(find.textContaining('after being away for more than half a minute'), findsOneWidget);
      // Quem acabou de ligar não é trancada na hora.
      expect(find.byType(LockScreen), findsNothing);
    });

    testWidgets('se a pessoa cancela, não liga', (tester) async {
      final rig = await setup();
      auth.accept = false;
      await pump(tester, rig);
      await show(tester);

      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(rig.lock.enabled, isFalse);
      expect(isOn(tester), isFalse);
    });

    testWidgets('sem bloqueio de tela no aparelho, o interruptor fica travado e explica', (tester) async {
      final rig = await setup();
      auth.supported = false;
      await pump(tester, rig);
      await show(tester);

      expect(
        find.text('To use the lock, first set a screen lock (PIN, pattern, fingerprint or face) in the device settings.'),
        findsOneWidget,
      );
      expect(tester.widget<SwitchListTile>(tile).onChanged, isNull);
    });

    testWidgets('desligar também pede para se identificar', (tester) async {
      final rig = await setup(lockEnabled: true);
      await pump(tester, rig);
      await show(tester);
      expect(isOn(tester), isTrue);

      auth.accept = false;
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(rig.lock.enabled, isTrue);

      auth.accept = true;
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(auth.reasons.last, 'Confirm it’s you to turn the lock off.');
      expect(rig.lock.enabled, isFalse);
      expect(isOn(tester), isFalse);
    });
  });
}
