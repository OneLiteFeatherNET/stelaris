// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expression_function_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpressionFunctionModel {

 String get uiName; String get name; ExpressionFunctionKind get kind; ExpressionFunctionReturnType get returnType;@JsonKey(toJson: _parametersToJson) List<ExpressionVariable> get parameters; String? get body; String? get comment; String? get id; String? get projectId; DateTime? get creationDate; DateTime? get modificationDate;
/// Create a copy of ExpressionFunctionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpressionFunctionModelCopyWith<ExpressionFunctionModel> get copyWith => _$ExpressionFunctionModelCopyWithImpl<ExpressionFunctionModel>(this as ExpressionFunctionModel, _$identity);

  /// Serializes this ExpressionFunctionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpressionFunctionModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpressionFunctionModel&&(identical(other.uiName, _this.uiName) || other.uiName == _this.uiName)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.returnType, _this.returnType) || other.returnType == _this.returnType)&&const DeepCollectionEquality().equals(other.parameters, _this.parameters)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.projectId, _this.projectId) || other.projectId == _this.projectId)&&(identical(other.creationDate, _this.creationDate) || other.creationDate == _this.creationDate)&&(identical(other.modificationDate, _this.modificationDate) || other.modificationDate == _this.modificationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpressionFunctionModel;
  return Object.hash(runtimeType,_this.uiName,_this.name,_this.kind,_this.returnType,const DeepCollectionEquality().hash(_this.parameters),_this.body,_this.comment,_this.id,_this.projectId,_this.creationDate,_this.modificationDate);
}

@override
String toString() {
  final _this = this as ExpressionFunctionModel;
  return 'ExpressionFunctionModel(uiName: ${_this.uiName}, name: ${_this.name}, kind: ${_this.kind}, returnType: ${_this.returnType}, parameters: ${_this.parameters}, body: ${_this.body}, comment: ${_this.comment}, id: ${_this.id}, projectId: ${_this.projectId}, creationDate: ${_this.creationDate}, modificationDate: ${_this.modificationDate})';
}


}

