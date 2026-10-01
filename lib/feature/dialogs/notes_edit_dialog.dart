import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Builds the action that saves [notes] — `null` when cleared — for the
/// model the dialog was opened on.
typedef NotesSaveAction = ReduxAction<AppState> Function(String? notes);

/// Edits a model's internal notes from its overview card and saves them
/// right away via [saveAction]. Stays open and shows the error if the save
/// fails, so nothing typed is lost.
class NotesEditDialog extends StatefulWidget {
  const NotesEditDialog({
    required this.name,
    required this.notes,
    required this.saveAction,
    super.key,
  });

  final String name;
  final String? notes;
  final NotesSaveAction saveAction;

  @override
  State<NotesEditDialog> createState() => _NotesEditDialogState();
}

class _NotesEditDialogState extends State<NotesEditDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.notes,
  );
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final trimmed = _controller.text.trim();
    final notes = trimmed.isEmpty ? null : trimmed;
    if (notes == widget.notes) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    final status = await context.dispatchAndWait(widget.saveAction(notes));
    if (!mounted) return;
    setState(() => _saving = false);

    if (status.isCompletedFailed) {
      final error = status.originalError;
      if (error != null) context.showErrorSnackBar(error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: context.l10n.dialog_notes_title(widget.name),
      actionIcon: Icons.check,
      actionLabel: context.l10n.button_save,
      onSubmit: _saving ? null : _save,
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.multiline,
        minLines: 5,
        maxLines: 12,
        decoration: InputDecoration(
          hintText: context.l10n.notes_hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
