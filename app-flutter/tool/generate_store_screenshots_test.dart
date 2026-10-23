// Gera as imagens da App Store: telas reais do app, com título e moldura de aparelho,
// em português, inglês e espanhol, para iPhone 6,3" (1206x2622), iPhone 6,9" (1320x2868) e
// iPad 13" (2064x2752).
//
// Como funciona: cada tela é o próprio app rodando no engine do Flutter, num viewport do
// tamanho do aparelho, com a fonte Nunito e a plataforma iOS (barra de título centralizada,
// seta de voltar do iOS). Uma data fixa e dados de exemplo deixam as imagens iguais a cada
// execução. Depois a tela é encaixada numa moldura sobre o fundo coral, com o texto.
//
// Para regenerar (saem em store/ios/screenshots/<idioma>/<aparelho>/, 24-bit RGB, sem alfa):
//   flutter test tool/generate_store_screenshots_test.dart
//
// É um "teste" só porque dart:ui (para desenhar e exportar PNG) precisa do engine do Flutter;
// ele fica fora de test/ para não rodar junto com a suíte.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabelinha/app.dart';
import 'package:tabelinha/core/cycle_calculator.dart';
import 'package:tabelinha/data/cycle_repository.dart';
import 'package:tabelinha/l10n/app_localizations.dart';
import 'package:tabelinha/state/app_controller.dart';
import 'package:tabelinha/ui/home/calendar_card.dart';
import 'package:tabelinha/ui/theme.dart';

const _outputDir = 'store/ios/screenshots';

/// Sexta, 17/10/2026: dia 13 de um ciclo de 28 dias iniciado em 5/10. Cai no período fértil,
/// com a menstruação, a ovulação (dia 19) e o dia de hoje à vista no mesmo mês.
final _now = DateTime(2026, 10, 17, 10, 30);

// ---------------------------------------------------------------------------------------
// Aparelhos
// ---------------------------------------------------------------------------------------

class _Device {
  const _Device({
    required this.folder,
    required this.canvas,
    required this.logical,
    required this.dpr,
    required this.safeTop,
    required this.safeBottom,
    required this.hasIsland,
    required this.frameWidth,
    required this.bezel,
    required this.screenRadius,
  });

  final String folder;

  /// Tamanho exato da imagem da loja, em pixels.
  final Size canvas;

  /// Tamanho da tela do app em pontos. Tem a mesma proporção da imagem da loja, mas não
  /// precisa ter o mesmo tamanho: no iPad a tela é renderizada em 768x1024 pt para a coluna
  /// do app preencher a moldura, em vez de sobrar fundo vazio dos lados.
  final Size logical;
  final double dpr;

  /// Áreas seguras (barra de status e indicador de início), em pontos.
  final double safeTop, safeBottom;
  final bool hasIsland;

  /// Moldura, em pixels da imagem final.
  final double frameWidth, bezel, screenRadius;

  /// Tamanho em pixels da tela capturada do app.
  Size get screenSize => logical * dpr;

  /// Fator de escala dos textos e enfeites em relação ao iPhone (1320 px de largura).
  double get k => canvas.width / 1320;
}

const _devices = [
  // iPhone 16/17 Pro: a loja chama de 6,3" (1206x2622) e aceita também 1179x2556 (6,1").
  _Device(
    folder: 'iphone-6.3',
    canvas: Size(1206, 2622),
    logical: Size(402, 874),
    dpr: 3,
    safeTop: 62,
    safeBottom: 34,
    hasIsland: true,
    frameWidth: 1040,
    bezel: 20,
    screenRadius: 124,
  ),
  _Device(
    folder: 'iphone-6.9',
    canvas: Size(1320, 2868),
    logical: Size(440, 956),
    dpr: 3,
    safeTop: 62,
    safeBottom: 34,
    hasIsland: true,
    frameWidth: 1130,
    bezel: 22,
    screenRadius: 136,
  ),
  _Device(
    folder: 'ipad-13',
    canvas: Size(2064, 2752),
    logical: Size(768, 1024),
    dpr: 2,
    safeTop: 24,
    safeBottom: 20,
    hasIsland: false,
    frameWidth: 1600,
    bezel: 40,
    screenRadius: 52,
  ),
];

