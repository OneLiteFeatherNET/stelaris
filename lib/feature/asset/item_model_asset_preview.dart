import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/asset_model.dart';
import 'package:stelaris/feature/asset/preview/asset_scene_view.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Shows the 3D preview of the item model [asset] on the lore preview's
/// surface, next to the component cards or in a bottom sheet.
///
/// Fills the height it is given. The caller finds the asset and decides
/// whether there is room for the panel.
class ItemModelPreview extends StatelessWidget {
  const ItemModelPreview({
    required this.projectId,
    required this.asset,
    super.key,
  });

  final String projectId;
  final AssetModel asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.preview_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.item_model_preview_title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: AssetSceneView(
            projectId: projectId,
            asset: asset,
            viewportFrame: _darkSurface,
          ),
        ),
      ],
    );
  }

  /// Puts the viewport on the dark preview surface; the controls stay on the page.
  Widget _darkSurface(Widget viewport) => Container(
    key: const Key('item_model_preview'),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: previewBackground,
      borderRadius: BorderRadius.circular(AppShapes.extraSmall),
      border: Border.all(color: previewBorder),
    ),
    child: viewport,
  );
}
