// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'font_string_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
FontStringDTO _$FontStringDTOFromJson(
  Map<String, dynamic> json
) {
    return _FontStringDto.fromJson(
      json
    );
}

/// @nodoc
mixin _$FontStringDTO {

 String get line; String? get id; int? get orderIndex;
/// Create a copy of FontStringDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FontStringDTOCopyWith<FontStringDTO> get copyWith => _$FontStringDTOCopyWithImpl<FontStringDTO>(this as FontStringDTO, _$identity);

  /// Serializes this FontStringDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FontStringDTO&&(identical(other.line, line) || other.line == line)&&(identical(other.id, id) || other.id == id)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,line,id,orderIndex);

@override
String toString() {
  return 'FontStringDTO(line: $line, id: $id, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class $FontStringDTOCopyWith<$Res>  {
  factory $FontStringDTOCopyWith(FontStringDTO value, $Res Function(FontStringDTO) _then) = _$FontStringDTOCopyWithImpl;
@useResult
$Res call({
 String line, String? id, int? orderIndex
});




}
/// @nodoc
class _$FontStringDTOCopyWithImpl<$Res>
    implements $FontStringDTOCopyWith<$Res> {
  _$FontStringDTOCopyWithImpl(this._self, this._then);

  final FontStringDTO _self;
  final $Res Function(FontStringDTO) _then;

/// Create a copy of FontStringDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? line = null,Object? id = freezed,Object? orderIndex = freezed,}) {
  return _then(_self.copyWith(
line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: freezed == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [FontStringDTO].
extension FontStringDTOPatterns on FontStringDTO {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FontStringDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FontStringDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FontStringDto value)  $default,){
final _that = this;
switch (_that) {
case _FontStringDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FontStringDto value)?  $default,){
final _that = this;
switch (_that) {
case _FontStringDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String line,  String? id,  int? orderIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FontStringDto() when $default != null:
return $default(_that.line,_that.id,_that.orderIndex);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String line,  String? id,  int? orderIndex)  $default,) {final _that = this;
switch (_that) {
case _FontStringDto():
return $default(_that.line,_that.id,_that.orderIndex);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String line,  String? id,  int? orderIndex)?  $default,) {final _that = this;
switch (_that) {
case _FontStringDto() when $default != null:
return $default(_that.line,_that.id,_that.orderIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FontStringDto extends FontStringDTO {
  const _FontStringDto({required this.line, this.id, this.orderIndex = 0}): super._();
  factory _FontStringDto.fromJson(Map<String, dynamic> json) => _$FontStringDtoFromJson(json);

@override final  String line;
@override final  String? id;
@override@JsonKey() final  int? orderIndex;

/// Create a copy of FontStringDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FontStringDtoCopyWith<_FontStringDto> get copyWith => __$FontStringDtoCopyWithImpl<_FontStringDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FontStringDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FontStringDto&&(identical(other.line, line) || other.line == line)&&(identical(other.id, id) || other.id == id)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,line,id,orderIndex);

@override
String toString() {
  return 'FontStringDTO(line: $line, id: $id, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class _$FontStringDtoCopyWith<$Res> implements $FontStringDTOCopyWith<$Res> {
  factory _$FontStringDtoCopyWith(_FontStringDto value, $Res Function(_FontStringDto) _then) = __$FontStringDtoCopyWithImpl;
@override @useResult
$Res call({
 String line, String? id, int? orderIndex
});




}
/// @nodoc
class __$FontStringDtoCopyWithImpl<$Res>
    implements _$FontStringDtoCopyWith<$Res> {
  __$FontStringDtoCopyWithImpl(this._self, this._then);

  final _FontStringDto _self;
  final $Res Function(_FontStringDto) _then;

/// Create a copy of FontStringDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? line = null,Object? id = freezed,Object? orderIndex = freezed,}) {
  return _then(_FontStringDto(
line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: freezed == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
