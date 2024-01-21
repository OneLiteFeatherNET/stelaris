import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/base_card.dart';
import 'package:stelaris_ui/util/constants.dart';

class ExpandableDataCardV2 extends StatefulWidget {
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
  State<ExpandableDataCardV2> createState() => _ExpandableDataCardV2State();
}

class _ExpandableDataCardV2State extends State<ExpandableDataCardV2> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: ColoredBox(
        color: Colors.teal[800] ?? Colors.teal,
        child: widget.title
      ),
      trailing: IconButton(
        onPressed: widget.buttonClick,
        icon: addModelIcon,
      ),
      children: widget.widgets,
    );
  }
}

/**  child: Column(
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
    return BaseCard(
    display: widget.cardTitle,
    message: widget.message,
    widget: ExpansionTile(
    controlAffinity: ListTileControlAffinity.leading,
    title: widget.title,
    trailing: IconButton(
    onPressed: widget.buttonClick,
    icon: addModelIcon,
    ),
    children: widget.widgets
    ),
    );
    return const Placeholder();
    }
    }*/
