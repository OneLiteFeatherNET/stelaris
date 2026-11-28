import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/stelaris_icons.dart';

class SettingsEndTile extends StatelessWidget {
  const SettingsEndTile({this.clock = const Clock(), super.key});

  /// Where the year comes from.
  final Clock clock;

  /// The heart is an icon rather than the ❤ glyph: the app font lacks it,
  /// so the web build would fetch an emoji font just for this line.
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    // Split around the heart, so it works wherever a language puts it.
    final [before, after] = context.l10n
        .settings_end_tile_footer('${clock.now().year}', '\u0000')
        .split('\u0000');
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: before),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                StelarisIcons.heart,
                key: const Key('settings_end_tile_heart'),
                size: style?.fontSize,
                color: style?.color,
              ),
            ),
            TextSpan(text: after),
          ],
        ),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
