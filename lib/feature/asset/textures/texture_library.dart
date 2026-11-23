import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris/feature/asset/loading/project_assets.dart';
import 'package:stelaris/feature/asset/textures/texture_usage_sources.dart';
import 'package:stelaris/feature/asset/textures/texture_usages.dart';
import 'package:stelaris/util/bytes.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The textures of one project with where each is used, for the textures
/// page and the texture picker.
///
/// Loads the [ProjectAssets] and the fonts and pack metas that refer to
/// textures side by side; the uses are known once both are in. The sources
/// can be loaded again alone after they failed. Notifies whenever the
/// assets or the sources change.
class TextureLibrary extends ChangeNotifier {
  TextureLibrary({
    required this.library,
    required this.projectId,
    required this.loadUsageSources,
    ValueChanged<ProblemDetail>? onReloadFailed,
  }) {
    assets = ProjectAssets(
      library: library,
      projectId: projectId,
      onReloadFailed: onReloadFailed,
      onResume: load,
    )..addListener(_onAssetsChanged);
  }

  final AssetLibrary library;
  final String projectId;

  /// Loads the fonts and pack metas that refer to textures, for the uses.
  final Future<TextureUsageSources> Function(String projectId) loadUsageSources;

  /// The models and textures of the project.
  late final ProjectAssets assets;

  /// The bytes of the textures shown as thumbnails, by their sha1, so a
  /// rebuild doesn't load them again.
  final Map<String, Future<Uint8List>> _thumbnails = {};

  /// The fonts and pack metas of the current load, null while they load.
  TextureUsageSources? _sources;
  bool _sourcesFailed = false;

  /// Counts the loads of [_sources], so an older one ending last is ignored.
  int _sourcesLoadId = 0;

  /// Where the textures are used, built once everything it needs has loaded
  /// and dropped whenever the assets or [_sources] change.
  TextureUsageIndex? _index;

  bool _disposed = false;

  /// The TEXTURE assets, in the order the backend lists them.
  List<AssetModel> get textures => assets.textures;

  /// Whether the fonts and pack metas for the uses could not be loaded.
  bool get usagesFailed => _sourcesFailed;

  /// Loads the assets and the sources of the uses.
  Future<void> load() async {
    final sources = loadSources();
    await assets.load();
    await sources;
  }

  /// Loads the fonts and pack metas for the uses, also alone after they
  /// failed. A reload keeps the uses shown until its own sources are in,
  /// and keeps them when it fails.
  Future<void> loadSources() async {
    final loadId = ++_sourcesLoadId;
    if (_sources == null) {
      _sourcesFailed = false;
      _notify();
    }
    TextureUsageSources? loaded;
    try {
      loaded = await loadUsageSources(projectId);
    } on Object {
      loaded = null;
    }
    if (_disposed || loadId != _sourcesLoadId) return;
    if (loaded == null && _sources != null) return;
    _sources = loaded;
    _sourcesFailed = loaded == null;
    _index = null;
    _notify();
  }

  /// Whether the uses of every texture are known.
  bool get usagesLoaded => _usageIndex != null;

  /// Where [texture] is used, null until everything it needs has loaded.
  TextureUsages? usagesOf(AssetModel texture) => _usageIndex?.of(texture);

  TextureUsageIndex? get _usageIndex {
    final sources = _sources;
    if (sources == null || !assets.referencesLoaded) return null;
    return _index ??= TextureUsageIndex(
      models: assets.models,
      textures: assets.textures,
      references: assets.references,
      fonts: sources.fonts,
      packMetas: sources.packMetas,
    );
  }

  /// The model [texture] was extracted from, null for an uploaded one.
  AssetModel? sourceOf(AssetModel texture) {
    final sourceId = texture.sourceAssetId;
    if (sourceId == null) return null;
    for (final model in assets.models) {
      if (model.id == sourceId) return model;
    }
    return null;
  }

  /// The bytes of [texture], loaded once per file. A failed load is
  /// forgotten, so the next build after a reload tries again.
  Future<Uint8List> thumbnailOf(AssetModel texture) {
    final sha1 = texture.sha1;
    return _thumbnails.putIfAbsent(sha1, () async {
      try {
        return asUint8List(await library.contentOf(projectId, texture));
      } on Object {
        _thumbnails.remove(sha1);
        rethrow;
      }
    });
  }

  void _onAssetsChanged() {
    _index = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    assets
      ..removeListener(_onAssetsChanged)
      ..dispose();
    super.dispose();
  }
}
