import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String _locale(BuildContext context) => Localizations.localeOf(context).toString();

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "Outubro de 2026"
String monthTitle(BuildContext context, DateTime date) =>
    _capitalize(DateFormat.yMMMM(_locale(context)).format(date));

/// "05/10/2026"
String shortDate(BuildContext context, DateTime date) =>
    DateFormat.yMd(_locale(context)).format(date);

/// "5 de out."
String dayAndMonth(BuildContext context, DateTime date) =>
    DateFormat.MMMd(_locale(context)).format(date);

/// "domingo" — nome completo, para leitores de tela (o cabeçalho visual usa só a inicial).
String weekdayName(BuildContext context, int sundayBasedIndex) =>
    DateFormat.EEEE(_locale(context)).format(DateTime.utc(2024, 1, 7 + sundayBasedIndex));
