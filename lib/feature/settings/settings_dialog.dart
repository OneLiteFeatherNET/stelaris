import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/settings/rows/account_settings_row.dart';
import 'package:stelaris/feature/settings/rows/accessibility_settings_row.dart';
import 'package:stelaris/feature/settings/rows/misc_settings_row.dart';
import 'package:stelaris/feature/settings/rows/project_settings_row.dart';
import 'package:stelaris/feature/settings/rows/theme_settings_row.dart';
import 'package:stelaris/feature/settings/settings_end_tile.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The settings, in the chrome of the other dialogs. A setting applies as
/// soon as it is changed, so there is no action row.
class SettingsDialog extends StatelessWidget {
  const SettingsDialog({this.clock = const Clock(), super.key});

  /// Where the footer takes the year from.
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: context.l10n.settings_title,
      actionLabel: '',
      onSubmit: null,
      showActions: false,
      maxWidth: 560,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AccountSettingsRow(),
          const ProjectSettingsRow(),
          const ThemeSettingsRow(),
          const AccessibilitySettingsRow(),
          const MiscSettingsRow(),
          SettingsEndTile(clock: clock),
        ],
      ),
    );
  }
}
