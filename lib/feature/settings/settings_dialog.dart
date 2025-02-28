import 'package:flutter/material.dart';
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Dialog(
          clipBehavior: Clip.hardEdge,
          child: Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.5 + (value * 0.5),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth < 1000 ? constraints.maxWidth : 1000;
                  final double height = constraints.maxHeight < 600 ? constraints.maxHeight : 600;
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: width * 0.8,
                      minHeight: height * 0.8,
                      maxHeight: height,
                      maxWidth: width,
                    ),
                    child: const Column(
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
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
