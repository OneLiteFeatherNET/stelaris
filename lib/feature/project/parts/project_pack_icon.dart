import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The icon of a project's resource pack: its asset and the bytes of it,
/// which may still be loading.
class ProjectPackIcon {
  const ProjectPackIcon({required this.asset, required this.bytes});

  final AssetModel asset;
  final Future<Uint8List> bytes;
}

/// Loads the pack icon of the project [projectId], null when it has none.
typedef ProjectPackIconLoader = Future<ProjectPackIcon?> Function(
  String projectId,
);

/// Loads the icon of the resource pack of [projectId] from the backend.
///
/// A project without a pack, a pack without an icon and a failed request all
/// answer null: the overview then shows the project without a picture.
Future<ProjectPackIcon?> loadProjectPackIcon(String projectId) async {
  final api = ApiService();
  try {
    final meta = await api.packMetaApi.get(projectId, PackType.resource);
    final iconAssetId = meta.iconAssetId;
    if (iconAssetId == null) return null;
    final bytes = api.assetApi
        .content(projectId, iconAssetId)
        .then(Uint8List.fromList);
    // Shown by the thumbnail once it listens, not reported before that.
    bytes.ignore();
    final asset = await api.assetApi.getById(projectId, iconAssetId);
    return ProjectPackIcon(asset: asset, bytes: bytes);
  } on Object {
    return null;
  }
}

/// What stands in front of a project in the overview: its pack icon as a
/// thumbnail, or a folder while [icon] loads and when the project has none.
class ProjectLeading extends StatelessWidget {
  const ProjectLeading({
    required this.icon,
    required this.isSelected,
    super.key,
  });

  final Future<ProjectPackIcon?>? icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: TextureThumbnail.size,
      child: FutureBuilder<ProjectPackIcon?>(
        future: icon,
        builder: (context, snapshot) {
          final icon = snapshot.data;
          if (icon == null) {
            return Icon(
              isSelected ? Icons.folder : Icons.folder_outlined,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 22,
            );
          }
          return TextureThumbnail(asset: icon.asset, bytes: icon.bytes);
        },
      ),
    );
  }
}
