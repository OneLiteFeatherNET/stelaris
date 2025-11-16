import 'package:flutter/material.dart';
import 'package:stelaris/feature/font/chars/actions/font_char_menu_actions.dart';

class FontCharEntryActions extends StatelessWidget {
  const FontCharEntryActions({
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // Statische const Widgets außerhalb von build
  static const _editIcon = Icon(Icons.edit);
  static const _deleteIcon = Icon(Icons.delete_forever);
  static const _moreIcon = Icon(Icons.more_vert);
  static const _spacing = SizedBox(width: 8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 650) {
      return FontCharMenu(onEdit: onEdit, onDelete: onDelete);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onDelete, icon: _deleteIcon),
        _spacing,
        IconButton(onPressed: onEdit, icon: _editIcon),
      ],
    );
  }
}