// ---------------------------------------------------------------------------------------
// Textos
// ---------------------------------------------------------------------------------------

class _Caption {
  const _Caption(this.title, this.subtitle);
  final String title, subtitle;
}

class _Lang {
  const _Lang({
    required this.folder,
    required this.locale,
    required this.captions,
    required this.notes,
  });

  final String folder;
  final Locale locale;

  /// Uma por tela, na ordem de [_shots].
  final List<_Caption> captions;

  /// Anotações de exemplo: outubro (um diário de cinco linhas, de até ~38 caracteres cada,
  /// para a prévia do histórico não cortar palavra), setembro e julho (curtas); agosto fica
  /// vazio de propósito, para aparecer o convite "adicionar anotação".
  final ({String october, String september, String july}) notes;
}

const _langs = [
  _Lang(
    folder: 'pt-BR',
    locale: Locale('pt'),
    captions: [
      _Caption('Seu ciclo num relance', 'Veja em que fase você está hoje'),
      _Caption('Tudo no calendário', 'Menstruação, período fértil e ovulação'),
      _Caption('Do seu jeito', 'Ajuste a duração do ciclo e da menstruação'),
      _Caption('Seus registros', 'Guarde cada período e consulte quando quiser'),
      _Caption('Anotações', 'Registre como foi cada ciclo'),
      _Caption('Também no escuro', 'Confortável para usar à noite'),
    ],
    notes: (
      october: 'Dia 1: fluxo moderado, dor de cabeça.\n'
          'Dia 2: cólica leve e mais cansaço.\n'
          'Dia 3: bem melhor, voltei a treinar.\n'
          'Dia 4: fluxo fraco.\n'
          'Dia 5: acabou. Bebi bastante água.',
      september: 'Fluxo mais intenso no primeiro dia.',
      july: 'Sem sintomas.',
    ),
  ),
  _Lang(
    folder: 'en-US',
    locale: Locale('en'),
    captions: [
      _Caption('Your cycle at a glance', 'See which phase you’re in today'),
      _Caption('It’s all on the calendar', 'Period, fertile window and ovulation'),
      _Caption('Made to fit you', 'Set your cycle and period length'),
      _Caption('Your records', 'Keep every period and look back anytime'),
      _Caption('Notes', 'Write down how each cycle went'),
      _Caption('Dark mode, too', 'Easy on the eyes at night'),
    ],
    notes: (
      october: 'Day 1: moderate flow, mild headache.\n'
          'Day 2: light cramps, more tired.\n'
          'Day 3: much better, back to training.\n'
          'Day 4: light flow.\n'
          'Day 5: all done. Drank plenty of water.',
      september: 'Heavier flow on the first day.',
      july: 'No symptoms.',
    ),
  ),
  _Lang(
    folder: 'es-ES',
    locale: Locale('es'),
    captions: [
      _Caption('Tu ciclo de un vistazo', 'Descubre en qué fase estás hoy'),
      _Caption('Todo en el calendario', 'Menstruación, período fértil y ovulación'),
      _Caption('A tu manera', 'Ajusta la duración del ciclo y de la menstruación'),
      _Caption('Tus registros', 'Guarda cada período y consúltalo cuando quieras'),
      _Caption('Notas', 'Anota cómo fue cada ciclo'),
      _Caption('También en modo oscuro', 'Cómoda para la vista por la noche'),
    ],
    notes: (
      october: 'Día 1: flujo medio, dolor de cabeza.\n'
          'Día 2: cólicos leves y más cansancio.\n'
          'Día 3: mucho mejor, volví a entrenar.\n'
          'Día 4: flujo ligero.\n'
          'Día 5: terminó. Bebí mucha agua.',
      september: 'Flujo más abundante el primer día.',
      july: 'Sin síntomas.',
    ),
  ),
];

