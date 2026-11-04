import 'dart:math';

import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris/feature/asset/picker/asset_picker_dialog.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/font/font_texture_asset.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The font's General tab: its provider and the face it renders with
/// (texture, ascent, height), each field a card that opens a dialog. The
/// texture is a texture asset of the project, chosen or uploaded in a picker.
class FontGeneralPage extends StatelessWidget {
  const FontGeneralPage({super.key});

  /// The folder of a project the textures of its fonts are uploaded into.
  static const String _textureFolder = 'font';

  /// Puts [font] into the store and marks the page unsaved. The header's
  /// save sends it to the backend.
  static void _stage(BuildContext context, FontModel font) {
    context
      ..dispatch(UpdateFontAction(font))
      ..dispatch(MarkUnsavedChangesAction(NavigationEntry.font));
  }

  /// Lets the user choose or upload a texture of [project] for [font] and
  /// stages the chosen one.
  static Future<void> _pickTexture(
    BuildContext context,
    Project project,
    FontModel font,
    FontTextureState texture,
    FontTextureLoaderState loader,
  ) async {
    final projectId = project.id;
    if (projectId == null) return;
    final asset = await showAssetPickerDialog(
      context,
      projectId: projectId,
      namespace: project.key,
      selectedKey: switch (texture) {
        LoadedFontTexture(:final asset) => asset.key,
        _ => null,
      },
      kinds: textureAssetKinds,
      uploadKinds: textureAssetKinds,
      keyFolder: _textureFolder,
      hideExtracted: true,
      replaceable: true,
      previewBuilder: (asset) =>
          TexturePreview(projectId: projectId, asset: asset),
    );
    if (asset == null || asset.id == font.textureAssetId) return;
    loader.remember(asset);
    if (!context.mounted) return;
    _stage(context, font.copyWith(textureAssetId: asset.id));
  }

  /// How [texture] reads on its card.
  static String _textureLabel(
    AppLocalizations l10n,
    FontTextureState texture,
  ) => switch (texture) {
    NoFontTexture() => emptyString,
    LoadingFontTexture() => l10n.font_texture_loading,
    LoadedFontTexture(:final asset) => asset.key,
    MissingFontTexture() => l10n.font_texture_missing,
  };

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final font = vm.selected;
        final project = vm.project;
        final numberFormatters = [
          FilteringTextInputFormatter.allow(fontNumberPattern),
        ];
        return FontTextureLoader(
          projectId: project?.id,
          assetId: font.textureAssetId,
          builder: (context, texture, loader) => EditCardGrid(
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
                  if (project != null)
                    PickEdit(
                      label: l10n.card_font_texture,
                      icon: Icons.image_outlined,
                      value: _textureLabel(l10n, texture),
                      footer: l10n.font_hint_texture,
                      pick: (context) =>
                          _pickTexture(context, project, font, texture, loader),
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
                    formatters: [
                      FilteringTextInputFormatter.allow(
                        signedFontNumberPattern,
                      ),
                    ],
                    validator: Validators.maximum(l10n, font.height),
                    onChanged: (value) => _stage(
                      context,
                      font.copyWith(ascent: int.parse(value)),
                    ),
                  ),
                  TextEdit(
                    label: l10n.card_height,
                    icon: Icons.tag,
                    value: font.height.toString(),
                    footer: l10n.font_hint_height,
                    keyboardType: numberInput,
                    formatters: numberFormatters,
                    validator: Validators.minimum(l10n, max(1, font.ascent)),
                    onChanged: (value) => _stage(
                      context,
                      font.copyWith(height: int.parse(value)),
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
