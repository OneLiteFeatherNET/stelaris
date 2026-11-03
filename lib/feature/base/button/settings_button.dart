import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({this.style, super.key});

  /// Overrides the default icon button style, e.g. to match the rail.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: style,
      tooltip: context.l10n.settings_title,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const SettingsDialog(),
        );
      },
      icon: const Icon(Icons.settings_outlined),
    );
  }
}
