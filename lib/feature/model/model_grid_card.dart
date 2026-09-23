import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/feature/base/button/model_actions_menu.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/relative_time.dart';
import 'package:stelaris/util/typedefs.dart';

import 'model_card_actions.dart';
import 'model_page.dart';

/// A grid-friendly card for [ModelPage]: primary content in a header row,
/// a divider, and a "last edited" footer row (from
/// [DataModel.modificationDate]) below it. The info/delete actions sit in
/// the header's corner.
class ModelGridCard<E extends DataModel> extends StatelessWidget {
  const ModelGridCard({
    required this.rawModel,
    required this.mapToDataModelItem,
    required this.deleteTitle,
    required this.mapToDeleteSuccessfully,
    required this.nameSelector,
    required this.keySelector,
    required this.projectKey,
    this.deleteWarning,
    this.onTap,
    super.key,
  });

  final E rawModel;
  final MapToDataModelItem<E> mapToDataModelItem;
  final String deleteTitle;
  final String? deleteWarning;
  final MapToDeleteSuccessfully<E> mapToDeleteSuccessfully;
  final ModelNameSelector<E> nameSelector;
  final ModelKeySelector<E> keySelector;
  final String projectKey;
  final VoidCallback? onTap;

  String? get _namespacedKey {
    final key = keySelector(rawModel);
    return key.isEmpty ? null : '$projectKey:$key';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timestamp = _TimestampInfo.of(context, rawModel);

    // Fill only, no outline — the content sheet behind it already provides
    // the framing, so fill + border on top of that read as nested boxes.
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      ModelActionsMenu<E>(
                        value: rawModel,
                        nameSelector: nameSelector,
                        keySelector: keySelector,
                        projectKey: projectKey,
                      ),
                      DeleteModelButton<E>(
                        value: rawModel,
                        deleteTitle: deleteTitle,
                        deleteWarning: deleteWarning,
                        name: nameSelector(rawModel),
                        mapToDeleteSuccessfully: mapToDeleteSuccessfully,
                        namespacedKey: _namespacedKey,
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
