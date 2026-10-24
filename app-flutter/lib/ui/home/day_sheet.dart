import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../data/intercourse.dart';
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
    final marked = controller.hasIntercourse(date);

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
              value: marked,
              onChanged: (_) => controller.toggleIntercourse(date),
              title: Text(l10n.intercourse),
              subtitle: Text(l10n.intercourseHint),
            ),
            // Só depois de marcar o dia: informar contraceptivo não marca o dia sozinho.
            if (marked) _Contraception(date: date),
          ],
        ),
      ),
    );
  }
}


/// "Com" ou "Sem", e nenhum dos dois quando a pessoa não quis informar. O app não lê risco
/// nenhum disso: é registro, não conselho.
class _Contraception extends StatelessWidget {
  const _Contraception({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = AppScope.of(context);
    final theme = Theme.of(context);
    final current = controller.contraceptionOn(date);

    ButtonSegment<Contraception> segment(Contraception value, String short, String full) =>
        ButtonSegment(
          value: value,
          tooltip: full,
          label: Semantics(label: full, child: ExcludeSemantics(child: Text(short))),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.contraception, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<Contraception>(
            // Tocar o que já está marcado volta para "não informado".
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            segments: [
              segment(Contraception.com, l10n.contraceptionWith, l10n.contraceptionWithLabel),
              segment(
                Contraception.sem,
                l10n.contraceptionWithout,
                l10n.contraceptionWithoutLabel,
              ),
            ],
            selected: current == Contraception.naoInformado ? const {} : {current},
            onSelectionChanged: (selection) => controller.setContraception(
              date,
              selection.isEmpty ? Contraception.naoInformado : selection.first,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.contraceptionHint,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
