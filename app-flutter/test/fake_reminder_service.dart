import 'package:tabelinha/data/reminder_service.dart';

/// Serviço de lembretes de mentira: guarda o que seria agendado, sem tocar no sistema.
class FakeReminderService implements ReminderService {
  /// O sistema deixa o app mostrar notificações?
  bool allowed = true;

  /// O que o diálogo de permissão responde quando a pessoa liga os lembretes.
  bool grantOnRequest = true;

  int permissionRequests = 0;
  int cancelCalls = 0;

  /// Cada chamada de `replaceAll`, na ordem.
  final List<List<ScheduledReminder>> schedules = [];

  String? channelName;

  List<ScheduledReminder> get lastSchedule => schedules.last;

  @override
  Future<bool> isAllowed() async => allowed;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (grantOnRequest) allowed = true;
    return grantOnRequest;
  }

  @override
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required String channelName,
    required String channelDescription,
  }) async {
    this.channelName = channelName;
    schedules.add(reminders);
  }

  @override
  Future<void> cancelAll() async => cancelCalls++;
}
