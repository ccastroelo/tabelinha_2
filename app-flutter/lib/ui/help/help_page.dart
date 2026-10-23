import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/soft_card.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodyLarge;
    final paragraphs = l10n.helpBody.split('\n\n');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                SoftCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < paragraphs.length; i++) ...[
                        if (i > 0) const SizedBox(height: 16),
                        Text(paragraphs[i], style: style),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
