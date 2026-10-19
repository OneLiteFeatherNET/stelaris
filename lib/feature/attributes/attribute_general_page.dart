import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/attribute/selected_attribute_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/validators.dart';

/// The attribute's page: whether its value is synced to the client, its
/// minimum, default and maximum value and the translation key of its name.
/// The sync flag changes in place, every other field is a card that opens a
/// dialog.
///
/// The values have to stay in order, minimum <= default <= maximum, so each
/// one is checked against the other two as they are staged.
class AttributeGeneralPage extends StatelessWidget {
  /// Creates an instance of [AttributeGeneralPage].
  const AttributeGeneralPage({super.key});

  /// Puts [attribute] into the store and marks the page unsaved. The
  /// header's save sends it to the backend.
  static void _stage(BuildContext context, AttributeModel attribute) {
    context
      ..dispatch(UpdateAttributeAction(attribute))
      ..dispatch(MarkUnsavedChangesAction(NavigationEntry.attributes));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedAttributeView>(
      vm: () => SelectedAttributeFactory(),
      builder: (context, vm) {
        final l10n = context.l10n;
        final selected = vm.selected;
        TextEdit value(
          String label,
          String footer,
          double value,
          FormValidator<String> validator,
          AttributeModel Function(double value) change,
        ) => TextEdit(
          label: label,
          icon: Icons.tag,
          value: formatDecimal(value),
          footer: footer,
          keyboardType: decimalInput,
          formatters: [decimalFormatter],
          validator: validator,
          onChanged: (input) =>
              _stage(context, change(double.parse(input.trim()))),
        );

        return EditCardGrid(
          header: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<bool>(
              emptySelectionAllowed: true,
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(l10n.card_attribute_synced),
                  tooltip: l10n.tooltip_attribute_synced,
                ),
              ],
              selected: {if (selected.synced) true},
              onSelectionChanged: (flags) => _stage(
                context,
                selected.copyWith(synced: flags.contains(true)),
              ),
            ),
          ),
          sections: [
            EditSection(
              title: l10n.attribute_section_values,
              fields: [
                value(
                  l10n.card_attribute_minimum_value,
                  l10n.attribute_hint_minimum,
                  selected.minimumValue,
                  Validators.decimalBetween(l10n, max: selected.defaultValue),
                  (minimum) => selected.copyWith(minimumValue: minimum),
                ),
                value(
                  l10n.card_attribute_default_value,
                  l10n.attribute_hint_default,
                  selected.defaultValue,
                  Validators.decimalBetween(
                    l10n,
                    min: selected.minimumValue,
                    max: selected.maximumValue,
                  ),
                  (defaultValue) =>
                      selected.copyWith(defaultValue: defaultValue),
                ),
                value(
                  l10n.card_attribute_maximum_value,
                  l10n.attribute_hint_maximum,
                  selected.maximumValue,
                  // Every vanilla maximum is positive and the backend
                  // rejects anything else
                  Validators.compose([
                    Validators.positive(l10n),
                    Validators.decimalBetween(l10n, min: selected.defaultValue),
                  ]),
                  (maximum) => selected.copyWith(maximumValue: maximum),
                ),
              ],
            ),
            EditSection(
              title: l10n.attribute_section_client,
              fields: [
                TextEdit(
                  label: l10n.card_attribute_translation_key,
                  icon: Icons.translate,
                  value: selected.translationKey ?? emptyString,
                  hintText: 'attribute.name.max_health',
                  footer: l10n.attribute_hint_translation_key,
                  maxLength: 128,
                  onChanged: (value) => _stage(
                    context,
                    selected.copyWith(
                      translationKey: value.isEmpty ? null : value,
                    ),
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
