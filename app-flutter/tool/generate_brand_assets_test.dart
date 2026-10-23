// Deriva do ícone original do app (assets/icon/icon.png) os arquivos de origem que as
// plataformas pedem: camada do Android adaptativo, ícone temático e imagens da splash.
//
// O original é o ícone do app iOS antigo em 2048x2048, quadrado cheio: fundo coral liso
// e símbolo (setas, pontos e o anel) em rosa claro. O símbolo vira uma camada com fundo
// transparente mapeando a cor de cada pixel entre o coral (alfa 0) e o rosa (alfa 1).
// Assim a arte continua sendo exatamente a original, sem ser redesenhada.
//
// Para regenerar tudo (os PNGs e os arquivos de cada plataforma):
//   flutter test tool/generate_brand_assets_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// É um "teste" só porque dart:ui (para desenhar e exportar PNG) precisa do engine do Flutter;
// ele fica fora de test/ para não rodar junto com a suíte.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _source = 'assets/icon/icon.png';
const _background = Color(0xFFFF5A5A); // coral do ícone original
const _glyph = Color(0xFFFFDCDC); // rosa dos pontos e setas no original
const _white = Color(0xFFFFFFFF);

class _Source {
  _Source(this.image, this.centerX, this.centerY, this.width, this.height);

  final ui.Image image;

  /// Caixa do símbolo dentro do original, em pixels.
  final double centerX, centerY, width, height;
}

Future<_Source> _loadSource() async {
  final codec = await ui.instantiateImageCodec(File(_source).readAsBytesSync());
  final image = (await codec.getNextFrame()).image;
  final w = image.width, h = image.height;
  expect(w, h, reason: 'o ícone de origem precisa ser quadrado');

  final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  int channel(int x, int y, int c) => bytes.getUint8((y * w + x) * 4 + c);

  // O original deve ser opaco e ter o coral nos cantos; se não, o mapeamento de alfa erra.
  for (final (x, y) in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]) {
    expect(channel(x, y, 3), 255, reason: 'canto ($x,$y) deveria ser opaco');
    expect(
      (channel(x, y, 0), channel(x, y, 1), channel(x, y, 2)),
      ((_background.r * 255).round(), (_background.g * 255).round(), (_background.b * 255).round()),
      reason: 'canto ($x,$y) deveria ser o coral do ícone',
    );
  }

  var minX = w, minY = h, maxX = 0, maxY = 0;
  final threshold = (_background.g * 255).round() + 12; // qualquer coisa mais clara que o fundo
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (channel(x, y, 1) > threshold) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  final s = _Source(
    image,
    (minX + maxX + 1) / 2,
    (minY + maxY + 1) / 2,
    (maxX - minX + 1).toDouble(),
    (maxY - minY + 1).toDouble(),
  );
  stdout.writeln(
    'original: ${w}x$h; símbolo ${s.width.toInt()}x${s.height.toInt()} px, '
    'centro (${s.centerX}, ${s.centerY}) — o centro da tela é (${w / 2}, ${h / 2})',
  );
  return s;
}

/// Filtro que transforma o canal verde (coral = 0, rosa = 1) em alfa e pinta tudo de [color].
ColorFilter _glyphFilter(Color color) {
  final low = _background.g * 255; // verde do coral
  final high = _glyph.g * 255; // verde do rosa
  final k = 255 / (high - low);
  return ColorFilter.matrix([
    0, 0, 0, 0, color.r * 255,
    0, 0, 0, 0, color.g * 255,
    0, 0, 0, 0, color.b * 255,
    0, k, 0, 0, -low * k,
  ]);
}

/// Desenha só o símbolo, centralizado em uma tela quadrada de lado [size].
/// [scale] 1 faz o original inteiro (2048) caber na tela.
void _drawGlyph(Canvas canvas, _Source src, double size, double scale, Color color) {
  canvas.save();
  canvas.translate(size / 2, size / 2);
  canvas.scale(size / src.image.width * scale);
  canvas.translate(-src.centerX, -src.centerY);
  canvas.drawImage(
    src.image,
    Offset.zero,
    Paint()
      ..colorFilter = _glyphFilter(color)
      ..filterQuality = FilterQuality.high,
  );
  canvas.restore();
}

