import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tabelinha'**
  String get appTitle;

  /// No description provided for @helpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get helpTitle;

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Registros'**
  String get historyTitle;

  /// No description provided for @notesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Anotações'**
  String get notesTitle;

  /// No description provided for @shareTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar calendário'**
  String get shareTooltip;

  /// No description provided for @shareError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível compartilhar.'**
  String get shareError;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @goToToday.
  ///
  /// In pt, this message translates to:
  /// **'Ir para hoje'**
  String get goToToday;

  /// No description provided for @previousMonth.
  ///
  /// In pt, this message translates to:
  /// **'Mês anterior'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In pt, this message translates to:
  /// **'Próximo mês'**
  String get nextMonth;

  /// No description provided for @menstruation.
  ///
  /// In pt, this message translates to:
  /// **'Menstruação'**
  String get menstruation;

  /// No description provided for @fertileWindow.
  ///
  /// In pt, this message translates to:
  /// **'Período fértil'**
  String get fertileWindow;

  /// No description provided for @ovulation.
  ///
  /// In pt, this message translates to:
  /// **'Ovulação'**
  String get ovulation;

  /// No description provided for @yourCycle.
  ///
  /// In pt, this message translates to:
  /// **'Seu ciclo'**
  String get yourCycle;

  /// No description provided for @cycleStart.
  ///
  /// In pt, this message translates to:
  /// **'Início do ciclo'**
  String get cycleStart;

  /// No description provided for @cycleLength.
  ///
  /// In pt, this message translates to:
  /// **'Duração do ciclo'**
  String get cycleLength;

  /// No description provided for @periodLength.
  ///
  /// In pt, this message translates to:
  /// **'Duração da menstruação'**
  String get periodLength;

  /// No description provided for @daysCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia} other{{count} dias}}'**
  String daysCount(int count);

  /// No description provided for @inDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{hoje} =1{amanhã} other{em {count} dias}}'**
  String inDays(int count);

  /// No description provided for @decreaseValue.
  ///
  /// In pt, this message translates to:
  /// **'Diminuir: {label}'**
  String decreaseValue(String label);

  /// No description provided for @increaseValue.
  ///
  /// In pt, this message translates to:
  /// **'Aumentar: {label}'**
  String increaseValue(String label);

  /// No description provided for @setupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vamos começar'**
  String get setupTitle;

  /// No description provided for @setupBody.
  ///
  /// In pt, this message translates to:
  /// **'Informe o primeiro dia da sua última menstruação para ver o calendário.'**
  String get setupBody;

  /// No description provided for @setupAction.
  ///
  /// In pt, this message translates to:
  /// **'Informar data'**
  String get setupAction;

  /// No description provided for @dayOfCycle.
  ///
  /// In pt, this message translates to:
  /// **'Dia {day} do ciclo'**
  String dayOfCycle(int day);

  /// No description provided for @nextPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Próxima menstruação'**
  String get nextPeriod;

  /// No description provided for @estimateNote.
  ///
  /// In pt, this message translates to:
  /// **'Cálculo estimado. Não use como método contraceptivo.'**
  String get estimateNote;

  /// No description provided for @registerMonth.
  ///
  /// In pt, this message translates to:
  /// **'Registrar menstruação do mês'**
  String get registerMonth;

  /// No description provided for @registeredSnack.
  ///
  /// In pt, this message translates to:
  /// **'Menstruação registrada no histórico.'**
  String get registeredSnack;

  /// No description provided for @alreadyRegisteredSnack.
  ///
  /// In pt, this message translates to:
  /// **'Este mês já estava no histórico.'**
  String get alreadyRegisteredSnack;

  /// No description provided for @viewAction.
  ///
  /// In pt, this message translates to:
  /// **'Ver'**
  String get viewAction;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro ainda'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Na tela inicial, toque em “Registrar menstruação do mês” para guardar um período aqui.'**
  String get historyEmptyBody;

  /// No description provided for @recordRemoved.
  ///
  /// In pt, this message translates to:
  /// **'Registro removido'**
  String get recordRemoved;

  /// No description provided for @undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// No description provided for @deleteRecord.
  ///
  /// In pt, this message translates to:
  /// **'Excluir registro'**
  String get deleteRecord;

  /// No description provided for @notesHint.
  ///
  /// In pt, this message translates to:
  /// **'Escreva aqui suas anotações…'**
  String get notesHint;

  /// No description provided for @termsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atenção'**
  String get termsTitle;

  /// No description provided for @termsBody.
  ///
  /// In pt, this message translates to:
  /// **'A \"tabelinha\" não deve ser usada como um método contraceptivo. O período de ovulação pode variar de mulher para mulher, além de existirem diversos fatores que também alteram a duração do ciclo, tais como: ansiedade, estresse, doenças, entre outros.\n\nPortanto, o método é recomendado à mulher que quer engravidar, e não para aquela que pretende evitar a gravidez. Além disso, seu cálculo é apenas uma estimativa.'**
  String get termsBody;

  /// No description provided for @termsAgree.
  ///
  /// In pt, this message translates to:
  /// **'Estou ciente'**
  String get termsAgree;

  /// No description provided for @termsContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get termsContinue;

  /// No description provided for @helpBody.
  ///
  /// In pt, this message translates to:
  /// **'A \"tabelinha\" é um método usado para tentar prever os períodos férteis e inférteis de uma mulher. Através dela é possível estimar as datas onde há maior ou menor probabilidade de gravidez em caso de relação sexual.\n\nNo entanto, ao contrário que a maioria das pessoas pensa, a tabelinha não deve ser usada como meio contraceptivo, mas pode ser usada como ótima ferramenta para quem busca engravidar. Porém, o método de engravidar usando a tabelinha ainda é algo muito confuso para a maioria das mulheres.\n\nO método fornece, através de cálculos estimados, a provável data da ovulação e os períodos mais e menos propícios para engravidar, com base na data da última ovulação e na quantidade de dias do ciclo menstrual.\n\nNormalmente a ovulação ocorre no meio do ciclo menstrual. Assim, por exemplo, em um ciclo de 28 dias, a ovulação ocorrerá entre o 12º e o 15º dias a contar do primeiro dia da menstruação anterior. Devido a possíveis variações da ovulação, bem como tempo de vida dos espermatozoides, o período fértil é considerado de 4 dias antes a 4 dias depois do dia provável, totalizando 9 dias.\n\nEm algumas situações, onde o ciclo menstrual não segue uma regularidade, a tabelinha não deve ser utilizada.\nComo os casos de:\n• Adolescentes, onde é raro haver um ciclo regular.\n• Mulheres com ciclo menstrual desregulado.\n• Mulheres com alterações hormonais, emocionais, ou mesmo alimentares.\n\nPercebe-se então, que a tabelinha não é um método confiável como contraceptivo. Além disso, existem casos de mulheres que podem engravidar fora do período fértil, mesmo durante a menstruação.\n\nÉ importante lembrar que este método não previne a AIDS nem outras DSTs.'**
  String get helpBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
