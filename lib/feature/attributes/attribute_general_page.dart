import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/api/state/actions/attribute_actions.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

class AttributeGeneralPage extends StatelessWidget {
  final AttributeModel attributeModel;

  AttributeGeneralPage({required this.attributeModel, super.key});

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                  currentValue: attributeModel.name ?? emptyString,
                  formatter: [FilteringTextInputFormatter.allow(stringPattern)],
                  valueUpdate: (value) {
                    if (value == attributeModel.modelName) return;
                    final oldModel = attributeModel;
                    final newEntry = oldModel.copyWith(name: value);
                    StoreProvider.dispatch(
                        context, UpdateAttributeAction(oldModel, newEntry));
                  },
                  formValidator: (value) {
                    var input = value as String;
                    return checkIfEmptyAndReturnErrorString(input, context);
                  },
                  maxLength: 30,
                ),
                TextInputCard<double>(
                  display: 'Default value',
                  currentValue:
                      attributeModel.defaultValue?.toString() ?? zeroString,
                  valueUpdate: (value) {
                    if (value == attributeModel.defaultValue) return;
                    final oldModel = attributeModel;
                    final newValue = double.parse(value);
                    final newEntry = oldModel.copyWith(defaultValue: newValue);
                    StoreProvider.dispatch(
                        context, UpdateAttributeAction(oldModel, newEntry));
                  },
                  maxLength: 100,
                ),
                TextInputCard<double>(
                  display: 'Maximum value',
                  currentValue:
                      attributeModel.maximumValue?.toString() ?? zeroString,
                  valueUpdate: (value) {
                    if (value == attributeModel.maximumValue) return;
                    final oldModel = attributeModel;
                    final newValue = double.parse(value);
                    final newEntry = oldModel.copyWith(maximumValue: newValue);
                    StoreProvider.dispatch(
                        context, UpdateAttributeAction(oldModel, newEntry));
                  },
                  maxLength: 100,
                ),
              ],
            ),
          ),
          SaveButton(
            callback: () {
              if (!_key.currentState!.validate()) return;
              ApiService().attributesAPI.update(attributeModel);
            },
          )
        ],
      ),
    );
  }
}
