import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';
import '../theme.dart';
import '../widgets/soft_card.dart';

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
          _StepperRow(
            label: l10n.cycleLength,
            value: settings.cycleLength,
            min: CycleSettings.minCycleLength,
            max: CycleSettings.maxCycleLength,
            onChanged: controller.setCycleLength,
          ),
          divider,
          _StepperRow(
            label: l10n.periodLength,
            value: settings.periodLength,
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
    final text = Theme.of(context).textTheme;

    final labelText = Text(label, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700));
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: l10n.decreaseValue(label),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        // Flexible + FittedBox: se faltar largura o valor encolhe em vez de estourar a linha.
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Semantics(
                liveRegion: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.daysCount(value),
                    textAlign: TextAlign.center,
                    style: text.titleSmall,
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
