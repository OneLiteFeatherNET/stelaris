import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/util/minecraft/item_flag.dart';

const List<ItemFlag> flags = ItemFlag.values;
List<DropdownMenuItem<String>> items =
  List.generate(flags.length, (index) =>
      DropdownMenuItem(value: flags[index].display,child: Text(flags[index].display),)
  );

class EntryAddDialog extends StatelessWidget {

  final Text title;
  final Widget widget;

  const EntryAddDialog({Key? key, required this.title, required this.widget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: title,
      contentPadding: const EdgeInsets.all(20.0),
      children: [
        widget,
        const SizedBox(height: 25),
        TextButton(onPressed: () {

        }, child: const Text("Add"))
      ],
    );
  }
}
