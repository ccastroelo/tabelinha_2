import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../state/app_controller.dart';
import 'cycle_repository.dart';
import 'legacy_data.dart';

abstract class LegacyDataSource {
  /// `null` quando não há nada do app antigo.
  Future<LegacyData?> read();
}

/// Pede ao código nativo do iOS (`LegacyDataReader`) os dados do app antigo.
class ChannelLegacyDataSource implements LegacyDataSource {
  static const channel = MethodChannel('br.eti.claudiocastro.tabelinha/data');

  @override
  Future<LegacyData?> read() async {
    final json = await channel.invokeMethod<String>('getData');
    return json == null ? null : LegacyData.tryParse(json);
  }
}

/// Traz para o app novo os dados de quem usava o app iOS original. Roda uma vez
/// (na primeira abertura depois da atualização) e nunca derruba a inicialização.
class LegacyImporter {
  LegacyImporter({
    required this.repository,
    required this.controller,
    LegacyDataSource? source,
  }) : source = source ?? _platformSource();

  final CycleRepository repository;
  final AppController controller;

  /// `null` fora do iOS: o app antigo nunca existiu lá.
  final LegacyDataSource? source;

  static LegacyDataSource? _platformSource() =>
      defaultTargetPlatform == TargetPlatform.iOS ? ChannelLegacyDataSource() : null;

  /// `true` se algo foi importado agora.
  Future<bool> run() async {
    final source = this.source;
    if (source == null || repository.legacyImported) return false;

    try {
      final data = await source.read();
      final hasData = data != null && !data.isEmpty;
      if (hasData) await controller.importLegacy(data);
      // Só marca como feito se a leitura funcionou. Se falhou (canal ausente,
      // arquivo ilegível), tenta de novo na próxima abertura.
      await repository.markLegacyImported();
      return hasData;
    } on Exception catch (e, stack) {
      debugPrint('Importação dos dados antigos falhou: $e\n$stack');
      return false;
    }
  }
}
