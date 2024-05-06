import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/util/constants.dart';

class SettingsHeaderTile extends StatelessWidget {
  const SettingsHeaderTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      height: fiftyLength,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Settings',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => context.pop(false),
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
