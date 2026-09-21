import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/relative_time.dart';
import 'package:stelaris/util/typedefs.dart';

import 'model_card_actions.dart';

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
    this.onTap,
    super.key,
  });

  final E rawModel;
  final MapToDataModelItem<E> mapToDataModelItem;
  final MapToDeleteDialog<E> mapToDeleteDialog;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timestamp = _TimestampInfo.of(context, rawModel);

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
                  ModelCardActions(
                    color: colorScheme.onSurfaceVariant,
                    children: [
                      DeleteModelButton<E>(
                        value: rawModel,
                        mapToDeleteDialog: mapToDeleteDialog,
                        mapToDeleteSuccessfully: mapToDeleteSuccessfully,
                      ),
                    ],
                  ),
                ],
              ),
              if (timestamp != null) ...[
                const SizedBox(height: 8),
                Divider(height: 1, color: colorScheme.outlineVariant),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      timestamp.icon,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${timestamp.label} ${relativeTime(context, timestamp.date)}',
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

/// The icon, label, and date for a [ModelGridCard]'s "last edited"/"created"
/// footer, derived from a [DataModel]'s [DataModel.creationDate] and
/// [DataModel.modificationDate].
class _TimestampInfo {
  const _TimestampInfo({
    required this.icon,
    required this.label,
    required this.date,
  });

  final IconData icon;
  final String label;
  final DateTime date;

  /// Returns `null` if [model] has neither a creation nor a modification
  /// date. Only one timestamp is ever shown: if [model] was edited after
  /// creation, that edit is the more relevant one; otherwise it falls back
  /// to the creation date.
  static _TimestampInfo? of(BuildContext context, DataModel model) {
    final creationDate = model.creationDate;
    final modificationDate = model.modificationDate;
    final wasEdited =
        modificationDate != null &&
        (creationDate == null || modificationDate.isAfter(creationDate));
    final date = wasEdited ? modificationDate : creationDate;
    if (date == null) return null;

    return _TimestampInfo(
      icon: wasEdited ? Icons.edit_outlined : Icons.add_circle_outline,
      label: wasEdited
          ? context.l10n.model_card_edited_prefix
          : context.l10n.model_card_created_prefix,
      date: date,
    );
  }
}