// ---------------------------------------------------------------------------------------
// Telas
// ---------------------------------------------------------------------------------------

typedef _Navigate = Future<void> Function(WidgetTester tester, _Device device, AppLocalizations l10n);

class _Shot {
  const _Shot(this.slug, this.navigate, {this.dark = false});

  final String slug;
  final _Navigate navigate;
  final bool dark;
}

ScrollPosition _homeScroll(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable).first).position;

Future<void> _nothing(WidgetTester tester, _Device device, AppLocalizations l10n) async {}

/// Rola a home até o cartão do calendário ficar logo abaixo da barra de título.
Future<void> _scrollToCalendar(WidgetTester tester, _Device device, AppLocalizations l10n) async {
  final position = _homeScroll(tester);
  final cardTop = tester.getTopLeft(find.byType(CalendarCard)).dy;
  final appBarBottom = device.safeTop + kToolbarHeight;
  position.jumpTo(position.pixels + cardTop - appBarBottom - 8);
  await tester.pumpAndSettle();
}

Future<void> _scrollToSettings(WidgetTester tester, _Device device, AppLocalizations l10n) async {
  // Um pouco acima do fim, para o cartão do calendário entrar inteiro sob a barra de título
  // em vez de ter o nome do mês cortado ao meio.
  final position = _homeScroll(tester);
  position.jumpTo(math.max(0, position.maxScrollExtent - 28));
  await tester.pumpAndSettle();
}

Future<void> _openHistory(WidgetTester tester, _Device device, AppLocalizations l10n) async {
  await tester.tap(find.byTooltip(l10n.historyTitle));
  await tester.pumpAndSettle();
}

Future<void> _openNotes(WidgetTester tester, _Device device, AppLocalizations l10n) async {
  await _openHistory(tester, device, l10n);
  await tester.tap(find.byType(InkWell).first);
  await tester.pumpAndSettle();
}

const _shots = [
  _Shot('01-today', _nothing),
  _Shot('02-calendar', _scrollToCalendar),
  _Shot('03-settings', _scrollToSettings),
  _Shot('04-records', _openHistory),
  _Shot('05-notes', _openNotes),
  _Shot('06-dark', _nothing, dark: true),
];

// ---------------------------------------------------------------------------------------
// Dados de exemplo
// ---------------------------------------------------------------------------------------

Future<AppController> _controller(_Lang lang) async {
  // Este arquivo roda como teste, só não fica em test/; o aviso do analisador não se aplica.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({
    'termsAcceptedAt': '2026-01-01T10:00:00.000',
    'cycleStart': '2026-10-05',
    'cycleLength': 28,
    'periodLength': 5,
  });
  final controller = AppController(await CycleRepository.open(), now: () => _now);

  // Ciclos de 28 dias, com durações um pouco diferentes, como acontece de verdade.
  await controller.registerPeriods([
    PeriodRange(DateTime.utc(2026, 10, 5), DateTime.utc(2026, 10, 9)),
    PeriodRange(DateTime.utc(2026, 9, 7), DateTime.utc(2026, 9, 10)),
    PeriodRange(DateTime.utc(2026, 8, 10), DateTime.utc(2026, 8, 15)),
    PeriodRange(DateTime.utc(2026, 7, 13), DateTime.utc(2026, 7, 17)),
  ]);
  final byStart = {for (final r in controller.records) r.start: r};
  await controller.updateNote(byStart[DateTime.utc(2026, 10, 5)]!, lang.notes.october);
  await controller.updateNote(byStart[DateTime.utc(2026, 9, 7)]!, lang.notes.september);
  await controller.updateNote(byStart[DateTime.utc(2026, 7, 13)]!, lang.notes.july);
  return controller;
}

