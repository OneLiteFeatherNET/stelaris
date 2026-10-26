import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_controller.dart';
import 'package:stelaris/feature/asset/preview/asset_preview_placeholder.dart';
import 'package:web/web.dart' as web;

// The bridge in web/asset_viewer.js. It is loaded as a module, so it may appear
// a moment after the Flutter app starts; the promise tells when it is ready.
@JS('stelarisAssetViewer')
external JSAny? get _viewerApi;

@JS('stelarisAssetViewerReady')
external JSAny? get _viewerReady;

extension type _AssetViewerApi._(JSObject _) implements JSObject {
  external _ViewerHandle mount(web.HTMLElement element, JSObject scene);
}

extension type _ViewerHandle._(JSObject _) implements JSObject {
  external void setDetail(JSAny? level);
  external void setAutoRotate(JSBoolean enabled);
  external void resetView();
  external void dispose();
}

/// Mounts the three.js viewer in a div and keeps it in step with [controller].
class AssetPreviewViewport extends StatefulWidget {
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
  State<AssetPreviewViewport> createState() => _AssetPreviewViewportState();
}

class _AssetPreviewViewportState extends State<AssetPreviewViewport> {
  web.HTMLElement? _element;
  _ViewerHandle? _handle;
  bool _viewerMissing = false;
  // Bumped on every unmount, so a mount that is still waiting for the bridge gives up.
  int _generation = 0;
  int _appliedResets = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_applyCommands);
  }

  @override
  void didUpdateWidget(covariant AssetPreviewViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_applyCommands);
      widget.controller.addListener(_applyCommands);
    }
    if (!identical(oldWidget.scene, widget.scene)) {
      _unmount();
      _mount();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_applyCommands);
    _unmount();
    super.dispose();
  }

  void _onElementCreated(Object element) {
    _element = element as web.HTMLElement;
    _mount();
  }

  Future<void> _mount() async {
    final generation = _generation;
    final loaded = await _awaitViewer();
    if (!mounted || generation != _generation || _element == null) return;
    if (!loaded) {
      setState(() => _viewerMissing = true);
      return;
    }
    final api = _viewerApi! as _AssetViewerApi;
    _handle = api.mount(_element!, widget.scene.jsify()! as JSObject);
    _applyCommands();
  }

  /// Waits for the bridge module. Resolves to false when the page has no bridge.
  Future<bool> _awaitViewer() async {
    final ready = _viewerReady;
    if (ready == null || ready.isUndefinedOrNull) return false;
    await (ready as JSPromise<JSAny?>).toDart;
    return !_viewerApi.isUndefinedOrNull;
  }

  void _unmount() {
    _generation++;
    _handle?.dispose();
    _handle = null;
  }

  void _applyCommands() {
    final handle = _handle;
    if (handle == null) return;
    final controller = widget.controller;
    handle.setDetail(controller.detail.viewerLevel?.toJS);
    handle.setAutoRotate(controller.autoRotate.toJS);
    if (controller.resetRequests != _appliedResets) {
      _appliedResets = controller.resetRequests;
      handle.resetView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_viewerMissing) return AssetPreviewPlaceholder(assetKey: widget.assetKey);
    return HtmlElementView.fromTagName(
      tagName: 'div',
      onElementCreated: _onElementCreated,
    );
  }
}
