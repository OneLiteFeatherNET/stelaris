import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/actions/theme_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/settings/settings_base_row.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

class ThemeSettingsRow extends StatelessWidget {
  const ThemeSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ThemeSettings>(
      converter: (store) => store.state.themeSettings,
      builder: (context, themeSettings) {
        final systemDarkMode =
            MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final theme = Theme.of(context);
        return SettingsBaseRow(
          title: context.l10n.settings_display_title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible( // Use Flexible instead of Column directly
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use System Theme',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          "Automatically match your system's theme settings",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeSettings.useSystemTheme,
                    onChanged: (_) => context.dispatch(
                      ToggleSystemThemeAction(systemDarkMode),
                    ),
                  ),
                ],
              ),
              verticalSpacing25,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dark Mode'),
                      Text('Update your preferred theme'),
                    ],
                  ),
                  Switch(
                    value: themeSettings.isDarkMode,
                    onChanged: themeSettings.useSystemTheme
                        ? null
                        : (_) => context.dispatch(
                              ToggleDarkModeAction(),
                            ),
                  ),
                ],
              ),
              verticalSpacing25,
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Colors',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Customize the primary and accent colors',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ColorPickerButton(
                        color: themeSettings.primaryColor,
                        onColorChanged: (color) => context.dispatch(
                          UpdatePrimaryColorAction(color),
                        ),
                        label: context.l10n.settings_primary_color,
                      ),
                      const SizedBox(width: 8),
                      ColorPickerButton(
                        color: themeSettings.accentColor,
                        onColorChanged: (color) => context.dispatch(
                          UpdateAccentColorAction(color),
                        ),
                        label: context.l10n.settings_accent_color,
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing25,*/
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Adjust the text size throughout the app',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Slider(
                      value: themeSettings.fontScale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label: '${(themeSettings.fontScale * 100).round()}%',
                      onChanged: (value) => context.dispatch(
                        UpdateFontScaleAction(value),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
