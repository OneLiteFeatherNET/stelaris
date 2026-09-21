import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/button/copy_model_button.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/relative_time.dart';
import 'package:stelaris/util/typedefs.dart';

/// A grid-friendly card for [ModelPage]: primary content in a header row,
/// a divider, and a "last edited" footer row (from
/// [DataModel.modificationDate]) below it. The delete action sits in the
/// header's corner.
class ModelGridCard<E extends DataModel> extends StatelessWidget {
  const ModelGridCard({
    required this.rawModel,
    required this.mapToDataModelItem,
    required this.mapToDeleteDialog,
    required this.mapToDeleteSuccessfully,
    required this.nameSelector,
    required this.keySelector,
    required this.copyDialogTitle,
    required this.mapToCopySuccessfully,
    required this.projects,
    required this.currentProject,
    this.hasRelationshipData,
    this.onTap,
    super.key,
  });

  final E rawModel;
  final MapToDataModelItem<E> mapToDataModelItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final ModelNameSelector<E> nameSelector;
  final ModelKeySelector<E> keySelector;
  final String copyDialogTitle;
  final MapToCopySuccessfully<E> mapToCopySuccessfully;
  final HasRelationshipData<E>? hasRelationshipData;
  final List<Project> projects;
  final Project currentProject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final creationDate = rawModel.creationDate;
    final modificationDate = rawModel.modificationDate;
    // Only one timestamp is shown: if it was ever edited after creation,
    // that edit is the more relevant one; otherwise fall back to creation.
    final wasEdited =
        modificationDate != null &&
        (creationDate == null || modificationDate.isAfter(creationDate));
    final timestampDate = wasEdited ? modificationDate : creationDate;
    final timestampIcon = wasEdited
        ? Icons.edit_outlined
        : Icons.add_circle_outline;
    final timestampLabel = wasEdited
        ? context.l10n.model_card_edited_prefix
        : context.l10n.model_card_created_prefix;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        key: const Key('model_grid_card_inkwell'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: mapToDataModelItem(rawModel)),
                  // DeleteModelButton/CopyModelButton wrap a plain
                  // IconButton. Content below the title (e.g. a key badge)
                  // means the header can be taller than one line, so the
                  // icons are top-aligned against it rather than centered
                  // against the whole block. 28x28 keeps their box close to
                  // titleMedium's line-box height (~24px), but Text's font
                  // leading and IconButton's own centering don't share the
                  // same top inset, so a small manual offset closes the
                  // remaining gap between the title's glyphs and the icons.
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: IconButtonTheme(
                      data: IconButtonThemeData(
                        style: IconButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(28, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CopyModelButton<E>(
                            value: rawModel,
                            copyDialogTitle: copyDialogTitle,
                            nameSelector: nameSelector,
                            keySelector: keySelector,
                            projects: projects,
                            currentProject: currentProject,
                            mapToCopySuccessfully: mapToCopySuccessfully,
                            hasRelationshipData: hasRelationshipData,
                          ),
                          DeleteModelButton<E>(
                            value: rawModel,
                            mapToDeleteDialog: mapToDeleteDialog,
                            mapToDeleteSuccessfully: mapToDeleteSuccessfully,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (timestampDate != null) ...[
                const SizedBox(height: 8),
                Divider(height: 1, color: colorScheme.outlineVariant),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      timestampIcon,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '$timestampLabel ${relativeTime(context, timestampDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
