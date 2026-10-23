import 'package:flutter/widgets.dart';

import '../data/cycle_repository.dart';

/// Quanto tempo o app pode ficar fora da tela sem pedir a identificação de novo. Evita
/// pedir ao voltar da folha de compartilhar, de um diálogo de permissão ou de uma
/// espiada em outro app.
const lockGracePeriod = Duration(seconds: 30);

/// Como o app pergunta ao aparelho "é você?". É uma interface para o estado do bloqueio e os
/// testes não dependerem do plugin; a implementação de verdade usa o `local_auth`.
abstract class Authenticator {
  /// O aparelho tem alguma forma de identificar a pessoa: biometria ou bloqueio de tela?
  Future<bool> isSupported();

  /// Mostra a tela do sistema (digital, rosto ou código). `true` se a pessoa se identificou;
  /// `false` se cancelou ou falhou.
  Future<bool> authenticate(String reason);
}

/// Não identifica ninguém: para onde não há bloqueio (testes, desktop).
class NoAuthenticator implements Authenticator {
  const NoAuthenticator();

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<bool> authenticate(String reason) async => false;
}

/// Bloqueio opcional do app, com a autenticação do próprio aparelho: o app não guarda senha
/// nem recebe a digital ou o rosto, só ouve "sim" ou "não" do sistema.
///
/// Ligado, o app começa bloqueado e volta a bloquear depois de [gracePeriod] fora da tela.
/// Ligar e desligar exigem se identificar: quem pegar o celular desbloqueado não desliga.
class AppLock extends ChangeNotifier {
  AppLock({
    CycleRepository? repository,
    Authenticator? authenticator,
    DateTime Function()? now,
    this.gracePeriod = lockGracePeriod,
  })  : _repository = repository,
        _authenticator = authenticator ?? const NoAuthenticator(),
        _now = now ?? DateTime.now,
        _enabled = repository?.loadAppLockEnabled() ?? false {
    // Com o bloqueio ligado, o app já abre trancado: nada aparece antes de se identificar.
    _locked = _enabled;
  }

  final CycleRepository? _repository;
  final Authenticator _authenticator;
  final DateTime Function() _now;
  final Duration gracePeriod;

  bool _enabled;
  late bool _locked;
  bool _authenticating = false;
  bool? _supported;
  bool _disabledBySystem = false;

  /// Quando o app saiu da tela, se está fora dela agora.
  DateTime? _leftAt;

  bool get enabled => _enabled;

  /// O conteúdo do app está escondido até a pessoa se identificar.
  bool get locked => _locked;

  /// A tela do sistema está aberta pedindo a identificação.
  bool get authenticating => _authenticating;

  /// O aparelho consegue identificar a pessoa? `null` até a primeira verificação.
  bool? get supported => _supported;

  /// O bloqueio foi desligado sozinho porque o aparelho ficou sem bloqueio de tela.
  bool get disabledBySystem => _disabledBySystem;

  /// Pergunta ao aparelho se ele sabe identificar a pessoa; a tela usa isso para liberar ou
  /// não o interruptor. Os ajustes do sistema mudam fora do app, então se repete ao voltar.
  Future<void> refreshSupport() async {
    final supported = await _checkSupport();
    // Um erro do plugin ("não sei") não muda o que a tela já sabe.
    if (supported == null || supported == _supported) return;
    _supported = supported;
    notifyListeners();
  }

  /// Liga ou desliga o bloqueio, depois de a pessoa se identificar. `false` se o aparelho
  /// não consegue identificar (ao ligar) ou se ela cancelou.
  Future<bool> setEnabled(bool value, {required String reason}) async {
    if (value == _enabled) return true;
    if (value && await _checkSupport() != true) return false;
    if (!await _authenticate(reason)) return false;

    _enabled = value;
    _locked = false;
    _leftAt = null;
    _disabledBySystem = false;
    notifyListeners();
    await _repository?.saveAppLockEnabled(value);
    return true;
  }

  /// Abre o app, se a pessoa se identificar. Sem bloqueio de tela no aparelho não há como
  /// pedir nada: o bloqueio se desliga em vez de trancar a pessoa para fora. Só desliga se o
  /// aparelho garante que não suporta; um erro do plugin ("não sei") mantém tudo trancado.
  Future<bool> unlock(String reason) async {
    if (!_locked) return true;
    if (await _checkSupport() == false) {
      _enabled = false;
      _locked = false;
      _disabledBySystem = true;
      notifyListeners();
      await _repository?.saveAppLockEnabled(false);
      return true;
    }
    if (!await _authenticate(reason)) return false;

    _locked = false;
    notifyListeners();
    return true;
  }

  /// Tranca agora, sem esperar a carência.
  void lockNow() {
    if (!_enabled || _locked) return;
    _locked = true;
    notifyListeners();
  }

  /// O app foi para segundo plano ou voltou. Tranca ao voltar se ficou fora tempo demais.
  void didChangeLifecycle(AppLifecycleState state) {
    // A própria tela de identificação tira o app do primeiro plano: não conta como saída.
    if (!_enabled || _authenticating) return;

    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _leftAt ??= _now();
      case AppLifecycleState.resumed:
        final leftAt = _leftAt;
        _leftAt = null;
        if (leftAt == null) return;
        final now = _now();
        // Relógio que voltou para trás: não dá para saber quanto tempo passou, então tranca.
        if (now.isBefore(leftAt) || now.difference(leftAt) >= gracePeriod) lockNow();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Um erro do plugin ao identificar conta como "não": nunca abre o app nem trava a tela.
  Future<bool> _authenticate(String reason) async {
    _authenticating = true;
    notifyListeners();
    try {
      return await _authenticator.authenticate(reason);
    } catch (error) {
      debugPrint('Bloqueio: $error');
      return false;
    } finally {
      _authenticating = false;
      notifyListeners();
    }
  }

  /// `true` ou `false` conforme o aparelho; `null` se o plugin deu erro e não dá para saber.
  Future<bool?> _checkSupport() async {
    try {
      return await _authenticator.isSupported();
    } catch (error) {
      debugPrint('Bloqueio: $error');
      return null;
    }
  }
}

/// Dá acesso ao [AppLock] a qualquer widget abaixo dele.
class AppLockScope extends InheritedNotifier<AppLock> {
  const AppLockScope({super.key, required AppLock lock, required super.child})
      : super(notifier: lock);

  static AppLock of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLockScope>();
    assert(scope != null, 'AppLockScope não encontrado acima deste contexto');
    return scope!.notifier!;
  }
}
