import 'package:flutter/material.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_controller.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_view.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A 3D preview of a model, with reset, auto-rotate and detail controls.
///
/// [scene] is the JSON the viewer draws (see `web/asset_viewer.js`). [unsupported]
/// names the parts that are not drawn; they are listed under the preview.
/// Pass a [controller] to read or drive the controls; otherwise the preview keeps its own.
class AssetPreview extends StatefulWidget {
  const AssetPreview({
    required this.scene,
    required this.assetKey,
    this.unsupported = const [],
    this.controller,
    super.key,
  });

  final Map<String, Object?> scene;
  final String assetKey;
  final List<String> unsupported;
  final AssetPreviewController? controller;

  @override
  State<AssetPreview> createState() => _AssetPreviewState();
}

class _AssetPreviewState extends State<AssetPreview> {
  final AssetPreviewController _ownController = AssetPreviewController();

  AssetPreviewController get _controller => widget.controller ?? _ownController;

  @override
  void dispose() {
    _ownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final controller = _controller;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 320,
              child: AssetPreviewViewport(
                scene: widget.scene,
                assetKey: widget.assetKey,
                controller: controller,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  tooltip: l10n.asset_preview_reset_view,
                  icon: const Icon(Icons.restart_alt),
                  onPressed: controller.resetView,
                ),
                IconButton(
                  tooltip: l10n.asset_preview_auto_rotate,
                  isSelected: controller.autoRotate,
                  icon: const Icon(Icons.autorenew_outlined),
                  selectedIcon: const Icon(Icons.autorenew),
                  onPressed: () => controller.setAutoRotate(!controller.autoRotate),
                ),
                SegmentedButton<AssetDetail>(
                  showSelectedIcon: false,
                  segments: [
                    for (final detail in AssetDetail.values)
                      ButtonSegment(value: detail, label: Text(_detailLabel(l10n, detail))),
                  ],
                  selected: {controller.detail},
                  onSelectionChanged: (selection) => controller.setDetail(selection.single),
                ),
              ],
            ),
            if (widget.unsupported.isNotEmpty)
              Text(
                l10n.asset_preview_unsupported(widget.unsupported.join(', ')),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        );
      },
    );
  }

  String _detailLabel(AppLocalizations l10n, AssetDetail detail) => switch (detail) {
    AssetDetail.automatic => l10n.asset_preview_detail_auto,
    AssetDetail.full => l10n.asset_preview_detail_full,
    AssetDetail.reduced => l10n.asset_preview_detail_reduced,
    AssetDetail.box => l10n.asset_preview_detail_box,
  };
}
