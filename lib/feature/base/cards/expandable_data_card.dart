import 'package:flutter/material.dart';

import '../../../util/constants.dart';
import '../base_layout.dart';

const BoxConstraints constraints = BoxConstraints(
    minWidth: 300,
    minHeight: 100,
    maxWidth: 300
);

class ExpandableDataCard extends StatefulWidget {

  final Text title;
  final VoidCallback buttonClick;
  final List<Widget> widgets;

  const ExpandableDataCard({Key? key, required this.title, required this.buttonClick, required this.widgets}) : super(key: key);

  @override
  State<ExpandableDataCard> createState() => _ExpandableDataCardState();
}

class _ExpandableDataCardState extends State<ExpandableDataCard> with BaseLayout {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: constructContainer(
          [
            ConstrainedBox(
              constraints: constraints,
              child: ExpansionTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: widget.title,
                trailing: IconButton(
                  onPressed: widget.buttonClick,
                  icon: addModelIcon,
                ),
                children: widget.widgets
              ),
            )
          ]
      ),
    );
  }
}