import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';

/// Aviso exibido na primeira abertura. Só segue quem marcar "estou ciente".
class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final controller = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                // Só o texto rola; o botão de seguir fica sempre à vista.
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                    children: [
                      ExcludeSemantics(
                        child: Icon(Icons.info_outline, size: 48, color: scheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        header: true,
                        child: Text(l10n.termsTitle, style: text.headlineMedium),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.termsBody, style: text.bodyLarge?.copyWith(height: 1.5)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CheckboxListTile(
                        value: _agreed,
                        onChanged: (value) => setState(() => _agreed = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.termsAgree),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _agreed ? controller.acceptTerms : null,
                        child: Text(l10n.termsContinue),
                      ),
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
