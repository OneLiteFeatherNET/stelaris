import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/attribute_model.dart';
import 'package:stelaris_ui/feature/base/button/delete_entry_button.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';

import '../../util/constants.dart';

class AttributesTile extends StatelessWidget {
  final AttributeModel attributeModel;

  const AttributesTile({super.key, required this.attributeModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(attributeModel.name!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.save_rounded,
              color: Colors.white,
            ),
          ),
          DeleteEntryButton<AttributeModel>(
            title: "Confirm deletion",
            header: [
              TextSpan(
                  text: context.l10n.delete_dialog_first_line,
                  style: whiteStyle),
              TextSpan(text: attributeModel.name, style: redStyle),
              TextSpan(
                  text: context.l10n.delete_dialog_entry,
                  style: whiteStyle),
            ],
            value: attributeModel,
            mapToDeleteSuccessfully: (value) {
              return true;
            },
          ),
        ],
      ),
    );
  }
}
