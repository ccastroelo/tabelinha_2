import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabelinha/ui/theme.dart';
import 'package:tabelinha/ui/widgets/hero_banner.dart';

/// Razão de contraste WCAG entre duas cores opacas.
double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final brightness in Brightness.values) {
    group('contraste no tema ${brightness.name}', () {
      final theme = buildTheme(brightness);
      final s = theme.colorScheme;
      final c = theme.extension<CycleColors>()!;
      final card = s.surfaceContainerLowest;

      // WCAG: 4,5:1 para texto normal.
      final text = <String, (Color, Color)>{
        'texto sobre o fundo': (s.onSurface, s.surface),
        'texto secundário sobre o fundo': (s.onSurfaceVariant, s.surface),
        'texto sobre o cartão': (s.onSurface, card),
        'texto secundário sobre o cartão': (s.onSurfaceVariant, card),
        'número sobre menstruação': (c.onMenstruation, c.menstruation),
        'número sobre período fértil': (c.onFertile, c.fertile),
        'número sobre ovulação': (c.onOvulation, c.ovulation),
        'ícone/texto tonal': (c.onTonal, c.tonal),
        'botão principal': (s.onPrimary, s.primary),
      };
      for (final MapEntry(:key, :value) in text.entries) {
        test(key, () {
          final ratio = contrast(value.$1, value.$2);
          expect(ratio, greaterThanOrEqualTo(4.5), reason: '$key: ${ratio.toStringAsFixed(2)}:1');
        });
      }

      // O destaque coral leva só texto grande (≥ 24 px, ou ≥ 18,66 px em negrito): 3:1.
      test('branco sobre o destaque (texto grande)', () {
        for (final end in [c.heroStart, c.heroEnd]) {
          final ratio = contrast(Colors.white, end);
          expect(ratio, greaterThanOrEqualTo(3.0), reason: '${ratio.toStringAsFixed(2)}:1');
        }
      });

      // Com fonte ampliada o título pode cair sobre os pontos decorativos do banner.
      test('branco sobre os pontos do destaque (texto grande)', () {
        for (final base in [c.heroStart, c.heroEnd]) {
          final dot = Color.alphaBlend(Colors.white.withValues(alpha: HeroBanner.decorationAlpha), base);
          final ratio = contrast(Colors.white, dot);
          expect(ratio, greaterThanOrEqualTo(3.0), reason: '${ratio.toStringAsFixed(2)}:1');
        }
      });
    });
  }
}
