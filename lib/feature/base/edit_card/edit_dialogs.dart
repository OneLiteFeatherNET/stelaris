import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/base/input/material_autocomplete.dart';
import 'package:stelaris/feature/component/component_dialog.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/minimessage_json.dart';

/// Opens the dialog of [field] and hands a changed value to it.
Future<void> editField(BuildContext context, EditField field) async {
  switch (field) {
    case TextEdit():
      final value = await showDialog<String>(
        context: context,
        builder: (_) => _TextEditDialog(field: field),
      );
      if (value != null && value != field.value) field.onChanged(value);
    case ChoiceEdit():
      await field.pick(context);
    case TextComponentEdit():
      final text = await showDialog<String>(
        context: context,
        builder: (dialogContext) => ComponentDialog(
          title: field.label,
          actionLabel: context.l10n.button_save,
          componentContext: field.componentContext,
          initialValue: textComponentSource(field.value),
          required: false,
          onSave: (text) => Navigator.of(dialogContext).pop(text),
        ),
      );
      if (text == null) return;
      final json = text.isEmpty
          ? null
          : jsonEncode(MiniMessageJson.encode(text));
      if (json != field.value) field.onChanged(json);
  }
}

/// The MiniMessage of a text component kept as a JSON string. A string that
/// is no JSON was stored as plain text before and is taken as that.
String textComponentSource(String? json) {
  if (json == null || json.isEmpty) return '';
  try {
    return MiniMessageJson.decode(jsonDecode(json));
  } on FormatException {
    return json;
  }
}

/// The height of one option in the choice dialog.
const double _optionExtent = 48;

/// The most options the choice dialog shows at once, more scroll.
const int _visibleOptions = 8;

/// Lets the user pick one of [field]'s options, the current one marked. A
/// tap picks and closes. Resolves to the pick, or null when closed.
///
/// The options are built lazily, a parent advancement can have hundreds,
/// and the list starts at the current one.
Future<T?> showChoiceEditDialog<T>(BuildContext context, ChoiceEdit<T> field) {
  return showDialog<T>(
    context: context,
    builder: (context) => FormDialog(
      title: field.label,
      actionLabel: context.l10n.button_save,
      maxWidth: 440,
      onSubmit: null,
      showActions: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChoiceList<T>(field: field),
          if (field.footer case final footer?) ...[
            const SizedBox(height: 8),
            Text(
              footer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// The options of a [ChoiceEdit], at most [_visibleOptions] in view.
class _ChoiceList<T> extends StatefulWidget {
  const _ChoiceList({required this.field});

  final ChoiceEdit<T> field;

  @override
  State<_ChoiceList<T>> createState() => _ChoiceListState<T>();
}

class _ChoiceListState<T> extends State<_ChoiceList<T>> {
  late final List<T> _options = widget.field.options;
  late final int _visible = _options.length.clamp(1, _visibleOptions);

  /// Starts with the current option in view, as far down as the list goes.
  late final ScrollController _controller = ScrollController(
    initialScrollOffset:
        (_options.indexOf(widget.field.value) - _visible ~/ 2).clamp(
          0,
          _options.length - _visible,
        ) *
        _optionExtent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    return SizedBox(
      height: _visible * _optionExtent,
      child: ListView.builder(
        key: const Key('choice_edit_options'),
        controller: _controller,
        itemCount: _options.length,
        itemExtent: _optionExtent,
        itemBuilder: (context, index) {
          final option = _options[index];
          final current = option == field.value;
          return ListTile(
            dense: true,
            selected: current,
            leading: current
                ? const Icon(Icons.check)
                : const SizedBox(width: 24),
            title: Text(field.display(option)),
            trailing: field.optionTrailing?.call(option),
            onTap: () => Navigator.of(context).pop(option),
          );
        },
      ),
    );
  }
}

/// Edits a [TextEdit] in one line. Opens with the value selected, so typing
/// replaces it, and Enter saves.
class _TextEditDialog extends StatefulWidget {
  const _TextEditDialog({required this.field});

  final TextEdit field;

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.field.value)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.field.value.length,
        );
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text);
  }

  Widget _field({VoidCallback? onSubmitted}) {
    final field = widget.field;
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      maxLength: field.maxLength,
      keyboardType: field.keyboardType,
      inputFormatters: field.formatters,
      validator: field.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        // Takes a highlighted suggestion first, which rewrites the text.
        onSubmitted?.call();
        _save();
      },
      decoration: InputDecoration(
        hintText: field.hintText,
        helperText: field.footer,
        helperMaxLines: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    return FormDialog(
      title: field.label,
      actionIcon: Icons.check,
      actionLabel: context.l10n.button_save,
      maxWidth: 440,
      onSubmit: _save,
      content: Form(
        key: _formKey,
        child: field.suggestsMaterials
            ? MaterialAutocomplete(
                controller: _controller,
                focusNode: _focusNode,
                onSelected: (_) {},
                fieldBuilder: (context, controller, focusNode, onSubmitted) =>
                    _field(onSubmitted: onSubmitted),
              )
            : _field(),
      ),
    );
  }
}
