import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The font's General tab: its provider and the face it renders with
/// (texture path, ascent, height), each field a card that opens a dialog.
class FontGeneralPage extends StatelessWidget {
  const FontGeneralPage({super.key});

  /// Puts [font] into the store and marks the page unsaved. The header's
  /// save sends it to the backend.
  static void _stage(BuildContext context, FontModel font) {
    context
      ..dispatch(UpdateFontAction(font))
      ..dispatch(MarkUnsavedChangesAction(NavigationEntry.font));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final font = vm.selected;
        final numberFormatters = [
          FilteringTextInputFormatter.allow(fontNumberPattern),
        ];
        return EditCardGrid(
          sections: [
            EditSection(
              title: l10n.font_section_source,
              fields: [
                TextEdit(
                  label: l10n.card_font_provider,
                  icon: Icons.short_text,
                  value: font.provider ?? emptyString,
                  footer: l10n.font_hint_provider,
                  formatters: [stringPatternFormatter],
                  onChanged: (value) =>
                      _stage(context, font.copyWith(provider: value)),
                ),
                TextEdit(
                  label: l10n.card_font_texture_path,
                  icon: Icons.image_outlined,
                  value: font.texturePath ?? emptyString,
                  hintText: 'minecraft:font/ascii.png',
                  footer: l10n.font_hint_texture_path,
                  validator: Validators.pattern(
                    adventureKeyPattern,
                    l10n.validation_texture_path_invalid,
                  ),
                  onChanged: (value) =>
                      _stage(context, font.copyWith(texturePath: value)),
                ),
              ],
            ),
            EditSection(
              title: l10n.font_section_metrics,
              fields: [
                TextEdit(
                  label: l10n.card_ascent,
                  icon: Icons.tag,
                  value: font.ascent.toString(),
                  footer: l10n.font_hint_ascent,
                  keyboardType: numberInput,
                  formatters: numberFormatters,
                  onChanged: (value) => _stage(
                    context,
                    font.copyWith(ascent: int.tryParse(value) ?? 0),
                  ),
                ),
                TextEdit(
                  label: l10n.card_height,
                  icon: Icons.tag,
                  value: font.height.toString(),
                  footer: l10n.font_hint_height,
                  keyboardType: numberInput,
                  formatters: numberFormatters,
                  onChanged: (value) => _stage(
                    context,
                    font.copyWith(height: int.tryParse(value) ?? 0),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
