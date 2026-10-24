import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';

/// Folha de um dia do calendário: diz em que fase ele cai e deixa marcar relação sexual.
///
/// É aqui, e não no toque da célula, porque marcar relação é dado íntimo: um toque solto no
/// calendário não pode gravar isso sem a pessoa ver o que está fazendo.
Future<void> showDaySheet(BuildContext context, DateTime date) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _DaySheet(date: date),
    );

class _DaySheet extends StatelessWidget {
  const _DaySheet({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = AppScope.of(context);
    final theme = Theme.of(context);

    final phase = switch (controller.calculator.kindOf(date)) {
      DayKind.none => l10n.noPhaseDay,
      DayKind.menstruation => l10n.menstruation,
      DayKind.fertile => l10n.fertileWindow,
      DayKind.ovulation => '${l10n.fertileWindow} · ${l10n.ovulation}',
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(fullDate(context, date), style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 4),
            Text(
              phase,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.hasIntercourse(date),
              onChanged: (_) => controller.toggleIntercourse(date),
              title: Text(l10n.intercourse),
              subtitle: Text(l10n.intercourseHint),
            ),
          ],
        ),
      ),
    );
  }
}
