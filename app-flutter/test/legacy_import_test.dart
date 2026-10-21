import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabelinha/data/cycle_repository.dart';
import 'package:tabelinha/data/legacy_data.dart';
import 'package:tabelinha/data/legacy_importer.dart';
import 'package:tabelinha/state/app_controller.dart';

/// Formato que `LegacyDataReader` (AppDelegate.swift) devolve, com os defeitos
/// que dados de 2013–2015 podem ter: anotação com espaços, registro repetido,
/// registro sem fim e fim antes do início.
const _legacyJson = '''
{
  "start": "2026-10-05",
  "cycleLength": 30,
  "periodLength": 6,
  "termsAcceptedAt": "2015-03-02T13:45:00Z",
  "records": [
    {"start": "2026-08-08", "end": "2026-08-12", "note": "  dor forte  "},
    {"start": "2026-09-07", "end": "2026-09-11", "note": ""},
    {"start": "2026-09-07", "end": "2026-09-11", "note": "repetido"},
    {"start": "2026-07-01"},
    {"start": "2026-06-10", "end": "2026-06-05", "note": "x"}
  ]
}
''';

class _FakeSource implements LegacyDataSource {
  _FakeSource({this.data, this.error});

  final LegacyData? data;
  final Object? error;
  int calls = 0;

  @override
  Future<LegacyData?> read() async {
    calls++;
    if (error != null) throw error!;
    return data;
  }
}

