import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

/// A customizable card widget that displays a title, an optional message, and a child widget.
class BaseCard extends StatelessWidget {
  const BaseCard({
    required this.display,
    required this.widget,
    this.message = emptyString,
    this.width = 350,
    this.height = 200,
    super.key,
  });

  final String display;
  final Widget widget;
  final String message;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display,
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (message.isNotEmpty)
                    Tooltip(
                      message: message,
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: widget),
          ],
        ),
      ),
    );
  }
}
