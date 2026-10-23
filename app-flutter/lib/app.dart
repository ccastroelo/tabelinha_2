import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'state/app_controller.dart';
import 'state/app_lock.dart';
import 'ui/home/home_page.dart';
import 'ui/lock/app_lock_gate.dart';
import 'ui/terms/terms_page.dart';
import 'ui/theme.dart';

class TabelinhaApp extends StatelessWidget {
  /// Sem [lock], o app não tem bloqueio (como nos testes): um [AppLock] desligado.
  TabelinhaApp({super.key, required this.controller, AppLock? lock}) : lock = lock ?? AppLock();

  final AppController controller;
  final AppLock lock;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AppLockScope(
        lock: lock,
        child: MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          // Acima do Navigator: o bloqueio cobre também as telas empilhadas e os diálogos.
          builder: (context, child) => AppLockGate(
            lock: lock,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const _Root(),
        ),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return AppScope.of(context).termsAccepted ? const HomePage() : const TermsPage();
  }
}
