import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/auth/role_gate.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// One font char line as a card in the style of the lore cards. A tap on the
/// card edits the line.
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card.filled(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.medium),
        ),
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fontString.line,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // A tap on the card edits, so only deleting needs a button.
                RoleGate(
                  role: Roles.admin,
                  child: IconButton(
                    tooltip: context.l10n.tooltip_delete,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_forever),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
