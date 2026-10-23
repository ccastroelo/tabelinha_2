import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabelinha/data/cycle_repository.dart';
import 'package:tabelinha/state/app_lock.dart';

import 'fake_authenticator.dart';

void main() {
  late FakeAuthenticator auth;
  late DateTime clock;
  late CycleRepository repository;

  Future<AppLock> lockWith({bool enabled = false}) async {
    SharedPreferences.setMockInitialValues({if (enabled) 'appLockEnabled': true});
    repository = await CycleRepository.open();
    return AppLock(repository: repository, authenticator: auth, now: () => clock);
  }

  setUp(() {
    auth = FakeAuthenticator();
    clock = DateTime(2026, 10, 23, 10);
  });

  group('estado inicial', () {
    test('sem bloqueio o app abre livre', () async {
      final lock = await lockWith();
      expect(lock.enabled, isFalse);
      expect(lock.locked, isFalse);
    });

    test('com o bloqueio ligado o app já abre trancado', () async {
      final lock = await lockWith(enabled: true);
      expect(lock.enabled, isTrue);
      expect(lock.locked, isTrue);
    });

    test('sem repositório nem plugin é um bloqueio desligado', () {
      final lock = AppLock();
      expect(lock.enabled, isFalse);
      expect(lock.locked, isFalse);
    });
  });

  group('unlock', () {
    test('abre quando a pessoa se identifica, e leva o motivo para a tela do sistema', () async {
      final lock = await lockWith(enabled: true);
      expect(await lock.unlock('motivo'), isTrue);
      expect(lock.locked, isFalse);
      expect(auth.reasons, ['motivo']);
    });

    test('continua trancado se ela cancela ou falha', () async {
      final lock = await lockWith(enabled: true);
      auth.accept = false;
      expect(await lock.unlock('motivo'), isFalse);
      expect(lock.locked, isTrue);
      expect(lock.enabled, isTrue);
    });

    test('destrancado, não pergunta nada', () async {
      final lock = await lockWith();
      expect(await lock.unlock('motivo'), isTrue);
      expect(auth.reasons, isEmpty);
    });

    test('um erro do plugin ao identificar mantém tudo trancado', () async {
      final lock = await lockWith(enabled: true);
      auth.throwOnAuthenticate = true;
      expect(await lock.unlock('motivo'), isFalse);
      expect(lock.locked, isTrue);
      expect(lock.authenticating, isFalse);
    });

    test('aparelho sem bloqueio de tela: o bloqueio se desliga em vez de trancar para fora', () async {
      final lock = await lockWith(enabled: true);
      auth.supported = false;

      expect(await lock.unlock('motivo'), isTrue);
      expect(lock.locked, isFalse);
      expect(lock.enabled, isFalse);
      expect(lock.disabledBySystem, isTrue);
      expect(repository.loadAppLockEnabled(), isFalse);
      expect(auth.reasons, isEmpty);
    });

    test('um erro do plugin ao perguntar se há suporte NÃO desliga o bloqueio', () async {
      final lock = await lockWith(enabled: true);
      auth.throwOnSupport = true;
      auth.accept = false;

      expect(await lock.unlock('motivo'), isFalse);
      expect(lock.locked, isTrue);
      expect(lock.enabled, isTrue);
      expect(lock.disabledBySystem, isFalse);
      expect(repository.loadAppLockEnabled(), isTrue);

      // E se, apesar do erro na pergunta, a pessoa de fato se identifica, o app abre.
      auth.accept = true;
      expect(await lock.unlock('motivo'), isTrue);
      expect(lock.enabled, isTrue);
    });
  });

  group('setEnabled', () {
    test('ligar exige suporte e identificação, e fica gravado', () async {
      final lock = await lockWith();
      expect(await lock.setEnabled(true, reason: 'ligar'), isTrue);

      expect(lock.enabled, isTrue);
      expect(lock.locked, isFalse); // quem acabou de se identificar não é trancada na hora
      expect(auth.reasons, ['ligar']);
      expect(repository.loadAppLockEnabled(), isTrue);

      // Ao abrir de novo, já vem trancado.
      final next = AppLock(repository: repository, authenticator: auth);
      expect(next.locked, isTrue);
    });

    test('ligar sem suporte do aparelho não liga nem pergunta', () async {
      final lock = await lockWith();
      auth.supported = false;

      expect(await lock.setEnabled(true, reason: 'ligar'), isFalse);
      expect(lock.enabled, isFalse);
      expect(auth.reasons, isEmpty);
    });

    test('ligar, se ela cancela, não liga', () async {
      final lock = await lockWith();
      auth.accept = false;

      expect(await lock.setEnabled(true, reason: 'ligar'), isFalse);
      expect(lock.enabled, isFalse);
      expect(repository.loadAppLockEnabled(), isFalse);
    });

    test('desligar também exige se identificar', () async {
      final lock = await lockWith(enabled: true);
      await lock.unlock('abrir');

      auth.accept = false;
      expect(await lock.setEnabled(false, reason: 'desligar'), isFalse);
      expect(lock.enabled, isTrue);

      auth.accept = true;
      expect(await lock.setEnabled(false, reason: 'desligar'), isTrue);
      expect(lock.enabled, isFalse);
      expect(repository.loadAppLockEnabled(), isFalse);
    });

    test('desligar funciona mesmo que o aparelho tenha perdido o bloqueio de tela', () async {
      final lock = await lockWith(enabled: true);
      await lock.unlock('abrir');
      auth.supported = false;
      // Sem suporte já não há como se identificar, mas desligar não pode ser impossível:
      // o `authenticate` do plugin responde, então é ele quem decide.
      expect(await lock.setEnabled(false, reason: 'desligar'), isTrue);
    });

    test('pedir o que já está valendo não pergunta nada', () async {
      final lock = await lockWith();
      expect(await lock.setEnabled(false, reason: 'x'), isTrue);
      expect(auth.reasons, isEmpty);
    });
  });

  group('carência ao voltar para o app', () {
    Future<AppLock> unlocked() async {
      final lock = await lockWith(enabled: true);
      await lock.unlock('abrir');
      return lock;
    }

    test('fora por pouco tempo não tranca', () async {
      final lock = await unlocked();
      lock.didChangeLifecycle(AppLifecycleState.paused);
      clock = clock.add(const Duration(seconds: 10));
      lock.didChangeLifecycle(AppLifecycleState.resumed);
      expect(lock.locked, isFalse);
    });

    test('fora pelo tempo da carência tranca', () async {
      final lock = await unlocked();
      lock.didChangeLifecycle(AppLifecycleState.paused);
      clock = clock.add(lockGracePeriod);
      lock.didChangeLifecycle(AppLifecycleState.resumed);
      expect(lock.locked, isTrue);
    });

    test('hidden conta como sair, e o primeiro momento é o que vale', () async {
      final lock = await unlocked();
      lock.didChangeLifecycle(AppLifecycleState.inactive);
      lock.didChangeLifecycle(AppLifecycleState.hidden);
      clock = clock.add(const Duration(seconds: 20));
      lock.didChangeLifecycle(AppLifecycleState.paused); // não reinicia a contagem
      clock = clock.add(const Duration(seconds: 15));
      lock.didChangeLifecycle(AppLifecycleState.resumed);
      expect(lock.locked, isTrue); // 35 s desde que escondeu
    });

    test('inactive sozinho (folha do sistema, app switcher) não conta como sair', () async {
      final lock = await unlocked();
      lock.didChangeLifecycle(AppLifecycleState.inactive);
      clock = clock.add(const Duration(minutes: 5));
      lock.didChangeLifecycle(AppLifecycleState.resumed);
      expect(lock.locked, isFalse);
    });

    test('relógio que voltou para trás: não dá para confiar, então tranca', () async {
      final lock = await unlocked();
      lock.didChangeLifecycle(AppLifecycleState.paused);
      clock = clock.subtract(const Duration(hours: 1));
      lock.didChangeLifecycle(AppLifecycleState.resumed);
      expect(lock.locked, isTrue);
    });

    test('a própria tela de identificação não conta como sair do app', () async {
      final lock = await lockWith(enabled: true);
      final hold = Completer<bool>();
      auth.hold = hold;

      final pending = lock.unlock('abrir');
      await Future<void>.delayed(Duration.zero);
      expect(lock.authenticating, isTrue);

      // A tela do sistema tira o app do primeiro plano e o devolve, muito depois da carência.
      lock.didChangeLifecycle(AppLifecycleState.paused);
      clock = clock.add(const Duration(minutes: 10));
      lock.didChangeLifecycle(AppLifecycleState.resumed);

      hold.complete(true);
      expect(await pending, isTrue);
      expect(lock.locked, isFalse);
      expect(lock.authenticating, isFalse);
    });

    test('depois de trancar de novo, destrancar funciona outra vez', () async {
      final lock = await unlocked();
      lock.didChangeLifecycle(AppLifecycleState.paused);
      clock = clock.add(const Duration(minutes: 1));
      lock.didChangeLifecycle(AppLifecycleState.resumed);
      expect(lock.locked, isTrue);

      expect(await lock.unlock('abrir'), isTrue);
      expect(lock.locked, isFalse);
    });

    test('sem o bloqueio ligado nada disso acontece', () async {
      final lock = await lockWith();
      lock.didChangeLifecycle(AppLifecycleState.paused);
      clock = clock.add(const Duration(hours: 1));
      lock.didChangeLifecycle(AppLifecycleState.resumed);
      lock.lockNow();
      expect(lock.locked, isFalse);
    });

    test('lockNow tranca na hora, sem carência', () async {
      final lock = await unlocked();
      lock.lockNow();
      expect(lock.locked, isTrue);
    });
  });

  group('refreshSupport', () {
    test('guarda o que o aparelho responde e avisa quem escuta', () async {
      final lock = await lockWith();
      expect(lock.supported, isNull);

      var notified = 0;
      lock.addListener(() => notified++);

      await lock.refreshSupport();
      expect(lock.supported, isTrue);
      expect(notified, 1);

      auth.supported = false;
      await lock.refreshSupport();
      expect(lock.supported, isFalse);
      expect(notified, 2);

      // Mesma resposta: ninguém é incomodado à toa.
      await lock.refreshSupport();
      expect(notified, 2);
    });

    test('um erro do plugin não muda o que já se sabia', () async {
      final lock = await lockWith();
      await lock.refreshSupport();
      auth.throwOnSupport = true;
      await lock.refreshSupport();
      expect(lock.supported, isTrue);
    });
  });
}
