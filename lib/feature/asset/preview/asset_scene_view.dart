import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/preview/asset_preview.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Loads the model [asset] of [projectId] and shows it in an [AssetPreview].
///
/// The scene is loaded once per widget; a failed load shows a short error.
/// [viewportFrame] is forwarded to [AssetPreview] and wraps only the viewport.
class AssetSceneView extends StatefulWidget {
  const AssetSceneView({
    required this.projectId,
    required this.asset,
    this.viewportFrame,
    super.key,
  });

  final String projectId;
  final AssetModel asset;
  final Widget Function(Widget viewport)? viewportFrame;

  @override
  State<AssetSceneView> createState() => _AssetSceneViewState();
}

class _AssetSceneViewState extends State<AssetSceneView> {
  late Future<AssetSceneData> _scene = _load();

  Future<AssetSceneData> _load() =>
      AssetLibrary.shared.loadScene(widget.projectId, widget.asset);

  @override
  void didUpdateWidget(AssetSceneView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id ||
        oldWidget.asset.sha1 != widget.asset.sha1 ||
        oldWidget.projectId != widget.projectId) {
      _scene = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssetSceneData>(
      future: _scene,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorText(context.l10n.asset_preview_failed);
        }
        final data = snapshot.data;
        if (data == null) {
          return const Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return AssetPreview(
          scene: data.scene,
          assetKey: widget.asset.key,
          unsupported: data.unsupported,
          viewportFrame: widget.viewportFrame,
        );
      },
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
