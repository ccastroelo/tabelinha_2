import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_lock.dart';
import '../widgets/soft_card.dart';

/// Liga e desliga o bloqueio do app, que usa a digital, o rosto ou o código do próprio
/// aparelho. Sem bloqueio de tela no aparelho não há como identificar a pessoa: o interruptor
/// fica desligado e a frase explica o que fazer.
class AppLockCard extends StatelessWidget {
  const AppLockCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final lock = AppLockScope.of(context);

    final status = lock.enabled
        ? l10n.appLockHintOn
        : lock.disabledBySystem
            ? l10n.appLockDisabledBySystem
            : lock.supported == false
                ? l10n.appLockUnavailable
                : l10n.appLockHintOff;

    // Ligado, dá para desligar sempre; desligado, só se o aparelho sabe identificar.
    final canToggle = lock.enabled || lock.supported == true;

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: lock.enabled,
        onChanged: canToggle
            ? (on) => lock.setEnabled(
                  on,
                  reason: on ? l10n.appLockReasonEnable : l10n.appLockReasonDisable,
                )
            : null,
        title: Semantics(
          header: true,
          child: Text(l10n.appLockTitle, style: text.titleMedium),
        ),
        subtitle: Text(
          status,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
