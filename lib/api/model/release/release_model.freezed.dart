// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseModel {

 String get version; DateTime get publishedAt; String? get url; bool get prerelease;// The naming of this comes from the official api https://docs.github.com/en/rest/releases/releases. Search for target_commitish
 String? get targetCommitish;
/// Create a copy of ReleaseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseModelCopyWith<ReleaseModel> get copyWith => _$ReleaseModelCopyWithImpl<ReleaseModel>(this as ReleaseModel, _$identity);

  /// Serializes this ReleaseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseModel&&(identical(other.version, version) || other.version == version)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.url, url) || other.url == url)&&(identical(other.prerelease, prerelease) || other.prerelease == prerelease)&&(identical(other.targetCommitish, targetCommitish) || other.targetCommitish == targetCommitish));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,publishedAt,url,prerelease,targetCommitish);

@override
String toString() {
  return 'ReleaseModel(version: $version, publishedAt: $publishedAt, url: $url, prerelease: $prerelease, targetCommitish: $targetCommitish)';
}


}

/// @nodoc
abstract mixin class $ReleaseModelCopyWith<$Res>  {
  factory $ReleaseModelCopyWith(ReleaseModel value, $Res Function(ReleaseModel) _then) = _$ReleaseModelCopyWithImpl;
@useResult
$Res call({
 String version, DateTime publishedAt, String? url, bool prerelease, String? targetCommitish
});




}
/// @nodoc
class _$ReleaseModelCopyWithImpl<$Res>
    implements $ReleaseModelCopyWith<$Res> {
  _$ReleaseModelCopyWithImpl(this._self, this._then);

  final ReleaseModel _self;
  final $Res Function(ReleaseModel) _then;

/// Create a copy of ReleaseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? publishedAt = null,Object? url = freezed,Object? prerelease = null,Object? targetCommitish = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,prerelease: null == prerelease ? _self.prerelease : prerelease // ignore: cast_nullable_to_non_nullable
as bool,targetCommitish: freezed == targetCommitish ? _self.targetCommitish : targetCommitish // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseModel].
extension ReleaseModelPatterns on ReleaseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseModel value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  DateTime publishedAt,  String? url,  bool prerelease,  String? targetCommitish)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseModel() when $default != null:
return $default(_that.version,_that.publishedAt,_that.url,_that.prerelease,_that.targetCommitish);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  DateTime publishedAt,  String? url,  bool prerelease,  String? targetCommitish)  $default,) {final _that = this;
switch (_that) {
case _ReleaseModel():
return $default(_that.version,_that.publishedAt,_that.url,_that.prerelease,_that.targetCommitish);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  DateTime publishedAt,  String? url,  bool prerelease,  String? targetCommitish)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseModel() when $default != null:
return $default(_that.version,_that.publishedAt,_that.url,_that.prerelease,_that.targetCommitish);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseModel extends ReleaseModel {
  const _ReleaseModel({required this.version, required this.publishedAt, this.url, this.prerelease = false, this.targetCommitish}): super._();
  factory _ReleaseModel.fromJson(Map<String, dynamic> json) => _$ReleaseModelFromJson(json);

@override final  String version;
@override final  DateTime publishedAt;
@override final  String? url;
@override@JsonKey() final  bool prerelease;
// The naming of this comes from the official api https://docs.github.com/en/rest/releases/releases. Search for target_commitish
@override final  String? targetCommitish;

/// Create a copy of ReleaseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseModelCopyWith<_ReleaseModel> get copyWith => __$ReleaseModelCopyWithImpl<_ReleaseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseModel&&(identical(other.version, version) || other.version == version)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.url, url) || other.url == url)&&(identical(other.prerelease, prerelease) || other.prerelease == prerelease)&&(identical(other.targetCommitish, targetCommitish) || other.targetCommitish == targetCommitish));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,publishedAt,url,prerelease,targetCommitish);

@override
String toString() {
  return 'ReleaseModel(version: $version, publishedAt: $publishedAt, url: $url, prerelease: $prerelease, targetCommitish: $targetCommitish)';
}


}

/// @nodoc
abstract mixin class _$ReleaseModelCopyWith<$Res> implements $ReleaseModelCopyWith<$Res> {
  factory _$ReleaseModelCopyWith(_ReleaseModel value, $Res Function(_ReleaseModel) _then) = __$ReleaseModelCopyWithImpl;
@override @useResult
$Res call({
 String version, DateTime publishedAt, String? url, bool prerelease, String? targetCommitish
});




}
/// @nodoc
class __$ReleaseModelCopyWithImpl<$Res>
    implements _$ReleaseModelCopyWith<$Res> {
  __$ReleaseModelCopyWithImpl(this._self, this._then);

  final _ReleaseModel _self;
  final $Res Function(_ReleaseModel) _then;

/// Create a copy of ReleaseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? publishedAt = null,Object? url = freezed,Object? prerelease = null,Object? targetCommitish = freezed,}) {
  return _then(_ReleaseModel(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,prerelease: null == prerelease ? _self.prerelease : prerelease // ignore: cast_nullable_to_non_nullable
as bool,targetCommitish: freezed == targetCommitish ? _self.targetCommitish : targetCommitish // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
