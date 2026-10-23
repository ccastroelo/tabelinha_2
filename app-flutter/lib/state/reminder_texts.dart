import 'dart:ui';

import '../core/reminders.dart';
import '../data/reminder_service.dart';
import '../l10n/app_localizations.dart';

/// Texto do aviso, no idioma de [l10n]. Sem data e sem nome: a notificação pode aparecer
/// com a tela bloqueada, então diz só o necessário e lembra que é uma estimativa.
ScheduledReminder reminderText(AppLocalizations l10n, PlannedReminder reminder) {
  final (title, body) = switch (reminder.kind) {
    ReminderKind.period => (l10n.reminderPeriodTitle, l10n.reminderPeriodBody(reminder.daysAhead)),
    ReminderKind.fertile => (l10n.reminderFertileTitle, l10n.reminderFertileBody),
    ReminderKind.ovulation => (l10n.reminderOvulationTitle, l10n.reminderOvulationBody),
  };
  return ScheduledReminder(id: reminder.id, at: reminder.at, title: title, body: body);
}

/// Idioma das notificações: o do aparelho, se o app o traduz; senão, inglês.
AppLocalizations reminderLocalizations(Locale device) {
  final supported = AppLocalizations.supportedLocales.any((l) => l.languageCode == device.languageCode);
  return lookupAppLocalizations(supported ? Locale(device.languageCode) : const Locale('en'));
}
