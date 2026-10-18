import 'package:material_ui/material_ui.dart';

/// A search input at the top of a dialog, styled like the app bar search: a
/// flat bar on the surface with an outline that turns primary on focus.
class DialogSearchBar extends StatelessWidget {
  const DialogSearchBar({
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.focusNode,
    this.trailing,
    this.onSubmitted,
    super.key,
  });

  /// The height of the bar, lower than a [SearchBar] by default.
  static const double height = 44;

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Shown at the end of the bar, e.g. a filter menu.
  final Iterable<Widget>? trailing;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SearchBar(
      controller: controller,
      focusNode: focusNode,
      autoFocus: true,
      hintText: hintText,
      leading: const Icon(Icons.search),
      trailing: trailing,
      elevation: const WidgetStatePropertyAll(0),
      constraints: const BoxConstraints(minHeight: height, maxHeight: height),
      backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
      side: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.only(left: 12, right: 6),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
