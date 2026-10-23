import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_lock.dart';
import '../theme.dart';
import '../widgets/dot_grid.dart';
import '../widgets/soft_card.dart';

/// Fica acima de todas as telas do app (no `builder` do `MaterialApp`) e cuida do bloqueio:
///
/// - trancado, esconde o app inteiro e mostra a tela de bloqueio, pedindo a identificação sozinha;
/// - com o bloqueio ligado, cobre o app assim que ele sai da frente, para a prévia nos apps
///   recentes não mostrar os dados;
/// - repassa ao [AppLock] os momentos em que o app vai para segundo plano e volta.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.lock, required this.child});

  final AppLock lock;
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  AppLifecycleState? _lifecycle = WidgetsBinding.instance.lifecycleState;

  /// Já pediu a identificação para este trancamento: não pede de novo sozinho, a pessoa
  /// usa o botão. Evita a tela do sistema reaparecer em laço depois de um cancelamento.
  bool _prompted = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.lock.addListener(_onLockChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.lock.refreshSupport();
      _prompt();
    });
  }

  @override
  void didUpdateWidget(AppLockGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lock != widget.lock) {
      oldWidget.lock.removeListener(_onLockChanged);
      widget.lock.addListener(_onLockChanged);
    }
  }

  @override
  void dispose() {
    widget.lock.removeListener(_onLockChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lifecycle = state);
    widget.lock.didChangeLifecycle(state);
    if (state == AppLifecycleState.resumed) {
      widget.lock.refreshSupport();
      _prompt();
    }
  }

  void _onLockChanged() {
    if (!widget.lock.locked) {
      _prompted = false;
      _failed = false;
    } else {
      _prompt();
    }
  }

  bool get _inFront => _lifecycle == null || _lifecycle == AppLifecycleState.resumed;

  Future<void> _prompt() async {
    final lock = widget.lock;
    if (!mounted || !lock.locked || lock.authenticating || _prompted || !_inFront) return;
    _prompted = true;
    final opened = await lock.unlock(AppLocalizations.of(context).appLockReasonOpen);
    if (mounted) setState(() => _failed = !opened);
  }

  void _retry() {
    _prompted = false;
    setState(() => _failed = false);
    _prompt();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.lock,
      builder: (context, _) {
        final lock = widget.lock;
        final covered = lock.enabled && !_inFront;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Offstage: o app continua vivo por baixo (a pessoa volta ao ponto em que estava),
            // mas não aparece, não recebe toque e não chega a leitores de tela.
            Offstage(offstage: lock.locked, child: widget.child),
            if (lock.locked)
              LockScreen(failed: _failed, busy: lock.authenticating, onUnlock: _retry)
            else if (covered)
              const PrivacyCover(),
          ],
        );
      },
    );
  }
}

/// Fundo coral das telas de bloqueio, com a grade de pontos do ícone.
class _LockBackground extends StatelessWidget {
  const _LockBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = CycleColors.of(context);
    const dots = DotGridPainter(color: Color(0x1FFFFFFF), radius: 34, gap: 30);

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.heroStart, colors.heroEnd],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -60,
              top: -50,
              child: ExcludeSemantics(
                child: CustomPaint(size: dots.size, painter: dots),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Cobre o app enquanto ele não está na frente: é o que aparece nos apps recentes.
class PrivacyCover extends StatelessWidget {
  const PrivacyCover({super.key});

  @override
  Widget build(BuildContext context) => const _LockBackground(child: SizedBox.expand());
}

/// A tela que esconde o app: nome, uma frase e o botão de tentar de novo.
class LockScreen extends StatelessWidget {
  const LockScreen({
    super.key,
    required this.failed,
    required this.busy,
    required this.onUnlock,
  });

  /// A última tentativa não deu certo (a pessoa cancelou ou errou).
  final bool failed;

  /// A tela do sistema está aberta agora.
  final bool busy;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // O título é grande e fica sobre o coral; a frase e o botão vão num cartão branco, porque
    // o branco sobre o coral só tem contraste para texto grande.
    return _LockBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: text.headlineMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SoftCard(
                    radius: 24,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.lockScreenBody,
                          textAlign: TextAlign.center,
                          style: text.bodyLarge,
                        ),
                        if (failed) ...[
                          const SizedBox(height: 12),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              l10n.lockScreenFailed,
                              textAlign: TextAlign.center,
                              style: text.bodyMedium?.copyWith(color: scheme.error),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: busy ? null : onUnlock,
                          icon: const Icon(Icons.lock_open_outlined),
                          label: Text(l10n.lockScreenButton),
                        ),
                      ],
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
