// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Feminine Calendar';

  @override
  String get helpTitle => 'Help';

  @override
  String get historyTitle => 'Records';

  @override
  String get notesTitle => 'Notes';

  @override
  String get shareTooltip => 'Share calendar';

  @override
  String get shareError => 'Couldn’t share.';

  @override
  String get today => 'Today';

  @override
  String get goToToday => 'Go to today';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get menstruation => 'Menstruation';

  @override
  String get fertileWindow => 'Fertile period';

  @override
  String get ovulation => 'Ovulation';

  @override
  String get yourCycle => 'Your cycle';

  @override
  String get cycleStart => 'First day of cycle';

  @override
  String get cycleLength => 'Cycle length';

  @override
  String get periodLength => 'Period length';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'tomorrow',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String decreaseValue(String label) {
    return 'Decrease: $label';
  }

  @override
  String increaseValue(String label) {
    return 'Increase: $label';
  }

  @override
  String get setupTitle => 'Let’s get started';

  @override
  String get setupBody =>
      'Enter the first day of your last period to see your calendar.';

  @override
  String get setupAction => 'Enter date';

  @override
  String dayOfCycle(int day) {
    return 'Day $day of cycle';
  }

  @override
  String get nextPeriod => 'Next period';

  @override
  String get estimateNote =>
      'Estimated calculation. Do not use as a contraceptive method.';

  @override
  String get registerMonth => 'Log this month’s period';

  @override
  String get registeredSnack => 'Period saved to your records.';

  @override
  String get alreadyRegisteredSnack =>
      'This month was already in your records.';

  @override
  String get viewAction => 'View';

  @override
  String get historyEmptyTitle => 'No records yet';

  @override
  String get historyEmptyBody =>
      'On the home screen, tap “Log this month’s period” to keep a period here.';

  @override
  String get recordRemoved => 'Record removed';

  @override
  String get undo => 'Undo';

  @override
  String get deleteRecord => 'Delete record';

  @override
  String get notesHint => 'Write your notes here…';

  @override
  String get addNote => 'Add a note';

  @override
  String get termsTitle => 'Attention';

  @override
  String get termsBody =>
      'The \"Menstrual Period Calendar\" shall not be used as a contraceptive method. The ovulation period is different for every woman, besides that there are a lot of other factors that may change the cycle length, such as anxiety, stress, diseases and others.\n\nSo, the method is recommended to the woman who intends to get pregnant, not for the ones who are avoiding pregnancy. Besides that, its calculation is just an estimate.';

  @override
  String get termsAgree => 'I’m aware of it';

  @override
  String get termsContinue => 'Continue';

  @override
  String get helpBody =>
      'The \"Menstrual Period Calendar\" is a method used to forecast the fertile and infertile periods of a woman. Through this calendar it is possible to estimate the most likely dates of getting pregnant in case of sexual relations.\n\nHowever, contrary to what most people think, the \"menstrual period calendar\" shall not be used as a contraceptive method, but it is a great tool for those looking to get pregnant. Nevertheless, the method for getting pregnant by using the \"menstrual period calendar\" is still very confusing for most women.\n\nThe method indicates, using estimated calculations, the most likely date of ovulation and the periods that are more and less favorable for getting pregnant, based on the date of the last ovulation and the number of days of the menstrual cycle.\n\nUsually the ovulation happens in the middle of the menstrual cycle. Thus, for example, in a 28-day cycle, the ovulation will happen between the 12th and the 15th day counting from the first day of the last menstrual period. Due to possible variations in ovulation, as well as the sperm lifetime, the fertile period is considered between 4 days before and 4 days after the most likely day, totalling 9 days.\n\nIn some situations, where the cycle is not regular, the \"menstrual period calendar\" must not be used.\nSuch as the cases of:\n• Teenagers, in which a regular cycle is rare.\n• Women with an irregular cycle.\n• Women with hormonal, emotional or even dietary changes.\n\nThen, it is clear that the \"menstrual period calendar\" is not a reliable contraceptive method. Besides that, there are cases in which women get pregnant outside their fertile period, even during menstruation.\n\nIt is important to keep in mind that this method does not prevent AIDS or any other STD.';
}
