import 'package:flutter/services.dart';
import 'package:stelaris/util/constants.dart';

class VersionInputFormatter extends TextInputFormatter {

  const VersionInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Check if the new value contains only numbers and dots
    if (versionPattern.hasMatch(newValue.text)) {
      // If it does, allow the change
      return newValue;
    } else {
      // If it doesn't, return the old value
      return oldValue;
    }
  }
}