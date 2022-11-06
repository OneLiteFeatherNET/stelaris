import 'package:flutter/material.dart';

enum PluginAction {
  edit("Edit", Icons.edit),
  remove("Remove", Icons.delete_forever);

  final String displayName;
  final IconData iconData;

  const PluginAction(this.displayName, this.iconData);

  Icon toIcon() {
    return Icon(iconData);
  }

  Widget toButton(ActionClick click) {
    return IconButton(
      padding: const EdgeInsets.only(top: 2.5),
        tooltip: displayName,
        hoverColor: Colors.transparent,
        onPressed: () {
          click(this);
        },
        icon: toIcon()
    );
  }
}

typedef ActionClick = void Function(PluginAction action);