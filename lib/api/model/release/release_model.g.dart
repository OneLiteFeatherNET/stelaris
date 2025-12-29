// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseModel _$ReleaseModelFromJson(Map<String, dynamic> json) =>
    _ReleaseModel(
      version: json['version'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      url: json['url'] as String?,
      prerelease: json['prerelease'] as bool? ?? false,
      targetCommitish: json['targetCommitish'] as String?,
    );

Map<String, dynamic> _$ReleaseModelToJson(_ReleaseModel instance) =>
    <String, dynamic>{
      'version': instance.version,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'url': instance.url,
      'prerelease': instance.prerelease,
      'targetCommitish': instance.targetCommitish,
    };
