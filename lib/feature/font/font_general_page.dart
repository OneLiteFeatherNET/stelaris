import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/dropdown_card.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

const List<FontType> values = FontType.values;

class FontGeneralPage extends StatelessWidget {
  final FontModel model;

  FontGeneralPage({
    required this.model,
    super.key,
  });

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _key,
          child: Wrap(
            children: [
              TextInputCard<String>(
                display: context.l10n.card_name,
                currentValue: model.name ?? emptyString,
                formatter: [FilteringTextInputFormatter.allow(stringPattern)],
                valueUpdate: (value) {
                  if (value == model.name) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(name: value);
                  StoreProvider.dispatch(
                      context, UpdateFontAction(oldModel, newEntry));
                },
                formValidator: (value) {
                  var input = value as String;
                  return checkIfEmptyAndReturnErrorString(input, context);
                },
              ),
              TextInputCard<String>(
                display: context.l10n.card_description,
                currentValue: model.description ?? emptyString,
                formatter: [FilteringTextInputFormatter.allow(stringPattern)],
                valueUpdate: (value) {
                  if (value == model.description) return;
                  final oldModel = model;
                  final newEntry = oldModel.copyWith(description: value);
                  StoreProvider.dispatch(
                    context,
                    UpdateFontAction(
                      oldModel,
                      newEntry,
                    ),
                  );
                },
              ),
              TextInputCard<int>(
                isNumber: true,
                tooltipMessage: context.l10n.tooltip_ascent,
                display: context.l10n.card_ascent,
                currentValue: model.ascent?.toString() ?? zeroString,
                valueUpdate: (value) {
                  if (value == model.ascent) return;
                  final oldModel = model;
                  final newAscent = int.parse(value);
                  final newEntry = oldModel.copyWith(ascent: newAscent);
                  StoreProvider.dispatch(
                      context, UpdateFontAction(oldModel, newEntry));
                },
                inputType: numberInput,
                formatter: [FilteringTextInputFormatter.allow(fontNumberPattern)],
              ),
              TextInputCard<int>(
                isNumber: true,
                tooltipMessage: context.l10n.tooltip_height,
                display: context.l10n.card_height,
                currentValue: model.height?.toString() ?? zeroString,
                valueUpdate: (value) {
                  if (value == model.height) return;
                  final oldModel = model;
                  final newHeight = int.parse(value);
                  final newEntry = oldModel.copyWith(height: newHeight);
                  StoreProvider.dispatch(
                      context, UpdateFontAction(oldModel, newEntry));
                },
                inputType: numberInput,
                formatter: [FilteringTextInputFormatter.allow(fontNumberPattern)],
              ),
              DropdownCard<FontType, FontModel>(
                  display: context.l10n.card_type,
                  items: getItems(),
                  valueUpdate: (value) {
                    if (value == null) return;
                    if (value.displayName == model.type) return;
                    StoreProvider.dispatch(context, UpdateFontAction(
                      model,
                      model.copyWith(type: value),
                    ));
                  },
                  defaultValue: (value) => value.type,
                  currentValue: model,
              )
            ],
          ),
        ),
        SaveButton(
          callback: () {
            if (!_key.currentState!.validate()) return;
            ApiService().fontAPI.update(model);
          },
        )
      ],
    );
  }

  List<DropdownMenuItem<FontType>>? getItems() {
    return List.generate(
        values.length,
            (index) => DropdownMenuItem(
          value: values[index],
          child: Text(values[index].displayName),
        ));
  }
}
