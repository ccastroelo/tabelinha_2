import 'package:local_auth/local_auth.dart';

import '../state/app_lock.dart';

/// Identifica a pessoa com o que o aparelho tem: digital, rosto ou, na falta deles (ou se ela
/// preferir), o código de bloqueio de tela. Usa o plugin `local_auth`.
///
/// O app só recebe "sim" ou "não" do sistema: não vê a digital nem o rosto, nem o código.
class LocalAuthAuthenticator implements Authenticator {
  LocalAuthAuthenticator() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  /// Verdadeiro se há biometria ou um bloqueio de tela (PIN, padrão, senha) configurado.
  @override
  Future<bool> isSupported() => _auth.isDeviceSupported();

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        // Aceita também o código do aparelho: quem não tem biometria, ou a biometria que
        // falhou, não fica de fora.
        biometricOnly: false,
        // Uma ligação ou outro aviso tira o app da frente no meio do pedido: espera voltar
        // e pergunta de novo, em vez de dar o pedido por cancelado.
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      // Cancelou, errou demais, bloqueio temporário: para o app é tudo "não".
      return false;
    }
  }
}
