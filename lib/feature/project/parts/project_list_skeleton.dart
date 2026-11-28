import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/base/skeleton_bar.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Stands in for the project list and its buttons while the projects load.
///
/// Shaped like the list, so the card keeps its height once the projects are
/// there instead of the whole page jumping into place.
class ProjectListSkeleton extends StatelessWidget {
  const ProjectListSkeleton({super.key});

  /// How many project rows the placeholder shows.
  static const int rows = 3;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
    );

    return Semantics(
      label: context.l10n.project_selection_loading_label,
      container: true,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppShapes.medium),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < rows; i++) ...[
                    if (i > 0) divider,
                    const _SkeletonRow(),
                  ],
                ],
              ),
            ),
            verticalSpacing25,
            const Row(
              children: [
                Expanded(child: _SkeletonButton()),
                horizontalSpacing10,
                Expanded(child: _SkeletonButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A project row: the pack icon, the name and the description.
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: TextureThumbnail.size,
            height: TextureThumbnail.size,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppShapes.small),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBar(widthFactor: 0.5, height: 14),
                SizedBox(height: 8),
                SkeletonBar(widthFactor: 0.8, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the two buttons below the list.
class _SkeletonButton extends StatelessWidget {
  const _SkeletonButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppShapes.full),
      ),
    );
  }
}
