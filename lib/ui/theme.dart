import 'package:flutter/material.dart';

import '../core/cycle_calculator.dart';

const _seed = Color(0xFFE5575C);

/// Cores que carregam significado no calendário. Pares fundo/texto com
/// contraste ≥ 4,5:1; menstruação (escura/saturada) e fértil (clara) também
/// diferem em luminosidade, então não dependem só do matiz.
@immutable
class CycleColors extends ThemeExtension<CycleColors> {
  const CycleColors({
    required this.menstruation,
    required this.onMenstruation,
    required this.fertile,
    required this.onFertile,
    required this.ovulation,
    required this.onOvulation,
  });

  final Color menstruation;
  final Color onMenstruation;
  final Color fertile;
  final Color onFertile;
  final Color ovulation;
  final Color onOvulation;

  static const light = CycleColors(
    menstruation: Color(0xFFD1343A),
    onMenstruation: Color(0xFFFFFFFF),
    fertile: Color(0xFFBFC6FF),
    onFertile: Color(0xFF1B2266),
    ovulation: Color(0xFFF5A524),
    onOvulation: Color(0xFF2B1B00),
  );

  static const dark = CycleColors(
    menstruation: Color(0xFFF2878B),
    onMenstruation: Color(0xFF3B0A0D),
    fertile: Color(0xFF3A3F8F),
    onFertile: Color(0xFFE3E5FF),
    ovulation: Color(0xFFF5A524),
    onOvulation: Color(0xFF2B1B00),
  );

  static CycleColors of(BuildContext context) =>
      Theme.of(context).extension<CycleColors>()!;

  /// Fundo da faixa que cobre o dia. A ovulação fica sobre a faixa fértil.
  Color? bandFor(DayKind kind) => switch (kind) {
        DayKind.menstruation => menstruation,
        DayKind.fertile || DayKind.ovulation => fertile,
        DayKind.none => null,
      };

  Color onBandFor(DayKind kind) => switch (kind) {
        DayKind.menstruation => onMenstruation,
        DayKind.fertile || DayKind.ovulation => onFertile,
        DayKind.none => Colors.transparent,
      };

  @override
  CycleColors copyWith({
    Color? menstruation,
    Color? onMenstruation,
    Color? fertile,
    Color? onFertile,
    Color? ovulation,
    Color? onOvulation,
  }) {
    return CycleColors(
      menstruation: menstruation ?? this.menstruation,
      onMenstruation: onMenstruation ?? this.onMenstruation,
      fertile: fertile ?? this.fertile,
      onFertile: onFertile ?? this.onFertile,
      ovulation: ovulation ?? this.ovulation,
      onOvulation: onOvulation ?? this.onOvulation,
    );
  }

  @override
  CycleColors lerp(CycleColors? other, double t) {
    if (other == null) return this;
    return CycleColors(
      menstruation: Color.lerp(menstruation, other.menstruation, t)!,
      onMenstruation: Color.lerp(onMenstruation, other.onMenstruation, t)!,
      fertile: Color.lerp(fertile, other.fertile, t)!,
      onFertile: Color.lerp(onFertile, other.onFertile, t)!,
      ovulation: Color.lerp(ovulation, other.ovulation, t)!,
      onOvulation: Color.lerp(onOvulation, other.onOvulation, t)!,
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  // `vibrant`: o esquema padrão do fromSeed apaga o coral da semente até virar marrom.
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );
  final isLight = brightness == Brightness.light;

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [isLight ? CycleColors.light : CycleColors.dark],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
