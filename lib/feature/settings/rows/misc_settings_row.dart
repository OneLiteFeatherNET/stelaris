import 'package:flutter/material.dart';
import 'package:stelaris/feature/settings/settings_base_row.dart';
import 'package:stelaris/feature/settings/settings_text_tile.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/url_launcher.dart';

class MiscSettingsRow extends StatelessWidget {
  const MiscSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsBaseRow(
      title: context.l10n.settings_misc_title,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SettingsTextTile(
                  headerLine: context.l10n.settings_misc_bug_header,
                  bodyLine: context.l10n.settings_misc_bug_body,
                ),
              ),
              OutlinedButton(
                onPressed: () => UriLauncher.launchUrlInTab(gitUrl),
                child: Text(context.l10n.settings_misc_bug_button),
              ),
            ],
          ),
          verticalSpacing25,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SettingsTextTile(
                  headerLine: context.l10n.settings_misc_suggestion_header,
                  bodyLine: context.l10n.settings_misc_suggestion_body,
                ),
              ),
              OutlinedButton(
                onPressed: () => UriLauncher.launchUrlInTab(gitUrl),
                child: Text(context.l10n.settings_misc_suggestion_button),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
