import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/cards/expandable_header.dart';

class ExpandableDataCard extends StatelessWidget {

  final Text title;
  final VoidCallback buttonClick;
  final List<Widget> widgets;

  const ExpandableDataCard({
    required this.title,
    required this.buttonClick,
    required this.widgets,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
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
              addCallback: buttonClick,
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
                    addCallback: buttonClick,
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
