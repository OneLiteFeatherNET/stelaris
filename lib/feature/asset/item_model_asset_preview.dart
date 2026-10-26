import 'package:flutter/material.dart';
import 'package:stelaris/api/model/asset_model.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/preview/asset_scene_view.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Shows the project model whose key is [assetKey] as a 3D preview.
///
/// When the project has no model with that key, [fallback] is shown instead.
class ItemModelAssetPreview extends StatefulWidget {
  const ItemModelAssetPreview({
    required this.projectId,
    required this.assetKey,
    required this.fallback,
    super.key,
  });

  final String projectId;
  final String assetKey;
  final Widget fallback;

  @override
  State<ItemModelAssetPreview> createState() => _ItemModelAssetPreviewState();
}

class _ItemModelAssetPreviewState extends State<ItemModelAssetPreview> {
  late Future<AssetModel?> _model = _find();

  Future<AssetModel?> _find() =>
      AssetLibrary.shared.findModelByKey(widget.projectId, widget.assetKey);

  @override
  void didUpdateWidget(ItemModelAssetPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.assetKey != widget.assetKey) {
      _model = _find();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssetModel?>(
      future: _model,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              context.l10n.asset_preview_failed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final asset = snapshot.data;
        if (asset == null) return widget.fallback;
        return AssetSceneView(projectId: widget.projectId, asset: asset);
      },
    );
  }
}
