import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('AssetModel.fromJson', () {
    test('decodes a texture with its size and source model', () {
      final asset = AssetModel.fromJson({
        'id': '6f1c0000-0000-4000-8000-000000000001',
        'projectId': 'p-1',
        'key': 'vulpes:item/ruby',
        'kind': 'TEXTURE',
        'fileName': 'ruby.png',
        'contentType': 'image/png',
        'size': 1234,
        'sha1': 'da39a3ee5e6b4b0d3255bfef95601890afd80709',
        'width': 16,
        'height': 16,
        'sourceAssetId': '6f1c0000-0000-4000-8000-000000000002',
        'derivedAssetIds': <String>[],
        'creationDate': '2026-10-01T10:00:00Z',
        'modificationDate': '2026-10-02T11:30:00Z',
      });

      expect(asset.kind, AssetKind.TEXTURE);
      expect(asset.key, 'vulpes:item/ruby');
      expect(asset.width, 16);
      expect(asset.height, 16);
      expect(
        asset.sourceAssetId,
        '6f1c0000-0000-4000-8000-000000000002',
      );
      expect(asset.derivedAssetIds, isEmpty);
      expect(asset.creationDate, DateTime.utc(2026, 10, 1, 10));
      expect(asset.modificationDate, DateTime.utc(2026, 10, 2, 11, 30));
    });

    test('decodes a Blockbench model with its derived texture ids and null width and height', () {
      final asset = AssetModel.fromJson({
        'id': 'bb-1',
        'projectId': 'p-1',
        'key': 'vulpes:item/sword',
        'kind': 'BBMODEL',
        'fileName': 'sword.bbmodel',
        'contentType': 'application/json',
        'size': 4096,
        'sha1': 'aaaa',
        'width': null,
        'height': null,
        'sourceAssetId': null,
        'derivedAssetIds': ['tex-1', 'tex-2'],
        'creationDate': null,
        'modificationDate': null,
      });

      expect(asset.kind, AssetKind.BBMODEL);
      expect(asset.width, isNull);
      expect(asset.height, isNull);
      expect(asset.sourceAssetId, isNull);
      expect(asset.derivedAssetIds, ['tex-1', 'tex-2']);
      expect(asset.creationDate, isNull);
    });

    test('decodes a Minecraft model JSON without optional fields present', () {
      final asset = AssetModel.fromJson({
        'id': 'm-1',
        'projectId': 'p-1',
        'key': 'vulpes:item/ruby',
        'kind': 'MODEL',
        'fileName': 'ruby.json',
        'contentType': 'application/json',
        'size': 512,
        'sha1': 'bbbb',
        'derivedAssetIds': <String>[],
      });

      expect(asset.kind, AssetKind.MODEL);
      expect(asset.width, isNull);
      expect(asset.derivedAssetIds, isEmpty);
      expect(asset.modificationDate, isNull);
    });
  });
}
