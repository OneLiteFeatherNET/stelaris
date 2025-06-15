// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sound_file_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoundFileSource {

 String get name; double get volume; double get pitch; int get attenuationDistance; bool get preload; String get type; int get weight; String? get id;
/// Create a copy of SoundFileSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoundFileSourceCopyWith<SoundFileSource> get copyWith => _$SoundFileSourceCopyWithImpl<SoundFileSource>(this as SoundFileSource, _$identity);

  /// Serializes this SoundFileSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoundFileSource&&(identical(other.name, name) || other.name == name)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.attenuationDistance, attenuationDistance) || other.attenuationDistance == attenuationDistance)&&(identical(other.preload, preload) || other.preload == preload)&&(identical(other.type, type) || other.type == type)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,volume,pitch,attenuationDistance,preload,type,weight,id);

@override
String toString() {
  return 'SoundFileSource(name: $name, volume: $volume, pitch: $pitch, attenuationDistance: $attenuationDistance, preload: $preload, type: $type, weight: $weight, id: $id)';
}


}

/// @nodoc
abstract mixin class $SoundFileSourceCopyWith<$Res>  {
  factory $SoundFileSourceCopyWith(SoundFileSource value, $Res Function(SoundFileSource) _then) = _$SoundFileSourceCopyWithImpl;
@useResult
$Res call({
 String name, double volume, double pitch, int attenuationDistance, bool preload, String type, int weight, String? id
});




}
/// @nodoc
class _$SoundFileSourceCopyWithImpl<$Res>
    implements $SoundFileSourceCopyWith<$Res> {
  _$SoundFileSourceCopyWithImpl(this._self, this._then);

  final SoundFileSource _self;
  final $Res Function(SoundFileSource) _then;

/// Create a copy of SoundFileSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? volume = null,Object? pitch = null,Object? attenuationDistance = null,Object? preload = null,Object? type = null,Object? weight = null,Object? id = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as double,attenuationDistance: null == attenuationDistance ? _self.attenuationDistance : attenuationDistance // ignore: cast_nullable_to_non_nullable
as int,preload: null == preload ? _self.preload : preload // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as int,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SoundFileSource extends SoundFileSource {
  const _SoundFileSource({required this.name, required this.volume, required this.pitch, required this.attenuationDistance, required this.preload, required this.type, required this.weight, this.id}): super._();
  factory _SoundFileSource.fromJson(Map<String, dynamic> json) => _$SoundFileSourceFromJson(json);

@override final  String name;
@override final  double volume;
@override final  double pitch;
@override final  int attenuationDistance;
@override final  bool preload;
@override final  String type;
@override final  int weight;
@override final  String? id;

/// Create a copy of SoundFileSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoundFileSourceCopyWith<_SoundFileSource> get copyWith => __$SoundFileSourceCopyWithImpl<_SoundFileSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoundFileSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoundFileSource&&(identical(other.name, name) || other.name == name)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.attenuationDistance, attenuationDistance) || other.attenuationDistance == attenuationDistance)&&(identical(other.preload, preload) || other.preload == preload)&&(identical(other.type, type) || other.type == type)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,volume,pitch,attenuationDistance,preload,type,weight,id);

@override
String toString() {
  return 'SoundFileSource(name: $name, volume: $volume, pitch: $pitch, attenuationDistance: $attenuationDistance, preload: $preload, type: $type, weight: $weight, id: $id)';
}


}

/// @nodoc
abstract mixin class _$SoundFileSourceCopyWith<$Res> implements $SoundFileSourceCopyWith<$Res> {
  factory _$SoundFileSourceCopyWith(_SoundFileSource value, $Res Function(_SoundFileSource) _then) = __$SoundFileSourceCopyWithImpl;
@override @useResult
$Res call({
 String name, double volume, double pitch, int attenuationDistance, bool preload, String type, int weight, String? id
});




}
/// @nodoc
class __$SoundFileSourceCopyWithImpl<$Res>
    implements _$SoundFileSourceCopyWith<$Res> {
  __$SoundFileSourceCopyWithImpl(this._self, this._then);

  final _SoundFileSource _self;
  final $Res Function(_SoundFileSource) _then;

/// Create a copy of SoundFileSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? volume = null,Object? pitch = null,Object? attenuationDistance = null,Object? preload = null,Object? type = null,Object? weight = null,Object? id = freezed,}) {
  return _then(_SoundFileSource(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as double,attenuationDistance: null == attenuationDistance ? _self.attenuationDistance : attenuationDistance // ignore: cast_nullable_to_non_nullable
as int,preload: null == preload ? _self.preload : preload // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as int,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
