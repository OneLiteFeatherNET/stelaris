import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';

typedef ValueUpdate = void Function(String value);

class DropDownCard extends StatefulWidget {

  final Text title;
  final List<DropdownMenuItem<String>> items;
  final ValueUpdate valueUpdate;

  const DropDownCard({Key? key, required this.title, required this.items, required this.valueUpdate}) : super(key: key);

  @override
  State<DropDownCard> createState() => _DropDownCardState();
}

class _DropDownCardState extends State<DropDownCard> with BaseLayout {

  String defaultValue = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: constructContainer(
          [
            widget.title,
            spaceBox,
            SizedBox(
              width: 300,
              child: DropdownButtonFormField<String>(
                items: widget.items,
                value: widget.items[0].value,
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() {
                    defaultValue = value;
                    widget.valueUpdate(defaultValue);
                  });
                },
              )
            )
          ]
      ),
    );
  }
}
