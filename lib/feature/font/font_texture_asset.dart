import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// What is known about the texture asset of a font while it loads.
sealed class FontTextureState {
  const FontTextureState();
}

/// The font has no texture asset.
final class NoFontTexture extends FontTextureState {
  const NoFontTexture();
}

/// The texture asset is being loaded.
final class LoadingFontTexture extends FontTextureState {
  const LoadingFontTexture();
}

/// The texture asset is loaded.
final class LoadedFontTexture extends FontTextureState {
  const LoadedFontTexture(this.asset);

  final AssetModel asset;
}

/// The texture asset could not be loaded, e.g. because it was deleted.
final class MissingFontTexture extends FontTextureState {
  const MissingFontTexture();
}

/// Loads the texture asset [assetId] of [projectId] and builds with what is
/// known about it. An asset handed to [FontTextureLoaderState.remember], e.g.
/// one just picked, is shown without loading it again.
class FontTextureLoader extends StatefulWidget {
  const FontTextureLoader({
    required this.projectId,
    required this.assetId,
    required this.builder,
    super.key,
  });

  final String? projectId;
  final String? assetId;
  final Widget Function(
    BuildContext context,
    FontTextureState texture,
    FontTextureLoaderState loader,
  )
  builder;

  @override
  State<FontTextureLoader> createState() => FontTextureLoaderState();
}

class FontTextureLoaderState extends State<FontTextureLoader> {
  AssetModel? _asset;
  bool _failed = false;

  /// Counts the loads, so an answer for an older id is dropped.
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(FontTextureLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetId != widget.assetId ||
        oldWidget.projectId != widget.projectId) {
      _load();
    }
  }

  /// Shows [asset] as the texture without loading it.
  void remember(AssetModel asset) {
    _loadId++;
    setState(() {
      _asset = asset;
      _failed = false;
    });
  }

  Future<void> _load() async {
    final projectId = widget.projectId;
    final assetId = widget.assetId;
    if (assetId == null || projectId == null || _asset?.id == assetId) return;
    final loadId = ++_loadId;
    setState(() {
      _asset = null;
      _failed = false;
    });
    try {
      final asset = await ApiService().assetApi.getById(projectId, assetId);
      if (!mounted || loadId != _loadId) return;
      setState(() => _asset = asset);
    } on DioException {
      if (!mounted || loadId != _loadId) return;
      setState(() => _failed = true);
    }
  }

  FontTextureState get _state {
    final assetId = widget.assetId;
    if (assetId == null) return const NoFontTexture();
    final asset = _asset;
    if (asset != null && asset.id == assetId) return LoadedFontTexture(asset);
    return _failed ? const MissingFontTexture() : const LoadingFontTexture();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _state, this);
}
