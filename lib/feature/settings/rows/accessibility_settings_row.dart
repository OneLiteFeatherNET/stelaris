import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/actions/theme_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/settings/settings_card.dart';
import 'package:stelaris/feature/settings/settings_section.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The Accessibility section: the font size.
class AccessibilitySettingsRow extends StatelessWidget {
  const AccessibilitySettingsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, double>(
      converter: (store) => store.state.themeSettings.fontScale,
      builder: (context, fontScale) {
        final isDefault =
            fontScale == ThemeSettings.defaultSettings().fontScale;
        return SettingsSection(
          title: context.l10n.settings_accessibility_title,
          trailing: SettingsResetButton(
            onPressed: isDefault
                ? null
                : () => context.dispatch(ResetFontScaleAction()),
          ),
          children: [_FontScaleCard(fontScale: fontScale)],
        );
      },
    );
  }
}

/// A slider and a sample text. The sample follows the thumb while it is
/// dragged, the setting is stored when the drag ends, so the app is not laid
/// out again on every tick.
class _FontScaleCard extends StatefulWidget {
  const _FontScaleCard({required this.fontScale});

  /// The stored font scale.
  final double fontScale;

  @override
  State<_FontScaleCard> createState() => _FontScaleCardState();
}

class _FontScaleCardState extends State<_FontScaleCard> {
  late double _value = widget.fontScale;

  @override
  void didUpdateWidget(_FontScaleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follows the store, so a reset moves the thumb.
    if (oldWidget.fontScale != widget.fontScale) _value = widget.fontScale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SettingsCard(
      icon: Icons.text_fields,
      title: l10n.settings_item_font_title,
      subtitle: l10n.settings_item_font_subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: _value,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            label: '${(_value * 100).round()}%',
            onChanged: (value) => setState(() => _value = value),
            onChangeEnd: (value) =>
                context.dispatch(UpdateFontScaleAction(value)),
          ),
          // The text theme already carries the stored scale, so the sample
          // only scales by the difference.
          Text(
            l10n.settings_font_preview,
            style: theme.textTheme.bodyMedium,
            textScaler: TextScaler.linear(_value / widget.fontScale),
          ),
        ],
      ),
    );
  }
}
