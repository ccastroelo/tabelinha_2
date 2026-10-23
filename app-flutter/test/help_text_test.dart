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

  test('o texto de ajuda cita os números da previsão pelo histórico', () {
    const minPeriods = estimateMinCycles + 1;

    expect(AppLocalizationsPt().helpBody, contains('$minPeriods menstruações no histórico'));
    expect(AppLocalizationsPt().helpBody, contains('(até $estimateMaxCycles)'));
    expect(AppLocalizationsEn().helpBody, contains('$minPeriods periods in your history'));
    expect(AppLocalizationsEn().helpBody, contains('(up to $estimateMaxCycles)'));
    expect(AppLocalizationsEs().helpBody, contains('$minPeriods menstruaciones en el historial'));
    expect(AppLocalizationsEs().helpBody, contains('(hasta $estimateMaxCycles)'));
  });
}
