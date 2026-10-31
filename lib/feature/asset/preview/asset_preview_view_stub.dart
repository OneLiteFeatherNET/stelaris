import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_controller.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_placeholder.dart';

/// Outside the web build there are no 3D viewers to dispose.
void disposeLeftoverAssetViewers() {}

/// Outside the web build there is no three.js viewer, so the preview is a placeholder.
class AssetPreviewViewport extends StatelessWidget {
  const AssetPreviewViewport({
    required this.scene,
    required this.assetKey,
    required this.controller,
    super.key,
  });

  final Map<String, Object?> scene;
  final String assetKey;
  final AssetPreviewController controller;

  @override
  Widget build(BuildContext context) => AssetPreviewPlaceholder(assetKey: assetKey);
}
