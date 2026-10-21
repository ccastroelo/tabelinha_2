import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'state/app_controller.dart';
import 'ui/home/home_page.dart';
import 'ui/terms/terms_page.dart';
import 'ui/theme.dart';

class TabelinhaApp extends StatelessWidget {
  const TabelinhaApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const _Root(),
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
