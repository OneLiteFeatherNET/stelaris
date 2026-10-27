import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/client/asset_client_api.dart';
import 'package:stelaris/feature/asset/scene/asset_scene.dart';
import 'package:stelaris/feature/asset/scene/blockbench_model_reader.dart';
import 'package:stelaris/feature/asset/scene/detail_levels.dart';
import 'package:stelaris/feature/asset/scene/minecraft_model_reader.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The drawable scene of one model asset, ready for the JS bridge, and the parts it leaves out.
class AssetSceneData {
  const AssetSceneData({required this.scene, required this.unsupported});

  /// The contract JSON of `AssetScene.toJson` with the three detail levels.
  final Map<String, Object?> scene;

  /// Parts of the model that are not drawn, e.g. `mesh: Sword blade`.
  final List<String> unsupported;
}

/// Finds the model assets of a project by key and loads them as scenes.
///
/// Lookups and texture indexes are read from the backend on every call, so a model saved again
/// under the same key is seen at once. Downloaded contents are cached in memory for the lifetime
/// of the instance, by the asset's sha1: a sha1 names one content, so a cached content is never
/// stale.
class AssetLibrary {
  AssetLibrary(this._assets);

  /// The library of the running app, backed by the shared [ApiService].
  static final AssetLibrary shared = AssetLibrary(ApiService().assetApi);

  static const int _defaultTextureSize = 16;

  final AssetClientApi _assets;

  final Map<String, Future<List<int>>> _contents = {};

  /// Returns the MODEL or BBMODEL asset of [projectId] whose key equals [key] exactly, or null.
  ///
  /// A TEXTURE with the same key does not count.
  Future<AssetModel?> findModelByKey(String projectId, String key) async {
    for (final kind in const [AssetKind.MODEL, AssetKind.BBMODEL]) {
      final match = await _firstOnPages(
        projectId,
        kind: kind,
        where: (asset) => asset.key == key,
      );
      if (match != null) {
        return match;
      }
    }
    return null;
  }

  /// Loads the model [asset] of [projectId] as a scene.
  ///
  /// Throws a [FormatException] when the stored file is not a JSON object.
  Future<AssetSceneData> loadScene(String projectId, AssetModel asset) async {
    final json = _decodeModel(asset, await _bytes(projectId, asset));
    switch (asset.kind) {
      case AssetKind.BBMODEL:
        final scene = readBlockbenchModel(json);
        return _sceneData(scene);
      case AssetKind.MODEL:
        final textures = await _modelTextures(projectId, json);
        final scene = readMinecraftModel(json, texture: (key) => textures[key]);
        return _sceneData(scene);
      case AssetKind.TEXTURE:
        throw ArgumentError.value(
          asset.kind,
          'asset.kind',
          '${asset.key} is a texture, not a model',
        );
    }
  }

  /// Walks the pages of [kind] until [where] matches or the last page has been read.
  Future<AssetModel?> _firstOnPages(
    String projectId, {
    required AssetKind kind,
    required bool Function(AssetModel asset) where,
  }) async {
    var page = 0;
    while (true) {
      final result = await _assets.getPage(projectId, kind: kind, page: page);
      for (final asset in result.items) {
        if (where(asset)) {
          return asset;
        }
      }
      page++;
      if (result.items.isEmpty || page >= result.totalPages) {
        return null;
      }
    }
  }

  Future<Map<String, AssetModel>> _textureIndex(String projectId) async {
    final index = <String, AssetModel>{};
    var page = 0;
    while (true) {
      final result = await _assets.getPage(
        projectId,
        kind: AssetKind.TEXTURE,
        page: page,
      );
      for (final asset in result.items) {
        index.putIfAbsent(asset.key, () => asset);
      }
      page++;
      if (result.items.isEmpty || page >= result.totalPages) {
        return index;
      }
    }
  }

  /// Loads the texture assets that [json] refers to, keyed by their namespaced key.
  Future<Map<String, SceneTexture>> _modelTextures(
    String projectId,
    Map<String, Object?> json,
  ) async {
    final keys = referencedTextureKeys(json);
    if (keys.isEmpty) {
      return const {};
    }
    final index = await _textureIndex(projectId);
    final textures = <String, SceneTexture>{};
    for (final key in keys) {
      final asset = index[key];
      if (asset == null) {
        continue;
      }
      final bytes = await _bytes(projectId, asset);
      textures[key] = SceneTexture(
        id: 't${textures.length}',
        dataUri: 'data:image/png;base64,${base64Encode(bytes)}',
        width: asset.width ?? _defaultTextureSize,
        height: asset.height ?? _defaultTextureSize,
      );
    }
    return textures;
  }

  /// Drops every downloaded content, so a test does not see the contents of
  /// another test through [shared].
  @visibleForTesting
  void clearContents() => _contents.clear();

  Future<List<int>> _bytes(String projectId, AssetModel asset) =>
      _memo(_contents, asset.sha1, () => _assets.content(projectId, asset.id));

  AssetSceneData _sceneData(AssetScene scene) => AssetSceneData(
    scene: scene.toJson(detailLevels(scene)),
    unsupported: scene.unsupported,
  );

  Map<String, Object?> _decodeModel(AssetModel asset, List<int> bytes) {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on FormatException catch (error) {
      throw FormatException(
        'Asset ${asset.key} is not valid JSON: ${error.message}',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw FormatException('Asset ${asset.key} is not a JSON object');
    }
    return decoded;
  }
}

/// Returns the future cached under [key], or starts [load] and caches it.
///
/// A failed load is removed from the cache, so the next call tries again.
Future<T> _memo<K, T>(
  Map<K, Future<T>> cache,
  K key,
  Future<T> Function() load,
) {
  final cached = cache[key];
  if (cached != null) {
    return cached;
  }
  final future = load();
  cache[key] = future;
  future.then<void>(
    (_) {},
    onError: (Object _) {
      if (identical(cache[key], future)) {
        cache.remove(key);
      }
    },
  );
  return future;
}
