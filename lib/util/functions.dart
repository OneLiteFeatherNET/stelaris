import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';

import 'constants.dart';

String? checkIfEmptyAndReturnErrorString(String value, BuildContext context) {
  if (value.trim().isEmpty) {
    return context.l10n.error_card_empty;
  }
  return null;
}

List<TextSpan> createDeleteText(String? name, BuildContext context) {
  final textStyle = Theme.of(context).textTheme.bodyMedium;
  return [
    TextSpan(text: context.l10n.delete_dialog_first_line, style: textStyle),
    TextSpan(
      text: name ?? unknownEntry,
      style: redStyle,
    ),
    TextSpan(text: context.l10n.delete_dialog_entry, style: textStyle),
  ];
}