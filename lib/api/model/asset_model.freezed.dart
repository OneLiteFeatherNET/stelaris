// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetModel {

 String get id; String get projectId;/// Minecraft resource location without file extension, e.g. `vulpes:item/ruby`.
 String get key; AssetKind get kind;/// The original name of the uploaded file.
 String get fileName; String get contentType;/// Size of the stored file in bytes.
 int get size; String get sha1;/// Only set for textures.
 int? get width;/// Only set for textures.
 int? get height;/// Set on textures extracted from a `.bbmodel`: the id of that model.
 String? get sourceAssetId;/// For a `.bbmodel`: the ids of the textures extracted from it.
 List<String> get derivedAssetIds; DateTime? get creationDate; DateTime? get modificationDate;
/// Create a copy of AssetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetModelCopyWith<AssetModel> get copyWith => _$AssetModelCopyWithImpl<AssetModel>(this as AssetModel, _$identity);

  /// Serializes this AssetModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AssetModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.projectId, _this.projectId) || other.projectId == _this.projectId)&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.contentType, _this.contentType) || other.contentType == _this.contentType)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.sha1, _this.sha1) || other.sha1 == _this.sha1)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.sourceAssetId, _this.sourceAssetId) || other.sourceAssetId == _this.sourceAssetId)&&const DeepCollectionEquality().equals(other.derivedAssetIds, _this.derivedAssetIds)&&(identical(other.creationDate, _this.creationDate) || other.creationDate == _this.creationDate)&&(identical(other.modificationDate, _this.modificationDate) || other.modificationDate == _this.modificationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AssetModel;
  return Object.hash(runtimeType,_this.id,_this.projectId,_this.key,_this.kind,_this.fileName,_this.contentType,_this.size,_this.sha1,_this.width,_this.height,_this.sourceAssetId,const DeepCollectionEquality().hash(_this.derivedAssetIds),_this.creationDate,_this.modificationDate);
}

@override
String toString() {
  final _this = this as AssetModel;
  return 'AssetModel(id: ${_this.id}, projectId: ${_this.projectId}, key: ${_this.key}, kind: ${_this.kind}, fileName: ${_this.fileName}, contentType: ${_this.contentType}, size: ${_this.size}, sha1: ${_this.sha1}, width: ${_this.width}, height: ${_this.height}, sourceAssetId: ${_this.sourceAssetId}, derivedAssetIds: ${_this.derivedAssetIds}, creationDate: ${_this.creationDate}, modificationDate: ${_this.modificationDate})';
}


}