// ---------------------------------------------------------------------------------------
// Tela do app com barra de status e indicador de início
// ---------------------------------------------------------------------------------------

class _AppScreen extends StatelessWidget {
  const _AppScreen({
    required this.boundaryKey,
    required this.controller,
    required this.device,
    required this.dark,
  });

  final GlobalKey boundaryKey;
  final AppController controller;
  final _Device device;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TabelinhaApp(controller: controller),
            IgnorePointer(child: _SystemChrome(device: device, dark: dark)),
          ],
        ),
      ),
    );
  }
}

class _SystemChrome extends StatelessWidget {
  const _SystemChrome({required this.device, required this.dark});

  final _Device device;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : const Color(0xFF1B1213);
    final time = Text(
      '9:41',
      style: TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w800,
        fontSize: 17,
        color: color,
        decoration: TextDecoration.none,
      ),
    );
    final status = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SignalBars(color: color),
        const SizedBox(width: 7),
        Icon(Icons.wifi, size: 18, color: color),
        const SizedBox(width: 7),
        _Battery(color: color),
      ],
    );

    return Stack(
      children: [
        if (device.hasIsland) ...[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 59,
            child: Row(
              children: [
                Expanded(child: Center(child: time)),
                const SizedBox(width: 125 + 24),
                Expanded(child: Center(child: status)),
              ],
            ),
          ),
          Positioned(
            top: 11,
            left: 0,
            right: 0,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18.5),
                ),
                child: const SizedBox(width: 125, height: 37),
              ),
            ),
          ),
        ] else
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: device.safeTop,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [time, status],
              ),
            ),
          ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              child: const SizedBox(width: 139, height: 5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final height in const [5.0, 7.5, 10.0, 12.5])
          Padding(
            padding: const EdgeInsets.only(right: 1.6),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
              child: SizedBox(width: 3.2, height: height),
            ),
          ),
      ],
    );
  }
}

class _Battery extends StatelessWidget {
  const _Battery({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.5)),
              child: const SizedBox(width: 21, height: 8.5),
            ),
          ),
        ),
        const SizedBox(width: 1.5),
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(1),
          ),
          child: const SizedBox(width: 1.8, height: 4.2),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------
// Imagem da loja: fundo, texto e moldura
// ---------------------------------------------------------------------------------------

class _Poster extends StatelessWidget {
  const _Poster({
    required this.boundaryKey,
    required this.device,
    required this.screen,
    required this.caption,
    required this.dark,
  });

  final GlobalKey boundaryKey;
  final _Device device;
  final ui.Image screen;
  final _Caption caption;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final k = device.k;
    final canvas = device.canvas;
    final colors = buildTheme(dark ? Brightness.dark : Brightness.light).extension<CycleColors>()!;

    // Claro: o degradê do destaque do app. Escuro: o vinho do tema escuro.
    final background = dark
        ? const [Color(0xFF3B2224), Color(0xFF231517)]
        : [colors.heroStart, const Color(0xFFF4636A)];
    final titleColor = dark ? const Color(0xFFFFE9E6) : Colors.white;
    final subtitleColor = dark ? const Color(0xFFFFC9C5) : Colors.white;
    // Mesma opacidade do destaque do app: o título branco que passar por cima segue ≥ 3:1.
    final dotColor = Colors.white.withValues(alpha: dark ? 0.06 : 0.10);

    TextStyle style(double size, FontWeight weight, Color color, double height) => TextStyle(
          fontFamily: 'Nunito',
          fontSize: size * k,
          fontWeight: weight,
          color: color,
          height: height,
          decoration: TextDecoration.none,
        );

    final headerHeight = 480 * k;
    final screenWidth = device.frameWidth - 2 * device.bezel;
    final screenHeight = screenWidth * screen.height / screen.width;
    final frameHeight = screenHeight + 2 * device.bezel;
    final outerRadius = device.screenRadius + device.bezel;

