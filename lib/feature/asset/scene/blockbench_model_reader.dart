import 'asset_scene.dart';

const _defaultResolution = 16.0;

/// Reads a Blockbench `.bbmodel` into an [AssetScene].
///
/// Cube elements are read with their inflate, origin and rotation. Face UVs are scaled from the
/// texture's UV space (`uv_width`/`uv_height`, else `resolution`) to 0..16. Textures are the
/// embedded data URIs. Mesh elements and other non-cube types are skipped and reported in
/// [AssetScene.unsupported]. Outliner and animations are ignored.
AssetScene readBlockbenchModel(Map<String, Object?> json) {
  final resolution = json['resolution'];
  final resolutionWidth =
      _positive(_field(resolution, 'width')) ?? _defaultResolution;
  final resolutionHeight =
      _positive(_field(resolution, 'height')) ?? _defaultResolution;

  final rawTextures = json['textures'];
  final slots = <SceneTexture?>[];
  final uvSizes = <({double width, double height})>[];
  if (rawTextures is List) {
    for (var index = 0; index < rawTextures.length; index++) {
      final texture = rawTextures[index];
      final uvWidth = _positive(_field(texture, 'uv_width')) ?? resolutionWidth;
      final uvHeight =
          _positive(_field(texture, 'uv_height')) ?? resolutionHeight;
      final source = _field(texture, 'source');
      uvSizes.add((width: uvWidth, height: uvHeight));
      slots.add(
        source is String && source.startsWith('data:')
            ? SceneTexture(
                id: 't$index',
                dataUri: source,
                width: uvWidth.round(),
                height: uvHeight.round(),
              )
            : null,
      );
    }
  }

  final boxes = <SceneBox>[];
  final unsupported = <String>[];
  final elements = json['elements'];
  if (elements is List) {
    for (final element in elements.whereType<Map<String, Object?>>()) {
      final type = element['type'] is String
          ? element['type'] as String
          : 'cube';
      if (type != 'cube') {
        final name = element['name'] is String
            ? element['name'] as String
            : '(unnamed)';
        unsupported.add('$type: $name');
        continue;
      }
      final box = _cube(
        element,
        slots,
        uvSizes,
        resolutionWidth,
        resolutionHeight,
      );
      if (box != null) {
        boxes.add(box);
      }
    }
  }

  return AssetScene(
    textures: slots.whereType<SceneTexture>().toList(),
    boxes: boxes,
    unsupported: unsupported,
  );
}

SceneBox? _cube(
  Map<String, Object?> element,
  List<SceneTexture?> slots,
  List<({double width, double height})> uvSizes,
  double resolutionWidth,
  double resolutionHeight,
) {
  final from = numListFromJson(element['from'], 3);
  final to = numListFromJson(element['to'], 3);
  if (from == null || to == null) {
    return null;
  }
  final inflate = element['inflate'] is num
      ? (element['inflate'] as num).toDouble()
      : 0.0;
  final faces = <String, SceneFace>{};
  final facesJson = element['faces'];
  for (final direction in sceneFaceDirections) {
    final face = facesJson is Map<String, Object?>
        ? facesJson[direction]
        : null;
    if (face is! Map<String, Object?>) {
      continue;
    }
    final index = face['texture'] is num
        ? (face['texture'] as num).toInt()
        : -1;
    final inRange = index >= 0 && index < slots.length;
    final texture = inRange ? slots[index] : null;
    final uvSpace = inRange && texture != null
        ? uvSizes[index]
        : (width: resolutionWidth, height: resolutionHeight);
    final uv =
        numListFromJson(face['uv'], 4) ?? [0, 0, uvSpace.width, uvSpace.height];
    faces[direction] = SceneFace(
      uv: [
        uv[0] * 16 / uvSpace.width,
        uv[1] * 16 / uvSpace.height,
        uv[2] * 16 / uvSpace.width,
        uv[3] * 16 / uvSpace.height,
      ],
      textureId: texture?.id,
      rotation: quarterTurnFromJson(face['rotation']),
    );
  }
  return SceneBox(
    from: [for (final value in from) value - inflate],
    to: [for (final value in to) value + inflate],
    rotation: _rotation(element),
    faces: faces,
  );
}

SceneRotation? _rotation(Map<String, Object?> element) {
  final angles = numListFromJson(element['rotation'], 3);
  if (angles == null || angles.every((angle) => angle == 0)) {
    return null;
  }
  return SceneRotation(
    origin: numListFromJson(element['origin'], 3) ?? const [0, 0, 0],
    angles: angles,
  );
}

Object? _field(Object? value, String name) =>
    value is Map<String, Object?> ? value[name] : null;

double? _positive(Object? value) {
  if (value is! num || value <= 0) {
    return null;
  }
  return value.toDouble();
}
