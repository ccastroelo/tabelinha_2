import 'package:flutter/widgets.dart';

import '../core/cycle_calculator.dart';
import '../core/date_only.dart';
import '../data/cycle_repository.dart';
import '../data/legacy_data.dart';
import '../data/period_record.dart';

/// Estado do app: ajustes do ciclo, histórico e aceite dos termos.
class AppController extends ChangeNotifier {
  AppController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        _settings = _repository.loadSettings(),
        _records = _repository.loadRecords(),
        _termsAccepted = _repository.loadTermsAcceptedAt() != null;

  final CycleRepository _repository;
  final DateTime Function() _now;

  CycleSettings _settings;
  List<PeriodRecord> _records;
  bool _termsAccepted;

  CycleSettings get settings => _settings;
  CycleCalculator get calculator => CycleCalculator(_settings);
  bool get termsAccepted => _termsAccepted;

  /// Dia de hoje sem hora, calculado a cada leitura para acompanhar a virada do dia.
  DateTime get today => dateOnly(_now());

  /// Do mais recente para o mais antigo.
  List<PeriodRecord> get records {
    final sorted = [..._records]..sort((a, b) => b.end.compareTo(a.end));
    return List.unmodifiable(sorted);
  }

  Future<void> acceptTerms([DateTime? at]) async {
    _termsAccepted = true;
    notifyListeners();
    await _repository.saveTermsAcceptedAt(at ?? _now());
  }

  /// Traz dados do app antigo sem sobrescrever nada: ajustes só entram se ainda
  /// não há data de início, registros com o mesmo início são mesclados (a
  /// anotação existente vence) e quem já aceitou os termos antes não aceita de novo.
  Future<void> importLegacy(LegacyData data) async {
    final start = data.start;
    if (_settings.start == null && start != null) {
      _settings = _settings.copyWith(
        start: start,
        cycleLength: data.cycleLength,
        periodLength: data.periodLength,
      );
      await _repository.saveSettings(_settings);
    }

    if (data.records.isNotEmpty) {
      final next = [..._records];
      for (final old in data.records) {
        final index = next.indexWhere((r) => r.start.isSameDay(old.start));
        if (index == -1) {
          next.add(old);
        } else if (next[index].note.isEmpty && old.note.isNotEmpty) {
          next[index] = next[index].copyWith(note: old.note);
        }
      }
      _records = next;
      await _repository.saveRecords(next);
    }

    final termsAt = data.termsAcceptedAt;
    if (!_termsAccepted && termsAt != null) {
      _termsAccepted = true;
      await _repository.saveTermsAcceptedAt(termsAt);
    }

    notifyListeners();
  }

  Future<void> setCycleStart(DateTime date) =>
      _updateSettings(_settings.copyWith(start: dateOnly(date)));

  Future<void> setCycleLength(int days) =>
      _updateSettings(_settings.copyWith(cycleLength: days));

  Future<void> setPeriodLength(int days) =>
      _updateSettings(_settings.copyWith(periodLength: days));

  Future<void> _updateSettings(CycleSettings next) async {
    _settings = next;
    notifyListeners();
    await _repository.saveSettings(next);
  }

  /// Guarda as menstruações no histórico. Quem já existe (mesmo início) tem o
  /// fim atualizado e mantém a anotação. Devolve quantas são novas.
  Future<int> registerPeriods(Iterable<PeriodRange> ranges) async {
    var added = 0;
    final next = [..._records];
    for (final range in ranges) {
      final index = next.indexWhere((r) => r.start.isSameDay(range.start));
      if (index == -1) {
        next.add(PeriodRecord(start: range.start, end: range.end));
        added++;
      } else {
        next[index] = next[index].copyWith(end: range.end);
      }
    }
    await _saveRecords(next);
    return added;
  }

  /// Também serve para desfazer uma exclusão.
  Future<void> putRecord(PeriodRecord record) async {
    final next = _records.where((r) => r.id != record.id).toList()..add(record);
    await _saveRecords(next);
  }

  Future<void> removeRecord(PeriodRecord record) =>
      _saveRecords(_records.where((r) => r.id != record.id).toList());

  Future<void> updateNote(PeriodRecord record, String note) async {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index == -1) return;
    final trimmed = note.trim();
    if (_records[index].note == trimmed) return;
    final next = [..._records];
    next[index] = next[index].copyWith(note: trimmed);
    await _saveRecords(next);
  }

  Future<void> _saveRecords(List<PeriodRecord> next) async {
    _records = next;
    notifyListeners();
    await _repository.saveRecords(next);
  }
}

/// Dá acesso ao [AppController] a qualquer widget abaixo dele.
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({super.key, required AppController controller, required super.child})
      : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado acima deste contexto');
    return scope!.notifier!;
  }
}
