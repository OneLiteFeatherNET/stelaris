import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/feature/dialogs/delete_dialog.dart';
import 'package:stelaris_ui/feature/item/enchantment_edit_dialog.dart';
import 'package:stelaris_ui/feature/item/enchantment_reducer.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class EnchantmentButtons extends StatelessWidget with EnchantmentReducer {
  final ItemModel model;
  final String? name;
  final int? level;
  final ValueUpdate<ItemModel> delete;
  final DoubleValueUpdate<String, String> update;

  EnchantmentButtons({Key? key,
    required this.model,
    required this.name,
    required this.level,
    required this.delete,
    required this.update})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Row(
        children: [
          IconButton(
            icon: deleteIcon,
            tooltip: context.l10n.tooltip_delete,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return DeleteDialog<String?>(
                    title: Text(context.l10n.dialog_delete_confirm, textAlign: TextAlign.center,),
                    header: [
                      TextSpan(
                          text: context.l10n.dialog_level_delete_first_line,
                          style: whiteStyle),
                      TextSpan(text: name, style: redStyle)
                    ],
                    value: name,
                    successfully: (value) {
                      delete(model);
                      return true;
                    },
                  );
                },
              );
            },
          ),
          IconButton(onPressed: () {
            showDialog(context: context, builder: (BuildContext context) {
              return LevelEditDialog(
                currentValue: level.toString(),
                newLevel: (value) {
                  update(name, value);
                },
              );
            });
          },
            icon: editIcon,
            tooltip: context.l10n.dialog_level_title
          )
        ],
      ),
    );
  }
}
