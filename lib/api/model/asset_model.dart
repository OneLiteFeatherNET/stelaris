// The kind names are the backend's wire values, hence upper case.
// ignore_for_file: constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_model.freezed.dart';
part 'asset_model.g.dart';

/// The kind of a project asset, as the backend derives it from file extension
/// and content. The names are the backend's wire values, hence upper case.
enum AssetKind {
  /// A PNG texture.
  TEXTURE,

  /// A Minecraft model JSON.
  MODEL,

  /// A Blockbench `.bbmodel` project.
  BBMODEL,
}

/// A file stored for a project, addressed by its Minecraft resource key.
@freezed
abstract class AssetModel with _$AssetModel {
  const AssetModel._();

  /// Creates an asset as returned by the backend's asset endpoints.
  const factory AssetModel({
    required String id,
    required String projectId,

    /// Minecraft resource location without file extension, e.g. `vulpes:item/ruby`.
    required String key,
    required AssetKind kind,

    /// The original name of the uploaded file.
    required String fileName,
    required String contentType,

    /// Size of the stored file in bytes.
    required int size,
    required String sha1,

    /// Only set for textures.
    int? width,

    /// Only set for textures.
    int? height,

    /// Set on textures extracted from a `.bbmodel`: the id of that model.
    String? sourceAssetId,

    /// For a `.bbmodel`: the ids of the textures extracted from it.
    @Default([]) List<String> derivedAssetIds,
    DateTime? creationDate,
    DateTime? modificationDate,
  }) = _AssetModel;

  /// Creates an [AssetModel] from the backend's JSON representation.
  factory AssetModel.fromJson(Map<String, dynamic> json) =>
      _$AssetModelFromJson(json);
}
