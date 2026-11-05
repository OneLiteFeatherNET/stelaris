import 'package:dio/dio.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/client/pack_meta_client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// A [PackMetaClientApi] that never touches dio: on the web a faked dio
/// request doesn't finish in the fake time of a widget test, which a request
/// started in `initState` would leave pending.
///
/// Keeps the resource pack meta in memory and records what was sent.
class FakePackMetaApi implements PackMetaClientApi {
  FakePackMetaApi({this.stored, this.failLoad = false, this.failPuts = 0});

  PackMeta? stored;
  final bool failLoad;

  /// How many of the next puts fail with a 500, without being recorded.
  int failPuts;
  final List<PackMeta> puts = [];
  final List<PackType> deletes = [];

  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<PackMeta> get(String projectId, PackType packType) async {
    final options = RequestOptions(path: '/pack-meta');
    if (failLoad) {
      throw DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 500),
      );
    }
    final meta = stored;
    if (meta == null) {
      throw DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 404),
      );
    }
    return meta;
  }

  @override
  Future<PackMeta> put(String projectId, PackMeta meta) async {
    if (failPuts > 0) {
      failPuts--;
      final options = RequestOptions(path: '/pack-meta');
      throw DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 500),
      );
    }
    puts.add(meta);
    return stored = meta.copyWith(id: 'meta-1', projectId: projectId);
  }

  @override
  Future<PackMeta> delete(String projectId, PackType packType) async {
    deletes.add(packType);
    final meta = stored!;
    stored = null;
    return meta;
  }

  @override
  Future<List<PackMeta>> getAll(String projectId) async => [?stored];
}
