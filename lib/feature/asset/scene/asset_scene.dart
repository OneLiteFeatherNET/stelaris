/// Model scene of one asset: textures, boxes and the parts that could not be drawn.
///
/// Plain immutable values, no IO and no Flutter. [AssetScene.toJson] produces the JSON that the
/// JS bridge (`web/asset_viewer.js`) consumes. The shape of that JSON is the shared contract:
///
/// ```
/// Units: Minecraft model units (a block is 0..16 on each axis). The JS bridge centres the bounds.
///
/// {
///   "textures": [ { "id": "t0", "dataUri": "data:image/png;base64,...", "width": 16, "height": 16 } ],
///   "levels": [ Level, Level, Level ]      // index 0 = full, 1 = reduced, 2 = bounding box
///   "unsupported": [ "mesh: Sword blade", "parent: block/cube_all" ]   // shown by Dart only
/// }
///
/// Level = { "boxes": [ Box, ... ] }
///
/// Box = {
///   "from": [x, y, z], "to": [x, y, z],
///   "rotation": null | { "origin": [x, y, z], "angles": [rx, ry, rz], "rescale": false },
///       // degrees; applied as Euler order 'ZYX' around origin (Blockbench convention;
///       // a Minecraft element sets only the one axis it names). rescale per Minecraft:
///       // scale the two non-rotated axes by 1/cos(angle) (only for single-axis rotations).
///   "faces": {                               // keys: north south east west up down; a missing key = no face
///     "north": { "uv": [u1, v1, u2, v2],     // in 0..16 units, Minecraft convention (v grows downward)
///                "texture": "t0" | null,     // null => magenta/black 2x2 checker
///                "rotation": 0 | 90 | 180 | 270,
///                "averageColor": false }     // true => draw flat colour = average of the texture's opaque pixels
///   }
/// }
/// ```
library;

/// Face keys of a box, in the order faces are read and written.
const List<String> sceneFaceDirections = [
  'north',
  'south',
  'east',
  'west',
  'up',
  'down',
];

/// A texture the bridge decodes from [dataUri].
class SceneTexture {
  const SceneTexture({
    required this.id,
    required this.dataUri,
    required this.width,
    required this.height,
  });

  final String id;
  final String dataUri;
  final int width;
  final int height;

  Map<String, Object?> toJson() => {
    'id': id,
    'dataUri': dataUri,
    'width': width,
    'height': height,
  };
}

/// Rotation of a box around [origin], in degrees per axis (x, y, z).
class SceneRotation {
  SceneRotation({
    required List<double> origin,
    required List<double> angles,
    this.rescale = false,
  }) : origin = List.unmodifiable(origin),
       angles = List.unmodifiable(angles);

  final List<double> origin;
  final List<double> angles;
  final bool rescale;

  Map<String, Object?> toJson() => {
    'origin': origin,
    'angles': angles,
    'rescale': rescale,
  };
}

/// One face of a box. [textureId] is null when the texture is missing; the bridge draws a checker.
class SceneFace {
  SceneFace({
    required List<double> uv,
    this.textureId,
    this.rotation = 0,
    this.averageColor = false,
  }) : uv = List.unmodifiable(uv);

  /// `[u1, v1, u2, v2]` in 0..16 units.
  final List<double> uv;
  final String? textureId;

  /// Quarter turns in degrees: 0, 90, 180 or 270.
  final int rotation;

  /// True when the bridge should draw the flat average colour of the texture.
  final bool averageColor;

  Map<String, Object?> toJson() => {
    'uv': uv,
    'texture': textureId,
    'rotation': rotation,
    'averageColor': averageColor,
  };
}

/// An axis-aligned box in model units (0..16 for a block), optionally rotated.
class SceneBox {
  SceneBox({
    required List<double> from,
    required List<double> to,
    this.rotation,
    Map<String, SceneFace> faces = const {},
  }) : from = List.unmodifiable(from),
       to = List.unmodifiable(to),
       faces = Map.unmodifiable(faces);

  final List<double> from;
  final List<double> to;
  final SceneRotation? rotation;

  /// Keys are members of [sceneFaceDirections]. A missing key means no face.
  final Map<String, SceneFace> faces;

  /// Volume of the unrotated box.
  double get volume {
    var result = 1.0;
    for (var axis = 0; axis < 3; axis++) {
      result *= (to[axis] - from[axis]).abs();
    }
    return result;
  }

  Map<String, Object?> toJson() => {
    'from': from,
    'to': to,
    'rotation': rotation?.toJson(),
    'faces': faces.map((direction, face) => MapEntry(direction, face.toJson())),
  };
}

/// The drawable parts of one asset model plus the names of the parts that were left out.
class AssetScene {
  AssetScene({
    required List<SceneTexture> textures,
    required List<SceneBox> boxes,
    List<String> unsupported = const [],
  }) : textures = List.unmodifiable(textures),
       boxes = List.unmodifiable(boxes),
       unsupported = List.unmodifiable(unsupported);

  final List<SceneTexture> textures;

  /// All boxes at full detail.
  final List<SceneBox> boxes;

  /// Parts that are not drawn, shown to the user as text, e.g. `mesh: Sword blade`.
  final List<String> unsupported;

  /// Encodes this scene with the given detail [levels] in the contract format.
  ///
  /// Pass `detailLevels(scene)` for the three levels (full, reduced, bounding box).
  Map<String, Object?> toJson(List<List<SceneBox>> levels) => {
    'textures': textures.map((texture) => texture.toJson()).toList(),
    'levels': levels
        .map((level) => {'boxes': level.map((box) => box.toJson()).toList()})
        .toList(),
    'unsupported': unsupported,
  };
}

/// Reads a JSON array of exactly [length] numbers, or returns null when the value is not one.
List<double>? numListFromJson(Object? value, int length) {
  if (value is! List || value.length != length) {
    return null;
  }
  final result = <double>[];
  for (final entry in value) {
    if (entry is! num) {
      return null;
    }
    result.add(entry.toDouble());
  }
  return result;
}

/// Snaps a JSON rotation in degrees to the nearest quarter turn in 0..270.
int quarterTurnFromJson(Object? value) {
  if (value is! num) {
    return 0;
  }
  final snapped = (value / 90).round() * 90;
  return ((snapped % 360) + 360) % 360;
}
