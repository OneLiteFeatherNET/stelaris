import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/feature/base/button/model_actions_menu.dart';
import 'package:stelaris/feature/dialogs/notes_edit_dialog.dart';
import 'package:stelaris/feature/model/model_copy.dart';
import 'package:stelaris/feature/model/model_notes.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/notes.dart';
import 'package:stelaris/util/relative_time.dart';
import 'package:stelaris/util/typedefs.dart';

import 'model_card_actions.dart';
import 'model_card_frame.dart';
import 'model_page.dart';

/// A grid-friendly card for [ModelPage], drawn by [ModelCardFrame]: primary
/// content in a header row, the first line of the model's [notes] below it,
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
    this.notes,
    this.copy,
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
  final ModelNotes<E>? notes;
  final ModelCopy<E>? copy;
  final String projectKey;
  final VoidCallback? onTap;

  String? get _namespacedKey {
    final key = keySelector(rawModel);
    return key.isEmpty ? null : '$projectKey:$key';
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = _TimestampInfo.of(context, rawModel);
    final notes = this.notes;
    final currentNotes = notes?.read(rawModel);

    return ModelCardFrame(
      content: mapToDataModelItem(rawModel),
      trailing: ModelCardActions(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        children: [
          ModelActionsMenu<E>(
            value: rawModel,
            nameSelector: nameSelector,
            keySelector: keySelector,
            projectKey: projectKey,
            onCopy: copy == null
                ? null
                : () => openCopyModelDialog<E>(
                    context,
                    model: rawModel,
                    copy: copy!,
                    name: nameSelector(rawModel),
                    key: keySelector(rawModel),
                  ),
            onEditNotes: notes == null
                ? null
                : () => showDialog<void>(
                    context: context,
                    builder: (_) => NotesEditDialog(
                      name: nameSelector(rawModel),
                      notes: currentNotes,
                      saveAction: (value) => notes.update(rawModel, value),
                    ),
                  ),
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
      summary: notesSummary(currentNotes),
      footerIcon: timestamp?.icon,
      footerText: timestamp == null
          ? null
          : '${timestamp.label} ${relativeTime(context, timestamp.date)}',
      onTap: onTap,
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
