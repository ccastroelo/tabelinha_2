import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../core/cycle_calculator.dart';
import '../core/date_only.dart';
import '../core/reminders.dart';
import '../data/cycle_repository.dart';
import '../data/legacy_data.dart';
import '../data/period_record.dart';
import '../data/reminder_service.dart';
import 'reminder_texts.dart';

/// Estado do app: ajustes do ciclo, histórico, lembretes e aceite dos termos.
class AppController extends ChangeNotifier {
  AppController(
    this._repository, {
    DateTime Function()? now,
    ReminderService? reminderService,
    Locale Function()? deviceLocale,
  })  : _now = now ?? DateTime.now,
        _reminderService = reminderService ?? const NoReminderService(),
        _deviceLocale = deviceLocale ?? (() => PlatformDispatcher.instance.locale),
        _settings = _repository.loadSettings(),
        _records = _repository.loadRecords(),
        _reminders = _repository.loadReminderSettings(),
        _intercourse = _repository.loadIntercourseDates(),
        _termsAccepted = _repository.loadTermsAcceptedAt() != null;

  final CycleRepository _repository;
  final DateTime Function() _now;
  final ReminderService _reminderService;
  final Locale Function() _deviceLocale;

  CycleSettings _settings;
  List<PeriodRecord> _records;
  ReminderSettings _reminders;
  Set<DateTime> _intercourse;
  bool _termsAccepted;

  /// Os lembretes estão ligados, mas o sistema não deixa o app mostrar notificações.
  bool _remindersBlocked = false;

  /// Já há avisos agendados nesta sessão (para só cancelar quando há o que cancelar).
  bool _hasScheduledReminders = false;

  /// As sincronizações correm uma depois da outra, para duas mudanças seguidas não se atropelarem.
  Future<void> _syncChain = Future.value();

  CycleSettings get settings => _settings;
  bool get termsAccepted => _termsAccepted;

  /// Menstruações já vividas: o início de referência e os registros que já começaram.
  List<PeriodRange> get _knownPeriods => knownPeriods(
        reference: _settings.start,
        periodLength: _settings.periodLength,
        records: _records.map((r) => PeriodRange(r.start, r.end)),
        today: today,
      );

  /// Média dos últimos ciclos, ou `null` enquanto o histórico não basta (ou se a pessoa
  /// desligou o cálculo pelo histórico).
  CycleEstimate? get estimate => _settings.autoCycleLength
      ? estimateCycleLength(_knownPeriods.map((p) => p.start), today: today)
      : null;

  /// Duração do ciclo que o app usa de fato nas projeções: a média, se houver, ou a
  /// que a pessoa definiu.
  int get effectiveCycleLength => estimate?.cycleLength ?? _settings.cycleLength;