    return RepaintBoundary(
      key: boundaryKey,
      child: SizedBox(
        width: canvas.width,
        height: canvas.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: background,
                  ),
                ),
              ),
            ),
            // Eco do ícone: a grade de pontos do destaque do app, em escala grande.
            Positioned(
              top: -120 * k,
              right: -90 * k,
              child: CustomPaint(
                size: Size(560 * k, 410 * k),
                painter: _DotGridPainter(color: dotColor, radius: 52 * k, gap: 48 * k),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 90 * k),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        caption.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: style(104, FontWeight.w800, titleColor, 1.05),
                      ),
                      SizedBox(height: 22 * k),
                      Text(
                        caption.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: style(48, FontWeight.w700, subtitleColor, 1.25),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // A moldura passa do rodapé da imagem: a tela "sai" por baixo, como nas lojas.
            Positioned(
              top: headerHeight,
              left: (canvas.width - device.frameWidth) / 2,
              width: device.frameWidth,
              height: frameHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF17100F),
                  borderRadius: BorderRadius.circular(outerRadius),
                  border: Border.all(color: const Color(0xFF4A3638), width: 3 * k),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: dark ? 0.55 : 0.30),
                      blurRadius: 90 * k,
                      offset: Offset(0, 36 * k),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(device.bezel),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(device.screenRadius),
                    child: RawImage(
                      image: screen,
                      width: screenWidth,
                      height: screenHeight,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color, required this.radius, required this.gap});

  final Color color;
  final double radius, gap;

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
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------------------
// PNG sem canal alfa (24 bits): a App Store não quer transparência nas imagens
// ---------------------------------------------------------------------------------------

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var i = 0; i < 8; i++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(Uint8List bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}

void _writeChunk(BytesBuilder out, String type, Uint8List data) {
  final typeAndData = Uint8List(4 + data.length)
    ..setRange(0, 4, type.codeUnits)
    ..setRange(4, 4 + data.length, data);
  final header = ByteData(4)..setUint32(0, data.length);
  final crc = ByteData(4)..setUint32(0, _crc32(typeAndData));
  out
    ..add(header.buffer.asUint8List())
    ..add(typeAndData)
    ..add(crc.buffer.asUint8List());
}

Uint8List _encodeRgbPng(int width, int height, ByteData rgba) {
  // Filtro "Sub" (1) em cada linha: comprime bem os degradês do fundo.
  final stride = width * 3;
  final raw = Uint8List(height * (1 + stride));
  for (var y = 0; y < height; y++) {
    final rowStart = y * (1 + stride);
    raw[rowStart] = 1;
    for (var x = 0; x < width; x++) {
      final src = (y * width + x) * 4;
      for (var c = 0; c < 3; c++) {
        final value = rgba.getUint8(src + c);
        final left = x == 0 ? 0 : rgba.getUint8(src - 4 + c);
        raw[rowStart + 1 + x * 3 + c] = (value - left) & 0xFF;
      }
    }
  }

  final ihdr = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // 8 bits por canal
    ..setUint8(9, 2) // RGB, sem alfa
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);

  final out = BytesBuilder()..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  _writeChunk(out, 'IHDR', ihdr.buffer.asUint8List());
  _writeChunk(out, 'IDAT', Uint8List.fromList(ZLibCodec(level: 6).encode(raw)));
  _writeChunk(out, 'IEND', Uint8List(0));
  return out.toBytes();
}

// ---------------------------------------------------------------------------------------
// Execução
// ---------------------------------------------------------------------------------------

/// O flutter test não carrega as fontes do app nem a de ícones: sem isto o texto sai na fonte
/// Ahem (quadrados) e os ícones viram caixas.
Future<void> _loadFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final nunito = FontLoader('Nunito');
  for (final weight in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
    nunito.addFont(rootBundle.load('assets/fonts/Nunito-$weight.ttf'));
  }
  await nunito.load();

  final icons = FontLoader('MaterialIcons')..addFont(_materialIcons());
  await icons.load();
}

