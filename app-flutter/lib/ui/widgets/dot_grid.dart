import 'package:flutter/widgets.dart';

/// A grade de 4×3 pontos do ícone do app, com um ponto vazado. Só decoração.
///
/// O tamanho natural é `4 * 2r + 3 * gap` de largura por `3 * 2r + 2 * gap` de altura.
class DotGridPainter extends CustomPainter {
  const DotGridPainter({required this.color, required this.radius, required this.gap});

  final Color color;
  final double radius;
  final double gap;

  Size get size => Size(4 * 2 * radius + 3 * gap, 3 * 2 * radius + 2 * gap);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.28;

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        final center = Offset(
          radius + col * (2 * radius + gap),
          radius + row * (2 * radius + gap),
        );
        if (row == 1 && col == 2) {
          canvas.drawCircle(center, radius - ring.strokeWidth / 2, ring);
        } else {
          canvas.drawCircle(center, radius, fill);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius || oldDelegate.gap != gap;
}
