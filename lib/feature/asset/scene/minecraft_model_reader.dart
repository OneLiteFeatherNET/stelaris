import 'asset_scene.dart';

const _minecraftNamespace = 'minecraft:';

/// Texture keys (namespaced, `#var` chains resolved) that the model's faces need.
///
/// A flat item model without elements needs its `layer0` texture only.
Set<String> referencedTextureKeys(Map<String, Object?> json) {
  final vars = _textureVars(json);
  final keys = <String>{};
  final elements = _elements(json);
  if (_isFlatItem(json, elements)) {
    final key = _resolveKey('#layer0', vars);
    if (key != null) {
      keys.add(key);
    }
    return keys;
  }
  for (final element in elements) {
    final faces = element['faces'];
    if (faces is! Map<String, Object?>) {
      continue;
    }
    for (final direction in sceneFaceDirections) {
      final face = faces[direction];
      final ref = face is Map<String, Object?> ? face['texture'] : null;
      if (ref is! String) {
        continue;
      }
      final key = _resolveKey(ref, vars);
      if (key != null) {
        keys.add(key);
      }
    }
  }
  return keys;
}

/// Reads a Minecraft model JSON into an [AssetScene].
///
/// [texture] looks up a namespaced texture key and returns the texture, or null when the project
/// has none. A face whose texture is missing is drawn as a checker (texture null).
AssetScene readMinecraftModel(
  Map<String, Object?> json, {
  required SceneTexture? Function(String key) texture,
}) {
  final vars = _textureVars(json);
  final elements = _elements(json);
  final parent = json['parent'];
  final parentName = parent is String ? parent : null;
  final unsupported = <String>[];
  if (parentName != null && !_isFlatParent(parentName)) {
    unsupported.add('parent: $parentName');
  }

  final used = <String, SceneTexture>{};
  SceneTexture? lookup(String ref) {
    final key = _resolveKey(ref, vars);
    final found = key == null ? null : texture(key);
    if (found != null) {
      used[found.id] = found;
    }
    return found;
  }

  final boxes = <SceneBox>[];
  if (elements.isNotEmpty) {
    for (final element in elements) {
      final box = _elementBox(element, lookup);
      if (box != null) {
        boxes.add(box);
      }
    }
  } else if (_isFlatItem(json, elements)) {
    final layer = lookup('#layer0');
    boxes.add(
      SceneBox(
        from: const [0, 0, 7.5],
        to: const [16, 16, 8.5],
        faces: {
          'north': SceneFace(uv: const [0, 0, 16, 16], textureId: layer?.id),
          'south': SceneFace(uv: const [0, 0, 16, 16], textureId: layer?.id),
        },
      ),
    );
  }

  return AssetScene(
    textures: used.values.toList(),
    boxes: boxes,
    unsupported: unsupported,
  );
}

bool _isFlatParent(String parent) =>
    parent.endsWith('item/generated') || parent.endsWith('item/handheld');

bool _isFlatItem(
  Map<String, Object?> json,
  List<Map<String, Object?>> elements,
) {
  final parent = json['parent'];
  return elements.isEmpty && parent is String && _isFlatParent(parent);
}

List<Map<String, Object?>> _elements(Map<String, Object?> json) {
  final raw = json['elements'];
  if (raw is! List) {
    return const [];
  }
  return raw.whereType<Map<String, Object?>>().toList();
}

Map<String, String> _textureVars(Map<String, Object?> json) {
  final raw = json['textures'];
  if (raw is! Map) {
    return const {};
  }
  return {
    for (final entry in raw.entries)
      if (entry.value is String) '${entry.key}': entry.value as String,
  };
}

/// Follows `#var` references through [vars] and returns the namespaced key, or null when a
/// reference is missing or cyclic.
String? _resolveKey(String ref, Map<String, String> vars) {
  var value = ref;
  final seen = <String>{};
  while (value.startsWith('#')) {
    final name = value.substring(1);
    if (!seen.add(name)) {
      return null;
    }
    final next = vars[name];
    if (next == null) {
      return null;
    }
    value = next;
  }
  return value.contains(':') ? value : '$_minecraftNamespace$value';
}

SceneBox? _elementBox(
  Map<String, Object?> element,
  SceneTexture? Function(String ref) lookup,
) {
  final from = numListFromJson(element['from'], 3);
  final to = numListFromJson(element['to'], 3);
  if (from == null || to == null) {
    return null;
  }
  final faces = <String, SceneFace>{};
  final facesJson = element['faces'];
  for (final direction in sceneFaceDirections) {
    final face = facesJson is Map<String, Object?>
        ? facesJson[direction]
        : null;
    if (face is! Map<String, Object?>) {
      continue;
    }
    final ref = face['texture'];
    final texture = ref is String ? lookup(ref) : null;
    faces[direction] = SceneFace(
      uv: numListFromJson(face['uv'], 4) ?? _defaultUv(direction, from, to),
      textureId: texture?.id,
      rotation: quarterTurnFromJson(face['rotation']),
    );
  }
  return SceneBox(
    from: from,
    to: to,
    rotation: _rotation(element['rotation']),
    faces: faces,
  );
}

SceneRotation? _rotation(Object? raw) {
  if (raw is! Map<String, Object?>) {
    return null;
  }
  final angle = raw['angle'];
  final axisIndex = switch (raw['axis']) {
    'x' => 0,
    'y' => 1,
    'z' => 2,
    _ => -1,
  };
  if (angle is! num || axisIndex < 0) {
    return null;
  }
  final angles = [0.0, 0.0, 0.0];
  angles[axisIndex] = angle.toDouble();
  return SceneRotation(
    origin: numListFromJson(raw['origin'], 3) ?? const [8, 8, 8],
    angles: angles,
    rescale: raw['rescale'] == true,
  );
}

/// The UV Minecraft derives for a face without an explicit `uv`.
List<double> _defaultUv(String direction, List<double> from, List<double> to) {
  switch (direction) {
    case 'down':
      return [from[0], 16 - to[2], to[0], 16 - from[2]];
    case 'up':
      return [from[0], from[2], to[0], to[2]];
    case 'north':
      return [16 - to[0], 16 - to[1], 16 - from[0], 16 - from[1]];
    case 'south':
      return [from[0], 16 - to[1], to[0], 16 - from[1]];
    case 'west':
      return [from[2], 16 - to[1], to[2], 16 - from[1]];
    default:
      return [16 - to[2], 16 - to[1], 16 - from[2], 16 - from[1]];
  }
}
