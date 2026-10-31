import 'dart:js_interop';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/picker/pick_asset_file_web.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';
import 'package:web/web.dart' as web;

/// Takes a file dropped anywhere on the page while it is shown, which suits
/// a dialog: the page behind it can't take the file anyway.
///
/// [builder] learns whether a file is dragged over the page, to highlight
/// where it goes. [onDrop] gets the file while it is still being read. A
/// disabled target still keeps the browser from opening the dropped file.
class AssetFileDropTarget extends StatefulWidget {
  const AssetFileDropTarget({
    required this.onDrop,
    required this.builder,
    this.enabled = true,
    super.key,
  });

  final ValueChanged<Future<PickedAssetFile>> onDrop;
  final Widget Function(BuildContext context, bool dragging) builder;
  final bool enabled;

  @override
  State<AssetFileDropTarget> createState() => _AssetFileDropTargetState();
}

class _AssetFileDropTargetState extends State<AssetFileDropTarget> {
  /// Enters minus leaves: the events come for every element the drag
  /// crosses, so only the balance tells whether it is still over the page.
  int _depth = 0;

  late final JSFunction _onEnter = _onDragEnter.toJS;
  late final JSFunction _onOver = _onDragOver.toJS;
  late final JSFunction _onLeave = _onDragLeave.toJS;
  late final JSFunction _onDropped = _onDrop.toJS;

  @override
  void initState() {
    super.initState();
    web.window
      ..addEventListener('dragenter', _onEnter)
      ..addEventListener('dragover', _onOver)
      ..addEventListener('dragleave', _onLeave)
      ..addEventListener('drop', _onDropped);
  }

  @override
  void dispose() {
    web.window
      ..removeEventListener('dragenter', _onEnter)
      ..removeEventListener('dragover', _onOver)
      ..removeEventListener('dragleave', _onLeave)
      ..removeEventListener('drop', _onDropped);
    super.dispose();
  }

  static bool _carriesFiles(web.DragEvent event) =>
      event.dataTransfer?.types.toDart.any((type) => type.toDart == 'Files') ??
      false;

  void _setDepth(int depth) {
    if (mounted && depth != _depth) setState(() => _depth = depth);
  }

  void _onDragEnter(web.DragEvent event) {
    if (!_carriesFiles(event)) return;
    event.preventDefault();
    _setDepth(_depth + 1);
  }

  void _onDragOver(web.DragEvent event) {
    if (!_carriesFiles(event)) return;
    // Without this the browser doesn't fire a drop.
    event.preventDefault();
    event.dataTransfer?.dropEffect = widget.enabled ? 'copy' : 'none';
  }

  void _onDragLeave(web.DragEvent event) {
    if (!_carriesFiles(event)) return;
    _setDepth(_depth > 0 ? _depth - 1 : 0);
  }

  void _onDrop(web.DragEvent event) {
    if (!_carriesFiles(event)) return;
    // Otherwise the browser leaves the app to open the file.
    event.preventDefault();
    _setDepth(0);
    final file = event.dataTransfer?.files.item(0);
    if (widget.enabled && file != null) widget.onDrop(readAssetFile(file));
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.enabled && _depth > 0);
}
