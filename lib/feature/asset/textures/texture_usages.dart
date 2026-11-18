import 'package:stelaris_models/stelaris_models.dart';

/// Where one texture of the project is used.
class TextureUsages {
  const TextureUsages({
    this.models = const [],
    this.fonts = const [],
    this.packIcons = const [],
    this.sameKeyAs,
  });

  /// The models drawing the texture, sorted by key.
  final List<AssetModel> models;

  /// The fonts whose provider uses the texture.
  final List<FontModel> fonts;

  /// The packs whose icon the texture is.
  final List<PackType> packIcons;

  /// The texture models get instead, when another texture has the same key
  /// and comes first.
  final AssetModel? sameKeyAs;

  bool get isEmpty => count == 0;

  int get count => models.length + fonts.length + packIcons.length;
}

/// Finds where [texture] is used.
///
/// Models refer to textures by key: like `modelTextures`, the first texture
/// with a key in [textures] owns it, so a later one with the same key is used
/// by no MODEL. A BBMODEL uses the textures extracted from it. Fonts and pack
/// metas refer to the texture by its id.
TextureUsages textureUsages(
  AssetModel texture, {
  required Iterable<AssetModel> models,
  required Iterable<AssetModel> textures,
  required Map<AssetModel, Set<String>> references,
  required Iterable<FontModel> fonts,
  required Iterable<PackMeta> packMetas,
}) {
  AssetModel? owner;
  for (final candidate in textures) {
    if (candidate.kind == AssetKind.TEXTURE && candidate.key == texture.key) {
      owner = candidate;
      break;
    }
  }
  final ownsKey = owner == null || owner.id == texture.id;
  final usingModels = [
    for (final model in models)
      if (model.kind == AssetKind.BBMODEL
          ? model.id == texture.sourceAssetId
          : ownsKey && (references[model]?.contains(texture.key) ?? false))
        model,
  ]..sort((a, b) => a.key.compareTo(b.key));
  return TextureUsages(
    models: usingModels,
    fonts: [
      for (final font in fonts)
        if (font.textureAssetId == texture.id) font,
    ],
    packIcons: [
      for (final meta in packMetas)
        if (meta.iconAssetId == texture.id) meta.packType,
    ],
    sameKeyAs: ownsKey ? null : owner,
  );
}
