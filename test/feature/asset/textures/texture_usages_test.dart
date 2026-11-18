import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/textures/texture_usages.dart';
import 'package:stelaris_models/stelaris_models.dart';

AssetModel _asset(
  String id,
  String key,
  AssetKind kind, {
  String? sourceAssetId,
}) => AssetModel(
  id: id,
  projectId: 'p-1',
  displayName: 'Name of $id',
  key: key,
  kind: kind,
  fileName: '$id.json',
  contentType: 'application/json',
  size: 64,
  sha1: 'sha-$id',
  sourceAssetId: sourceAssetId,
);

final _ruby = _asset('m1', 'vulpes:item/ruby', AssetKind.MODEL);
final _sword = _asset('m2', 'vulpes:item/sword', AssetKind.MODEL);
final _axe = _asset('b1', 'vulpes:item/axe', AssetKind.BBMODEL);
final _gem = _asset('t1', 'vulpes:block/gem', AssetKind.TEXTURE);
final _gemCopy = _asset('t2', 'vulpes:block/gem', AssetKind.TEXTURE);
final _blade = _asset(
  't3',
  'vulpes:item/axe_blade',
  AssetKind.TEXTURE,
  sourceAssetId: 'b1',
);

PackMeta _meta(PackType type, String? icon) => PackMeta(
  id: 'pm-${type.name}',
  projectId: 'p-1',
  packType: type,
  description: '',
  minFormatMajor: 64,
  maxFormatMajor: 69,
  iconAssetId: icon,
);

TextureUsages _usages(
  AssetModel texture, {
  List<AssetModel> textures = const [],
  Map<AssetModel, Set<String>> references = const {},
  List<FontModel> fonts = const [],
  List<PackMeta> packMetas = const [],
}) => TextureUsageIndex(
  models: [_axe, _ruby, _sword],
  textures: textures.isEmpty ? [texture] : textures,
  references: references,
  fonts: fonts,
  packMetas: packMetas,
).of(texture);

void main() {
  test('models referring to the key', () {
    final usages = _usages(
      _gem,
      references: {
        _sword: {'vulpes:block/gem'},
        _ruby: {'vulpes:block/gem', 'vulpes:block/other'},
      },
    );

    expect(usages.models, [_ruby, _sword]);
    expect(usages.count, 2);
  });

  test('the bbmodel an extracted texture comes from', () {
    expect(_usages(_blade).models, [_axe]);
  });

  test('fonts by textureAssetId', () {
    const icons = FontModel(uiName: 'Icons', id: 'f1', textureAssetId: 't1');
    const other = FontModel(uiName: 'Other', id: 'f2', textureAssetId: 't9');

    final usages = _usages(_gem, fonts: [icons, other]);

    expect(usages.fonts, [icons]);
    expect(usages.isEmpty, isFalse);
  });

  test('pack icon by iconAssetId', () {
    final usages = _usages(
      _gem,
      packMetas: [_meta(PackType.data, 't9'), _meta(PackType.resource, 't1')],
    );

    expect(usages.packIcons, [PackType.resource]);
    expect(usages.count, 1);
  });

  test('a second texture with the same key is used by no model and names the '
      'first in sameKeyAs', () {
    final usages = _usages(
      _gemCopy,
      textures: [_gem, _gemCopy],
      references: {
        _ruby: {'vulpes:block/gem'},
      },
    );

    expect(usages.models, isEmpty);
    expect(usages.sameKeyAs, _gem);
    expect(
      _usages(
        _gem,
        textures: [_gem, _gemCopy],
        references: {
          _ruby: {'vulpes:block/gem'},
        },
      ).sameKeyAs,
      isNull,
    );
  });

  test('a texture missing from the list still owns its key', () {
    final usages = TextureUsageIndex(
      models: [_ruby],
      textures: const [],
      references: {
        _ruby: {'vulpes:block/gem'},
      },
      fonts: const [],
      packMetas: const [],
    ).of(_gem);

    expect(usages.models, [_ruby]);
    expect(usages.sameKeyAs, isNull);
  });

  test('an extracted texture also referred to by key lists both models '
      'sorted by key', () {
    final usages = _usages(
      _blade,
      references: {
        _sword: {'vulpes:item/axe_blade'},
      },
    );

    expect(usages.models, [_axe, _sword]);
  });

  test('asking twice returns the same uses', () {
    final index = TextureUsageIndex(
      models: [_ruby],
      textures: [_gem],
      references: {
        _ruby: {'vulpes:block/gem'},
      },
      fonts: const [],
      packMetas: const [],
    );

    expect(identical(index.of(_gem), index.of(_gem)), isTrue);
  });

  test('unused texture is empty with count 0', () {
    final usages = _usages(_gem);

    expect(usages.isEmpty, isTrue);
    expect(usages.count, 0);
  });
}
