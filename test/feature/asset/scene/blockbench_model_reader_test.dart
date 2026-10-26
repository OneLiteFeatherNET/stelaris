import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/scene/blockbench_model_reader.dart';

const _pixel = 'data:image/png;base64,AAAA';

Map<String, Object?> _cube({
  List<num> from = const [0, 0, 0],
  List<num> to = const [16, 16, 16],
  Map<String, Object?> extra = const {},
  Map<String, Object?> faces = const {},
}) => {'type': 'cube', 'from': from, 'to': to, 'faces': faces, ...extra};

void main() {
  test('scales face uv from the resolution to 0..16', () {
    final scene = readBlockbenchModel({
      'resolution': {'width': 32, 'height': 32},
      'textures': [
        {'source': _pixel},
      ],
      'elements': [
        _cube(
          faces: {
            'north': {
              'uv': [0, 0, 32, 16],
              'texture': 0,
            },
          },
        ),
      ],
    });

    expect(scene.boxes.single.faces['north']?.uv, [0, 0, 16, 8]);
  });

  test('scales face uv from the texture uv size when it is given', () {
    final scene = readBlockbenchModel({
      'resolution': {'width': 16, 'height': 16},
      'textures': [
        {'source': _pixel, 'uv_width': 64, 'uv_height': 32},
      ],
      'elements': [
        _cube(
          faces: {
            'north': {
              'uv': [0, 0, 64, 32],
              'texture': 0,
            },
          },
        ),
      ],
    });

    expect(scene.boxes.single.faces['north']?.uv, [0, 0, 16, 16]);
  });

  test('a cube inflate expands its from and to on every axis', () {
    final scene = readBlockbenchModel({
      'elements': [
        _cube(from: [2, 2, 2], to: [14, 14, 14], extra: {'inflate': 1}),
      ],
    });

    expect(scene.boxes.single.from, [1, 1, 1]);
    expect(scene.boxes.single.to, [15, 15, 15]);
  });

  test('a cube rotation keeps its origin and per-axis angles', () {
    final scene = readBlockbenchModel({
      'elements': [
        _cube(
          extra: {
            'origin': [8, 4, 8],
            'rotation': [0, 45, 0],
          },
        ),
      ],
    });

    final rotation = scene.boxes.single.rotation;
    expect(rotation?.origin, [8, 4, 8]);
    expect(rotation?.angles, [0, 45, 0]);
  });

  test('a cube with all-zero rotation has no rotation', () {
    final scene = readBlockbenchModel({
      'elements': [
        _cube(
          extra: {
            'rotation': [0, 0, 0],
          },
        ),
      ],
    });

    expect(scene.boxes.single.rotation, isNull);
  });

  test('a mesh element is skipped and reported by name', () {
    final scene = readBlockbenchModel({
      'elements': [
        {'type': 'mesh', 'name': 'Sword blade', 'vertices': {}},
        _cube(),
      ],
    });

    expect(scene.boxes, hasLength(1));
    expect(scene.unsupported, ['mesh: Sword blade']);
  });

  test(
    'embedded texture data URIs become textures with ids from their index',
    () {
      final scene = readBlockbenchModel({
        'textures': [
          {
            'source': 'data:image/png;base64,AAAA',
            'uv_width': 16,
            'uv_height': 16,
          },
          {'source': _pixel},
        ],
      });

      expect(scene.textures.map((texture) => texture.id), ['t0', 't1']);
      expect(scene.textures.first.dataUri, 'data:image/png;base64,AAAA');
    },
  );

  test('a face whose texture has no data URI gets no texture', () {
    final scene = readBlockbenchModel({
      'textures': [
        {'source': 'texture.png'},
      ],
      'elements': [
        _cube(
          faces: {
            'north': {
              'uv': [0, 0, 16, 16],
              'texture': 0,
            },
          },
        ),
      ],
    });

    expect(scene.textures, isEmpty);
    expect(scene.boxes.single.faces['north']?.textureId, isNull);
  });
}
