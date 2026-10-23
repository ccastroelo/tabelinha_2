import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'reminder_service.dart';

/// Avisos agendados no próprio aparelho, pelo plugin `flutter_local_notifications`.
/// Nada passa por servidor: o sistema operacional guarda os avisos e os mostra na hora.
///
/// Cada aviso é agendado como um instante absoluto: o horário local calculado pelo Dart
/// (que já sabe do horário de verão) convertido para UTC. Por isso não é preciso o banco de
/// fusos do pacote `timezone`, só a classe de data dele. Se a pessoa viajar para outro fuso,
/// os avisos já agendados seguem o horário de antes até o app abrir de novo e reagendar.
class LocalNotificationsService implements ReminderService {
  LocalNotificationsService() : _plugin = FlutterLocalNotificationsPlugin();

  /// Ícone pequeno da barra de status (`res/drawable/ic_stat_tabelinha.xml`).
  static const _androidIcon = 'ic_stat_tabelinha';
  static const _channelId = 'cycle_reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialized;

  /// A permissão só é pedida quando a pessoa liga os lembretes, e não ao abrir o app.
  ///
  /// Se a inicialização falhar, a falha não fica guardada: a próxima chamada tenta de novo, em
  /// vez de todas falharem para sempre com o mesmo erro.
  Future<void> _ensureInitialized() => _initialized ??= _plugin
          .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_androidIcon),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      )
          .then<void>((_) {}, onError: (Object error, StackTrace stack) {
        _initialized = null;
        return Future<void>.error(error, stack);
      });

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> isAllowed() async {
    await _ensureInitialized();
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => await _android?.areNotificationsEnabled() ?? false,
      TargetPlatform.iOS => (await _ios?.checkPermissions())?.isEnabled ?? false,
      _ => false,
    };
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => await _android?.requestNotificationsPermission() ?? false,
      TargetPlatform.iOS => await _ios?.requestPermissions(alert: true, sound: true) ?? false,
      _ => false,
    };
  }

  @override
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required String channelName,
    required String channelDescription,
  }) async {
    await _ensureInitialized();
    await _plugin.cancelAllPendingNotifications();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        channelName,
        channelDescription: channelDescription,
        icon: _androidIcon,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        // Com a tela bloqueada e protegida, o Android esconde o conteúdo do aviso.
        visibility: NotificationVisibility.private,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    for (final reminder in reminders) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.at.toUtc(), tz.UTC),
        notificationDetails: details,
        // Sem alarme exato: o aviso pode atrasar uns minutos, e o app não precisa da
        // permissão de alarmes exatos, que o Android 14 trata como especial.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAllPendingNotifications();
  }
}
