import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../widgets/hero_banner.dart';
import '../widgets/soft_card.dart';

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
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    children: [
                      Semantics(header: true, child: HeroBanner(title: l10n.termsTitle)),
                      const SizedBox(height: 12),
                      SoftCard(
                        radius: 24,
                        padding: const EdgeInsets.all(22),
                        child: Text(l10n.termsBody, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SoftCard(
                        radius: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CheckboxListTile(
                          value: _agreed,
                          onChanged: (value) => setState(() => _agreed = value ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.termsAgree,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
