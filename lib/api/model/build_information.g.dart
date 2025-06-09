// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_information.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuildInformation _$BuildInformationFromJson(Map<String, dynamic> json) =>
    _BuildInformation(
      data: (json['data'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$BuildInformationToJson(_BuildInformation instance) =>
    <String, dynamic>{'data': instance.data};
