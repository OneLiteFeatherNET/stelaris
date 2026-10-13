import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/settings_card.dart';
import 'package:stelaris/feature/settings/settings_section.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/url_launcher.dart';

/// The About section: the version, the licences and the links.
class MiscSettingsRow extends StatelessWidget {
  const MiscSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SettingsSection(
      title: l10n.settings_section_about,
      children: [
        SettingsCard(
          icon: Icons.info_outline,
          title: l10n.settings_misc_version_header,
          subtitle: l10n.settings_misc_version_body,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(AppShapes.small),
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
        SettingsCard(
          icon: Icons.description_outlined,
          title: l10n.settings_misc_license_header,
          subtitle: l10n.settings_misc_license_body,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(
            context: context,
            applicationName: appName,
            applicationVersion: appVersion,
          ),
        ),
        SettingsCard(
          icon: Icons.bug_report_outlined,
          title: l10n.settings_about_issues_title,
          subtitle: l10n.settings_about_issues_body,
          trailing: const Icon(Icons.open_in_new),
          onTap: () => UriLauncher.launchURL(gitUrl),
        ),
        SettingsCard(
          icon: Icons.help_outline,
          title: l10n.settings_about_help_title,
          subtitle: l10n.settings_about_help_body,
          trailing: const Icon(Icons.open_in_new),
          onTap: () => UriLauncher.launchURL(conceptURL),
        ),
      ],
    );
  }
}
