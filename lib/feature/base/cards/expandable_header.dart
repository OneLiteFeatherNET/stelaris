import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class ExpandableHeader extends StatelessWidget {
  final bool isExpanded;
  final Text title;
  final VoidCallback? addCallback;
  final VoidCallback? saveCallback;

  const ExpandableHeader({
    required this.isExpanded,
    required this.title,
    this.saveCallback,
    this.addCallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    final expandedColor = Theme.of(context).colorScheme.primary;
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
            color: isExpanded ? expandedColor : textColor,
          ),
          trailing: _getTrailingWidget(textColor, expandedColor)
        ),
      ),
    );
  }

  Widget? _getTrailingWidget(Color iconColor, Color expandedColor) {
    if (saveCallback != null) {
      return IconButton(
        onPressed: saveCallback,
        icon: saveIcon,
        color: isExpanded ? expandedColor : iconColor,
      );
    }
    if (addCallback != null) {
      return IconButton(
        onPressed: addCallback,
        icon: addModelIcon,
        color: isExpanded ? expandedColor : iconColor
      );
    }
    return null;
  }
}
