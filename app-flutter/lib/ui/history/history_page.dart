import 'package:flutter/material.dart';

import '../../data/period_record.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';
import '../theme.dart';
import '../widgets/soft_card.dart';
import 'record_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final records = AppScope.of(context).records;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: records.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _RecordTile(record: records[index]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = CycleColors.of(context);
    final text = Theme.of(context).textTheme;

    // ListView para rolar em telas baixas ou com fonte grande.
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        Center(
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(color: colors.tonal, shape: BoxShape.circle),
              child: SizedBox(
                width: 88,
                height: 88,
                child: Icon(Icons.history, size: 40, color: colors.onTonal),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(l10n.historyEmptyTitle, textAlign: TextAlign.center, style: text.titleMedium),
        const SizedBox(height: 8),
        Text(
          l10n.historyEmptyBody,
          textAlign: TextAlign.center,
          style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Rodapé do cartão. Sempre aparece, com seta, para deixar claro que o cartão abre as
/// anotações: sem anotação convida a escrever; com anotação mostra o começo dela.
class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = CycleColors.of(context);
    final text = Theme.of(context).textTheme;
    final hasNote = note.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Icon(
              hasNote ? Icons.notes : Icons.edit_note,
              size: 22,
              color: hasNote ? scheme.onSurfaceVariant : colors.onTonal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: hasNote
                ? Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyLarge?.copyWith(height: 1.35),
                  )
                : Text(
                    l10n.addNote,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onTonal,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          ExcludeSemantics(
            child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final PeriodRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final controller = AppScope.of(context);
    final colors = CycleColors.of(context);

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) {
        controller.removeRecord(record);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              persist: false,
              content: Text(l10n.recordRemoved),
              action: SnackBarAction(
                label: l10n.undo,
                onPressed: () => controller.putRecord(record),
              ),
            ),
          );
      },
      child: SoftCard(
        radius: 24,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RecordDetailPage(recordId: record.id),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(monthTitle(context, record.start), style: text.titleMedium),
                        ),
                        const SizedBox(width: 12),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.tonal,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              l10n.daysCount(record.length),
                              style: text.labelLarge?.copyWith(fontSize: 14, color: colors.onTonal),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shortDate(context, record.start)} – ${shortDate(context, record.end)}',
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    // Barra proporcional à duração (máx. 9 dias); decorativa, o texto acima já diz.
                    ExcludeSemantics(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (record.length / 9).clamp(0.0, 1.0),
                          minHeight: 8,
                          color: colors.menstruation,
                          backgroundColor: colors.tonal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: scheme.surface),
              _NoteRow(note: record.note),
            ],
          ),
        ),
      ),
    );
  }
}
