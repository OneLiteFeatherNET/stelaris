import 'package:material_ui/material_ui.dart';

import 'package:stelaris/feature/build/version_group_selection.dart';

class VersionUpdateInput extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool highlight;
  final VersionPart? highlightedPart;

  const VersionUpdateInput({
    required this.labelText,
    required this.controller,
    this.highlight = false,
    this.highlightedPart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If we have a highlighted part and the text follows X.Y.Z format
    if (highlightedPart != null && controller.text.split('.').length == 3) {
      final parts = controller.text.split('.');
      final TextStyle baseStyle =
          theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ) ??
          TextStyle(color: theme.colorScheme.onSurface);
      final TextStyle highlightStyle = baseStyle.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      );

      return InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          enabledBorder: highlight
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                )
              : const OutlineInputBorder(),
          filled: true,
          labelStyle: highlight
              ? TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                )
              : null,
        ),
        child: RichText(
          text: TextSpan(
            style: baseStyle,
            children: [
              TextSpan(
                text: parts[0],
                style: highlightedPart == VersionPart.major
                    ? highlightStyle
                    : null,
              ),
              const TextSpan(text: '.'),
              TextSpan(
                text: parts[1],
                style: highlightedPart == VersionPart.minor
                    ? highlightStyle
                    : null,
              ),
              const TextSpan(text: '.'),
              TextSpan(
                text: parts[2],
                style: highlightedPart == VersionPart.patch
                    ? highlightStyle
                    : null,
              ),
            ],
          ),
        ),
      );
    }

    // Fallback behavior
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        enabledBorder: highlight
            ? OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              )
            : const OutlineInputBorder(),
        filled: true,
        labelStyle: highlight
            ? TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              )
            : null,
      ),
      enabled: false,
      controller: controller,
      style: theme.textTheme.bodyLarge,
    );
  }
}
