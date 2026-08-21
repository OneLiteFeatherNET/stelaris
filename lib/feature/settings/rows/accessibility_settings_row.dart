import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/settings_base_row.dart';
import 'package:stelaris/feature/settings/settings_item.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/url_launcher.dart';

class AccessibilitySettingsRow extends StatelessWidget {
  const AccessibilitySettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsBaseRow(
      title: context.l10n.settings_accessibility_title,
      child: SettingsItem(
        title: context.l10n.settings_accessibility_body,
        subtitle: context.l10n.settings_accessibility_header,
        trailing: OutlinedButton(
          onPressed: () => UriLauncher.launchURL(conceptURL),
          child: Text(context.l10n.settings_accessibility_button),
        ),
      ),
    );
  }
}
