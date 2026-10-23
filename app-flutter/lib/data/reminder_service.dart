/// Um aviso pronto para o sistema: o texto já está no idioma da pessoa.
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  final int id;

  /// Momento do aviso, no horário local do aparelho.
  final DateTime at;
  final String title;
  final String body;
}

/// Agenda avisos no próprio aparelho. Nada passa por servidor nem por rede.
///
/// É uma interface para o estado do app e os testes não dependerem do plugin de
/// notificações; a implementação de verdade está em `local_notifications_service.dart`.
abstract class ReminderService {
  /// O sistema deixa o app mostrar notificações agora?
  Future<bool> isAllowed();

  /// Pede a permissão ao sistema (se ainda der para pedir) e diz se ficou liberada.
  Future<bool> requestPermission();

  /// Troca todos os avisos agendados por [reminders]. [channelName] e
  /// [channelDescription] aparecem nos ajustes de notificação do Android.
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required String channelName,
    required String channelDescription,
  });

  /// Cancela todos os avisos agendados.
  Future<void> cancelAll();
}

/// Não agenda nada: para onde não há notificações (testes, desktop).
class NoReminderService implements ReminderService {
  const NoReminderService();

  @override
  Future<bool> isAllowed() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required String channelName,
    required String channelDescription,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}
