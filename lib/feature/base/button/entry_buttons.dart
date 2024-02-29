import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/feature/base/button/delete_entry_button.dart';
import 'package:stelaris_ui/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class EntryButtons extends StatelessWidget {
  final String editTitle;
  final ItemModel model;
  final String? name;
  final String? value;
  final ValueUpdate<ItemModel> delete;
  final DoubleValueUpdate<String, String> update;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator formFieldValidator;

  const EntryButtons({
    required this.editTitle,
    required this.model,
    required this.name,
    required this.value,
    required this.delete,
    required this.update,
    required this.formFieldValidator,
    this.inputFormatters,
    super.key,
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
            onPressed: () => _showDialog(context),
            icon: editIcon,
            tooltip: context.l10n.dialog_level_title,
          )
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: editTitle,
          formKey: GlobalKey<FormState>(),
          valueUpdate: (value) {
            update(name, value);
            Navigator.pop(context, false);
          },
          formFieldValidator: formFieldValidator,
          autoFocus: true,
          data: value,
        );
      },
    );
  }
}
