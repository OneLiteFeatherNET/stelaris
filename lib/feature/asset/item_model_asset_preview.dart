import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/asset_model.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/preview/asset_scene_view.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Offers the 3D preview of the project model whose key is [assetKey].
///
/// Shows nothing while the lookup runs and when the project has no model with
/// that key, a texture with the same key doesn't count. Tapping the button
/// opens the model in a dialog.
class ItemModelPreviewButton extends StatefulWidget {
  const ItemModelPreviewButton({
    required this.projectId,
    required this.assetKey,
    super.key,
  });

  final String projectId;
  final String assetKey;

  @override
  State<ItemModelPreviewButton> createState() => _ItemModelPreviewButtonState();
}

class _ItemModelPreviewButtonState extends State<ItemModelPreviewButton> {
  late Future<AssetModel?> _model = _find();

  Future<AssetModel?> _find() =>
      AssetLibrary.shared.findModelByKey(widget.projectId, widget.assetKey);

  @override
  void didUpdateWidget(ItemModelPreviewButton oldWidget) {
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
        final asset = snapshot.data;
        if (asset == null) return const SizedBox.shrink();
        return IconButton(
          key: const Key('item_model_preview_button'),
          tooltip: context.l10n.item_model_preview_button,
          icon: const Icon(Icons.view_in_ar),
          onPressed: () => _open(context, asset),
        );
      },
    );
  }

  void _open(BuildContext context, AssetModel asset) {
    final size = MediaQuery.sizeOf(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset.key),
        content: SizedBox(
          width: math.min(560, size.width - 96),
          height: math.min(520, size.height - 200),
          child: AssetSceneView(projectId: widget.projectId, asset: asset),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.button_close),
          ),
        ],
      ),
    );
  }
}
