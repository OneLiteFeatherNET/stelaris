import 'package:flutter/material.dart';

enum _MenuAction { edit, delete }

class FontCharMenu extends StatelessWidget {

  const FontCharMenu({
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      icon: const Icon(Icons.more_horiz),
      onSelected: (action) {
        switch (action) {
          case _MenuAction.edit:
            onEdit();
          case _MenuAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _MenuAction.edit,
          child: _MenuItemContent(
            icon: Icon(Icons.edit),
            label: 'Edit',
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.delete,
          child: _MenuItemContent(
            icon: Icon(Icons.delete_forever),
            label: 'Delete',
          ),
        ),
      ],
    );
  }
}

// Separates const Widget für Menu Items
class _MenuItemContent extends StatelessWidget {
  const _MenuItemContent({
    required this.icon,
    required this.label,
  });

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}