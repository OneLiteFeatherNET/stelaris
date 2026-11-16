import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';

/// The red delete button of a card. What it deletes and how it asks first
/// is up to [onPressed].
class DeleteIconButton extends StatelessWidget {
  const DeleteIconButton({required this.onPressed, this.tooltip, super.key});

  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: tooltip, icon: deleteIcon, onPressed: onPressed);
}
