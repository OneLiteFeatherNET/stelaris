import 'package:flutter/material.dart';
import 'package:stelaris/util/constants.dart';

/// A customizable card widget that displays a title, an optional message, and a child widget.
class BaseCard extends StatelessWidget {

  const BaseCard({
    required this.display,
    required this.widget,
    this.message = emptyString, // Default to an empty string
    this.width = 350,
    this.height = 200,
    super.key,
  });

  final String display;
  final Widget widget;
  final String message; // Changed to non-nullable with a default value
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).secondaryHeaderColor,
              height: sizeFifty,
              child: ListTile(
                title: Text(display, style: whiteStyle),
                trailing: message.isNotEmpty
                    ? Tooltip(
                  message: message,
                  child: const Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                )
                    : null,
              ),
            ),
            const SizedBox(height: 10), // Use SizedBox for spacing
            widget,
          ],
        ),
      ),
    );
  }
}
