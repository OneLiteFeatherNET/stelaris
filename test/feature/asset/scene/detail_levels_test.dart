import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/scene/asset_scene.dart';
import 'package:stelaris/feature/asset/scene/detail_levels.dart';

SceneBox _box(
  List<double> from,
  List<double> to, {
  Map<String, String?> textures = const {},
}) => SceneBox(
  from: from,
  to: to,
  faces: {
    for (final entry in textures.entries)
      entry.key: SceneFace(uv: const [0, 0, 16, 16], textureId: entry.value),
  },
);

AssetScene _scene(List<SceneBox> boxes) =>
    AssetScene(textures: const [], boxes: boxes);

void main() {
  test('the full level holds every box', () {
    final big = _box([0, 0, 0], [16, 16, 16]);
    final small = _box([0, 0, 0], [1, 1, 1]);

    final levels = detailLevels(_scene([big, small]));

    expect(levels[0], [big, small]);
  });

  test(
    'the reduced level drops boxes below two percent of the largest volume',
    () {
      final large = _box([0, 0, 0], [16, 16, 16]);
      final medium = _box([0, 0, 0], [8, 8, 8]);
      final tiny = _box([0, 0, 0], [1, 1, 1]);

      final reduced = detailLevels(_scene([large, medium, tiny]))[1];

      expect(reduced, [large, medium]);
    },
  );

  test('the reduced level keeps the largest box when it is the only box', () {
    final flat = _box([0, 0, 7.5], [16, 16, 8.5]);

    final reduced = detailLevels(_scene([flat]))[1];

    expect(reduced, [flat]);
  });

  test('the bounding level is one box over the bounds of all boxes', () {
    final a = _box([0, 0, 0], [4, 4, 4]);
    final b = _box([10, 2, -3], [12, 6, 1]);

    final bounding = detailLevels(_scene([a, b]))[2];

    expect(bounding, hasLength(1));
    expect(bounding.single.from, [0, 0, -3]);
    expect(bounding.single.to, [12, 6, 4]);
  });

  test('the bounding level takes the first textured face of the largest box with average colour', () {
    final largest = _box(
      [0, 0, 0],
      [16, 16, 16],
      textures: {'north': null, 'south': 'tex-a', 'up': 'tex-b'},
    );
    final smaller = _box([0, 0, 0], [2, 2, 2], textures: {'north': 'tex-c'});

    final face = detailLevels(_scene([smaller, largest]))[2].single.faces;

    expect(face.keys, unorderedEquals(sceneFaceDirections));
    for (final value in face.values) {
      expect(value.textureId, 'tex-a');
      expect(value.averageColor, isTrue);
      expect(value.uv, [0, 0, 16, 16]);
    }
  });

  test('every level of an empty scene is empty', () {
    final levels = detailLevels(_scene([]));

    expect(levels, [isEmpty, isEmpty, isEmpty]);
  });
}
