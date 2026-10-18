import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/card/folder_icon.dart';
import 'package:stelaris/util/app_shapes.dart';

/// The narrow form of a sound file card that shows only the folder icon. A tap
/// on the card edits the file.
class SmallFileCard extends StatelessWidget {
  const SmallFileCard({required this.onEdit, super.key});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppShapes.medium),
      ),
      child: InkWell(onTap: onEdit, child: const FolderIcon()),
    );
  }
}
