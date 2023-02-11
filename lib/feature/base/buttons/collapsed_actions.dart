import 'package:flutter/material.dart';

class CollapsedActionButtons extends StatelessWidget {

  final List<Widget> widgets;

  const CollapsedActionButtons({Key? key, required this.widgets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: widgets
    );
  }
}
