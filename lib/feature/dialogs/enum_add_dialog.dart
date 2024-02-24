import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class EnumAddDialog<E> extends StatefulWidget {
  final Text title;
  final List<DropdownMenuItem<E>> items;
  final ValueUpdate<E> valueUpdate;

  const EnumAddDialog({
    required this.title,
    required this.items,
    required this.valueUpdate,
    super.key,
  });

  @override
  State<EnumAddDialog<E>> createState() => _EnumAddDialogState<E>();
}

class _EnumAddDialogState<E> extends State<EnumAddDialog<E>> {
  E? defaultValue;

  @override
  Widget build(BuildContext context) {
    defaultValue = widget.items.first.value;
    return SimpleDialog(
      title: widget.title,
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        SizedBox(
          width: 300,
          child: DropdownButtonFormField<E>(
            items: widget.items,
            value: defaultValue,
            onChanged: (E? value) {
              if (value == null) return;
              defaultValue = value;
            },
          ),
        ),
        verticalSpacing25,
        TextButton(
          onPressed: () {
            widget.valueUpdate(defaultValue);
          },
          child: Text(context.l10n.button_add),
        )
      ],
    );
  }
}
