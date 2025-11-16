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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 650) {
      return FontCharMenu(onEdit: onEdit, onDelete: onDelete);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onDelete, icon: Icon(Icons.delete_forever)),
        const SizedBox(width: 8),
        IconButton(onPressed: onEdit, icon: Icon(Icons.edit)),
      ],
    );
  }
}
