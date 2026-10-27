import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/models/model_textures.dart';
import 'package:stelaris_models/stelaris_models.dart';

AssetModel _asset(
  String id,
  String key,
  AssetKind kind, {
  String? sourceAssetId,
}) => AssetModel(
  id: id,
  projectId: 'p-1',
  key: key,
  kind: kind,
  fileName: '$id.bin',
  contentType: 'application/octet-stream',
  size: 1,
  sha1: 'sha-$id',
  sourceAssetId: sourceAssetId,
);

void main() {
  final ruby = _asset('m1', 'vulpes:item/ruby', AssetKind.MODEL);
  final sword = _asset('m2', 'vulpes:item/sword', AssetKind.MODEL);
  final gem = _asset('t1', 'vulpes:block/gem', AssetKind.TEXTURE);
  final rubyTexture = _asset('t2', 'vulpes:item/ruby', AssetKind.TEXTURE);

  group('modelTextures for a model JSON', () {
    test('marks referenced keys as present or missing', () {
      final result = modelTextures(
        ruby,
        references: {
          ruby: {'vulpes:block/gem', 'vulpes:item/ruby_glow'},
        },
        textures: [gem],
      );

      expect(result.readOnly, isFalse);
      expect(result.slots.map((slot) => slot.key), [
        'vulpes:block/gem',
        'vulpes:item/ruby_glow',
      ]);
      expect(result.slots.first.texture, gem);
      expect(result.slots.last.missing, isTrue);
      expect(result.missingCount, 1);
    });

    test('a texture with the model key counts, the model itself does not', () {
      final result = modelTextures(
        ruby,
        references: {
          ruby: {'vulpes:item/ruby'},
        },
        textures: [rubyTexture],
      );

      expect(result.slots.single.texture, rubyTexture);
      expect(result.missingCount, 0);
    });

    test('names the other models using a key, never the model itself', () {
      final result = modelTextures(
        ruby,
        references: {
          ruby: {'vulpes:block/gem'},
          sword: {'vulpes:block/gem', 'vulpes:item/blade'},
        },
        textures: [gem],
      );

      expect(result.slots.single.alsoIn, [sword]);
    });

    test('a model whose references are not known yet has no slots', () {
      final result = modelTextures(ruby, references: {}, textures: [gem]);

      expect(result.slots, isEmpty);
      expect(result.missingCount, 0);
    });
  });

  group('modelTextures for a Blockbench model', () {
    test('lists the extracted textures read-only', () {
      final bbmodel = _asset('b1', 'vulpes:item/axe', AssetKind.BBMODEL);
      final embedded = _asset(
        't3',
        'vulpes:item/axe_0',
        AssetKind.TEXTURE,
        sourceAssetId: 'b1',
      );

      final result = modelTextures(
        bbmodel,
        references: {},
        textures: [gem, embedded],
      );

      expect(result.readOnly, isTrue);
      expect(result.slots.single.texture, embedded);
      expect(result.missingCount, 0);
    });
  });
}
