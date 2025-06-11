import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/attribute/selected_attribute_state.dart';
import 'package:stelaris/feature/base/button/save_button.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

/// A widget that represents the general attributes management page.
///
/// The [AttributeGeneralPage] allows users to view and edit the details
/// of a selected attribute, including its name, default value, and maximum value.
/// It provides a form for input and a save button to commit changes.
class AttributeGeneralPage extends StatelessWidget {
  /// Creates an instance of [AttributeGeneralPage].
  AttributeGeneralPage({super.key});

  /// A global key for the form to manage its state and validation.
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedAttributeView>(
      vm: () => SelectedAttributeFactory(),
      builder: (context, vm) {
        return Expanded(
          child: Stack(
            children: [
              Form(
                autovalidateMode: AutovalidateMode.always,
                key: _key,
                child: Wrap(
                  children: [
                    TextInputCard<String>(
                      display: context.l10n.card_name,
                      tooltipMessage: context.l10n.tooltip_name,
                      currentValue: vm.selected.variableName ?? zeroString,
                      formatter: [
                        FilteringTextInputFormatter.allow(stringPattern),
                      ],
                      valueUpdate: (value) {
                        if (value == vm.selected.variableName) return;
                        final AttributeModel oldModel = vm.selected;
                        final AttributeModel newEntry = oldModel.copyWith(
                          variableName: value,
                        );
                        context.dispatch(UpdateAttributeAction(newEntry));
                      },
                      formValidator: (value) {
                        final String input = value as String;
                        return checkIfEmptyAndReturnErrorString(input, context);
                      },
                      maxLength: 30,
                    ),
                    TextInputCard<double>(
                      display: 'Default value',
                      currentValue:
                          vm.selected.defaultValue?.toString() ?? zeroString,
                      formatter: [
                        FilteringTextInputFormatter.allow(numberPattern),
                      ],
                      valueUpdate: (value) {
                        final parsedValue = double.tryParse(value) ?? 0;
                        if (parsedValue == vm.selected.defaultValue) return;
                        final oldModel = vm.selected;
                        final newEntry = oldModel.copyWith(
                          defaultValue: parsedValue,
                        );
                        context.dispatch(UpdateAttributeAction(newEntry));
                      },
                      maxLength: 100,
                    ),
                    TextInputCard<double>(
                      display: 'Maximum value',
                      currentValue:
                          vm.selected.maximumValue?.toString() ?? zeroString,
                      valueUpdate: (value) {
                        final parsedValue = double.tryParse(value) ?? 0;
                        if (parsedValue == vm.selected.maximumValue) return;
                        final oldModel = vm.selected;
                        final newEntry = oldModel.copyWith(
                          maximumValue: parsedValue,
                        );
                        context.dispatch(UpdateAttributeAction(newEntry));
                      },
                      maxLength: 100,
                      formatter: [
                        FilteringTextInputFormatter.allow(numberPattern),
                      ],
                    ),
                  ],
                ),
              ),
              SaveButton(
                callback: () {
                  if (!_key.currentState!.validate()) return;
                  context.dispatchAndWait(AttributeDatabaseUpdate());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
