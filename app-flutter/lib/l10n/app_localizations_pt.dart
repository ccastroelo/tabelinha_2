// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Tabelinha';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get historyTitle => 'Registros';

  @override
  String get notesTitle => 'Anotações';

  @override
  String get shareTooltip => 'Compartilhar calendário';

  @override
  String get shareError => 'Não foi possível compartilhar.';

  @override
  String get today => 'Hoje';

  @override
  String get goToToday => 'Ir para hoje';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Próximo mês';

  @override
  String get menstruation => 'Menstruação';

  @override
  String get fertileWindow => 'Período fértil';

  @override
  String get ovulation => 'Ovulação';

  @override
  String get yourCycle => 'Seu ciclo';

  @override
  String get cycleStart => 'Início do ciclo';

  @override
  String get cycleLength => 'Duração do ciclo';

  @override
  String get periodLength => 'Duração da menstruação';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'em $count dias',
      one: 'amanhã',
      zero: 'hoje',
    );
    return '$_temp0';
  }

  @override
  String decreaseValue(String label) {
    return 'Diminuir: $label';
  }

  @override
  String increaseValue(String label) {
    return 'Aumentar: $label';
  }

  @override
  String get setupTitle => 'Vamos começar';

  @override
  String get setupBody =>
      'Informe o primeiro dia da sua última menstruação para ver o calendário.';

  @override
  String get setupAction => 'Informar data';

  @override
  String dayOfCycle(int day) {
    return 'Dia $day do ciclo';
  }

  @override
  String get nextPeriod => 'Próxima menstruação';

  @override
  String get estimateNote =>
      'Cálculo estimado. Não use como método contraceptivo.';

  @override
  String get registerMonth => 'Registrar menstruação do mês';

  @override
  String get registeredSnack => 'Menstruação registrada no histórico.';

  @override
  String get alreadyRegisteredSnack => 'Este mês já estava no histórico.';

  @override
  String get viewAction => 'Ver';

  @override
  String get historyEmptyTitle => 'Nenhum registro ainda';

  @override
  String get historyEmptyBody =>
      'Na tela inicial, toque em “Registrar menstruação do mês” para guardar um período aqui.';

  @override
  String get recordRemoved => 'Registro removido';

  @override
  String get undo => 'Desfazer';

  @override
  String get deleteRecord => 'Excluir registro';

  @override
  String get notesHint => 'Escreva aqui suas anotações…';

  @override
  String get termsTitle => 'Atenção';

  @override
  String get termsBody =>
      'A \"tabelinha\" não deve ser usada como um método contraceptivo. O período de ovulação pode variar de mulher para mulher, além de existirem diversos fatores que também alteram a duração do ciclo, tais como: ansiedade, estresse, doenças, entre outros.\n\nPortanto, o método é recomendado à mulher que quer engravidar, e não para aquela que pretende evitar a gravidez. Além disso, seu cálculo é apenas uma estimativa.';

  @override
  String get termsAgree => 'Estou ciente';

  @override
  String get termsContinue => 'Continuar';

  @override
  String get helpBody =>
      'A \"tabelinha\" é um método usado para tentar prever os períodos férteis e inférteis de uma mulher. Através dela é possível estimar as datas onde há maior ou menor probabilidade de gravidez em caso de relação sexual.\n\nNo entanto, ao contrário que a maioria das pessoas pensa, a tabelinha não deve ser usada como meio contraceptivo, mas pode ser usada como ótima ferramenta para quem busca engravidar. Porém, o método de engravidar usando a tabelinha ainda é algo muito confuso para a maioria das mulheres.\n\nO método fornece, através de cálculos estimados, a provável data da ovulação e os períodos mais e menos propícios para engravidar, com base na data da última ovulação e na quantidade de dias do ciclo menstrual.\n\nNormalmente a ovulação ocorre no meio do ciclo menstrual. Assim, por exemplo, em um ciclo de 28 dias, a ovulação ocorrerá entre o 12º e o 15º dias a contar do primeiro dia da menstruação anterior. Devido a possíveis variações da ovulação, bem como tempo de vida dos espermatozoides, o período fértil é considerado de 4 dias antes a 4 dias depois do dia provável, totalizando 9 dias.\n\nEm algumas situações, onde o ciclo menstrual não segue uma regularidade, a tabelinha não deve ser utilizada.\nComo os casos de:\n• Adolescentes, onde é raro haver um ciclo regular.\n• Mulheres com ciclo menstrual desregulado.\n• Mulheres com alterações hormonais, emocionais, ou mesmo alimentares.\n\nPercebe-se então, que a tabelinha não é um método confiável como contraceptivo. Além disso, existem casos de mulheres que podem engravidar fora do período fértil, mesmo durante a menstruação.\n\nÉ importante lembrar que este método não previne a AIDS nem outras DSTs.';
}
