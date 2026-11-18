import 'package:stelaris/api/api_service.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// What refers to textures by id besides the models: the fonts and the pack
/// metas of a project.
class TextureUsageSources {
  const TextureUsageSources({this.fonts = const [], this.packMetas = const []});

  final List<FontModel> fonts;
  final List<PackMeta> packMetas;
}

/// Loads every font of [projectId] and its pack metas.
///
/// The store only holds the fonts paged in so far, so this asks the backend
/// for all of them.
Future<TextureUsageSources> loadTextureUsageSources(String projectId) async {
  final api = ApiService();
  final fonts = <FontModel>[];
  var page = 1;
  while (true) {
    final result = await api.fontApi.getPage(
      page: page,
      size: 100,
      projectId: projectId,
    );
    fonts.addAll(result.items);
    if (result.items.isEmpty || page >= result.totalPages) break;
    page++;
  }
  final packMetas = await api.packMetaApi.getAll(projectId);
  return TextureUsageSources(fonts: fonts, packMetas: packMetas);
}
