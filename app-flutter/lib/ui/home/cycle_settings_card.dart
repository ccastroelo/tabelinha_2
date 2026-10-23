import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';
import '../theme.dart';
import '../widgets/soft_card.dart';
import '../widgets/stepper_row.dart';

/// Abre o seletor de data e grava o primeiro dia do ciclo.
Future<void> pickCycleStart(BuildContext context, AppController controller) async {
  final today = controller.today;
  final current = controller.settings.start ?? today;

  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime(current.year, current.month, current.day),
    firstDate: DateTime(2000),
    lastDate: DateTime(today.year + 1, today.month, today.day),
  );
  if (picked != null) await controller.setCycleStart(picked);
}

class CycleSettingsCard extends StatelessWidget {
  const CycleSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final controller = AppScope.of(context);
    final settings = controller.settings;
    final divider = Divider(height: 1, thickness: 1, color: scheme.surface);

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.yourCycle, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 4),
          _StartDateRow(
            start: settings.start,
            onTap: () => pickCycleStart(context, controller),
          ),
          divider,
          StepperRow(
            label: l10n.cycleLength,
            value: controller.effectiveCycleLength,
            valueLabel: l10n.daysCount(controller.effectiveCycleLength),
            min: CycleSettings.minCycleLength,
            max: CycleSettings.maxCycleLength,
            // Com a média em uso, o valor não é da pessoa: para mudar, desliga o cálculo.
            enabled: controller.estimate == null,
            onChanged: controller.setCycleLength,
          ),
          _AutoCycleRow(
            enabled: settings.autoCycleLength,
            estimate: controller.estimate,
            onChanged: controller.setAutoCycleLength,
          ),
          divider,
          StepperRow(
            label: l10n.periodLength,
            value: settings.periodLength,
            valueLabel: l10n.daysCount(settings.periodLength),
            min: CycleSettings.minPeriodLength,
            max: CycleSettings.maxPeriodLength,
            onChanged: controller.setPeriodLength,
          ),
        ],
      ),
    );
  }
}

class _StartDateRow extends StatelessWidget {
  const _StartDateRow({required this.start, required this.onTap});

  final DateTime? start;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final colors = CycleColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Row(
          children: [
            ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(color: colors.tonal, shape: BoxShape.circle),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.event_outlined, size: 20, color: colors.onTonal),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cycleStart,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      start == null ? '—' : shortDate(context, start!),
                      style: text.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
            ExcludeSemantics(
              child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Liga e desliga o cálculo pelo histórico e diz, numa frase, o que está valendo.
class _AutoCycleRow extends StatelessWidget {
  const _AutoCycleRow({
    required this.enabled,
    required this.estimate,
    required this.onChanged,
  });

  final bool enabled;
  final CycleEstimate? estimate;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final estimate = this.estimate;
    final status = !enabled
        ? l10n.autoCycleOff
        : estimate != null
            ? l10n.autoCycleUsing(estimate.cycleLength, estimate.cycles)
            : l10n.autoCycleNeedsData(estimateMinCycles + 1);

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: enabled,
      onChanged: onChanged,
      title: Text(
        l10n.autoCycleTitle,
        style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        status,
        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
