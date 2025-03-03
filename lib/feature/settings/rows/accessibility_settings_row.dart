import 'package:flutter/material.dart';
import 'package:stelaris/feature/settings/settings_base_row.dart';
import 'package:stelaris/feature/settings/settings_text_tile.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/url_launcher.dart';

class AccessibilitySettingsRow extends StatelessWidget {
  const AccessibilitySettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsBaseRow(
      title: context.l10n.settings_accessibility_title,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SettingsTextTile(
              headerLine: context.l10n.settings_accessibility_body,
              bodyLine: context.l10n.settings_accessibility_header,
            ),
          ),
          OutlinedButton(
            onPressed: () => UriLauncher.launchUrlInTab(conceptURL),
            child: Text(context.l10n.settings_accessibility_button),
          ),
        ],
      ),
    );
  }
}
