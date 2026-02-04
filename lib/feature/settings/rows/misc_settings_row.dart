import 'package:flutter/material.dart';
import 'package:stelaris/feature/settings/settings_base_row.dart';
import 'package:stelaris/feature/settings/settings_item.dart';
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
          SettingsItem(
            title: context.l10n.settings_misc_bug_header,
            subtitle: context.l10n.settings_misc_bug_body,
            trailing: OutlinedButton(
              onPressed: () => UriLauncher.launchURL(gitUrl),
              child: Text(context.l10n.settings_misc_bug_button),
            ),
          ),
          verticalSpacing25,
          SettingsItem(
            title: context.l10n.settings_misc_suggestion_header,
            subtitle: context.l10n.settings_misc_suggestion_body,
            trailing: OutlinedButton(
              onPressed: () => UriLauncher.launchURL(gitUrl),
              child: Text(context.l10n.settings_misc_suggestion_button),
            ),
          ),
          verticalSpacing25,
          SettingsItem(
            title: context.l10n.settings_misc_license_header,
            subtitle: context.l10n.settings_misc_license_body,
            trailing: OutlinedButton(
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: appName,
                  applicationVersion: '0.1.0',
                );
              },
              child: Text(context.l10n.settings_misc_license_button),
            ),
          ),
        ],
      ),
    );
  }
}
