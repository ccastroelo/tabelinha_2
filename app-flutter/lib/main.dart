import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/cycle_repository.dart';
import 'data/legacy_importer.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A licença da fonte embutida (Nunito, SIL OFL) aparece na tela de licenças do app.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Nunito'], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });

  final repository = await CycleRepository.open();
  final controller = AppController(repository);

  // Antes da primeira tela: quem veio do app antigo não deve ver o calendário vazio.
  await LegacyImporter(repository: repository, controller: controller).run();

  runApp(TabelinhaApp(controller: controller));
}
