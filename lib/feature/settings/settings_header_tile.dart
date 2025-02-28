import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/util/constants.dart';

class SettingsHeaderTile extends StatelessWidget {
  const SettingsHeaderTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.secondaryHeaderColor,
      height: fiftyLength,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Settings',
              textAlign: TextAlign.start,
              style: theme.textTheme.titleLarge,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => context.pop(false),
                icon: Icon(
                  Icons.close,
                  color: theme.buttonTheme.colorScheme?.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
