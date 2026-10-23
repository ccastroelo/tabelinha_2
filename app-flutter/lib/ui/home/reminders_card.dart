import 'package:flutter/material.dart';

import '../../core/reminders.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../theme.dart';
import '../widgets/soft_card.dart';
import '../widgets/stepper_row.dart';

/// Lembretes opcionais: avisos no próprio aparelho sobre a próxima menstruação, o início do
/// período fértil e a ovulação. Desligados até a pessoa ligar; o sistema pede permissão.
class RemindersCard extends StatelessWidget {
  const RemindersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final controller = AppScope.of(context);
    final settings = controller.reminders;
    final divider = Divider(height: 1, thickness: 1, color: scheme.surface);

    void update(ReminderSettings next) => controller.updateReminders(next);

    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: settings.hour, minute: settings.minute));

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: settings.enabled,
            onChanged: controller.setRemindersEnabled,
            title: Semantics(
              header: true,
              child: Text(l10n.remindersTitle, style: text.titleMedium),
            ),
            subtitle: Text(
              settings.enabled ? l10n.remindersHintOn(time) : l10n.remindersHintOff,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          if (controller.remindersBlocked) const _BlockedNotice(),
          if (settings.enabled) ...[
            divider,
            _TimeRow(
              time: time,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
                );
                if (picked != null) {
                  update(settings.copyWith(hour: picked.hour, minute: picked.minute));
                }
              },
            ),
            divider,
            _ToggleRow(
              label: l10n.nextPeriod,
              value: settings.period,
              onChanged: (on) => update(settings.copyWith(period: on)),
            ),
            if (settings.period)
              StepperRow(
                label: l10n.reminderAdvance,
                value: settings.periodDaysBefore,
                valueLabel: l10n.reminderDaysBefore(settings.periodDaysBefore),
                min: 0,
                max: maxReminderDaysBefore,
                onChanged: (days) => update(settings.copyWith(periodDaysBefore: days)),
              ),
            _ToggleRow(
              label: l10n.reminderFertileToggle,
              value: settings.fertile,
              onChanged: (on) => update(settings.copyWith(fertile: on)),
            ),
            _ToggleRow(
              label: l10n.reminderOvulationToggle,
              value: settings.ovulation,
              onChanged: (on) => update(settings.copyWith(ovulation: on)),
            ),
          ],
        ],
      ),
    );
  }
}

/// O sistema bloqueia as notificações: sem isto a pessoa liga o interruptor e nada acontece.
class _BlockedNotice extends StatelessWidget {
  const _BlockedNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = CycleColors.of(context);
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.tonal, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(Icons.notifications_off_outlined, size: 22, color: colors.onTonal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.remindersBlocked,
                    style: text.bodyMedium?.copyWith(color: colors.onTonal),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.time, required this.onTap});

  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: MergeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reminderTime,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(time, style: text.titleSmall),
              const SizedBox(width: 4),
              ExcludeSemantics(
                child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(label, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