/// @nodoc
abstract mixin class $AssetModelCopyWith<$Res>  {
  factory $AssetModelCopyWith(AssetModel value, $Res Function(AssetModel) _then) = _$AssetModelCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String key, AssetKind kind, String fileName, String contentType, int size, String sha1, int? width, int? height, String? sourceAssetId, List<String> derivedAssetIds, DateTime? creationDate, DateTime? modificationDate
});




}
/// @nodoc
class _$AssetModelCopyWithImpl<$Res>
    implements $AssetModelCopyWith<$Res> {
  _$AssetModelCopyWithImpl(this._self, this._then);

  final AssetModel _self;
  final $Res Function(AssetModel) _then;

/// Create a copy of AssetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? key = null,Object? kind = null,Object? fileName = null,Object? contentType = null,Object? size = null,Object? sha1 = null,Object? width = freezed,Object? height = freezed,Object? sourceAssetId = freezed,Object? derivedAssetIds = null,Object? creationDate = freezed,Object? modificationDate = freezed,}) {
  return _then(AssetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AssetKind,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,sha1: null == sha1 ? _self.sha1 : sha1 // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,sourceAssetId: freezed == sourceAssetId ? _self.sourceAssetId : sourceAssetId // ignore: cast_nullable_to_non_nullable
as String?,derivedAssetIds: null == derivedAssetIds ? _self.derivedAssetIds : derivedAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,creationDate: freezed == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,modificationDate: freezed == modificationDate ? _self.modificationDate : modificationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetModel].
extension AssetModelPatterns on AssetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetModel value)  $default,){
final _that = this;
switch (_that) {
case _AssetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetModel value)?  $default,){
final _that = this;
switch (_that) {
case _AssetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String key,  AssetKind kind,  String fileName,  String contentType,  int size,  String sha1,  int? width,  int? height,  String? sourceAssetId,  List<String> derivedAssetIds,  DateTime? creationDate,  DateTime? modificationDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetModel() when $default != null:
return $default(_that.id,_that.projectId,_that.key,_that.kind,_that.fileName,_that.contentType,_that.size,_that.sha1,_that.width,_that.height,_that.sourceAssetId,_that.derivedAssetIds,_that.creationDate,_that.modificationDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String key,  AssetKind kind,  String fileName,  String contentType,  int size,  String sha1,  int? width,  int? height,  String? sourceAssetId,  List<String> derivedAssetIds,  DateTime? creationDate,  DateTime? modificationDate)  $default,) {final _that = this;
switch (_that) {
case _AssetModel():
return $default(_that.id,_that.projectId,_that.key,_that.kind,_that.fileName,_that.contentType,_that.size,_that.sha1,_that.width,_that.height,_that.sourceAssetId,_that.derivedAssetIds,_that.creationDate,_that.modificationDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String key,  AssetKind kind,  String fileName,  String contentType,  int size,  String sha1,  int? width,  int? height,  String? sourceAssetId,  List<String> derivedAssetIds,  DateTime? creationDate,  DateTime? modificationDate)?  $default,) {final _that = this;
switch (_that) {
case _AssetModel() when $default != null:
return $default(_that.id,_that.projectId,_that.key,_that.kind,_that.fileName,_that.contentType,_that.size,_that.sha1,_that.width,_that.height,_that.sourceAssetId,_that.derivedAssetIds,_that.creationDate,_that.modificationDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssetModel extends AssetModel {
  const _AssetModel({required this.id, required this.projectId, required this.key, required this.kind, required this.fileName, required this.contentType, required this.size, required this.sha1, this.width, this.height, this.sourceAssetId,  List<String> derivedAssetIds = const [], this.creationDate, this.modificationDate}): _derivedAssetIds = derivedAssetIds,super._();
  factory _AssetModel.fromJson(Map<String, dynamic> json) => _$AssetModelFromJson(json);

@override final  String id;
@override final  String projectId;
/// Minecraft resource location without file extension, e.g. `vulpes:item/ruby`.
@override final  String key;
@override final  AssetKind kind;
/// The original name of the uploaded file.
@override final  String fileName;
@override final  String contentType;
/// Size of the stored file in bytes.
@override final  int size;
@override final  String sha1;
/// Only set for textures.
@override final  int? width;
/// Only set for textures.
@override final  int? height;
/// Set on textures extracted from a `.bbmodel`: the id of that model.
@override final  String? sourceAssetId;
/// For a `.bbmodel`: the ids of the textures extracted from it.
 final  List<String> _derivedAssetIds;
/// For a `.bbmodel`: the ids of the textures extracted from it.
@override@JsonKey() List<String> get derivedAssetIds {
  if (_derivedAssetIds is EqualUnmodifiableListView) return _derivedAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_derivedAssetIds);
}

@override final  DateTime? creationDate;
@override final  DateTime? modificationDate;

/// Create a copy of AssetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetModelCopyWith<_AssetModel> get copyWith => __$AssetModelCopyWithImpl<_AssetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.key, key) || other.key == key)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.size, size) || other.size == size)&&(identical(other.sha1, sha1) || other.sha1 == sha1)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.sourceAssetId, sourceAssetId) || other.sourceAssetId == sourceAssetId)&&const DeepCollectionEquality().equals(other.derivedAssetIds, _derivedAssetIds)&&(identical(other.creationDate, creationDate) || other.creationDate == creationDate)&&(identical(other.modificationDate, modificationDate) || other.modificationDate == modificationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,projectId,key,kind,fileName,contentType,size,sha1,width,height,sourceAssetId,const DeepCollectionEquality().hash(_derivedAssetIds),creationDate,modificationDate);
}

@override
String toString() {
    return 'AssetModel(id: $id, projectId: $projectId, key: $key, kind: $kind, fileName: $fileName, contentType: $contentType, size: $size, sha1: $sha1, width: $width, height: $height, sourceAssetId: $sourceAssetId, derivedAssetIds: $derivedAssetIds, creationDate: $creationDate, modificationDate: $modificationDate)';
}


}

/// @nodoc
abstract mixin class _$AssetModelCopyWith<$Res> implements $AssetModelCopyWith<$Res> {
  factory _$AssetModelCopyWith(_AssetModel value, $Res Function(_AssetModel) _then) = __$AssetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String key, AssetKind kind, String fileName, String contentType, int size, String sha1, int? width, int? height, String? sourceAssetId, List<String> derivedAssetIds, DateTime? creationDate, DateTime? modificationDate
});




}
/// @nodoc
class __$AssetModelCopyWithImpl<$Res>
    implements _$AssetModelCopyWith<$Res> {
  __$AssetModelCopyWithImpl(this._self, this._then);

  final _AssetModel _self;
  final $Res Function(_AssetModel) _then;

/// Create a copy of AssetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? key = null,Object? kind = null,Object? fileName = null,Object? contentType = null,Object? size = null,Object? sha1 = null,Object? width = freezed,Object? height = freezed,Object? sourceAssetId = freezed,Object? derivedAssetIds = null,Object? creationDate = freezed,Object? modificationDate = freezed,}) {
  return _then(_AssetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AssetKind,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,sha1: null == sha1 ? _self.sha1 : sha1 // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,sourceAssetId: freezed == sourceAssetId ? _self.sourceAssetId : sourceAssetId // ignore: cast_nullable_to_non_nullable
as String?,derivedAssetIds: null == derivedAssetIds ? _self._derivedAssetIds : derivedAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,creationDate: freezed == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,modificationDate: freezed == modificationDate ? _self.modificationDate : modificationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
