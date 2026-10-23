import 'dart:async';

import 'package:tabelinha/state/app_lock.dart';

/// Identificação de mentira: responde o que o teste mandar, sem tocar no sistema.
class FakeAuthenticator implements Authenticator {
  /// O aparelho tem biometria ou bloqueio de tela?
  bool supported = true;

  /// A pessoa se identifica quando a tela do sistema abre?
  bool accept = true;

  bool throwOnSupport = false;
  bool throwOnAuthenticate = false;

  /// Se preenchido, a identificação só termina quando o teste completar isto (para simular a
  /// tela do sistema aberta).
  Completer<bool>? hold;

  int supportChecks = 0;
  final List<String> reasons = [];

  @override
  Future<bool> isSupported() async {
    supportChecks++;
    if (throwOnSupport) throw StateError('plugin quebrou');
    return supported;
  }

  @override
  Future<bool> authenticate(String reason) async {
    reasons.add(reason);
    if (throwOnAuthenticate) throw StateError('plugin quebrou');
    final pending = hold;
    if (pending != null) return pending.future;
    return accept;
  }
}
