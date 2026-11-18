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

/// Where every texture of a project is used, worked out once per load so a
/// rebuild only looks the uses up.
///
/// Models refer to textures by key: like `modelTextures`, the first texture
/// with a key in `textures` owns it, so a later one with the same key is used
/// by no MODEL. A BBMODEL uses the textures extracted from it. Fonts and pack
/// metas refer to the texture by its id.
class TextureUsageIndex {
  TextureUsageIndex({
    required Iterable<AssetModel> models,
    required Iterable<AssetModel> textures,
    required Map<AssetModel, Set<String>> references,
    required Iterable<FontModel> fonts,
    required Iterable<PackMeta> packMetas,
  }) {
    for (final texture in textures) {
      if (texture.kind == AssetKind.TEXTURE) {
        _owners.putIfAbsent(texture.key, () => texture);
      }
    }
    for (final model in models) {
      if (model.kind == AssetKind.BBMODEL) {
        _bbmodels[model.id] = model;
        continue;
      }
      for (final key in references[model] ?? const <String>{}) {
        (_modelsByKey[key] ??= []).add(model);
      }
    }
    for (final font in fonts) {
      if (font.textureAssetId case final id?) (_fonts[id] ??= []).add(font);
    }
    for (final meta in packMetas) {
      if (meta.iconAssetId case final id?) {
        (_packIcons[id] ??= []).add(meta.packType);
      }
    }
  }

  /// The first texture of each key.
  final Map<String, AssetModel> _owners = {};

  /// The BBMODEL assets by id, for the textures extracted from them.
  final Map<String, AssetModel> _bbmodels = {};

  /// The MODEL assets referring to each texture key.
  final Map<String, List<AssetModel>> _modelsByKey = {};
  final Map<String, List<FontModel>> _fonts = {};
  final Map<String, List<PackType>> _packIcons = {};

  /// The uses asked for so far, by texture id.
  final Map<String, TextureUsages> _usages = {};

  /// Where [texture] is used.
  TextureUsages of(AssetModel texture) =>
      _usages.putIfAbsent(texture.id, () {
        final owner = _owners[texture.key];
        final ownsKey = owner == null || owner.id == texture.id;
        final source = _bbmodels[texture.sourceAssetId];
        final models = [
          ?source,
          if (ownsKey) ...?_modelsByKey[texture.key],
        ]..sort((a, b) => a.key.compareTo(b.key));
        return TextureUsages(
          models: models,
          fonts: _fonts[texture.id] ?? const [],
          packIcons: _packIcons[texture.id] ?? const [],
          sameKeyAs: ownsKey ? null : owner,
        );
      });
}
