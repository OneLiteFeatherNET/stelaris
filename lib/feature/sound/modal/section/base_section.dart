import 'package:flutter/material.dart';

/// A foundational container widget that provides consistent visual styling
/// for grouped content sections throughout the application.
///
/// `BaseSection` serves as a reusable building block for creating visually
/// cohesive sections with standardized appearance. It applies a consistent
/// background color, rounded corners, and internal padding to any child widget,
/// making it ideal for forms, settings panels, content cards, and other
/// grouped UI elements.
///
/// The widget automatically adapts to the current theme, using the
/// `surfaceContainerHighest` color from the Material 3 color scheme to
/// ensure proper contrast and accessibility across different themes.
///
/// ## Usage
///
/// ```dart
/// BaseSection(
///   child: Column(
///     children: [
///       Text('Section Title'),
///       // Other section content...
///     ],
///   ),
/// )
/// ```
/// See also:
///
/// * [Container], the underlying widget used for styling
/// * [Material], for more complex surface styling needs
/// * [Card], for elevated content sections
class BaseSection extends StatelessWidget {
  /// Creates a styled container section with consistent visual appearance.
  ///
  /// The [child] parameter is required and represents the content to be
  /// displayed within the styled container.
  ///
  /// ```dart
  /// BaseSection(
  ///   child: Text('Hello, World!'),
  /// )
  /// ```
  const BaseSection({
    required this.child,
    super.key,
  });

  /// The widget to be displayed inside the styled container.
  ///
  /// This can be any widget - from simple text to complex layouts.
  /// The child will be wrapped with consistent padding and background styling.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Extract the surface variant color from the current theme
    // This ensures the section adapts to light/dark themes automatically
    final surfaceVariant = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      decoration: BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}