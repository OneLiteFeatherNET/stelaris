import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/constants.dart';

class BaseCard extends StatelessWidget {
  final String display;
  final String? message;
  final Widget widget;

  const BaseCard(
      {super.key,
      required this.display,
      required this.message,
      required this.widget});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 200,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).secondaryHeaderColor,
              height: 50,
              child: ListTile(
                title: Text(display, style: whiteStyle),
                trailing: _getToolTip()
              ),
            ),
            spaceBox,
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
