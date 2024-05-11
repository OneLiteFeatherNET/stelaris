import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/state/actions/font_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris_ui/api/util/minecraft/font_type.dart';
import 'package:stelaris_ui/feature/base/button/save_button.dart';
import 'package:stelaris_ui/feature/base/cards/dropdown_card.dart';
import 'package:stelaris_ui/feature/base/cards/text_input_card.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

const List<FontType> values = FontType.values;
List<DropdownMenuItem<FontType>> types = List.generate(
  values.length,
  (index) => DropdownMenuItem(
    value: values[index],
    child: Text(values[index].displayName),
  ),
);

class FontGeneralPage extends StatelessWidget {
  FontGeneralPage({
    super.key,
  });

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        return Stack(
          children: [
            Form(
              autovalidateMode: AutovalidateMode.always,
              key: _key,
              child: Wrap(
                children: [
                  TextInputCard<String>(
                    display: context.l10n.card_name,
                    currentValue: vm.selected.name ?? emptyString,
                    formatter: [
                      FilteringTextInputFormatter.allow(stringPattern)
                    ],
                    valueUpdate: (value) {
                      if (value == vm.selected.name) return;
                      final oldModel = vm.selected;
                      final newEntry = oldModel.copyWith(name: value);
                      context.dispatch(UpdateFontAction(newEntry));
                    },
                    formValidator: (value) {
                      var input = value as String;
                      return checkIfEmptyAndReturnErrorString(input, context);
                    },
                  ),
                  TextInputCard<String>(
                    display: context.l10n.card_description,
                    currentValue: vm.selected.description ?? emptyString,
                    formatter: [
                      FilteringTextInputFormatter.allow(stringPattern)
                    ],
                    valueUpdate: (value) {
                      if (value == vm.selected.description) return;
                      final oldModel = vm.selected;
                      final newEntry = oldModel.copyWith(description: value);
                      context.dispatch(UpdateFontAction(newEntry));
                    },
                  ),
                  TextInputCard<int>(
                    isNumber: true,
                    tooltipMessage: context.l10n.tooltip_ascent,
                    display: context.l10n.card_ascent,
                    currentValue: vm.selected.ascent?.toString() ?? zeroString,
                    valueUpdate: (value) {
                      if (value == vm.selected.ascent) return;
                      final oldModel = vm.selected;
                      final newAscent = int.parse(value);
                      final newEntry = oldModel.copyWith(ascent: newAscent);
                      context.dispatch(UpdateFontAction(newEntry));
                    },
                    inputType: numberInput,
                    formatter: [
                      FilteringTextInputFormatter.allow(fontNumberPattern)
                    ],
                  ),
                  TextInputCard<int>(
                    isNumber: true,
                    tooltipMessage: context.l10n.tooltip_height,
                    display: context.l10n.card_height,
                    currentValue: vm.selected.height?.toString() ?? zeroString,
                    valueUpdate: (value) {
                      if (value == vm.selected.height) return;
                      final oldModel = vm.selected;
                      final newHeight = int.parse(value);
                      final newEntry = oldModel.copyWith(height: newHeight);
                      context.dispatch(UpdateFontAction(newEntry));
                    },
                    inputType: numberInput,
                    formatter: [
                      FilteringTextInputFormatter.allow(fontNumberPattern)
                    ],
                  ),
                  DropdownCard<FontType, FontModel>(
                    display: context.l10n.card_type,
                    items: types,
                    valueUpdate: (value) {
                      if (value == null) return;
                      if (value == vm.selected.type) return;
                      final FontModel newEntry =
                          vm.selected.copyWith(type: value);
                      context.dispatch(UpdateFontAction(newEntry));
                    },
                    defaultValue: (value) => value.type,
                    currentValue: vm.selected,
                  )
                ],
              ),
            ),
            SaveButton(
              callback: () {
                if (!_key.currentState!.validate()) return;
                context.dispatch(FontDatabaseUpdate());
              },
            )
          ],
        );
      },
    );
  }
}
