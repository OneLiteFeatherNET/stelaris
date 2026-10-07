import 'package:material_ui/material_ui.dart';

/// Stands in for a line of text while it loads: a rounded bar of
/// [widthFactor] of the available width and [height].
///
/// Placeholders are built from these in the shape of what they stand in
/// for, so the layout doesn't jump once the data is there.
class SkeletonBar extends StatelessWidget {
  const SkeletonBar({
    required this.widthFactor,
    required this.height,
    super.key,
  });

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
