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

const List<FontType> values = FontType.values;

class FontGeneralPage extends StatefulWidget {

  final FontModel model;
  final ValueNotifier<FontModel?> selectedItem;

  const FontGeneralPage({Key? key, required this.model, required this.selectedItem}) : super(key: key);

  @override
  State<FontGeneralPage> createState() => _FontGeneralPageState();
}

class _FontGeneralPageState extends State<FontGeneralPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Wrap(
          children: [
            TextInputCard<String>(
              infoText: context.l10n.tooltip_name,
              title: Text(context.l10n.card_name),
              currentValue: widget.model.name ?? empty,
              formatter: [FilteringTextInputFormatter.allow(stringPattern)],
              valueUpdate: (value) {
                if (value == widget.model.name) return;
                final oldModel = widget.model;
                final newEntry = oldModel.copyWith(name: value);
                setState(() {
                  StoreProvider.dispatch(
                      context, UpdateFontAction(oldModel, newEntry));
                  widget.selectedItem.value = newEntry;
                });
              },
            ),
            TextInputCard<String>(
              infoText: context.l10n.tooltip_description,
              title: Text(context.l10n.card_description),
              currentValue: widget.model.description ?? empty,
              formatter: [FilteringTextInputFormatter.allow(stringPattern)],
              valueUpdate: (value) {
                if (value == widget.model.description) return;
                final oldModel = widget.model;
                final newEntry = oldModel.copyWith(description: value);
                setState(() {
                  StoreProvider.dispatch(
                      context, UpdateFontAction(oldModel, newEntry));
                  widget.selectedItem.value = newEntry;
                });
              },
            ),
            TextInputCard<String>(
              infoText: context.l10n.tooltip_ascent,
              title: Text(context.l10n.card_ascent),
              currentValue: widget.model.ascent?.toString() ?? zero,
              valueUpdate: (value) {
                if (value == widget.model.ascent) return;
                final oldModel = widget.model;
                final newAscent = int.parse(value);
                final newEntry = oldModel.copyWith(ascent: newAscent);
                setState(() {
                  StoreProvider.dispatch(
                      context, UpdateFontAction(oldModel, newEntry));
                  widget.selectedItem.value = newEntry;
                });
              },
              inputType: numberInput,
              formatter: [FilteringTextInputFormatter.allow(numberPattern)],
            ),
            TextInputCard(
              infoText: context.l10n.tooltip_height,
              title: Text(context.l10n.card_height),
              currentValue: widget.model.height?.toString() ?? zero,
              valueUpdate: (value) {
                if (value == widget.model.height) return;
                final oldModel = widget.model;
                final newHeight = int.parse(value);
                final newEntry = oldModel.copyWith(height: newHeight);
                setState(() {
                  StoreProvider.dispatch(
                      context, UpdateFontAction(oldModel, newEntry));
                  widget.selectedItem.value = newEntry;
                });
              },
              inputType: numberInput,
              formatter: [FilteringTextInputFormatter.allow(numberPattern)],
            ),
          ],
        ),
        SaveButton(
          callback: () {
            ApiService().fontAPI.update(widget.model);
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

  FontType getDefaultValue(FontModel value) {
    return FontType.values
        .firstWhere((element) => element.displayName == value.type);
  }
}
