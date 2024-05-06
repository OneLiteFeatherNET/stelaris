import 'package:flutter/material.dart';
import 'package:stelaris_ui/util/constants.dart';

class BaseCard extends StatelessWidget {
  final String display;
  final String? message;
  final Widget widget;
  final double width;
  final double height;

  const BaseCard({
    required this.display,
    required this.message,
    required this.widget,
    this.width = 350,
    this.height = 200,
    super.key,
  });

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
                  trailing: _getToolTip()),
            ),
            heightTen,
            widget
          ],
        ),
      ),
    );
  }

  Widget? _getToolTip() {
    if (message == null) return null;
    return Tooltip(
      message: message!,
      child: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    );
  }
}