/// @nodoc
abstract mixin class $ExpressionFunctionModelCopyWith<$Res>  {
  factory $ExpressionFunctionModelCopyWith(ExpressionFunctionModel value, $Res Function(ExpressionFunctionModel) _then) = _$ExpressionFunctionModelCopyWithImpl;
@useResult
$Res call({
 String uiName, String name, ExpressionFunctionKind kind, ExpressionFunctionReturnType returnType,@JsonKey(toJson: _parametersToJson) List<ExpressionVariable> parameters, String? body, String? comment, String? id, String? projectId, DateTime? creationDate, DateTime? modificationDate
});




}
/// @nodoc
class _$ExpressionFunctionModelCopyWithImpl<$Res>
    implements $ExpressionFunctionModelCopyWith<$Res> {
  _$ExpressionFunctionModelCopyWithImpl(this._self, this._then);

  final ExpressionFunctionModel _self;
  final $Res Function(ExpressionFunctionModel) _then;

/// Create a copy of ExpressionFunctionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uiName = null,Object? name = null,Object? kind = null,Object? returnType = null,Object? parameters = null,Object? body = freezed,Object? comment = freezed,Object? id = freezed,Object? projectId = freezed,Object? creationDate = freezed,Object? modificationDate = freezed,}) {
  return _then(ExpressionFunctionModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ExpressionFunctionKind,returnType: null == returnType ? _self.returnType : returnType // ignore: cast_nullable_to_non_nullable
as ExpressionFunctionReturnType,parameters: null == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<ExpressionVariable>,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,creationDate: freezed == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,modificationDate: freezed == modificationDate ? _self.modificationDate : modificationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpressionFunctionModel].
extension ExpressionFunctionModelPatterns on ExpressionFunctionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpressionFunctionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpressionFunctionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpressionFunctionModel value)  $default,){
final _that = this;
switch (_that) {
case _ExpressionFunctionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpressionFunctionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExpressionFunctionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uiName,  String name,  ExpressionFunctionKind kind,  ExpressionFunctionReturnType returnType, @JsonKey(toJson: _parametersToJson)  List<ExpressionVariable> parameters,  String? body,  String? comment,  String? id,  String? projectId,  DateTime? creationDate,  DateTime? modificationDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpressionFunctionModel() when $default != null:
return $default(_that.uiName,_that.name,_that.kind,_that.returnType,_that.parameters,_that.body,_that.comment,_that.id,_that.projectId,_that.creationDate,_that.modificationDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uiName,  String name,  ExpressionFunctionKind kind,  ExpressionFunctionReturnType returnType, @JsonKey(toJson: _parametersToJson)  List<ExpressionVariable> parameters,  String? body,  String? comment,  String? id,  String? projectId,  DateTime? creationDate,  DateTime? modificationDate)  $default,) {final _that = this;
switch (_that) {
case _ExpressionFunctionModel():
return $default(_that.uiName,_that.name,_that.kind,_that.returnType,_that.parameters,_that.body,_that.comment,_that.id,_that.projectId,_that.creationDate,_that.modificationDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uiName,  String name,  ExpressionFunctionKind kind,  ExpressionFunctionReturnType returnType, @JsonKey(toJson: _parametersToJson)  List<ExpressionVariable> parameters,  String? body,  String? comment,  String? id,  String? projectId,  DateTime? creationDate,  DateTime? modificationDate)?  $default,) {final _that = this;
switch (_that) {
case _ExpressionFunctionModel() when $default != null:
return $default(_that.uiName,_that.name,_that.kind,_that.returnType,_that.parameters,_that.body,_that.comment,_that.id,_that.projectId,_that.creationDate,_that.modificationDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpressionFunctionModel extends ExpressionFunctionModel {
  const _ExpressionFunctionModel({required this.uiName, this.name = '', this.kind = ExpressionFunctionKind.FORMULA, this.returnType = ExpressionFunctionReturnType.NUMBER, @JsonKey(toJson: _parametersToJson)  List<ExpressionVariable> parameters = const [], this.body, this.comment, this.id, this.projectId, this.creationDate, this.modificationDate}): _parameters = parameters,super._();
  factory _ExpressionFunctionModel.fromJson(Map<String, dynamic> json) => _$ExpressionFunctionModelFromJson(json);

@override final  String uiName;
@override@JsonKey() final  String name;
@override@JsonKey() final  ExpressionFunctionKind kind;
@override@JsonKey() final  ExpressionFunctionReturnType returnType;
 final  List<ExpressionVariable> _parameters;
@override@JsonKey(toJson: _parametersToJson) List<ExpressionVariable> get parameters {
  if (_parameters is EqualUnmodifiableListView) return _parameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parameters);
}

@override final  String? body;
@override final  String? comment;
@override final  String? id;
@override final  String? projectId;
@override final  DateTime? creationDate;
@override final  DateTime? modificationDate;

/// Create a copy of ExpressionFunctionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpressionFunctionModelCopyWith<_ExpressionFunctionModel> get copyWith => __$ExpressionFunctionModelCopyWithImpl<_ExpressionFunctionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpressionFunctionModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpressionFunctionModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.returnType, returnType) || other.returnType == returnType)&&const DeepCollectionEquality().equals(other.parameters, _parameters)&&(identical(other.body, body) || other.body == body)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.creationDate, creationDate) || other.creationDate == creationDate)&&(identical(other.modificationDate, modificationDate) || other.modificationDate == modificationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uiName,name,kind,returnType,const DeepCollectionEquality().hash(_parameters),body,comment,id,projectId,creationDate,modificationDate);
}

@override
String toString() {
    return 'ExpressionFunctionModel(uiName: $uiName, name: $name, kind: $kind, returnType: $returnType, parameters: $parameters, body: $body, comment: $comment, id: $id, projectId: $projectId, creationDate: $creationDate, modificationDate: $modificationDate)';
}


}

/// @nodoc
abstract mixin class _$ExpressionFunctionModelCopyWith<$Res> implements $ExpressionFunctionModelCopyWith<$Res> {
  factory _$ExpressionFunctionModelCopyWith(_ExpressionFunctionModel value, $Res Function(_ExpressionFunctionModel) _then) = __$ExpressionFunctionModelCopyWithImpl;
@override @useResult
$Res call({
 String uiName, String name, ExpressionFunctionKind kind, ExpressionFunctionReturnType returnType,@JsonKey(toJson: _parametersToJson) List<ExpressionVariable> parameters, String? body, String? comment, String? id, String? projectId, DateTime? creationDate, DateTime? modificationDate
});




}
/// @nodoc
class __$ExpressionFunctionModelCopyWithImpl<$Res>
    implements _$ExpressionFunctionModelCopyWith<$Res> {
  __$ExpressionFunctionModelCopyWithImpl(this._self, this._then);

  final _ExpressionFunctionModel _self;
  final $Res Function(_ExpressionFunctionModel) _then;

/// Create a copy of ExpressionFunctionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uiName = null,Object? name = null,Object? kind = null,Object? returnType = null,Object? parameters = null,Object? body = freezed,Object? comment = freezed,Object? id = freezed,Object? projectId = freezed,Object? creationDate = freezed,Object? modificationDate = freezed,}) {
  return _then(_ExpressionFunctionModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ExpressionFunctionKind,returnType: null == returnType ? _self.returnType : returnType // ignore: cast_nullable_to_non_nullable
as ExpressionFunctionReturnType,parameters: null == parameters ? _self._parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<ExpressionVariable>,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,creationDate: freezed == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,modificationDate: freezed == modificationDate ? _self.modificationDate : modificationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ExpressionFunctionInterface {

 String get language; String get typeName; String get source;
/// Create a copy of ExpressionFunctionInterface
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpressionFunctionInterfaceCopyWith<ExpressionFunctionInterface> get copyWith => _$ExpressionFunctionInterfaceCopyWithImpl<ExpressionFunctionInterface>(this as ExpressionFunctionInterface, _$identity);

  /// Serializes this ExpressionFunctionInterface to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpressionFunctionInterface;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpressionFunctionInterface&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.typeName, _this.typeName) || other.typeName == _this.typeName)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpressionFunctionInterface;
  return Object.hash(runtimeType,_this.language,_this.typeName,_this.source);
}

@override
String toString() {
  final _this = this as ExpressionFunctionInterface;
  return 'ExpressionFunctionInterface(language: ${_this.language}, typeName: ${_this.typeName}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $ExpressionFunctionInterfaceCopyWith<$Res>  {
  factory $ExpressionFunctionInterfaceCopyWith(ExpressionFunctionInterface value, $Res Function(ExpressionFunctionInterface) _then) = _$ExpressionFunctionInterfaceCopyWithImpl;
@useResult
$Res call({
 String language, String typeName, String source
});




}
/// @nodoc
class _$ExpressionFunctionInterfaceCopyWithImpl<$Res>
    implements $ExpressionFunctionInterfaceCopyWith<$Res> {
  _$ExpressionFunctionInterfaceCopyWithImpl(this._self, this._then);

  final ExpressionFunctionInterface _self;
  final $Res Function(ExpressionFunctionInterface) _then;

/// Create a copy of ExpressionFunctionInterface
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? typeName = null,Object? source = null,}) {
  return _then(ExpressionFunctionInterface(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,typeName: null == typeName ? _self.typeName : typeName // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpressionFunctionInterface].
extension ExpressionFunctionInterfacePatterns on ExpressionFunctionInterface {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpressionFunctionInterface value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpressionFunctionInterface() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpressionFunctionInterface value)  $default,){
final _that = this;
switch (_that) {
case _ExpressionFunctionInterface():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpressionFunctionInterface value)?  $default,){
final _that = this;
switch (_that) {
case _ExpressionFunctionInterface() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String language,  String typeName,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpressionFunctionInterface() when $default != null:
return $default(_that.language,_that.typeName,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String language,  String typeName,  String source)  $default,) {final _that = this;
switch (_that) {
case _ExpressionFunctionInterface():
return $default(_that.language,_that.typeName,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String language,  String typeName,  String source)?  $default,) {final _that = this;
switch (_that) {
case _ExpressionFunctionInterface() when $default != null:
return $default(_that.language,_that.typeName,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpressionFunctionInterface implements ExpressionFunctionInterface {
  const _ExpressionFunctionInterface({this.language = 'java', this.typeName = '', this.source = ''});
  factory _ExpressionFunctionInterface.fromJson(Map<String, dynamic> json) => _$ExpressionFunctionInterfaceFromJson(json);

@override@JsonKey() final  String language;
@override@JsonKey() final  String typeName;
@override@JsonKey() final  String source;

/// Create a copy of ExpressionFunctionInterface
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpressionFunctionInterfaceCopyWith<_ExpressionFunctionInterface> get copyWith => __$ExpressionFunctionInterfaceCopyWithImpl<_ExpressionFunctionInterface>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpressionFunctionInterfaceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpressionFunctionInterface&&(identical(other.language, language) || other.language == language)&&(identical(other.typeName, typeName) || other.typeName == typeName)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,language,typeName,source);
}

@override
String toString() {
    return 'ExpressionFunctionInterface(language: $language, typeName: $typeName, source: $source)';
}


}

/// @nodoc
abstract mixin class _$ExpressionFunctionInterfaceCopyWith<$Res> implements $ExpressionFunctionInterfaceCopyWith<$Res> {
  factory _$ExpressionFunctionInterfaceCopyWith(_ExpressionFunctionInterface value, $Res Function(_ExpressionFunctionInterface) _then) = __$ExpressionFunctionInterfaceCopyWithImpl;
@override @useResult
$Res call({
 String language, String typeName, String source
});




}
/// @nodoc
class __$ExpressionFunctionInterfaceCopyWithImpl<$Res>
    implements _$ExpressionFunctionInterfaceCopyWith<$Res> {
  __$ExpressionFunctionInterfaceCopyWithImpl(this._self, this._then);

  final _ExpressionFunctionInterface _self;
  final $Res Function(_ExpressionFunctionInterface) _then;

/// Create a copy of ExpressionFunctionInterface
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? typeName = null,Object? source = null,}) {
  return _then(_ExpressionFunctionInterface(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,typeName: null == typeName ? _self.typeName : typeName // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
