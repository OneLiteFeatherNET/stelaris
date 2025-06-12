// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_file_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoundFileSource _$SoundFileSourceFromJson(Map<String, dynamic> json) =>
    _SoundFileSource(
      name: json['name'] as String,
      id: json['id'] as String?,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      weight: (json['weight'] as num?)?.toInt(),
      attenuationDistance: (json['attenuationDistance'] as num?)?.toInt() ?? 16,
      preload: json['preload'] as bool? ?? false,
      type: json['type'] as String? ?? 'file',
    );

Map<String, dynamic> _$SoundFileSourceToJson(_SoundFileSource instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'volume': instance.volume,
      'pitch': instance.pitch,
      'weight': instance.weight,
      'attenuationDistance': instance.attenuationDistance,
      'preload': instance.preload,
      'type': instance.type,
    };
