import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/settings_base_row.dart';
import 'package:stelaris/feature/settings/settings_item.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/url_launcher.dart';

class MiscSettingsRow extends StatelessWidget {
  const MiscSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsBaseRow(
      title: context.l10n.settings_misc_title,
      child: Column(
        children: [
          SettingsItem(
            title: context.l10n.settings_misc_version_header,
            subtitle: context.l10n.settings_misc_version_body,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                appVersion,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          verticalSpacing25,
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
                  applicationVersion: appVersion,
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
