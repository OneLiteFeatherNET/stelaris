import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_header.dart';

class ExpandableDataCardV2 extends StatefulWidget {
  final String cardTitle;
  final Text title;
  final String message;
  final VoidCallback buttonClick;
  final List<Widget> widgets;

  const ExpandableDataCardV2({
    super.key,
    required this.cardTitle,
    required this.title,
    required this.message,
    required this.buttonClick,
    required this.widgets,
  });

  @override
  State<ExpandableDataCardV2> createState() => _ExpandableDataCardV2State();
}

class _ExpandableDataCardV2State extends State<ExpandableDataCardV2> {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Expandable(
          theme: const ExpandableThemeData(
            iconPlacement: ExpandablePanelIconPlacement.left,
            tapHeaderToExpand: false,
          ),
          collapsed: ExpandableHeader(
            title: widget.title,
            isExpanded: false,
            buttonClick: widget.buttonClick,
          ),
          expanded: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                ExpandableHeader(
                  title: widget.title,
                  isExpanded: true,
                  buttonClick: widget.buttonClick,
                ),
                ...widget.widgets
              ],
            ),
          ),
        ),
      ),
    );
  }
}
