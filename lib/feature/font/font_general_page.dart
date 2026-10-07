import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_grid.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The font's General tab: its provider and the face it renders with
/// (texture path, ascent, height).
class FontGeneralPage extends StatelessWidget {
  const FontGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        final font = vm.selected;
        void update(FontModel changed) =>
            context.dispatch(UpdateFontAction(changed));
        final numberFormatters = [
          FilteringTextInputFormatter.allow(fontNumberPattern),
        ];
        return PropertyGrid(
          properties: [
            TextProperty(
              label: context.l10n.card_font_provider,
              value: font.provider ?? emptyString,
              formatters: [stringPatternFormatter],
              onChanged: (value) => update(font.copyWith(provider: value)),
            ),
            TextProperty(
              label: context.l10n.card_font_texture_path,
              value: font.texturePath ?? emptyString,
              hintText: 'minecraft:font/ascii.png',
              validator: Validators.pattern(
                adventureKeyPattern,
                context.l10n.validation_texture_path_invalid,
              ),
              onChanged: (value) => update(font.copyWith(texturePath: value)),
            ),
            TextProperty(
              label: context.l10n.card_ascent,
              tooltip: context.l10n.tooltip_ascent,
              value: font.ascent.toString(),
              keyboardType: numberInput,
              formatters: numberFormatters,
              onChanged: (value) =>
                  update(font.copyWith(ascent: int.tryParse(value) ?? 0)),
            ),
            TextProperty(
              label: context.l10n.card_height,
              tooltip: context.l10n.tooltip_height,
              value: font.height.toString(),
              keyboardType: numberInput,
              formatters: numberFormatters,
              onChanged: (value) =>
                  update(font.copyWith(height: int.tryParse(value) ?? 0)),
            ),
          ],
        );
      },
    );
  }
}
