import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/info_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Explains the characters of a font: why they come from the Unicode Private
/// Use Area, which areas there are, how to type them and how the lines map
/// to the texture.
class FontCharInfoDialog extends StatelessWidget {
  const FontCharInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return InfoDialog(
      title: l10n.font_char_info_title,
      intro: l10n.font_char_info_intro,
      topics: [
        InfoTopic(
          icon: Icons.grid_view_outlined,
          title: l10n.font_char_info_areas_title,
          text: l10n.font_char_info_areas,
        ),
        InfoTopic(
          icon: Icons.keyboard_outlined,
          title: l10n.font_char_info_input_title,
          text: l10n.font_char_info_input,
        ),
        InfoTopic(
          icon: Icons.view_module_outlined,
          title: l10n.font_char_info_rows_title,
          text: l10n.font_char_info_rows,
        ),
      ],
    );
  }
}
