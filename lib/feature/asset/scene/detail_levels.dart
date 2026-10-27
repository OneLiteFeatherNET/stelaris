import 'dart:math' as math;

import 'asset_scene.dart';

/// Share of the largest box's volume below which a box is dropped from the reduced level.
const _reducedVolumeShare = 0.02;

/// Returns the three detail levels of [scene]: full, reduced and a single bounding box.
///
/// - Full is every box.
/// - Reduced drops boxes whose volume is below 2 % of the largest box. The largest box is always
///   kept, so the level is never empty while the scene has boxes.
/// - Bounding box is one box over all boxes. Its faces use the first textured face of the largest
///   box and are drawn in that texture's average colour.
///
/// Volumes and bounds use the unrotated `from`/`to` of each box. For rotated boxes this is an
/// approximation, good enough to choose which boxes are small.
List<List<SceneBox>> detailLevels(AssetScene scene) {
  final full = scene.boxes;
  return [full, _reducedLevel(full), _boundingLevel(full)];
}

List<SceneBox> _reducedLevel(List<SceneBox> boxes) {
  if (boxes.isEmpty) {
    return const [];
  }
  final largest = _largest(boxes);
  final threshold = largest.volume * _reducedVolumeShare;
  final kept = boxes.where((box) => box.volume >= threshold).toList();
  return kept.isEmpty ? [largest] : kept;
}

List<SceneBox> _boundingLevel(List<SceneBox> boxes) {
  if (boxes.isEmpty) {
    return const [];
  }
  final min = [double.infinity, double.infinity, double.infinity];
  final max = [
    double.negativeInfinity,
    double.negativeInfinity,
    double.negativeInfinity,
  ];
  for (final box in boxes) {
    for (var axis = 0; axis < 3; axis++) {
      min[axis] = math.min(min[axis], math.min(box.from[axis], box.to[axis]));
      max[axis] = math.max(max[axis], math.max(box.from[axis], box.to[axis]));
    }
  }
  final textureId = _firstTextureId(_largest(boxes));
  return [
    SceneBox(
      from: min,
      to: max,
      faces: {
        for (final direction in sceneFaceDirections)
          direction: SceneFace(
            uv: const [0, 0, 16, 16],
            textureId: textureId,
            averageColor: true,
          ),
      },
    ),
  ];
}

SceneBox _largest(List<SceneBox> boxes) =>
    boxes.reduce((best, box) => box.volume > best.volume ? box : best);

String? _firstTextureId(SceneBox box) {
  for (final direction in sceneFaceDirections) {
    final textureId = box.faces[direction]?.textureId;
    if (textureId != null) {
      return textureId;
    }
  }
  return null;
}