void _drawOriginal(Canvas canvas, _Source src, double size) {
  canvas.drawImageRect(
    src.image,
    Rect.fromLTWH(0, 0, src.image.width.toDouble(), src.image.height.toDouble()),
    Rect.fromLTWH(0, 0, size, size),
    Paint()..filterQuality = FilterQuality.high,
  );
}

Future<void> _writePng(String path, int side, void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(side, side);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(data!.buffer.asUint8List());
  stdout.writeln('gerado: $path (${side}x$side)');
}

// Escalas do símbolo, em relação ao original inteiro:
//  - Android adaptativo: o launcher garante só o miolo de 66 dp de uma tela de 108 dp, em
//    círculo; o símbolo (cantos com setas e pontos) precisa caber ali. O flutter_launcher_icons
//    já encolhe a camada com `inset="16%"` (fica em 68%), então aqui só falta 0,90 (0,90 x 0,68
//    deixa o símbolo em ~61% da tela, o limite da zona segura).
//  - Android 12+ (splash): a imagem é recortada em círculo (miolo de 2/3 de 960).
const _adaptiveScale = 0.90;
const _launcherInset = 0.68; // 1 - 2 x 16%, aplicado pelo flutter_launcher_icons (só na prévia)
const _splashScale = 0.85;
const _splash12Scale = 0.64;

/// Folha de contato (não versionada, em build/) para conferir máscaras e tamanhos pequenos.
Future<void> _writePreview(_Source src) async {
  const w = 1500.0, h = 820.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFE9E4E2));

  void tile(double x, double y, double side, Path clip, void Function(Canvas, double) body) {
    canvas.save();
    canvas.translate(x, y);
    canvas.clipPath(clip);
    body(canvas, side);
    canvas.restore();
  }

  Path squircle(double s) =>
      Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), Radius.circular(s * 0.2237)));
  Path circle(double s) => Path()..addOval(Rect.fromLTWH(0, 0, s, s));

  void ios(Canvas c, double s) => _drawOriginal(c, src, s);
  void android(Canvas c, double s) {
    c.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = _background);
    _drawGlyph(c, src, s, _adaptiveScale * _launcherInset, _glyph);
  }

  tile(30, 30, 360, squircle(360), ios);
  tile(420, 30, 360, circle(360), android);
  for (final (i, s) in [120.0, 80.0, 48.0].indexed) {
    final x = [830.0, 970.0, 1070.0][i];
    tile(x, 30, s, squircle(s), ios);
    tile(x, 170, s, circle(s), android);
  }

  // Splash (fundo coral, símbolo claro).
  canvas.drawRect(const Rect.fromLTWH(1160, 30, 150, 300), Paint()..color = _background);
  canvas.save();
  canvas.translate(1160, 105);
  _drawGlyph(canvas, src, 150, _splashScale, _glyph);
  canvas.restore();

  // Ícone temático do Android 13+ (o sistema pinta só o alfa, aqui em branco sobre cinza escuro).
  tile(420, 420, 360, circle(360), (c, s) {
    c.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = const Color(0xFF5B3A3C));
    _drawGlyph(c, src, s, _adaptiveScale * _launcherInset, _white);
  });

  final image = await recorder.endRecording().toImage(w.toInt(), h.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  File('build/brand_preview.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(data!.buffer.asUint8List());
  stdout.writeln('gerado: build/brand_preview.png');
}

void main() {
  test('gera os arquivos de origem do ícone e da splash a partir do ícone original', () async {
    final src = await _loadSource();

    // Android adaptativo: o fundo é a cor lisa (no pubspec); aqui só a camada do símbolo.
    await _writePng('assets/icon/adaptive_foreground.png', 1024, (c) => _drawGlyph(c, src, 1024, _adaptiveScale, _glyph));
    // Android 13+ "ícone temático": só o canal alfa importa, o sistema aplica a cor do tema.
    await _writePng('assets/icon/adaptive_monochrome.png', 1024, (c) => _drawGlyph(c, src, 1024, _adaptiveScale, _white));

    // Splash: símbolo sobre transparente (a cor de fundo vem do flutter_native_splash).
    await _writePng('assets/splash/splash.png', 768, (c) => _drawGlyph(c, src, 768, _splashScale, _glyph));
    await _writePng('assets/splash/splash_android12.png', 960, (c) => _drawGlyph(c, src, 960, _splash12Scale, _glyph));

    await _writePreview(src);
  });
}
