import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/animated_dialog.dart';
import 'package:stelaris/feature/settings/rows/accessibility_settings_row.dart';
import 'package:stelaris/feature/settings/rows/misc_settings_row.dart';
import 'package:stelaris/feature/settings/rows/project_settings_row.dart';
import 'package:stelaris/feature/settings/rows/theme_settings_row.dart';
import 'package:stelaris/feature/settings/settings_end_tile.dart';
import 'package:stelaris/feature/settings/settings_header_tile.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsHeaderTile(text: context.l10n.settings_title),
          verticalSpacing25,
          const Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heightTen,
                    ProjectSettingsRow(),
                    verticalSpacing25,
                    ThemeSettingsRow(),
                    verticalSpacing25,
                    AccessibilitySettingsRow(),
                    verticalSpacing25,
                    MiscSettingsRow(),
                    verticalSpacing25,
                    SettingsEndTile(),
                    heightTen,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
