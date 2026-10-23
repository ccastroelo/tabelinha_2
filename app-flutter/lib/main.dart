import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/cycle_repository.dart';
import 'data/legacy_importer.dart';
import 'data/local_notifications_service.dart';
import 'data/reminder_service.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A licença da fonte embutida (Nunito, SIL OFL) aparece na tela de licenças do app.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Nunito'], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });

  final repository = await CycleRepository.open();
  final controller = AppController(
    repository,
    // Notificações só existem no celular; no resto o app roda sem lembretes.
    reminderService: switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => LocalNotificationsService(),
      _ => const NoReminderService(),
    },
  );

  // Antes da primeira tela: quem veio do app antigo não deve ver o calendário vazio.
  await LegacyImporter(repository: repository, controller: controller).run();

  // Reagenda os avisos com o dia de hoje; a primeira tela não espera por isso.
  unawaited(controller.syncReminders());

  runApp(TabelinhaApp(controller: controller));
}
