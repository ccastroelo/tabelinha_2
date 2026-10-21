import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../help/help_page.dart';
import '../history/history_page.dart';
import 'calendar_card.dart';
import 'cycle_settings_card.dart';
import 'summary_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Voltar ao app em outro dia: "hoje" precisa ser recalculado.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  Future<void> _share(BuildContext buttonContext) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // iPad exige a origem do popover de compartilhamento.
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('Falha ao gerar a imagem');

      final dir = await Directory.systemTemp.createTemp('tabelinha');
      final file = File('${dir.path}/tabelinha.png')
        ..writeAsBytesSync(bytes.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          sharePositionOrigin: origin,
        ),
      );
    } catch (e, stack) {
      debugPrint('Erro ao compartilhar: $e\n$stack');
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareError)));
    }
  }

  void _open(Widget page) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: l10n.shareTooltip,
              onPressed: () => _share(buttonContext),
              icon: const Icon(Icons.ios_share),
            ),
          ),
          IconButton(
            tooltip: l10n.historyTitle,
            onPressed: () => _open(const HistoryPage()),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: l10n.helpTitle,
            onPressed: () => _open(const HelpPage()),
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const SummaryCard(),
                const SizedBox(height: 16),
                CalendarCard(captureKey: _captureKey),
                const SizedBox(height: 16),
                const CycleSettingsCard(),
                const SizedBox(height: 16),
                _EstimateNote(text: l10n.estimateNote),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstimateNote extends StatelessWidget {
  const _EstimateNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
