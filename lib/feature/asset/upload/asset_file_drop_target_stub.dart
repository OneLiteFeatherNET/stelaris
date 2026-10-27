import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/picker/picked_asset_file.dart';

/// Outside the web build files can't be dropped, so nothing is ever dragged.
class AssetFileDropTarget extends StatelessWidget {
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
  Widget build(BuildContext context) => builder(context, false);
}
