import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    required this.title,
    required this.subtitle,
    required this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              heightTen,
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 16),
        trailing,
      ],
    );
  }
}
