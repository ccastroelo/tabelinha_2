import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../core/date_only.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';
import '../theme.dart';
import 'cycle_settings_card.dart';

/// Topo da tela: pede o primeiro dia do ciclo ou mostra a situação de hoje.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return controller.calculator.isConfigured
        ? _TodaySummary(controller: controller)
        : _Setup(controller: controller);
  }
}

class _Setup extends StatelessWidget {
  const _Setup({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.setupTitle,
              style: text.titleLarge?.copyWith(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.setupBody,
              style: text.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => pickCycleStart(context, controller),
              icon: const Icon(Icons.event),
              label: Text(l10n.setupAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = CycleColors.of(context);
    final text = Theme.of(context).textTheme;

    final today = controller.today;
    final calculator = controller.calculator;
    final kind = calculator.kindOf(today);
    final dayOfCycle = calculator.dayOfCycle(today)!;

    final (Color background, Color foreground) = switch (kind) {
      DayKind.menstruation => (colors.menstruation, colors.onMenstruation),
      DayKind.fertile => (colors.fertile, colors.onFertile),
      DayKind.ovulation => (colors.ovulation, colors.onOvulation),
      DayKind.none => (scheme.surfaceContainerHigh, scheme.onSurface),
    };
    final (IconData icon, String? title) = switch (kind) {
      DayKind.menstruation => (Icons.water_drop, l10n.menstruation),
      DayKind.fertile => (Icons.local_florist, l10n.fertileWindow),
      DayKind.ovulation => (Icons.egg_alt, l10n.ovulation),
      DayKind.none => (Icons.calendar_today, null),
    };

    final cycleDay = l10n.dayOfCycle(dayOfCycle);
    final nextOvulation = calculator.nextOvulation(today)!;
    final nextPeriod = calculator.nextPeriodStart(today)!;
    final ovulationIn = nextOvulation.daysSince(today);

    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(child: Icon(icon, color: foreground, size: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: MergeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? cycleDay,
                          style: text.titleLarge?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (title != null)
                          Text(
                            cycleDay,
                            style: text.bodyMedium?.copyWith(color: foreground),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (ovulationIn > 0)
              _UpcomingRow(
                label: l10n.ovulation,
                when: l10n.inDays(ovulationIn),
                date: dayAndMonth(context, nextOvulation),
                color: foreground,
              ),
            _UpcomingRow(
              label: l10n.nextPeriod,
              when: l10n.inDays(nextPeriod.daysSince(today)),
              date: dayAndMonth(context, nextPeriod),
              color: foreground,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({
    required this.label,
    required this.when,
    required this.date,
    required this.color,
  });

  final String label;
  final String when;
  final String date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label, style: text.bodyMedium?.copyWith(color: color)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '$when · $date',
                textAlign: TextAlign.end,
                style: text.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
