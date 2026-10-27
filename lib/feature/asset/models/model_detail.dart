import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/asset_scene_view.dart';
import 'package:stelaris/feature/asset/models/model_textures.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The detail of one model on the Models page: its key, the 3D preview and
/// its textures.
class ModelDetail extends StatelessWidget {
  const ModelDetail({
    required this.projectId,
    required this.model,
    required this.textures,
    super.key,
  });

  final String projectId;
  final AssetModel model;
  final ModelTextures textures;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          model.key,
          key: const Key('model_detail_title'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        AssetSceneView(
          key: ValueKey(model.sha1),
          projectId: projectId,
          asset: model,
          viewportFrame: _darkSurface,
        ),
      ],
    );
  }

  /// Puts the viewport on the dark preview surface; the controls stay on the page.
  Widget _darkSurface(Widget viewport) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: previewBackground,
      borderRadius: BorderRadius.circular(AppShapes.extraSmall),
      border: Border.all(color: previewBorder),
    ),
    child: viewport,
  );
}
