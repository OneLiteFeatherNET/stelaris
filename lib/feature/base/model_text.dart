import 'package:flutter/material.dart';

/// The [TextWidget] is a simple widget implementation that displays a [Text]
/// which is given via a parameter.
class TextWidget extends StatelessWidget {
  const TextWidget({required this.displayName, super.key});

  final String displayName;

  /// Creates a [Text] widget with the provided [displayName].
  @override
  Widget build(BuildContext context) {
    return Text(displayName, overflow: TextOverflow.ellipsis);
  }
}