  CycleCalculator get calculator {
    if (!_settings.autoCycleLength) return CycleCalculator(_settings);
    return CycleCalculator(
      _settings.copyWith(cycleLength: effectiveCycleLength),
      known: _knownPeriods,
    );
  }

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
    unawaited(syncReminders());
  }

  Future<void> setCycleStart(DateTime date) =>
      _updateSettings(_settings.copyWith(start: dateOnly(date)));

  Future<void> setCycleLength(int days) =>
      _updateSettings(_settings.copyWith(cycleLength: days));

  Future<void> setPeriodLength(int days) =>
      _updateSettings(_settings.copyWith(periodLength: days));

  /// Liga ou desliga o cálculo pelo histórico. Ao desligar, o valor manual passa a ser o
  /// que a média estava dando, para o calendário não dar um salto sob os olhos da pessoa.
  Future<void> setAutoCycleLength(bool enabled) {
    final next = enabled
        ? _settings.copyWith(autoCycleLength: true)
        : _settings.copyWith(autoCycleLength: false, cycleLength: effectiveCycleLength);
    return _updateSettings(next);
  }

  Future<void> _updateSettings(CycleSettings next) async {
    _settings = next;
    notifyListeners();
    await _repository.saveSettings(next);
    unawaited(syncReminders());
  }

  ReminderSettings get reminders => _reminders;

  /// Os lembretes estão ligados, mas o sistema bloqueia as notificações do app.
  bool get remindersBlocked => _remindersBlocked;

  /// Liga ou desliga os lembretes. Ao ligar o sistema pede permissão; se ela for negada os
  /// lembretes continuam desligados e [remindersBlocked] avisa a tela.
  Future<void> setRemindersEnabled(bool enabled) async {
    if (!enabled) {
      _remindersBlocked = false;
      await _saveReminders(_reminders.copyWith(enabled: false));
      return;
    }
    // Um erro do plugin conta como "não deu": a tela explica, em vez de a exceção estourar no
    // toque do interruptor.
    var granted = false;
    try {
      granted = await _reminderService.requestPermission();
    } catch (error) {
      debugPrint('Lembretes: $error');
    }
    _remindersBlocked = !granted;
    if (granted) {
      await _saveReminders(_reminders.copyWith(enabled: true));
    } else {
      notifyListeners();
    }
  }

  /// Muda horário, antecedência e quais avisos valem. Ligar e desligar tudo passa por
  /// [setRemindersEnabled], que cuida da permissão.
  Future<void> updateReminders(ReminderSettings next) =>
      _saveReminders(next.copyWith(enabled: _reminders.enabled));

  Future<void> _saveReminders(ReminderSettings next) async {
    _reminders = next;
    notifyListeners();
    await _repository.saveReminderSettings(next);
    await syncReminders();
  }

  /// Põe no sistema os avisos que o calendário prevê agora (ou tira todos, se os lembretes
  /// estão desligados). Roda sempre que os dados mudam e quando o app abre.
  Future<void> syncReminders() {
    final run = _syncChain.then((_) => _syncRemindersNow()).catchError((Object error) {
      debugPrint('Lembretes: $error');
    });
    _syncChain = run;
    return run;
  }

  Future<void> _syncRemindersNow() async {
    Future<void> cancelIfScheduled() async {
      if (!_hasScheduledReminders) return;
      await _reminderService.cancelAll();
      _hasScheduledReminders = false;
    }

    if (!_reminders.enabled) return cancelIfScheduled();

    if (!await _reminderService.isAllowed()) {
      if (!_remindersBlocked) {
        _remindersBlocked = true;
        notifyListeners();
      }
      return cancelIfScheduled();
    }
    if (_remindersBlocked) {
      _remindersBlocked = false;
      notifyListeners();
    }

    final l10n = reminderLocalizations(_deviceLocale());
    final plan = planReminders(calculator: calculator, settings: _reminders, now: _now());
    await _reminderService.replaceAll(
      [for (final reminder in plan) reminderText(l10n, reminder)],
      channelName: l10n.reminderChannelName,
      channelDescription: l10n.reminderChannelDescription,
    );
    _hasScheduledReminders = true;
  }

  /// Guarda as menstruações no histórico. Quem já existe (mesmo início) tem o
  /// fim atualizado e mantém a anotação. Uma data a menos de
  /// [CycleSettings.minCycleLength] dias de um registro é a mesma menstruação com a data
  /// corrigida: substitui o registro (e mantém a anotação) em vez de criar outro, que
  /// estragaria a média dos ciclos. Devolve quantas são novas ou corrigidas.
  Future<int> registerPeriods(Iterable<PeriodRange> ranges) async {
    var added = 0;
    final next = [..._records];
    for (final range in ranges) {
      final same = next.indexWhere((r) => r.start.isSameDay(range.start));
      if (same != -1) {
        next[same] = next[same].copyWith(end: range.end);
        continue;
      }

      final near = next.indexWhere(
        (r) => r.start.daysSince(range.start).abs() < CycleSettings.minCycleLength,
      );
      final record = PeriodRecord(
        start: range.start,
        end: range.end,
        note: near == -1 ? '' : next[near].note,
      );
      if (near == -1) {
        next.add(record);
      } else {
        next[near] = record;
      }
      added++;
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

  /// Os dias marcados com relação sexual. Não entram em nenhum cálculo: servem para a
  /// pessoa olhar o calendário e saber se a relação caiu na janela fértil.
  Set<DateTime> get intercourseDates => Set.unmodifiable(_intercourse);

  bool hasIntercourse(DateTime day) => _intercourse.contains(dateOnly(day));

  /// Marca ou desmarca o dia. Não mexe nos lembretes nem na previsão: nada aqui muda o
  /// calendário, então não há o que reagendar.
  Future<void> toggleIntercourse(DateTime day) async {
    final date = dateOnly(day);
    final next = {..._intercourse};
    if (!next.remove(date)) next.add(date);
    _intercourse = next;
    notifyListeners();
    await _repository.saveIntercourseDates(next);
  }

  Future<void> _saveRecords(List<PeriodRecord> next) async {
    _records = next;
    notifyListeners();
    await _repository.saveRecords(next);
    unawaited(syncReminders());
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
