import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/auth/role_gate.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';
import 'package:stelaris/feature/sound/card/small_file_card.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// One sound file as a card in the style of the lore cards. A tap on the card
/// edits the file.
class SoundFileCard extends StatelessWidget {
  static const double _fullCardMinWidth = 230;

  const SoundFileCard({
    required this.source,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final SoundFileSource source;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the card is too narrow, show only the icon centered in a card
        if (constraints.maxWidth < _fullCardMinWidth) {
          return SmallFileCard(onEdit: onEdit);
        }
        return Card.filled(
          margin: const EdgeInsets.symmetric(vertical: 4),
          clipBehavior: Clip.antiAlias,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppShapes.medium),
          ),
          child: InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  const FolderIcon(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle(context),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
        );
      },
    );
  }

  /// The type of the file with its volume and pitch.
  String _subtitle(BuildContext context) {
    final type = source.type == 'event'
        ? context.l10n.sound_type_event
        : context.l10n.sound_type_file;
    return context.l10n.sound_file_card_subtitle(
      type,
      source.volume.toString(),
      source.pitch.toString(),
    );
  }
}
