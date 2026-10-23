import 'package:flutter/material.dart';

import '../../data/period_record.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../formatters.dart';

/// Anotações de um período. Salva sozinha ao sair da tela.
class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({super.key, required this.recordId});

  final String recordId;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  TextEditingController? _noteController;

  @override
  void dispose() {
    _noteController?.dispose();
    super.dispose();
  }

  PeriodRecord? _find(AppController controller) {
    for (final r in controller.records) {
      if (r.id == widget.recordId) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final controller = AppScope.of(context);

    final record = _find(controller);
    if (record == null) {
      // Excluído (ex.: desfazer não aconteceu a tempo): nada a editar.
      return Scaffold(appBar: AppBar(title: Text(l10n.notesTitle)));
    }
    final noteController = _noteController ??= TextEditingController(text: record.note);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) controller.updateNote(record, noteController.text);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.notesTitle),
          actions: [
            IconButton.filledTonal(
              tooltip: l10n.deleteRecord,
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                controller.removeRecord(record);
                Navigator.of(context).pop();
                messenger
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
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(monthTitle(context, record.start), style: text.headlineSmall),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${shortDate(context, record.start)} – ${shortDate(context, record.end)}'
                          // Espaço não separável: "5 days" não quebra entre o número e a unidade.
                          ' · ${l10n.daysCount(record.length).replaceAll(' ', ' ')}',
                          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    minLines: 6,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    style: text.bodyLarge,
                    decoration: InputDecoration(
                      hintText: l10n.notesHint,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
