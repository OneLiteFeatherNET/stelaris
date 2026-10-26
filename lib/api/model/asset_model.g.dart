// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetModel _$AssetModelFromJson(Map<String, dynamic> json) => _AssetModel(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  key: json['key'] as String,
  kind: $enumDecode(_$AssetKindEnumMap, json['kind']),
  fileName: json['fileName'] as String,
  contentType: json['contentType'] as String,
  size: (json['size'] as num).toInt(),
  sha1: json['sha1'] as String,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  sourceAssetId: json['sourceAssetId'] as String?,
  derivedAssetIds:
      (json['derivedAssetIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  creationDate: json['creationDate'] == null
      ? null
      : DateTime.parse(json['creationDate'] as String),
  modificationDate: json['modificationDate'] == null
      ? null
      : DateTime.parse(json['modificationDate'] as String),
);

Map<String, dynamic> _$AssetModelToJson(_AssetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'key': instance.key,
      'kind': _$AssetKindEnumMap[instance.kind]!,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
      'size': instance.size,
      'sha1': instance.sha1,
      'width': instance.width,
      'height': instance.height,
      'sourceAssetId': instance.sourceAssetId,
      'derivedAssetIds': instance.derivedAssetIds,
      'creationDate': instance.creationDate?.toIso8601String(),
      'modificationDate': instance.modificationDate?.toIso8601String(),
    };

const _$AssetKindEnumMap = {
  AssetKind.TEXTURE: 'TEXTURE',
  AssetKind.MODEL: 'MODEL',
  AssetKind.BBMODEL: 'BBMODEL',
};
