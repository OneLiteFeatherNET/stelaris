import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/base/input/material_autocomplete.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/component/component_dialog.dart';
import 'package:stelaris/util/constants.dart';
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
///
/// Once the options scroll, a search above them narrows them to the ones
/// whose text holds every typed word; Enter picks the first of those. The
/// list keeps its height while narrowing, so the dialog doesn't jump.
class _ChoiceList<T> extends StatefulWidget {
  const _ChoiceList({required this.field});

  final ChoiceEdit<T> field;

  @override
  State<_ChoiceList<T>> createState() => _ChoiceListState<T>();
}

class _ChoiceListState<T> extends State<_ChoiceList<T>> {
  late final List<T> _options = widget.field.options;
  late final int _visible = _options.length.clamp(1, _visibleOptions);
  late final bool _searchable = _options.length > _visibleOptions;
  final TextEditingController _search = TextEditingController();
  List<String> _words = const [];

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
    _search.dispose();
    super.dispose();
  }

  List<T> get _matches {
    if (_words.isEmpty) return _options;
    final field = widget.field;
    return [
      for (final option in _options)
        if (_matchesWords(field.display(option).toLowerCase())) option,
    ];
  }

  bool _matchesWords(String text) => _words.every(text.contains);

  void _onSearch(String text) {
    setState(() {
      _words = text.toLowerCase().split(' ')
        ..removeWhere((word) => word.isEmpty);
    });
    // The matches start at the top, not where the full list was scrolled to.
    if (_controller.hasClients) _controller.jumpTo(0);
  }

  void _clear() {
    _search.clear();
    _onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final matches = _matches;
    final list = SizedBox(
      height: _visible * _optionExtent,
      child: matches.isEmpty
          ? Center(child: Text(context.l10n.search_no_results))
          : ListView.builder(
              key: const Key('choice_edit_options'),
              controller: _controller,
              itemCount: matches.length,
              itemExtent: _optionExtent,
              itemBuilder: (context, index) {
                final option = matches[index];
                final current = option == field.value;
                return ListTile(
                  dense: true,
                  // The options line up with the title and the divider of
                  // the dialog instead of sitting inset from them.
                  contentPadding: EdgeInsets.zero,
                  // As high as the row, or a compact density on desktop
                  // centers the text in a shorter tile at the top of it.
                  minTileHeight: _optionExtent,
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
    if (!_searchable) return list;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogSearchBar(
          controller: _search,
          hintText: context.l10n.choice_edit_search_hint(field.label),
          trailing: [
            if (_search.text.isNotEmpty)
              IconButton(
                tooltip: context.l10n.search_clear_tooltip,
                icon: const Icon(Icons.close),
                onPressed: _clear,
              ),
          ],
          onChanged: _onSearch,
          onSubmitted: (_) {
            if (matches.isNotEmpty) Navigator.of(context).pop(matches.first);
          },
        ),
        // The same gap as below the search of the component picker.
        verticalSpacing10,
        list,
      ],
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
