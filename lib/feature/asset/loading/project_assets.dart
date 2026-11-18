import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/asset/loading/asset_library.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Loads the models and textures of one project, and the texture keys each
/// model file refers to, for the asset pages.
///
/// The lists come first, the references a moment later: every model file is
/// read for them. A load that ends after a newer one is ignored. The assets
/// are loaded again when the app resumes, e.g. when the browser tab regains
/// focus, so assets saved elsewhere are seen; a page that loads more than the
/// assets passes its own load as `onResume`.
class ProjectAssets extends ChangeNotifier {
  ProjectAssets({
    required this.library,
    required this.projectId,
    this.onReloadFailed,
    Future<void> Function()? onResume,
  }) {
    _lifecycle = AppLifecycleListener(onResume: onResume ?? load);
  }

  final AssetLibrary library;
  final String projectId;

  /// Told when a reload fails while a list is shown; the list is kept.
  final ValueChanged<ProblemDetail>? onReloadFailed;

  late final AppLifecycleListener _lifecycle;

  List<AssetModel> _models = const [];
  List<AssetModel> _textures = const [];
  Map<AssetModel, Set<String>> _references = const {};
  bool _referencesLoaded = false;
  bool _loading = true;
  ProblemDetail? _loadError;
  bool _listed = false;
  bool _disposed = false;

  /// Counts the loads, so a load that ends after a newer one is ignored.
  int _loadId = 0;

  /// The MODEL and BBMODEL assets, sorted by key.
  List<AssetModel> get models => _models;

  /// The TEXTURE assets, in the order the backend lists them.
  List<AssetModel> get textures => _textures;

  /// The texture keys of every MODEL asset whose file could be read.
  Map<AssetModel, Set<String>> get references => _references;

  /// Whether [references] belong to the current load.
  bool get referencesLoaded => _referencesLoaded;

  bool get loading => _loading;

  /// Why the first load failed; null once a list was shown.
  ProblemDetail? get loadError => _loadError;

  /// Whether a list was loaded once, so a reload keeps it on screen.
  bool get listed => _listed;

  Future<void> load() async {
    final loadId = ++_loadId;
    _referencesLoaded = false;
    if (!_listed) {
      _loading = true;
      _loadError = null;
      _notify();
    }
    final List<List<AssetModel>> lists;
    try {
      lists = await Future.wait([
        library.assetsOf(projectId, AssetKind.MODEL),
        library.assetsOf(projectId, AssetKind.BBMODEL),
        library.assetsOf(projectId, AssetKind.TEXTURE),
      ]);
    } on DioException catch (error) {
      if (_disposed || loadId != _loadId) return;
      final problem = ProblemDetail.fromDioException(error);
      _loading = false;
      if (_listed) {
        onReloadFailed?.call(problem);
      } else {
        _loadError = problem;
      }
      _notify();
      return;
    }
    if (_disposed || loadId != _loadId) return;
    _models = [...lists[0], ...lists[1]]
      ..sort((a, b) => a.key.compareTo(b.key));
    _textures = lists[2];
    _loading = false;
    _listed = true;
    _notify();

    final references = <AssetModel, Set<String>>{};
    for (final model in _models) {
      if (model.kind != AssetKind.MODEL) continue;
      try {
        references[model] = await library.textureKeysOf(projectId, model);
      } on Object {
        // A file that can't be read has no textures to count; its preview
        // says what is wrong.
      }
    }
    if (_disposed || loadId != _loadId) return;
    _references = references;
    _referencesLoaded = true;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _lifecycle.dispose();
    super.dispose();
  }
}
