import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

class SettingsEndTile extends StatelessWidget {
  const SettingsEndTile({this.clock = const Clock(), super.key});

  /// Where the year comes from.
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Text(
        context.l10n.settings_end_tile_footer('${clock.now().year}'),
        style: textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
