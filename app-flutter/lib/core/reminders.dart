import 'cycle_calculator.dart';
import 'date_only.dart';

/// Os três avisos que o app sabe dar.
enum ReminderKind { period, fertile, ovulation }

/// Por quantos dias à frente os avisos são agendados. O app reagenda toda vez que abre,
/// então isto só precisa cobrir o tempo entre uma abertura e outra: cerca de quatro ciclos
/// e meio, ou uns 14 avisos (o iOS aceita 64 agendados de uma vez).
const reminderHorizonDays = 130;

/// Quantos dias antes da menstruação o aviso pode vir, no máximo.
const maxReminderDaysBefore = 7;

class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.hour = 9,
    this.minute = 0,
    this.periodDaysBefore = 2,
    this.period = true,
    this.fertile = true,
    this.ovulation = true,
  });

  /// Liga todos os avisos. Desligado por padrão: o sistema pede permissão ao ligar.
  final bool enabled;

  /// Hora do dia em que o aviso aparece.
  final int hour;
  final int minute;

  /// Com quantos dias de antecedência vem o aviso da menstruação (0 = no próprio dia).
  final int periodDaysBefore;

  /// Quais avisos estão ligados.
  final bool period;
  final bool fertile;
  final bool ovulation;

  bool isOn(ReminderKind kind) => switch (kind) {
        ReminderKind.period => period,
        ReminderKind.fertile => fertile,
        ReminderKind.ovulation => ovulation,
      };

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    int? periodDaysBefore,
    bool? period,
    bool? fertile,
    bool? ovulation,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: (hour ?? this.hour).clamp(0, 23),
      minute: (minute ?? this.minute).clamp(0, 59),
      periodDaysBefore: (periodDaysBefore ?? this.periodDaysBefore).clamp(0, maxReminderDaysBefore),
      period: period ?? this.period,
      fertile: fertile ?? this.fertile,
      ovulation: ovulation ?? this.ovulation,
    );
  }
}

/// Um aviso já calculado: o que avisar e quando.
class PlannedReminder {
  const PlannedReminder({required this.kind, required this.event, required this.at});

  final ReminderKind kind;

  /// Dia do acontecimento previsto (a menstruação começa, a ovulação cai...).
  final DateTime event;

  /// Momento em que o aviso aparece, no horário local do aparelho.
  final DateTime at;

  /// Quantos dias faltam, no dia do aviso, para o acontecimento.
  int get daysAhead => event.daysSince(dateOnly(at));

  /// Número estável: reagendar o mesmo aviso mantém o mesmo id, e dois avisos nunca
  /// dividem um. Cabe nos 32 bits que o Android exige.
  int get id => kind.index * 100000 + event.daysSince(DateTime.utc(2020));
}

/// Calcula os avisos dos próximos [horizonDays] dias a partir do que o calendário prevê.
///
/// Só entram avisos que ainda vão acontecer ([now] exclusive). Sem lembretes ligados ou sem
/// data de início, não há nada a avisar. [now] é o horário local; os dias do calendário
/// são UTC à meia-noite, como no resto do app.
List<PlannedReminder> planReminders({
  required CycleCalculator calculator,
  required ReminderSettings settings,
  required DateTime now,
  int horizonDays = reminderHorizonDays,
}) {
  if (!settings.enabled || !calculator.isConfigured) return const [];

  bool inFertileWindow(DateTime day) {
    final kind = calculator.kindOf(day);
    return kind == DayKind.fertile || kind == DayKind.ovulation;
  }

  final today = dateOnly(now);
  final planned = <PlannedReminder>[];

  void add(ReminderKind kind, DateTime event, int daysBefore) {
    if (!settings.isOn(kind)) return;
    final day = event.addDays(-daysBefore);
    final at = DateTime(day.year, day.month, day.day, settings.hour, settings.minute);
    final withinHorizon = !day.isAfter(today.addDays(horizonDays));
    if (withinHorizon && at.isAfter(now)) {
      planned.add(PlannedReminder(kind: kind, event: event, at: at));
    }
  }

  // Os acontecimentos vão até o fim do horizonte mais a antecedência máxima, para não
  // perder o aviso de uma menstruação logo depois do corte.
  for (var i = 0; i <= horizonDays + maxReminderDaysBefore; i++) {
    final day = today.addDays(i);

    if (calculator.dayOfCycle(day) == 1) add(ReminderKind.period, day, settings.periodDaysBefore);
    if (inFertileWindow(day) && !inFertileWindow(day.addDays(-1))) {
      add(ReminderKind.fertile, day, 0);
    }
    if (calculator.kindOf(day) == DayKind.ovulation) add(ReminderKind.ovulation, day, 0);
  }

  planned.sort((a, b) => a.at.compareTo(b.at));
  return planned;
}
