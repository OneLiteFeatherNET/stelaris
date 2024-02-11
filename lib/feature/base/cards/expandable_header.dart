import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class ExpandableHeader extends StatelessWidget {
  final bool isExpanded;
  final Text title;
  final VoidCallback? addCallback;
  final VoidCallback? saveCallback;

  const ExpandableHeader({
    super.key,
    required this.isExpanded,
    required this.title,
    this.saveCallback,
    this.addCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableButton(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          title: title,
          leading: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: isExpanded ? Colors.tealAccent : Colors.white,
          ),
          trailing: _getTrailingWidget(),
        ),
      ),
    );
  }

  Widget? _getTrailingWidget() {
    if (saveCallback != null) {
      return IconButton(
        onPressed: saveCallback,
        icon: saveIcon,
        color: isExpanded ? Colors.tealAccent : Colors.white,
      );
    }
    if (addCallback != null) {
      return IconButton(
        onPressed: addCallback,
        icon: addModelIcon,
        color: isExpanded ? Colors.tealAccent : Colors.white,
      );
    }
    return null;
  }
}
