import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/dialog/animated_dialog.dart';
import 'package:stelaris/feature/settings/rows/accessibility_settings_row.dart';
import 'package:stelaris/feature/settings/rows/misc_settings_row.dart';
import 'package:stelaris/feature/settings/rows/theme_settings_row.dart';
import 'package:stelaris/feature/settings/settings_end_tile.dart';
import 'package:stelaris/feature/settings/settings_header_tile.dart';
import 'package:stelaris/util/constants.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsHeaderTile(),
          verticalSpacing25,
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heightTen,
                    ThemeSettingsRow(),
                    verticalSpacing25,
                    AccessibilitySettingsRow(),
                    verticalSpacing25,
                    MiscSettingsRow(),
                    verticalSpacing25,
                    SettingsEndTile(),
                    heightTen
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
