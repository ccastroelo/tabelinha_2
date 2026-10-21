import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../core/date_only.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// Altura de cada semana. Cresce com a escala de texto para o número nunca
/// ficar espremido dentro do círculo/faixa.
double _rowHeight(BuildContext context) =>
    math.max(48, MediaQuery.textScalerOf(context).scale(16) * 2.4);

/// Faixa de fundo que cobre o dia: 0 = nenhuma, 1 = menstruação, 2 = fértil.
int _band(DayKind kind) => switch (kind) {
      DayKind.none => 0,
      DayKind.menstruation => 1,
      DayKind.fertile || DayKind.ovulation => 2,
    };

class _Cell {
  const _Cell(this.day, this.kind, this.isToday);
  final int day;
  final DayKind kind;
  final bool isToday;
}

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.calculator,
    required this.today,
  });

  /// Primeiro dia do mês exibido.
  final DateTime month;
  final CycleCalculator calculator;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final firstDayOfWeek = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final lead = positiveMod(month.weekday % 7 - firstDayOfWeek, 7);
    final count = daysInMonth(month.year, month.month);
    final rows = ((lead + count) / 7).ceil();

    _Cell? cellAt(int index) {
      final day = index - lead + 1;
      if (day < 1 || day > count) return null;
      final date = DateTime.utc(month.year, month.month, day);
      return _Cell(day, calculator.kindOf(date), date.isSameDay(today));
    }

    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          _WeekRow(cells: [for (var c = 0; c < 7; c++) cellAt(r * 7 + c)]),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.cells});

  final List<_Cell?> cells;

  @override
  Widget build(BuildContext context) {
    final colors = CycleColors.of(context);
    final height = _rowHeight(context);

    // Agrupa dias vizinhos da mesma faixa: cada grupo vira uma pílula só.
    final groups = <List<_Cell?>>[];
    for (final cell in cells) {
      final band = cell == null ? 0 : _band(cell.kind);
      if (groups.isNotEmpty) {
        final last = groups.last.last;
        if ((last == null ? 0 : _band(last.kind)) == band) {
          groups.last.add(cell);
          continue;
        }
      }
      groups.add([cell]);
    }

    return Row(
      children: [
        for (final group in groups)
          Expanded(
            flex: group.length,
            child: Stack(
              children: [
                if (group.first != null && _band(group.first!.kind) != 0)
                  Positioned.fill(
                    top: 6,
                    bottom: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.bandFor(group.first!.kind),
                        borderRadius: BorderRadius.circular(height),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    for (final cell in group)
                      Expanded(
                        child: cell == null
                            ? SizedBox(height: height)
                            : _DayCell(cell: cell, height: height),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.cell, required this.height});

  final _Cell cell;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = CycleColors.of(context);

    final isOvulation = cell.kind == DayKind.ovulation;
    final textColor = switch (cell.kind) {
      DayKind.none => scheme.onSurface,
      DayKind.ovulation => colors.onOvulation,
      _ => colors.onBandFor(cell.kind),
    };
    final status = switch (cell.kind) {
      DayKind.none => null,
      DayKind.menstruation => l10n.menstruation,
      DayKind.fertile => l10n.fertileWindow,
      DayKind.ovulation => '${l10n.fertileWindow}, ${l10n.ovulation}',
    };
    final label = [
      '${cell.day}',
      ?status,
      if (cell.isToday) l10n.today,
    ].join(', ');

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isOvulation)
              _Disc(diameter: height - 12, color: colors.ovulation),
            if (cell.isToday)
              _Disc(diameter: height - 8, ringColor: scheme.onSurface),
            Text(
              '${cell.day}',
              maxLines: 1,
              softWrap: false,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: cell.isToday || isOvulation
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.diameter, this.color, this.ringColor});

  final double diameter;
  final Color? color;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: ringColor == null ? null : Border.all(color: ringColor!, width: 2),
      ),
    );
  }
}

/// Legenda: cada item repete a forma usada no calendário, não só a cor.
class CycleLegend extends StatelessWidget {
  const CycleLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = CycleColors.of(context);

    Widget pill(Color color) => Container(
          width: 24,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
        );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(swatch: pill(colors.menstruation), label: l10n.menstruation),
        _LegendItem(swatch: pill(colors.fertile), label: l10n.fertileWindow),
        _LegendItem(
          swatch: _Disc(diameter: 16, color: colors.ovulation),
          label: l10n.ovulation,
        ),
        _LegendItem(
          swatch: _Disc(diameter: 16, ringColor: scheme.onSurface),
          label: l10n.today,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.swatch, required this.label});

  final Widget swatch;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: swatch),
        const SizedBox(width: 8),
        Flexible(child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
      ],
    );
  }
}
