import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/feature/base/button/delete_entry_button.dart';
import 'package:stelaris_ui/feature/dialogs/entry_edit_dialog.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class EntryButtons extends StatelessWidget with EnchantmentReducer {
  final String editTitle;
  final ItemModel model;
  final String? name;
  final String? value;
  final ValueUpdate<ItemModel> delete;
  final DoubleValueUpdate<String, String> update;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator formFieldValidator;

  EntryButtons({
    super.key,
    required this.editTitle,
    required this.model,
    required this.name,
    required this.value,
    required this.delete,
    required this.update,
    this.inputFormatters,
    required this.formFieldValidator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Row(
        children: [
          DeleteEntryButton<String?>(
            title: context.l10n.dialog_delete_confirm,
            header: [
              TextSpan(
                text: context.l10n.dialog_level_delete_first_line,
                style: whiteStyle,
              ),
              TextSpan(
                text: name,
                style: redStyle,
              )
            ],
            value: name,
            mapToDeleteSuccessfully: (value) {
              delete(model);
              return true;
            },
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EntryEditDialog(
                      title: editTitle,
                      currentValue: value,
                      inputFormatters: inputFormatters,
                      valueUpdate: (value) {
                        update(name, value);
                      },
                      formFieldValidator: formFieldValidator,
                    );
                  });
            },
            icon: editIcon,
            tooltip: context.l10n.dialog_level_title,
          )
        ],
      ),
    );
  }
}
