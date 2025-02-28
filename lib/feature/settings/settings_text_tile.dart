import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

class SettingsTextTile extends StatelessWidget {
  const SettingsTextTile({
    required this.headerLine,
    required this.bodyLine,
    super.key,
  });

  final String headerLine;
  final String bodyLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          headerLine,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        heightTen,
        Text(
          bodyLine,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
