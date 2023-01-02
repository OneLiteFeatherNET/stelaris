import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/constants.dart';

const BoxConstraints constraints = BoxConstraints(
    minWidth: 300,
    minHeight: 100,
    maxWidth: 300
);

class ExpandableDataCard extends StatelessWidget with BaseLayout {

  final Text title;
  final VoidCallback buttonClick;
  final List<Widget> widgets;

  const ExpandableDataCard({Key? key, required this.title, required this.buttonClick, required this.widgets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: constructContainer(
          [
            ExpansionTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: title,
                trailing: IconButton(
                  onPressed: buttonClick,
                  icon: addModelIcon,
                ),
                children: widgets
            )
          ]
      ),
    );
  }
}