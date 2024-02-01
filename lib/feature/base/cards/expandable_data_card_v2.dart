import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_header.dart';

class ExpandableDataCardV2 extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ExpandableNotifier(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
          ),
          child: Expandable(
            theme: const ExpandableThemeData(
              iconPlacement: ExpandablePanelIconPlacement.left,
              tapHeaderToExpand: false,
            ),
            collapsed: ExpandableHeader(
              title: title,
              isExpanded: false,
              buttonClick: buttonClick,
            ),
            expanded: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
              ),
              child: Column(
                children: [
                  ExpandableHeader(
                    title: title,
                    isExpanded: true,
                    buttonClick: buttonClick,
                  ),
                  ...widgets
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
