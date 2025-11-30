import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/actions/theme_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/settings/settings_base_row.dart';
import 'package:stelaris/feature/settings/settings_item.dart';
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
              SettingsItem(
                title: 'Use System Theme',
                subtitle: "Automatically match your system's theme settings",
                trailing: Switch(
                  value: themeSettings.useSystemTheme,
                  onChanged: (_) => context.dispatch(
                    ToggleSystemThemeAction(systemDarkMode),
                  ),
                ),
              ),
              verticalSpacing25,
              SettingsItem(
                title: 'Dark Mode',
                subtitle: 'Update your preferred theme',
                trailing: Switch(
                  value: themeSettings.isDarkMode,
                  onChanged: themeSettings.useSystemTheme
                      ? null
                      : (_) => context.dispatch(
                            ToggleDarkModeAction(),
                          ),
                ),
              ),
              verticalSpacing25,
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
