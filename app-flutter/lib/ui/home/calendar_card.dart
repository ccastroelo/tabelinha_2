import 'package:flutter/material.dart';

import '../../core/date_only.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';
import '../history/history_page.dart';
import '../widgets/soft_card.dart';
import 'month_grid.dart';

class CalendarCard extends StatefulWidget {
  const CalendarCard({super.key, required this.captureKey});

  /// Marca a área que vai para a imagem de compartilhamento.
  final GlobalKey captureKey;

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  DateTime? _month;

  void _goTo(DateTime month) => setState(() => _month = firstDayOfMonth(month));

  void _shift(int months) {
    final m = _month!;
    _goTo(DateTime.utc(m.year, m.month + months));
  }

  Future<void> _register(AppController controller, DateTime month) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final ranges = controller.calculator.periodsStartingIn(month.year, month.month);
    final added = await controller.registerPeriods(ranges);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist: false, // com ação, o padrão é ficar até ser dispensado
          content: Text(added > 0 ? l10n.registeredSnack : l10n.alreadyRegisteredSnack),
          action: SnackBarAction(
            label: l10n.viewAction,
            onPressed: () => navigator.push(
              MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final controller = AppScope.of(context);
    final month = _month ??= firstDayOfMonth(controller.today);
    final calculator = controller.calculator;
    final canRegister = calculator.isConfigured &&
        calculator.periodsStartingIn(month.year, month.month).isNotEmpty;

    final cardColor = Theme.of(context).cardTheme.color ?? scheme.surfaceContainerLowest;

    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          RepaintBoundary(
            key: widget.captureKey,
            child: ColoredBox(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
                child: Column(
                  children: [
                    _MonthHeader(
                      title: monthTitle(context, month),
                      onPrevious: () => _shift(-1),
                      onNext: () => _shift(1),
                      onToday: () => _goTo(controller.today),
                    ),
                    const SizedBox(height: 10),
                    const _WeekdayHeader(),
                    const SizedBox(height: 8),
                    // Arrastar para os lados também troca o mês.
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity.abs() < 200) return;
                        _shift(velocity < 0 ? 1 : -1);
                      },
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.topCenter,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.topCenter,
                            children: [...previous, ?current],
                          ),
                          child: MonthGrid(
                            key: ValueKey(month),
                            month: month,
                            calculator: calculator,
                            today: controller.today,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Align(alignment: Alignment.centerLeft, child: CycleLegend()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (canRegister)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _register(controller, month),
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: Text(l10n.registerMonth),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.title,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: l10n.previousMonth,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Tooltip(
              message: l10n.goToToday,
              child: InkWell(
                onTap: onToday,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: l10n.nextMonth,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Builder(builder: (context) {
              final weekday = (material.firstDayOfWeekIndex + i) % 7;
              return Semantics(
                label: weekdayName(context, weekday),
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    material.narrowWeekdays[weekday],
                    textAlign: TextAlign.center,
                    style: style,
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}
