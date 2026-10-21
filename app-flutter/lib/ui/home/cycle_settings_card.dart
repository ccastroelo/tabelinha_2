import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';

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
    final controller = AppScope.of(context);
    final settings = controller.settings;
    final start = settings.start;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.yourCycle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(l10n.cycleStart),
              subtitle: Text(start == null ? '—' : shortDate(context, start)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => pickCycleStart(context, controller),
            ),
            _StepperRow(
              label: l10n.cycleLength,
              value: settings.cycleLength,
              min: CycleSettings.minCycleLength,
              max: CycleSettings.maxCycleLength,
              onChanged: controller.setCycleLength,
            ),
            _StepperRow(
              label: l10n.periodLength,
              value: settings.periodLength,
              min: CycleSettings.minPeriodLength,
              max: CycleSettings.maxPeriodLength,
              onChanged: controller.setPeriodLength,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final labelText = Text(label, style: Theme.of(context).textTheme.bodyLarge);
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: l10n.decreaseValue(label),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.daysCount(value),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: l10n.increaseValue(label),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );

    // Com fonte muito grande não sobra largura para rótulo e botões lado a lado.
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 22.4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelText, const SizedBox(height: 4), controls],
            )
          : Row(
              children: [
                Expanded(child: labelText),
                const SizedBox(width: 12),
                controls,
              ],
            ),
    );
  }
}
