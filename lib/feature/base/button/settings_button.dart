import 'package:flutter/material.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const SettingsDialog(),
        );
      },
      icon: const Icon(Icons.settings),
    );
  }
}