Future<ByteData> _materialIcons() async {
  try {
    return await rootBundle.load('fonts/MaterialIcons-Regular.otf');
  } catch (_) {
    // Não veio no bundle do teste: usa a cópia do próprio SDK do Flutter.
    final root = Platform.environment['FLUTTER_ROOT'];
    if (root == null) rethrow;
    final bytes = await File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
        .readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

Future<ui.Image> _capture(WidgetTester tester, GlobalKey key, double pixelRatio) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
  return (await tester.runAsync(() => boundary.toImage(pixelRatio: pixelRatio)))!;
}

void main() {
  setUpAll(_loadFonts);

  for (final device in _devices) {
    for (final lang in _langs) {
      testWidgets(
        '${lang.folder} ${device.folder}',
        timeout: const Timeout(Duration(minutes: 10)),
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          final l10n = lookupAppLocalizations(lang.locale);
          tester.platformDispatcher
            ..localeTestValue = lang.locale
            ..localesTestValue = [lang.locale];

          // O flutter test desliga o desfoque das sombras; sem isto elas saem como faixas
          // duras. O teste exige o valor original ao terminar, por isso o finally.
          debugDisableShadows = false;
          try {
            await _renderShots(tester, device, lang, l10n);
          } finally {
            debugDisableShadows = true;
          }
        },
      );
    }
  }
}

/// Gera as seis imagens de um idioma num aparelho.
Future<void> _renderShots(
  WidgetTester tester,
  _Device device,
  _Lang lang,
  AppLocalizations l10n,
) async {
  for (var i = 0; i < _shots.length; i++) {
    final shot = _shots[i];
    tester.platformDispatcher.platformBrightnessTestValue =
        shot.dark ? Brightness.dark : Brightness.light;

    // 1) o app, no tamanho do aparelho.
    final safe = FakeViewPadding(
      top: device.safeTop * device.dpr,
      bottom: device.safeBottom * device.dpr,
    );
    tester.view
      ..physicalSize = device.screenSize
      ..devicePixelRatio = device.dpr
      ..padding = safe
      ..viewPadding = safe;
    final appKey = GlobalKey();
    await tester.pumpWidget(
      _AppScreen(
        boundaryKey: appKey,
        controller: await _controller(lang),
        device: device,
        dark: shot.dark,
      ),
    );
    await tester.pumpAndSettle();
    await shot.navigate(tester, device, l10n);
    final screen = await _capture(tester, appKey, device.dpr);
    expect(screen.width, device.screenSize.width.round());
    expect(screen.height, device.screenSize.height.round());

    // 2) a imagem da loja, em pixels exatos (1 pixel lógico = 1 pixel final).
    await tester.pumpWidget(const SizedBox());
    tester.view
      ..physicalSize = device.canvas
      ..devicePixelRatio = 1
      ..resetPadding()
      ..resetViewPadding();
    final posterKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Nunito'),
        home: Material(
          type: MaterialType.transparency,
          child: _Poster(
            boundaryKey: posterKey,
            device: device,
            screen: screen,
            caption: lang.captions[i],
            dark: shot.dark,
          ),
        ),
      ),
    );
    await tester.pump();
    final poster = await _capture(tester, posterKey, 1);
    expect(poster.width, device.canvas.width.round());
    expect(poster.height, device.canvas.height.round());

    await tester.runAsync(() async {
      final rgba = (await poster.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final png = _encodeRgbPng(poster.width, poster.height, rgba);
      final file = File('$_outputDir/${lang.folder}/${device.folder}/${shot.slug}.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(png);
      debugPrint('${file.path}  ${poster.width}x${poster.height}  ${png.length ~/ 1024} KB');
    });
    screen.dispose();
    poster.dispose();
  }
}
