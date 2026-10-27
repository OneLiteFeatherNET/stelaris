import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/scene/asset_scene.dart';
import 'package:stelaris/feature/asset/scene/detail_levels.dart';

void main() {
  final scene = AssetScene(
    textures: [
      const SceneTexture(
        id: 't0',
        dataUri: 'data:image/png;base64,AAAA',
        width: 16,
        height: 16,
      ),
    ],
    boxes: [
      SceneBox(
        from: [0, 0, 0],
        to: [16, 16, 16],
        rotation: SceneRotation(origin: [8, 8, 8], angles: [0, 45, 0]),
        faces: {
          'north': SceneFace(uv: [0, 0, 16, 16], textureId: 't0'),
        },
      ),
    ],
    unsupported: ['mesh: Sword blade'],
  );

  test('toJson has the textures, levels and unsupported keys', () {
    final json = scene.toJson(detailLevels(scene));

    expect(json.keys, unorderedEquals(['textures', 'levels', 'unsupported']));
    expect(json['unsupported'], ['mesh: Sword blade']);
    expect(json['textures'], [
      {
        'id': 't0',
        'dataUri': 'data:image/png;base64,AAAA',
        'width': 16,
        'height': 16,
      },
    ]);
  });

  test('toJson writes one object per detail level with a boxes list', () {
    final levels = (scene.toJson(detailLevels(scene))['levels'] as List)
        .cast<Map<String, Object?>>();

    expect(levels, hasLength(3));
    for (final level in levels) {
      expect(level.keys, ['boxes']);
    }
  });

  test(
    'toJson writes a box with its rotation and the face keys of the contract',
    () {
      final levels = scene.toJson(detailLevels(scene))['levels'] as List;
      final box =
          ((levels.first as Map)['boxes'] as List).single
              as Map<String, Object?>;

      expect(box.keys, unorderedEquals(['from', 'to', 'rotation', 'faces']));
      expect(box['rotation'], {
        'origin': [8, 8, 8],
        'angles': [0, 45, 0],
        'rescale': false,
      });
      expect((box['faces'] as Map<String, Object?>)['north'], {
        'uv': [0, 0, 16, 16],
        'texture': 't0',
        'rotation': 0,
        'averageColor': false,
      });
    },
  );

  test('toJson writes a missing rotation and a missing texture as null', () {
    final plain = AssetScene(
      textures: const [],
      boxes: [
        SceneBox(
          from: [0, 0, 0],
          to: [1, 1, 1],
          faces: {
            'up': SceneFace(uv: [0, 0, 16, 16]),
          },
        ),
      ],
    );

    final box =
        ((plain.toJson([plain.boxes])['levels'] as List).single as Map)['boxes']
            as List;
    final json = box.single as Map<String, Object?>;

    expect(json['rotation'], isNull);
    expect(((json['faces'] as Map)['up'] as Map)['texture'], isNull);
  });
}
