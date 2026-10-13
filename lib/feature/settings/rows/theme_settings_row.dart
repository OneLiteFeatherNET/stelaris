import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/actions/theme_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/feature/settings/settings_card.dart';
import 'package:stelaris/feature/settings/settings_section.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The seed colors on offer, the Material primaries. The first is the
/// default. A curated list cannot produce an unreadable scheme.
final List<(String, MaterialColor, String Function(AppLocalizations))>
_swatches = [
  ('blue', Colors.blue, (l10n) => l10n.settings_color_blue),
  ('indigo', Colors.indigo, (l10n) => l10n.settings_color_indigo),
  ('teal', Colors.teal, (l10n) => l10n.settings_color_teal),
  ('green', Colors.green, (l10n) => l10n.settings_color_green),
  ('amber', Colors.amber, (l10n) => l10n.settings_color_amber),
  ('orange', Colors.orange, (l10n) => l10n.settings_color_orange),
  ('red', Colors.red, (l10n) => l10n.settings_color_red),
  ('pink', Colors.pink, (l10n) => l10n.settings_color_pink),
];

/// The Appearance section: the theme mode and the color.
class ThemeSettingsRow extends StatelessWidget {
  const ThemeSettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ThemeSettings>(
      converter: (store) => store.state.themeSettings,
      builder: (context, settings) {
        final l10n = context.l10n;
        final defaults = ThemeSettings.defaultSettings();
        // Compared by value, a stored color is a plain Color where a swatch
        // is a MaterialColor.
        final isDefault =
            settings.themeMode == defaults.themeMode &&
            settings.primaryColor.toARGB32() ==
                defaults.primaryColor.toARGB32() &&
            settings.accentColor.toARGB32() == defaults.accentColor.toARGB32();

        return SettingsSection(
          title: l10n.settings_section_appearance,
          trailing: SettingsResetButton(
            onPressed: isDefault
                ? null
                : () => context.dispatch(ResetAppearanceSettingsAction()),
          ),
          children: [
            SettingsCard(
              icon: Icons.brightness_6_outlined,
              title: l10n.settings_theme_mode_title,
              subtitle: l10n.settings_theme_mode_subtitle,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                expandedInsets: EdgeInsets.zero,
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.settings_theme_mode_system),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.settings_theme_mode_light),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.settings_theme_mode_dark),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selection) =>
                    context.dispatch(SetThemeModeAction(selection.first)),
              ),
            ),
            SettingsCard(
              icon: Icons.palette_outlined,
              title: l10n.settings_color_title,
              subtitle: l10n.settings_color_subtitle,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (id, color, name) in _swatches)
                    _Swatch(
                      key: ValueKey('swatch-$id'),
                      color: color,
                      label: name(l10n),
                      selected:
                          color.toARGB32() == settings.primaryColor.toARGB32(),
                      onTap: () =>
                          context.dispatch(UpdatePrimaryColorAction(color)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A round button in a seed color, with a check when it is the current one.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: selected
                ? Icon(Icons.check, size: 20, color: onColor)
                : null,
          ),
        ),
      ),
    );
  }
}
