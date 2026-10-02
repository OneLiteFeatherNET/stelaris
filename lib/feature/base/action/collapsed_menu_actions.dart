import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

enum _MenuAction { edit, delete }

class CollapsedMenuActions extends StatelessWidget {
  const CollapsedMenuActions({
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
      onSelected: (action) => switch (action) {
        _MenuAction.edit => onEdit(),
        _MenuAction.delete => onDelete(),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _MenuAction.edit,
          child: _MenuItemContent(
            icon: const Icon(Icons.edit),
            label: context.l10n.button_edit,
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.delete,
          child: _MenuItemContent(
            icon: const Icon(Icons.delete_forever),
            label: context.l10n.button_delete,
          ),
        ),
      ],
    );
  }
}

// Separates const Widget für Menu Items
class _MenuItemContent extends StatelessWidget {
  const _MenuItemContent({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [icon, const SizedBox(width: 12), Text(label)]);
  }
}
