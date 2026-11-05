import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/client/asset_client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_asset_api.dart';
import '../../../support/recording_http_client_adapter.dart';

void main() {
  late ApiClient apiClient;
  late AssetClientApi assetApi;

  setUp(() {
    apiClient = ApiClient('http://backend.test/api');
    assetApi = AssetClientApi(apiClient: apiClient);
  });

  group('delete', () {
    test('DELETEs the asset by its id', () async {
      final adapter = RecordingHttpClientAdapter(
        assetJson(id: 'a-1', key: 'proj:pack/icon', kind: 'TEXTURE'),
      );
      apiClient.dio.httpClientAdapter = adapter;

      final result = await assetApi.delete('p-1', 'a-1');

      expect(adapter.lastRequest!.method, 'DELETE');
      expect(
        adapter.lastRequest!.uri.path,
        '/api/project/p-1/asset/delete/a-1',
      );
      expect(result.id, 'a-1');
      expect(result.kind, AssetKind.TEXTURE);
    });
  });
}
