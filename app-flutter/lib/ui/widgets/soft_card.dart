import 'package:flutter/material.dart';

import '../theme.dart';

/// Cartão branco arredondado com sombra suave tingida de coral.
///
/// O `Material` fica por dentro da sombra para o efeito de toque (InkWell) aparecer
/// por cima do fundo do cartão.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: CycleColors.of(context).shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: theme.cardTheme.color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
