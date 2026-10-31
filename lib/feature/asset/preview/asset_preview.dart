import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_controller.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_view.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A 3D preview of a model, with reset, auto-rotate and detail controls stacked
/// in the top right corner of the viewport.
///
/// [scene] is the JSON the viewer draws (see `web/asset_viewer.js`). [unsupported]
/// names the parts that are not drawn; they are listed under the preview.
/// Pass a [controller] to read or drive the controls; otherwise the preview keeps its own.
/// [viewportFrame] wraps only the 3D viewport, so a caller can put a surface behind
/// the viewport; the controls sit on their own surface in the page's theme.
class AssetPreview extends StatefulWidget {
  const AssetPreview({
    required this.scene,
    required this.assetKey,
    this.unsupported = const [],
    this.controller,
    this.viewportFrame,
    super.key,
  });

  final Map<String, Object?> scene;
  final String assetKey;
  final List<String> unsupported;
  final AssetPreviewController? controller;
  final Widget Function(Widget viewport)? viewportFrame;

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
    final controller = _controller;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 320,
          child: Stack(
            children: [
              // The viewport listens to the controller itself, so a change of
              // the controls does not rebuild it.
              Positioned.fill(
                child: _frame(
                  AssetPreviewViewport(
                    scene: widget.scene,
                    assetKey: widget.assetKey,
                    controller: controller,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) => _Toolbar(controller: controller),
                ),
              ),
            ],
          ),
        ),
        if (widget.unsupported.isNotEmpty)
          Text(
            l10n.asset_preview_unsupported(widget.unsupported.join(', ')),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  Widget _frame(Widget viewport) => widget.viewportFrame?.call(viewport) ?? viewport;
}

/// The preview controls, top to bottom: reset view, auto-rotate, reduced detail.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller});

  final AssetPreviewController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduced = controller.detail == AssetDetail.reduced;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 1,
      borderRadius: BorderRadius.circular(AppShapes.medium),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            IconButton(
              tooltip: l10n.asset_preview_reduced_detail,
              isSelected: reduced,
              icon: const Icon(Icons.layers_outlined),
              selectedIcon: const Icon(Icons.layers),
              onPressed: () => controller.setDetail(
                reduced ? AssetDetail.automatic : AssetDetail.reduced,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