Future<(CycleRepository, AppController)> _open([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final repository = await CycleRepository.open();
  return (repository, AppController(repository, now: () => DateTime(2026, 10, 21)));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegacyData.tryParse', () {
    test('lê o que o Swift envia e descarta registros inválidos', () {
      final data = LegacyData.tryParse(_legacyJson)!;

      expect(data.start, DateTime.utc(2026, 10, 5));
      expect(data.cycleLength, 30);
      expect(data.periodLength, 6);
      expect(data.termsAcceptedAt, DateTime.utc(2015, 3, 2, 13, 45));
      // Sobram 3: sem fim e fim antes do início ficam de fora.
      expect(data.records, hasLength(3));
      expect(data.records.first.note, 'dor forte');
    });

    test('campos ausentes ou com tipo errado viram nulos sem derrubar o resto', () {
      final data = LegacyData.tryParse(
        '{"start": 5, "cycleLength": "28", "periodLength": 5.0, "records": "nada"}',
      )!;
      expect(data.start, isNull);
      expect(data.cycleLength, isNull);
      expect(data.periodLength, 5);
      expect(data.records, isEmpty);
    });

    test('lixo não é um objeto JSON', () {
      expect(LegacyData.tryParse('não é json'), isNull);
      expect(LegacyData.tryParse('[1, 2]'), isNull);
    });

    test('objeto vazio é "sem dados"', () {
      expect(LegacyData.tryParse('{"records": []}')!.isEmpty, isTrue);
    });
  });

  group('LegacyImporter', () {
    test('importa ajustes, histórico e termos, e tudo persiste', () async {
      final (repository, controller) = await _open();
      final source = _FakeSource(data: LegacyData.tryParse(_legacyJson));

      final imported = await LegacyImporter(
        repository: repository,
        controller: controller,
        source: source,
      ).run();

      expect(imported, isTrue);
      expect(controller.settings.start, DateTime.utc(2026, 10, 5));
      expect(controller.settings.cycleLength, 30);
      expect(controller.settings.periodLength, 6);
      expect(controller.termsAccepted, isTrue);
      // Do mais recente para o mais antigo; o duplicado de 7/9 virou um só, com a anotação.
      expect(controller.records.map((r) => r.id), ['2026-09-07', '2026-08-08']);
      expect(controller.records.first.note, 'repetido');
      expect(controller.records.last.note, 'dor forte');
      expect(repository.loadTermsAcceptedAt()?.toUtc(), DateTime.utc(2015, 3, 2, 13, 45));

      // Reabrir o app: está tudo salvo.
      final reopened = AppController(await CycleRepository.open());
      expect(reopened.settings.cycleLength, 30);
      expect(reopened.records, hasLength(2));
      expect(reopened.termsAccepted, isTrue);
    });

    test('roda uma única vez', () async {
      final (repository, controller) = await _open();
      final source = _FakeSource(data: LegacyData.tryParse(_legacyJson));
      final importer = LegacyImporter(repository: repository, controller: controller, source: source);

      expect(await importer.run(), isTrue);
      expect(repository.legacyImported, isTrue);
      expect(await importer.run(), isFalse);
      expect(source.calls, 1);
    });

    test('não sobrescreve nada que já existe no app novo', () async {
      final (repository, controller) = await _open({
        'termsAcceptedAt': '2026-01-01T10:00:00.000',
        'cycleStart': '2026-11-01',
        'cycleLength': 26,
        'periodLength': 4,
        'periodRecords': '[{"start":"2026-08-08","end":"2026-08-11","note":"minha"}]',
      });

      await LegacyImporter(
        repository: repository,
        controller: controller,
        source: _FakeSource(data: LegacyData.tryParse(_legacyJson)),
      ).run();

      expect(controller.settings.start, DateTime.utc(2026, 11, 1));
      expect(controller.settings.cycleLength, 26);
      expect(controller.settings.periodLength, 4);
      expect(repository.loadTermsAcceptedAt(), DateTime.parse('2026-01-01T10:00:00.000'));

      final aug = controller.records.firstWhere((r) => r.id == '2026-08-08');
      expect(aug.note, 'minha');
      expect(aug.end, DateTime.utc(2026, 8, 11));
      expect(controller.records, hasLength(2)); // 8/8 existente + 7/9 importado
    });

    test('anotação do app antigo preenche registro existente sem anotação', () async {
      final (repository, controller) = await _open({
        'periodRecords': '[{"start":"2026-08-08","end":"2026-08-12"}]',
      });

      await LegacyImporter(
        repository: repository,
        controller: controller,
        source: _FakeSource(data: LegacyData.tryParse(_legacyJson)),
      ).run();

      expect(controller.records.firstWhere((r) => r.id == '2026-08-08').note, 'dor forte');
    });

    test('falha na leitura não derruba o app e tenta de novo na próxima abertura', () async {
      final (repository, controller) = await _open();

      final imported = await LegacyImporter(
        repository: repository,
        controller: controller,
        source: _FakeSource(error: PlatformException(code: 'x')),
      ).run();

      expect(imported, isFalse);
      expect(repository.legacyImported, isFalse);
      expect(controller.settings.start, isNull);
      expect(controller.records, isEmpty);
    });

    test('sem dados antigos: nada muda, mas não pergunta de novo', () async {
      final (repository, controller) = await _open();

      final imported = await LegacyImporter(
        repository: repository,
        controller: controller,
        source: _FakeSource(data: const LegacyData()),
      ).run();

      expect(imported, isFalse);
      expect(repository.legacyImported, isTrue);
      expect(controller.termsAccepted, isFalse);
    });

    test('fora do iOS não há fonte e nada é feito', () async {
      final (repository, controller) = await _open();

      // Em teste, defaultTargetPlatform é Android.
      final imported = await LegacyImporter(repository: repository, controller: controller).run();

      expect(imported, isFalse);
      expect(repository.legacyImported, isFalse);
    });
  });

  group('ChannelLegacyDataSource', () {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(ChannelLegacyDataSource.channel, null));

    test('chama getData e interpreta a resposta', () async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(ChannelLegacyDataSource.channel, (call) async {
        calls.add(call.method);
        return _legacyJson;
      });

      final data = await ChannelLegacyDataSource().read();

      expect(calls, ['getData']);
      expect(data!.cycleLength, 30);
      expect(data.records, hasLength(3));
    });

    test('resposta nula do lado nativo é "sem dados"', () async {
      messenger.setMockMethodCallHandler(ChannelLegacyDataSource.channel, (_) async => null);
      expect(await ChannelLegacyDataSource().read(), isNull);
    });

    test('sem o código nativo registrado o importador desiste sem estourar', () async {
      final (repository, controller) = await _open();

      final imported = await LegacyImporter(
        repository: repository,
        controller: controller,
        source: ChannelLegacyDataSource(),
      ).run();

      expect(imported, isFalse);
      expect(repository.legacyImported, isFalse);
    });
  });
}
