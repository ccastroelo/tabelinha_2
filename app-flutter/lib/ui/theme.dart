import 'package:flutter/material.dart';

/// Direção visual "Acolhedor": creme-pêssego, cartões brancos arredondados, coral do
/// ícone como destaque e Nunito (arredondada). Valores aprovados no canvas de design;
/// os pares de cor de texto/fundo têm teste de contraste em test/contrast_test.dart.
const fontFamily = 'Nunito';

const _seed = Color(0xFFE5575C);

/// Cartões e tons que o `ColorScheme` do Material não expressa.
@immutable
class CycleColors extends ThemeExtension<CycleColors> {
  const CycleColors({
    required this.menstruation,
    required this.onMenstruation,
    required this.fertile,
    required this.onFertile,
    required this.ovulation,
    required this.onOvulation,
    required this.tonal,
    required this.onTonal,
    required this.heroStart,
    required this.heroEnd,
    required this.shadow,
  });

  /// Dia de menstruação (preenchido) e o texto sobre ele.
  final Color menstruation;
  final Color onMenstruation;

  /// Período fértil: tom claro com um ponto sob o número (não depende só de cor).
  final Color fertile;
  final Color onFertile;

  final Color ovulation;
  final Color onOvulation;

  /// Botões e ícones tonais.
  final Color tonal;
  final Color onTonal;

  /// Degradê do destaque do topo. O texto branco sobre ele só atinge 3:1, então
  /// vale apenas para texto grande (≥ 24 px, ou ≥ 18,66 px em negrito).
  final Color heroStart;
  final Color heroEnd;

  final Color shadow;

  static const light = CycleColors(
    menstruation: Color(0xFFD63A40),
    onMenstruation: Color(0xFFFFFFFF),
    fertile: Color(0xFFFFE3E0),
    onFertile: Color(0xFFA3262C),
    ovulation: Color(0xFFF5A524),
    onOvulation: Color(0xFF3B2426),
    tonal: Color(0xFFFFE3E0),
    onTonal: Color(0xFFA3262C),
    heroStart: Color(0xFFE8484F),
    heroEnd: Color(0xFFF2555B),
    shadow: Color(0x1AD63A40),
  );

  static const dark = CycleColors(
    menstruation: Color(0xFFFF6A70),
    onMenstruation: Color(0xFF2E0B0D),
    fertile: Color(0xFF4B2629),
    onFertile: Color(0xFFFFC9C5),
    ovulation: Color(0xFFF5A524),
    onOvulation: Color(0xFF3B2426),
    tonal: Color(0xFF4B2629),
    onTonal: Color(0xFFFFC9C5),
    heroStart: Color(0xFFC9363D),
    heroEnd: Color(0xFFD9444B),
    shadow: Color(0x59000000),
  );

  static CycleColors of(BuildContext context) =>
      Theme.of(context).extension<CycleColors>()!;

  @override
  CycleColors copyWith({
    Color? menstruation,
    Color? onMenstruation,
    Color? fertile,
    Color? onFertile,
    Color? ovulation,
    Color? onOvulation,
    Color? tonal,
    Color? onTonal,
    Color? heroStart,
    Color? heroEnd,
    Color? shadow,
  }) {
    return CycleColors(
      menstruation: menstruation ?? this.menstruation,
      onMenstruation: onMenstruation ?? this.onMenstruation,
      fertile: fertile ?? this.fertile,
      onFertile: onFertile ?? this.onFertile,
      ovulation: ovulation ?? this.ovulation,
      onOvulation: onOvulation ?? this.onOvulation,
      tonal: tonal ?? this.tonal,
      onTonal: onTonal ?? this.onTonal,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      shadow: shadow ?? this.shadow,
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
      tonal: Color.lerp(tonal, other.tonal, t)!,
      onTonal: Color.lerp(onTonal, other.onTonal, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final cycle = isLight ? CycleColors.light : CycleColors.dark;

  final base = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );
  // Os papéis principais são fixos (aprovados no design); o resto vem do fromSeed.
  final scheme = isLight
      ? base.copyWith(
          primary: cycle.menstruation,
          onPrimary: cycle.onMenstruation,
          primaryContainer: cycle.tonal,
          onPrimaryContainer: cycle.onTonal,
          secondaryContainer: cycle.tonal,
          onSecondaryContainer: cycle.onTonal,
          tertiary: cycle.ovulation,
          onTertiary: cycle.onOvulation,
          surface: const Color(0xFFFFF3EE),
          onSurface: const Color(0xFF3B2426),
          onSurfaceVariant: const Color(0xFF7A5D60),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFFFFFFF),
          surfaceContainer: const Color(0xFFFFEFE9),
          surfaceContainerHigh: const Color(0xFFFFE9E3),
          surfaceContainerHighest: const Color(0xFFFFE3E0),
          outline: const Color(0xFF7A5D60),
          outlineVariant: const Color(0xFFEBD3CD),
        )
      : base.copyWith(
          primary: cycle.menstruation,
          onPrimary: cycle.onMenstruation,
          primaryContainer: cycle.tonal,
          onPrimaryContainer: cycle.onTonal,
          secondaryContainer: cycle.tonal,
          onSecondaryContainer: cycle.onTonal,
          tertiary: cycle.ovulation,
          onTertiary: cycle.onOvulation,
          surface: const Color(0xFF231517),
          onSurface: const Color(0xFFFFE9E6),
          onSurfaceVariant: const Color(0xFFD4B5B7),
          surfaceContainerLowest: const Color(0xFF2E1D1F),
          surfaceContainerLow: const Color(0xFF2E1D1F),
          surfaceContainer: const Color(0xFF2A1A1C),
          surfaceContainerHigh: const Color(0xFF3A2427),
          surfaceContainerHighest: const Color(0xFF4B2629),
          outline: const Color(0xFFD4B5B7),
          outlineVariant: const Color(0xFF4B3033),
        );

  final text = _textTheme(scheme);
  final card = scheme.surfaceContainerLowest;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: fontFamily,
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [cycle],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: const StadiumBorder(),
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(iconSize: 22),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

/// Pesos e tamanhos da direção "Acolhedor" (títulos em 800, rótulos em 600/700).
TextTheme _textTheme(ColorScheme scheme) {
  final base = ThemeData(brightness: scheme.brightness).textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      );
  return base.copyWith(
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.1,
    ),
    headlineSmall: base.headlineSmall?.copyWith(fontSize: 26, fontWeight: FontWeight.w800),
    titleLarge: base.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
    titleMedium: base.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
    titleSmall: base.titleSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    bodySmall: base.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, height: 1.5),
    labelLarge: base.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
    labelMedium: base.labelMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
    labelSmall: base.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
  );
}
