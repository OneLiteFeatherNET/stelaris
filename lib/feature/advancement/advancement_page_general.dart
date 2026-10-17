import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/advancement/selected_advancement_state.dart';
import 'package:stelaris/feature/advancement/advancement_display_flags.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/validators.dart';
import 'package:vulpes_data/advancement.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';

/// The value of the parent choice for a root advancement.
const String _noParent = emptyString;

/// Allows a signed decimal number while it is typed.
final RegExp _decimalPattern = RegExp(r'^-?\d*\.?\d*');

const TextInputType _decimalInput = TextInputType.numberWithOptions(
  signed: true,
  decimal: true,
);

/// Shows a whole [value] without the trailing `.0`.
String _formatPosition(double value) =>
    value == value.truncateToDouble() ? value.toInt().toString() : '$value';

/// The advancement's page: how it is shown, its icon, title, description,
/// frame and its place in the advancement tree. The display flags change in
/// place, every other field is a card that opens a dialog. The title and
/// description are edited as MiniMessage and stored as JSON text
/// components.
class AdvancementGeneralPage extends StatelessWidget {
  /// Creates an instance of [AdvancementGeneralPage].
  const AdvancementGeneralPage({super.key});

  /// Puts [advancement] into the store and marks the page unsaved. The
  /// header's save sends it to the backend.
  static void _stage(BuildContext context, AdvancementModel advancement) {
    context
      ..dispatch(UpdateAdvancementAction(advancement))
      ..dispatch(MarkUnsavedChangesAction(NavigationEntry.advancements));
  }

  /// The parent options: a root, the loaded advancements and the current
  /// parent, if it is not loaded yet.
  static List<String> _parents(SelectedAdvancementView vm) {
    final parentId = vm.selected.parentId;
    return [
      _noParent,
      for (final model in vm.parents) model.id!,
      if (parentId != null && !vm.parents.any((model) => model.id == parentId))
        parentId,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedAdvancementView>(
      vm: () => SelectedAdvancementFactory(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final selected = vm.selected;
        final names = {for (final model in vm.parents) model.id: model.uiName};
        final decimalFormatters = [
          FilteringTextInputFormatter.allow(_decimalPattern),
        ];
        TextEdit position(
          String label,
          String footer,
          double value,
          AdvancementModel Function(double value) change,
        ) => TextEdit(
          label: label,
          icon: Icons.tag,
          value: _formatPosition(value),
          footer: footer,
          keyboardType: _decimalInput,
          formatters: decimalFormatters,
          validator: (input) => double.tryParse(input ?? emptyString) == null
              ? l10n.validation_number_invalid
              : null,
          onChanged: (input) => _stage(context, change(double.parse(input))),
        );

        return EditCardGrid(
          header: AdvancementDisplayFlags(selected: selected),
          sections: [
            EditSection(
              title: l10n.advancement_section_display,
              fields: [
                TextEdit(
                  label: l10n.card_material,
                  icon: Icons.category_outlined,
                  value: selected.material ?? emptyString,
                  hintText: defaultMaterial,
                  footer: l10n.advancement_hint_material,
                  suggestsMaterials: true,
                  maxLength: 64,
                  validator: (value) =>
                      value == null ||
                          value.isEmpty ||
                          minecraftPattern.hasMatch(value)
                      ? null
                      : l10n.input_validation_material,
                  onChanged: (value) =>
                      _stage(context, selected.copyWith(material: value)),
                ),
                ChoiceEdit<FrameType>(
                  label: l10n.card_frame_type,
                  icon: Icons.list,
                  value: selected.frameType,
                  options: FrameType.values,
                  display: (type) => type.displayName,
                  footer: l10n.advancement_hint_frame,
                  onChanged: (type) =>
                      _stage(context, selected.copyWith(frameType: type)),
                ),
                ChoiceEdit<String>(
                  label: l10n.card_advancement_parent,
                  icon: Icons.account_tree_outlined,
                  value: selected.parentId ?? _noParent,
                  options: _parents(vm),
                  display: (id) => id == _noParent
                      ? l10n.advancement_parent_none
                      : names[id] ?? id,
                  footer: l10n.tooltip_advancement_parent,
                  // Only a root has a background, a child would keep it
                  // hidden.
                  onChanged: (id) => _stage(
                    context,
                    id == _noParent
                        ? selected.copyWith(parentId: null)
                        : selected.copyWith(parentId: id, background: null),
                  ),
                ),
                if (selected.isRoot)
                  TextEdit(
                    label: l10n.card_advancement_background,
                    icon: Icons.image_outlined,
                    value: selected.background ?? emptyString,
                    hintText: 'minecraft:gui/advancements/backgrounds/stone',
                    footer: l10n.tooltip_advancement_background,
                    maxLength: 100,
                    validator: Validators.pattern(
                      adventureKeyPattern,
                      l10n.validation_background_invalid,
                    ),
                    onChanged: (value) => _stage(
                      context,
                      selected.copyWith(
                        background: value.isEmpty ? null : value,
                      ),
                    ),
                  ),
              ],
            ),
            EditSection(
              title: l10n.advancement_section_text,
              fields: [
                TextComponentEdit(
                  label: l10n.card_title,
                  icon: Icons.text_fields,
                  value: selected.title,
                  componentContext: ComponentContext.notificationTitle,
                  onChanged: (title) =>
                      _stage(context, selected.copyWith(title: title)),
                ),
                TextComponentEdit(
                  label: l10n.card_description,
                  icon: Icons.text_fields,
                  value: selected.description,
                  // Minecraft draws it in the color of the frame.
                  componentContext: selected.frameType == FrameType.challenge
                      ? ComponentContext.challengeDescription
                      : ComponentContext.advancementDescription,
                  onChanged: (description) => _stage(
                    context,
                    selected.copyWith(description: description),
                  ),
                ),
              ],
            ),
            EditSection(
              title: l10n.advancement_section_position,
              fields: [
                position(
                  l10n.card_advancement_x,
                  l10n.advancement_hint_x,
                  selected.x,
                  (x) => selected.copyWith(x: x),
                ),
                position(
                  l10n.card_advancement_y,
                  l10n.advancement_hint_y,
                  selected.y,
                  (y) => selected.copyWith(y: y),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
