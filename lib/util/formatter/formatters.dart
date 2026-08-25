import 'package:flutter/services.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/lower_case_formatter.dart';

/// The file contains some static variables for specific formatters.
/// These are often used in the app and a constant usage is better for the performance

final TextInputFormatter stringPatternFormatter =
    FilteringTextInputFormatter.allow(stringPattern);
final TextInputFormatter withSpacesFormatter =
    FilteringTextInputFormatter.allow(stringWithSpacePattern);
const TextInputFormatter lowerCaseFormatter = LowerCaseTextFormatter();
