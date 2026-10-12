import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_toolbar.dart';
import 'package:stelaris/feature/component/minimessage_field.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/minimessage_editing.dart';

/// The input for every text that is a text component: the formatting
/// toolbar over a [MiniMessageField], with the shortcuts for bold, italic
/// and underline. Reports every change of the text to [onChanged].
class MiniMessageEditor extends StatefulWidget {
  const MiniMessageEditor({
    required this.value,
    required this.onChanged,
    required this.componentContext,
    this.label,
    this.autofocus = false,
    this.multiline = false,
    this.validator,
    this.onSubmitted,
    super.key,
  });

  /// The text to show. A different one from outside replaces what is in the
  /// field, the one the field reported itself is ignored.
  final String value;
  final ValueChanged<String> onChanged;
  final ComponentContext componentContext;

  /// Shown above the toolbar. The field has no floating label, it would sit
  /// half on the dark background.
  final String? label;
  final bool autofocus;

  /// See [MiniMessageField.multiline].
  final bool multiline;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  State<MiniMessageEditor> createState() => _MiniMessageEditorState();
}

class _MiniMessageEditorState extends State<MiniMessageEditor> {
  late final MiniMessageController _controller = MiniMessageController(
    componentContext: widget.componentContext,
    text: widget.value,
  );
  final FocusNode _focusNode = FocusNode();
  late String _reported;
  bool _toolbarReady = false;

  /// The height of the toolbar's single row of buttons.
  static const double _toolbarHeight = 48;

  @override
  void initState() {
    super.initState();
    // Not lazily, the first read would already see the next widget.
    _reported = widget.value;
    _controller.addListener(_report);
    // The toolbar is half of what the editor builds. A frame later it no
    // longer slows down the first frame of a dialog opening, its place is
    // kept meanwhile.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _toolbarReady = true);
    });
  }

  @override
  void didUpdateWidget(MiniMessageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _reported) {
      _reported = widget.value;
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// The controller also notifies for a moved caret, only text counts.
  void _report() {
    if (_controller.text == _reported) return;
    _reported = _controller.text;
    widget.onChanged(_controller.text);
  }

  void _toggle(String tag) {
    _controller.value = MiniMessageEditing.toggle(_controller.value, tag);
  }

  Map<ShortcutActivator, VoidCallback> get _shortcuts => {
    for (final (key, tag) in [
      (LogicalKeyboardKey.keyB, 'b'),
      (LogicalKeyboardKey.keyI, 'i'),
      (LogicalKeyboardKey.keyU, 'u'),
    ]) ...{
      SingleActivator(key, control: true): () => _toggle(tag),
      SingleActivator(key, meta: true): () => _toggle(tag),
    },
  };

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        if (_toolbarReady)
          ComponentToolbar(controller: _controller, focusNode: _focusNode)
        else
          const SizedBox(height: _toolbarHeight),
        const SizedBox(height: 8),
        CallbackShortcuts(
          bindings: _shortcuts,
          child: MiniMessageField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            multiline: widget.multiline,
            validator: widget.validator,
            onSubmitted: widget.onSubmitted,
          ),
        ),
      ],
    );
  }
}
