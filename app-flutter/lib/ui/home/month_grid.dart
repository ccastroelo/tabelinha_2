import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/cycle_calculator.dart';
import '../../core/date_only.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';

const _rowGap = 4.0;
const _cellSize = 44.0;
const _tapTarget = 48.0;

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.calculator,
    required this.today,
    this.intercourse = const {},
    this.onDayTap,
  });

  /// Primeiro dia do mês exibido.
  final DateTime month;
  final CycleCalculator calculator;
  final DateTime today;

  /// Dias marcados com relação sexual. Vem vazio quando a imagem de compartilhamento
  /// está sendo gerada: dado íntimo não sai do aparelho numa foto.
  final Set<DateTime> intercourse;

  /// `null` deixa o calendário só de leitura (é o caso durante a captura da imagem).
  final void Function(DateTime date)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstDayOfWeek = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final lead = positiveMod(month.weekday % 7 - firstDayOfWeek, 7);
    final count = daysInMonth(month.year, month.month);
    final rows = ((lead + count) / 7).ceil();
    final textScale = MediaQuery.textScalerOf(context).scale(16);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Largura limitada pela coluna (telas estreitas); altura cresce com a fonte,
        // para o número nunca ficar espremido.
        final width = math.min(_cellSize, constraints.maxWidth / 7);
        // Com o dia tocável, a célula é um alvo de toque: nunca menos de 48 dp de altura.
        final floor = onDayTap == null ? width : math.max(width, _tapTarget);
        final height = math.max(floor, textScale * 2.2);

        Widget slot(int index) {
          final day = index - lead + 1;
          if (day < 1 || day > count) return SizedBox(height: height);
          final date = DateTime.utc(month.year, month.month, day);
          final cell = Center(
            child: _DayCell(
              day: day,
              kind: calculator.kindOf(date),
              isToday: date.isSameDay(today),
              marked: intercourse.contains(date),
              width: width,
              height: height,
            ),
          );
          final onTap = onDayTap;
          if (onTap == null) return cell;
          return InkWell(
            onTap: () => onTap(date),
            borderRadius: BorderRadius.circular(14),
            child: cell,
          );
        }

        return Column(
          children: [
            for (var r = 0; r < rows; r++)
              Padding(
                padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : _rowGap),
                child: Row(
                  children: [for (var c = 0; c < 7; c++) Expanded(child: slot(r * 7 + c))],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.kind,
    required this.isToday,
    required this.marked,
    required this.width,
    required this.height,
  });

  final int day;
  final DayKind kind;
  final bool isToday;
  final bool marked;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = CycleColors.of(context);

    final (Color? fill, Color foreground, FontWeight weight) = switch (kind) {
      DayKind.none => (null, scheme.onSurface, FontWeight.w600),
      DayKind.menstruation => (colors.menstruation, colors.onMenstruation, FontWeight.w800),
      DayKind.fertile => (colors.fertile, colors.onFertile, FontWeight.w800),
      DayKind.ovulation => (colors.ovulation, colors.onOvulation, FontWeight.w800),
    };
    // O anel de "hoje" precisa contrastar com o preenchimento do próprio dia.
    final ring = switch (kind) {
      DayKind.menstruation => colors.onMenstruation,
      DayKind.ovulation => colors.onOvulation,
      _ => colors.menstruation,
    };
    // Ovulação é sempre um círculo; com fonte grande a célula fica mais alta que larga.
    final isOvulation = kind == DayKind.ovulation;
    final side = math.min(width, height);
    final radius = BorderRadius.circular(isOvulation ? side / 2 : 14);

    final status = switch (kind) {
      DayKind.none => null,
      DayKind.menstruation => l10n.menstruation,
      DayKind.fertile => l10n.fertileWindow,
      DayKind.ovulation => '${l10n.fertileWindow}, ${l10n.ovulation}',
    };
    final label = ['$day', ?status, if (isToday) l10n.today, if (marked) l10n.intercourse]
        .join(', ');

    final number = Text(
      '$day',
      maxLines: 1,
      softWrap: false,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            height: 1.1,
            color: foreground,
            fontWeight: weight,
          ),
    );

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Container(
            width: isOvulation ? side : width,
            height: isOvulation ? side : height,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: fill, borderRadius: radius),
            foregroundDecoration: isToday
                ? BoxDecoration(borderRadius: radius, border: Border.all(color: ring, width: 2.5))
                : null,
            // Período fértil leva um ponto sob o número: não depende só do tom.
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (kind == DayKind.fertile)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      number,
                      const SizedBox(height: 2),
                      DecoratedBox(
                        decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
                        child: const SizedBox(width: 4, height: 4),
                      ),
                    ],
                  )
                else
                  number,
                // O coração vai no canto para não disputar espaço com o número nem com o
                // ponto do dia fértil.
                if (marked)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Icon(Icons.favorite, size: 9, color: foreground),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Legenda em pílulas; cada item repete a forma usada no calendário, não só a cor.
class CycleLegend extends StatelessWidget {
  const CycleLegend({super.key, this.showIntercourse = true});

  /// Fora na imagem de compartilhamento, onde a marca de relação também não aparece.
  final bool showIntercourse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = CycleColors.of(context);

    // Mesmas formas do calendário: quadrado cheio, quadrado tintado com ponto, círculo e anel.
    Widget swatch({Color? fill, Color? border, double borderWidth = 2, Color? dot, bool circle = false}) =>
        DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            shape: circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circle ? null : BorderRadius.circular(5),
            border: border == null ? null : Border.all(color: border, width: borderWidth),
          ),
          child: SizedBox(
            width: 16,
            height: 16,
            child: dot == null
                ? null
                : Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                      child: const SizedBox(width: 4, height: 4),
                    ),
                  ),
          ),
        );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _LegendChip(swatch: swatch(fill: colors.menstruation), label: l10n.menstruation),
        _LegendChip(
          // Tom sozinho some sobre a pílula; o contorno suave e o ponto marcam o dia fértil.
          swatch: swatch(
            fill: colors.fertile,
            border: colors.onFertile.withValues(alpha: 0.35),
            borderWidth: 1,
            dot: colors.onFertile,
          ),
          label: l10n.fertileWindow,
        ),
        _LegendChip(swatch: swatch(fill: colors.ovulation, circle: true), label: l10n.ovulation),
        _LegendChip(swatch: swatch(border: colors.menstruation), label: l10n.today),
        if (showIntercourse)
          _LegendChip(
            swatch: SizedBox(
              width: 16,
              height: 16,
              child: Icon(Icons.favorite, size: 12, color: colors.menstruation),
            ),
            label: l10n.intercourse,
          ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.swatch, required this.label});

  final Widget swatch;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: swatch),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
