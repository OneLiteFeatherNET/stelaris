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

/// The attribute's page: its default and maximum value, each a card that
/// opens a dialog.
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
          sections: [
            EditSection(
              title: l10n.attribute_section_values,
              fields: [
                value(
                  l10n.card_attribute_default_value,
                  l10n.attribute_hint_default,
                  selected.defaultValue,
                  Validators.decimal(l10n),
                  (defaultValue) =>
                      selected.copyWith(defaultValue: defaultValue),
                ),
                value(
                  l10n.card_attribute_maximum_value,
                  l10n.attribute_hint_maximum,
                  selected.maximumValue,
                  // Every vanilla maximum is positive and the backend
                  // rejects anything else
                  Validators.positive(l10n),
                  (maximum) => selected.copyWith(maximumValue: maximum),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
