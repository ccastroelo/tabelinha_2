import 'package:flutter_test/flutter_test.dart';
import 'package:tabelinha/core/cycle_calculator.dart';
import 'package:tabelinha/l10n/app_localizations_en.dart';
import 'package:tabelinha/l10n/app_localizations_es.dart';
import 'package:tabelinha/l10n/app_localizations_pt.dart';

void main() {
  test('o texto de ajuda cita a mesma janela fértil que o calendário usa', () {
    final half = fertileHalfWindow;
    final total = half * 2 + 1;

    final helpTexts = {
      'pt': AppLocalizationsPt().helpBody,
      'en': AppLocalizationsEn().helpBody,
      'es': AppLocalizationsEs().helpBody,
    };

    for (final MapEntry(:key, :value) in helpTexts.entries) {
      expect(value, contains('$half'), reason: '$key: meia-janela de $half dias');
      expect(value, contains('$total'), reason: '$key: janela total de $total dias');
    }
  });
}
