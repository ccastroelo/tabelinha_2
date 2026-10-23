import 'package:flutter/material.dart';

import '../theme.dart';
import 'dot_grid.dart';

/// Destaque coral do topo (estado de hoje, termos). O texto é branco e o contraste
/// sobre o degradê é só ~3,4:1 a 3,8:1: use apenas texto grande (título ≥ 24 px, subtítulo
/// ≥ 18,66 px em negrito). Detalhes menores vão em cartões brancos abaixo.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = CycleColors.of(context);
    final text = Theme.of(context).textTheme;

    return MergeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        // Sem a largura total o banner encolhe ao tamanho do texto e fica centralizado.
        child: SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.heroStart, colors.heroEnd],
              ),
            ),
            child: Stack(
              children: [
                // Eco do ícone: grade de pontos com um vazado, só decoração.
                Positioned(
                  right: -18,
                  top: -18,
                  child: ExcludeSemantics(
                    child: CustomPaint(
                      size: _dots.size,
                      painter: _dots,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: text.headlineMedium?.copyWith(color: Colors.white)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: text.titleLarge?.copyWith(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  static final _dots = DotGridPainter(
    color: Colors.white.withValues(alpha: decorationAlpha),
    radius: 11,
    gap: 10,
  );

  /// Opacidade dos pontos. Com texto grande por cima (fonte ampliada), o branco sobre o
  /// ponto precisa seguir ≥ 3:1: `contrast_test.dart` confere esse valor.
  static const decorationAlpha = 0.10;
}
