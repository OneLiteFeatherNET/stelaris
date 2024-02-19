import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';

String? checkIfEmptyAndReturnErrorString(String value, BuildContext context) {
  if (value.trim().isEmpty) {
    return context.l10n.error_card_empty;
  }
  return null;
}