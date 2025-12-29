import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/util/constants.dart';

class SettingsHeaderTile extends StatelessWidget {
  const SettingsHeaderTile({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      height: fiftyLength,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => context.pop(false),
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
