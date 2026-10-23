import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Linha "rótulo  − valor +", com botões de 48 dp. Em fonte muito grande o rótulo vai para
/// cima e os botões para baixo, em vez de os dois disputarem a largura.
class StepperRow extends StatelessWidget {
  const StepperRow({
    super.key,
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.min,
    required this.max,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final int value;

  /// O valor como aparece na tela ("28 dias", "2 dias antes").
  final String valueLabel;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool enabled;

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
          onPressed: enabled && value > min ? () => onChanged(value - 1) : null,
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
                  child: Text(valueLabel, textAlign: TextAlign.center, style: text.titleSmall),
                ),
              ),
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: l10n.increaseValue(label),
          onPressed: enabled && value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );

    final stacked = MediaQuery.textScalerOf(context).scale(16) > 22.4;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelText, const SizedBox(height: 4), controls],
            )
          : LayoutBuilder(
              builder: (context, box) {
                // Os botões não passam do que sobra depois de deixar um mínimo para o rótulo:
                // um valor longo ("2 dias antes") encolhe em vez de espremer o rótulo. Nunca
                // abaixo de 168, o que os dois botões e o valor mínimo ocupam.
                const gap = 12.0;
                const labelMin = 96.0;
                const controlsMin = 48.0 * 2 + 72;
                final controlsMax = (box.maxWidth - gap - labelMin).clamp(controlsMin, double.infinity);
                return Row(
                  children: [
                    Expanded(child: labelText),
                    const SizedBox(width: gap),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: controlsMax),
                      child: controls,
                    ),
                  ],
                );
              },
            ),
    );
  }
}
