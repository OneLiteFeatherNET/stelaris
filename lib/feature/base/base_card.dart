import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_layout.dart';
import 'package:stelaris_ui/util/constants.dart';

class BaseCard extends StatelessWidget {
  final String display;
  final String message;
  final Widget widget;

  const BaseCard(
      {super.key,
      required this.display,
      required this.message,
      required this.widget});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            color: Colors.teal[800],
            height: 50,
            child: ListTile(
              title: Text(display, style: whiteStyle),
              trailing: Tooltip(
                message: message,
                child: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          spaceBox,
          widget
        ],
      ),
    );
  }
}
