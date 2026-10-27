import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/scene/asset_scene.dart';
import 'package:stelaris/feature/asset/scene/minecraft_model_reader.dart';

SceneTexture _texture(String key) => SceneTexture(
  id: 'id:$key',
  dataUri: 'data:image/png;base64,AAAA',
  width: 16,
  height: 16,
);

/// A texture lookup that knows the given keys and records every key it was asked for.
class _Lookup {
  _Lookup(this.known);

  final Set<String> known;
  final List<String> requested = [];

  SceneTexture? call(String key) {
    requested.add(key);
    return known.contains(key) ? _texture(key) : null;
  }
}

Map<String, Object?> _cubeModel({
  Map<String, Object?> textures = const {},
  Map<String, Object?> north = const {'texture': '#all'},
  Object? parent,
}) => {
  'parent': ?parent,
  'textures': textures,
  'elements': [
    {
      'from': [0, 0, 0],
      'to': [16, 16, 16],
      'faces': {'north': north},
    },
  ],
};

void main() {
  test('resolves a #var chain to the namespaced texture key', () {
    final lookup = _Lookup({'vulpes:block/ruby'});
    final scene = readMinecraftModel(
      _cubeModel(
        textures: {
          'particle': '#side',
          'side': '#all',
          'all': 'vulpes:block/ruby',
        },
        north: {'texture': '#particle'},
      ),
      texture: lookup.call,
    );

    expect(lookup.requested, ['vulpes:block/ruby']);
    expect(
      scene.boxes.single.faces['north']?.textureId,
      'id:vulpes:block/ruby',
    );
  });

  test('adds the minecraft namespace to a texture key without one', () {
    final lookup = _Lookup({});
    readMinecraftModel(
      _cubeModel(textures: {'all': 'block/stone'}),
      texture: lookup.call,
    );

    expect(lookup.requested, ['minecraft:block/stone']);
  });

  test('a face whose texture the project lacks has no texture', () {
    final scene = readMinecraftModel(
      _cubeModel(textures: {'all': 'vulpes:block/missing'}),
      texture: _Lookup({}).call,
    );

    expect(scene.boxes.single.faces['north']?.textureId, isNull);
    expect(scene.textures, isEmpty);
  });

  test('a face with a cyclic texture reference has no texture', () {
    final lookup = _Lookup({});
    final scene = readMinecraftModel(
      _cubeModel(textures: {'a': '#b', 'b': '#a'}, north: {'texture': '#a'}),
      texture: lookup.call,
    );

    expect(lookup.requested, isEmpty);
    expect(scene.boxes.single.faces['north']?.textureId, isNull);
  });

  test(
    'a face without uv gets the uv Minecraft derives from its from and to',
    () {
      final scene = readMinecraftModel({
        'textures': {'all': 'minecraft:block/stone'},
        'elements': [
          {
            'from': [2, 3, 4],
            'to': [6, 8, 10],
            'faces': {
              'north': {'texture': '#all'},
            },
          },
        ],
      }, texture: _Lookup({'minecraft:block/stone'}).call);

      expect(scene.boxes.single.faces['north']?.uv, [10, 8, 14, 13]);
    },
  );

  test('an element rotation sets only the axis it names', () {
    final scene = readMinecraftModel({
      'elements': [
        {
          'from': [0, 0, 0],
          'to': [16, 16, 16],
          'rotation': {
            'origin': [4, 5, 6],
            'axis': 'y',
            'angle': 22.5,
            'rescale': true,
          },
          'faces': <String, Object?>{},
        },
      ],
    }, texture: _Lookup({}).call);

    final rotation = scene.boxes.single.rotation;
    expect(rotation?.angles, [0, 22.5, 0]);
    expect(rotation?.origin, [4, 5, 6]);
    expect(rotation?.rescale, isTrue);
  });

  test('a flat item model without elements becomes one box with layer0 on north and south', () {
    final scene = readMinecraftModel({
      'parent': 'minecraft:item/generated',
      'textures': {'layer0': 'vulpes:item/ruby'},
    }, texture: _Lookup({'vulpes:item/ruby'}).call);

    final box = scene.boxes.single;
    expect(box.from, [0, 0, 7.5]);
    expect(box.to, [16, 16, 8.5]);
    expect(box.faces.keys, unorderedEquals(['north', 'south']));
    expect(box.faces['north']?.textureId, 'id:vulpes:item/ruby');
    expect(box.faces['south']?.textureId, 'id:vulpes:item/ruby');
    expect(scene.unsupported, isEmpty);
  });

  test('a parent other than a flat item parent is reported as unsupported', () {
    final scene = readMinecraftModel({
      'parent': 'block/cube_all',
      'textures': {},
    }, texture: _Lookup({}).call);

    expect(scene.unsupported, ['parent: block/cube_all']);
    expect(scene.boxes, isEmpty);
  });

  test('elements under an unsupported parent are still drawn', () {
    final scene = readMinecraftModel(
      _cubeModel(
        parent: 'block/cube_all',
        textures: {'all': 'minecraft:block/stone'},
      ),
      texture: _Lookup({'minecraft:block/stone'}).call,
    );

    expect(scene.unsupported, ['parent: block/cube_all']);
    expect(scene.boxes, hasLength(1));
  });

  test('referencedTextureKeys lists the namespaced keys the faces need', () {
    final keys = referencedTextureKeys(
      _cubeModel(
        textures: {'side': 'vulpes:block/ruby', 'all': '#side'},
        north: {'texture': '#all'},
      ),
    );

    expect(keys, {'vulpes:block/ruby'});
  });

  test('referencedTextureKeys of a flat item model is its layer0 key', () {
    final keys = referencedTextureKeys({
      'parent': 'item/handheld',
      'textures': {'layer0': 'vulpes:item/sword'},
    });

    expect(keys, {'vulpes:item/sword'});
  });
}
