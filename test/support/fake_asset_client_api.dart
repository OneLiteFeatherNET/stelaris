import 'dart:typed_data';

import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/client/asset_client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// An [AssetClientApi] that never touches dio, like `FakePackMetaApi`: on the
/// web a faked dio request doesn't finish in the fake time of a widget test.
///
/// Keeps the assets and their bytes in memory and records what was sent.
/// Only the calls the pack icon needs are implemented.
class FakeAssetClientApi implements AssetClientApi {
  FakeAssetClientApi({Map<AssetModel, Uint8List> stored = const {}}) {
    for (final MapEntry(:key, :value) in stored.entries) {
      assets[key.id] = key;
      contents[key.id] = value;
    }
  }

  final Map<String, AssetModel> assets = {};
  final Map<String, Uint8List> contents = {};

  /// The key of each upload, in order.
  final List<String> uploads = [];

  /// The id of each asset whose content was replaced, in order.
  final List<String> replaces = [];

  /// The id of each deleted asset, in order.
  final List<String> deletes = [];

  /// When set, every content download throws it.
  Object? failContent;

  var _nextId = 1;

  /// A texture asset as the backend returns it.
  static AssetModel texture(String id, {String projectId = 'p1'}) => AssetModel(
    id: id,
    projectId: projectId,
    key: 'proj:pack/icon',
    displayName: 'Pack icon',
    kind: AssetKind.TEXTURE,
    fileName: 'pack.png',
    contentType: 'image/png',
    size: 1,
    sha1: 'sha-$id',
  );

  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<AssetModel> getById(String projectId, String id) async => assets[id]!;

  @override
  Future<List<int>> content(String projectId, String assetId) async {
    final failure = failContent;
    if (failure != null) throw failure;
    return contents[assetId]!;
  }

  @override
  Future<AssetModel> upload(
    String projectId, {
    required String key,
    required String displayName,
    required String fileName,
    required List<int> bytes,
  }) async {
    uploads.add(key);
    final asset = texture(
      'uploaded-${_nextId++}',
      projectId: projectId,
    ).copyWith(key: key, displayName: displayName, fileName: fileName);
    assets[asset.id] = asset;
    contents[asset.id] = Uint8List.fromList(bytes);
    return asset;
  }

  @override
  Future<AssetModel> replaceContent(
    AssetModel asset, {
    required String fileName,
    required List<int> bytes,
  }) async {
    replaces.add(asset.id);
    final replaced = asset.copyWith(sha1: 'sha-${asset.id}-${replaces.length}');
    assets[asset.id] = replaced;
    contents[asset.id] = Uint8List.fromList(bytes);
    return replaced;
  }

  @override
  Future<AssetModel> delete(String projectId, String assetId) async {
    deletes.add(assetId);
    contents.remove(assetId);
    return assets.remove(assetId)!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'FakeAssetClientApi does not fake ${invocation.memberName}',
  );
}
