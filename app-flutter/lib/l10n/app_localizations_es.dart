// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Calendario de Fertilidad';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get historyTitle => 'Registros';

  @override
  String get notesTitle => 'Notas';

  @override
  String get shareTooltip => 'Compartir calendario';

  @override
  String get shareError => 'No se pudo compartir.';

  @override
  String get today => 'Hoy';

  @override
  String get goToToday => 'Ir a hoy';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get menstruation => 'Menstruación';

  @override
  String get fertileWindow => 'Período fértil';

  @override
  String get ovulation => 'Ovulación';

  @override
  String get yourCycle => 'Tu ciclo';

  @override
  String get cycleStart => 'Inicio del ciclo';

  @override
  String get cycleLength => 'Duración del ciclo';

  @override
  String get periodLength => 'Duración de la menstruación';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count días',
      one: 'mañana',
      zero: 'hoy',
    );
    return '$_temp0';
  }

  @override
  String decreaseValue(String label) {
    return 'Disminuir: $label';
  }

  @override
  String increaseValue(String label) {
    return 'Aumentar: $label';
  }

  @override
  String get autoCycleTitle => 'Calcular según el historial';

  @override
  String autoCycleUsing(int days, int cycles) {
    return 'Usando $days días, la media de tus últimos $cycles ciclos.';
  }

  @override
  String autoCycleNeedsData(int count) {
    return 'Con $count menstruaciones en el historial, la app pasa a usar la media de tus ciclos. Por ahora vale la duración de arriba.';
  }

  @override
  String get autoCycleOff => 'Usando la duración que definiste arriba.';

  @override
  String get remindersTitle => 'Recordatorios';

  @override
  String get remindersHintOff =>
      'Avisos en el propio dispositivo. No se envía nada fuera de él.';

  @override
  String remindersHintOn(String time) {
    return 'Avisos en el dispositivo, a las $time.';
  }

  @override
  String get remindersBlocked =>
      'Las notificaciones están bloqueadas para la app. Actívalas en los ajustes del sistema.';

  @override
  String get reminderTime => 'Hora';

  @override
  String get reminderAdvance => 'Avisar con antelación';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días antes',
      one: '1 día antes',
      zero: 'El mismo día',
    );
    return '$_temp0';
  }

  @override
  String get reminderFertileToggle => 'Inicio del período fértil';

  @override
  String get reminderOvulationToggle => 'Día de la ovulación';

  @override
  String get reminderChannelName => 'Recordatorios del ciclo';

  @override
  String get reminderChannelDescription =>
      'Avisos sobre tu próxima menstruación, el período fértil y la ovulación.';

  @override
  String get reminderPeriodTitle => 'Menstruación en camino';

  @override
  String reminderPeriodBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Tu menstruación está prevista dentro de $days días. Es solo una estimación.',
      one: 'Tu menstruación está prevista para mañana. Es solo una estimación.',
      zero: 'Tu menstruación está prevista para hoy. Es solo una estimación.',
    );
    return '$_temp0';
  }

  @override
  String get reminderFertileTitle => 'Período fértil';

  @override
  String get reminderFertileBody => 'Tu período fértil estimado empieza hoy.';

  @override
  String get reminderOvulationTitle => 'Ovulación';

  @override
  String get reminderOvulationBody => 'Hoy es tu día probable de ovulación.';

  @override
  String get setupTitle => 'Empecemos';

  @override
  String get setupBody =>
      'Indica el primer día de tu última menstruación para ver el calendario.';

  @override
  String get setupAction => 'Indicar fecha';

  @override
  String dayOfCycle(int day) {
    return 'Día $day del ciclo';
  }

  @override
  String get nextPeriod => 'Próxima menstruación';

  @override
  String get estimateNote =>
      'Cálculo estimado. No lo uses como método anticonceptivo.';

  @override
  String get registerMonth => 'Registrar menstruación del mes';

  @override
  String get registeredSnack => 'Menstruación guardada en el historial.';

  @override
  String get alreadyRegisteredSnack => 'Este mes ya estaba en el historial.';

  @override
  String get viewAction => 'Ver';

  @override
  String get historyEmptyTitle => 'Aún no hay registros';

  @override
  String get historyEmptyBody =>
      'En la pantalla de inicio, toca “Registrar menstruación del mes” para guardar un período aquí.';

  @override
  String get recordRemoved => 'Registro eliminado';

  @override
  String get undo => 'Deshacer';

  @override
  String get deleteRecord => 'Eliminar registro';

  @override
  String get notesHint => 'Escribe aquí tus notas…';

  @override
  String get addNote => 'Añadir una nota';

  @override
  String get termsTitle => 'Atención';

  @override
  String get termsBody =>
      'El \"Calendario de Fertilidad\" no debe ser usado como un método anticonceptivo. El período de ovulación puede variar de mujer a mujer, además de que existen diversos factores que también alteran la duración del ciclo, tales como: ansiedad, estrés, enfermedades, entre otros.\n\nPor lo tanto, el método es recomendado para la mujer que quiere embarazarse, y no para aquella que pretende evitar el embarazo. Además de eso, su cálculo es solamente una estimación.';

  @override
  String get termsAgree => 'Estoy consciente';

  @override
  String get termsContinue => 'Continuar';

  @override
  String get helpBody =>
      'El \"Calendario de Fertilidad\" es un método usado para tratar de prever los períodos fértiles e infértiles de una mujer. Con él es posible estimar las fechas en las que hay mayor o menor probabilidad de embarazo en caso de relación sexual.\n\nMientras tanto, al contrario de lo que piensa la mayoría de las personas, el calendario de fertilidad no debe ser usado como medio anticonceptivo, pero puede ser usado como una óptima herramienta para quien quiere quedar embarazada. Sin embargo, el método de embarazarse usando el calendario de fertilidad todavía es algo muy confuso para la mayoría de las mujeres.\n\nEl método provee, a través de cálculos estimados, la probable fecha de la ovulación y los períodos más y menos propicios para embarazarse, basado en la fecha de la última ovulación y en la cantidad de días del ciclo menstrual.\n\nNormalmente la ovulación ocurre en el medio del ciclo menstrual. Así, por ejemplo, en un ciclo de 28 días, la ovulación ocurrirá entre el 12º y el 15º día a contar del primer día de la menstruación anterior. Debido a posibles variaciones de la ovulación, así como tiempo de vida de los espermatozoides, el período fértil es considerado de 4 días antes a 4 días después del día probable, totalizando 9 días.\n\nCuando hay al menos 3 menstruaciones en el historial, la app usa la media de tus últimos ciclos (hasta 6) en lugar de la duración que indicaste, y los ciclos que ya viviste aparecen con sus fechas reales. Así la previsión sigue tu propio ritmo. Puedes desactivarlo en «Tu ciclo».\n\nEn algunas situaciones, donde el ciclo menstrual no sigue una regularidad, el calendario de fertilidad no debe ser utilizado.\n\nComo los casos de:\n• Adolescentes, donde es raro que haya un ciclo regular.\n• Mujeres con ciclo menstrual irregular.\n• Mujeres con alteraciones hormonales, emocionales, o aun alimentarias.\n\nSe nota por lo tanto, que el calendario de fertilidad no es un método confiable como anticonceptivo. Además de eso, existen casos de mujeres que pueden quedar embarazadas fuera del período fértil, aun durante la menstruación.\n\nEs importante recordar que este método no previene el SIDA ni otras enfermedades de transmisión sexual.';
}
