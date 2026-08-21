import 'package:flutter/material.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/action/entry_actions.dart';

class CharListItem extends StatelessWidget {
  const CharListItem({
    required this.fontString,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final FontStringDTO fontString;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(fontString.line),
          trailing: EntryActions(onEdit: onEdit, onDelete: onDelete),
        ),
      ),
    );
  }
}
