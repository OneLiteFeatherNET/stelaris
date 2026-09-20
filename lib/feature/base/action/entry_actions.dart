import 'package:material_ui/material_ui.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/auth/role_gate.dart';
import 'package:stelaris/feature/base/action/collapsed_menu_actions.dart';

class EntryActions extends StatelessWidget {
  const EntryActions({required this.onEdit, required this.onDelete, super.key});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 650) {
      return CollapsedMenuActions(onEdit: onEdit, onDelete: onDelete);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Deleting is the one irreversible thing in this application, so it is
        // the one action worth hiding from somebody the backend would refuse
        // anyway. Editing stays offered: a refused save costs a message, a
        // hidden edit button costs a support question.
        RoleGate(
          role: Roles.admin,
          child: IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_forever),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
      ],
    );
  }
}
