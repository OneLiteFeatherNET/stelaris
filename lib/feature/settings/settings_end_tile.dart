import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

class SettingsEndTile extends StatelessWidget {
  const SettingsEndTile({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '@2025 Onelitefeather',
                style: textTheme.bodyMedium,
              ),
              TextSpan(text: ' • ', style: textTheme.bodyMedium),
              TextSpan(
                text: context.l10n.settings_end_tile_made_with,
                style: textTheme.bodyMedium,
              ),
              const TextSpan(
                text: ' \u2764 ',
                style: TextStyle(color: Colors.red),
              ),
              TextSpan(
                text: context.l10n.settings_end_tile_team,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
