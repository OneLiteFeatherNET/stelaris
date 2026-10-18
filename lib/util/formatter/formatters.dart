import 'package:flutter/services.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/lower_case_formatter.dart';

/// The file contains some static variables for specific formatters.
/// These are often used in the app and a constant usage is better for the performance

final TextInputFormatter stringPatternFormatter =
    FilteringTextInputFormatter.allow(stringPattern);
const TextInputFormatter lowerCaseFormatter = LowerCaseTextFormatter();

/// Keeps an input a (possibly unfinished) decimal number such as "-", "1." or
/// "-0.5" by rejecting every edit that would leave anything else
final TextInputFormatter decimalFormatter = TextInputFormatter.withFunction(
  (oldValue, newValue) =>
      decimalPattern.hasMatch(newValue.text) ? newValue : oldValue,
);
