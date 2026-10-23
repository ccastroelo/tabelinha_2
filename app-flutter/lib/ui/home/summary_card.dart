import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../core/date_only.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';
import '../theme.dart';
import '../widgets/hero_banner.dart';
import '../widgets/soft_card.dart';
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

    // Só o título grande fica sobre o coral; o texto corrido vai no cartão branco.
    return Column(
      children: [
        HeroBanner(title: l10n.setupTitle),
        const SizedBox(height: 12),
        SoftCard(
          radius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.setupBody,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
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
      ],
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = CycleColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    final today = controller.today;
    final calculator = controller.calculator;
    final kind = calculator.kindOf(today);
    final cycleDay = l10n.dayOfCycle(calculator.dayOfCycle(today)!);
    final nextOvulation = calculator.nextOvulation(today)!;
    final nextPeriod = calculator.nextPeriodStart(today)!;
    final ovulationIn = nextOvulation.daysSince(today);

    final title = switch (kind) {
      DayKind.menstruation => l10n.menstruation,
      DayKind.fertile => l10n.fertileWindow,
      DayKind.ovulation => l10n.ovulation,
      DayKind.none => null,
    };

    return Column(
      children: [
        HeroBanner(title: title ?? cycleDay, subtitle: title == null ? null : cycleDay),
        const SizedBox(height: 12),
        SoftCard(
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              if (ovulationIn > 0) ...[
                _UpcomingRow(
                  color: colors.ovulation,
                  label: l10n.ovulation,
                  value: '${l10n.inDays(ovulationIn)} · ${dayAndMonth(context, nextOvulation)}',
                ),
                Divider(height: 1, thickness: 1, color: scheme.surface),
              ],
              _UpcomingRow(
                color: colors.menstruation,
                label: l10n.nextPeriod,
                value:
                    '${l10n.inDays(nextPeriod.daysSince(today))} · ${dayAndMonth(context, nextPeriod)}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const SizedBox(width: 40, height: 40),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  Text(value, style: text.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
