import 'package:flutter/material.dart';

import '../theme.dart';

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
                const Positioned(
                  right: -18,
                  top: -18,
                  child: ExcludeSemantics(
                    child: CustomPaint(size: Size(118, 86), painter: _DotGridPainter()),
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

  /// Opacidade dos pontos. Com texto grande por cima (fonte ampliada), o branco sobre o
  /// ponto precisa seguir ≥ 3:1: `contrast_test.dart` confere esse valor.
  static const decorationAlpha = 0.10;
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 11.0, gap = 10.0;
    final fill = Paint()..color = Colors.white.withValues(alpha: HeroBanner.decorationAlpha);
    final ring = Paint()
      ..color = Colors.white.withValues(alpha: HeroBanner.decorationAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        final center = Offset(
          radius + col * (2 * radius + gap),
          radius + row * (2 * radius + gap),
        );
        if (row == 1 && col == 2) {
          canvas.drawCircle(center, radius - 1.5, ring);
        } else {
          canvas.drawCircle(center, radius, fill);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
