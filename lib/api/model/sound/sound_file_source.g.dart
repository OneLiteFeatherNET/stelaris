// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_file_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoundFileSource _$SoundFileSourceFromJson(Map<String, dynamic> json) =>
    _SoundFileSource(
      name: json['name'] as String,
      volume: (json['volume'] as num).toDouble(),
      pitch: (json['pitch'] as num).toDouble(),
      attenuationDistance: (json['attenuationDistance'] as num).toInt(),
      preload: json['preload'] as bool,
      type: json['type'] as String,
      weight: (json['weight'] as num).toInt(),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$SoundFileSourceToJson(_SoundFileSource instance) =>
    <String, dynamic>{
      'name': instance.name,
      'volume': instance.volume,
      'pitch': instance.pitch,
      'attenuationDistance': instance.attenuationDistance,
      'preload': instance.preload,
      'type': instance.type,
      'weight': instance.weight,
      'id': instance.id,
    };
