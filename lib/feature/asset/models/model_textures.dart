import 'package:stelaris_models/stelaris_models.dart';

/// One texture a model needs, and whether the project has it.
class TextureSlot {
  const TextureSlot({required this.key, this.texture, this.alsoIn = const []});

  /// The namespaced key the model refers to.
  final String key;

  /// The project's texture with [key], null when it is missing.
  final AssetModel? texture;

  /// The other models that refer to [key] too.
  final List<AssetModel> alsoIn;

  bool get missing => texture == null;
}

/// The textures of one model, as shown in its detail.
class ModelTextures {
  const ModelTextures({required this.slots, this.readOnly = false});

  final List<TextureSlot> slots;

  /// True for a Blockbench model: its textures come from the model file and
  /// cannot be uploaded on their own.
  final bool readOnly;

  int get missingCount => slots.where((slot) => slot.missing).length;
}

/// Computes the textures of [model] from what the project stores right now.
///
/// [references] maps each MODEL asset whose file has been read to the texture
/// keys it refers to (see `referencedTextureKeys`). Nothing is persisted: the
/// result is computed again whenever the assets change.
ModelTextures modelTextures(
  AssetModel model, {
  required Map<AssetModel, Set<String>> references,
  required Iterable<AssetModel> textures,
}) {
  final projectTextures = textures.where(
    (asset) => asset.kind == AssetKind.TEXTURE,
  );
  if (model.kind == AssetKind.BBMODEL) {
    return ModelTextures(
      readOnly: true,
      slots: [
        for (final texture in projectTextures)
          if (texture.sourceAssetId == model.id)
            TextureSlot(key: texture.key, texture: texture),
      ],
    );
  }
  final byKey = <String, AssetModel>{};
  for (final texture in projectTextures) {
    byKey.putIfAbsent(texture.key, () => texture);
  }
  final keys = (references[model] ?? const <String>{}).toList()..sort();
  return ModelTextures(
    slots: [
      for (final key in keys)
        TextureSlot(
          key: key,
          texture: byKey[key],
          alsoIn: [
            for (final MapEntry(key: other, value: otherKeys)
                in references.entries)
              if (other.id != model.id && otherKeys.contains(key)) other,
          ],
        ),
    ],
  );
}
