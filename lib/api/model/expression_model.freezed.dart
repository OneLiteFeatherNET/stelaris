// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expression_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpressionVariable {

 String get name; ExpressionVariableType get type; String? get testValue;
/// Create a copy of ExpressionVariable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpressionVariableCopyWith<ExpressionVariable> get copyWith => _$ExpressionVariableCopyWithImpl<ExpressionVariable>(this as ExpressionVariable, _$identity);

  /// Serializes this ExpressionVariable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpressionVariable;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpressionVariable&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.testValue, _this.testValue) || other.testValue == _this.testValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpressionVariable;
  return Object.hash(runtimeType,_this.name,_this.type,_this.testValue);
}

@override
String toString() {
  final _this = this as ExpressionVariable;
  return 'ExpressionVariable(name: ${_this.name}, type: ${_this.type}, testValue: ${_this.testValue})';
}


}

/// @nodoc
abstract mixin class $ExpressionVariableCopyWith<$Res>  {
  factory $ExpressionVariableCopyWith(ExpressionVariable value, $Res Function(ExpressionVariable) _then) = _$ExpressionVariableCopyWithImpl;
@useResult
$Res call({
 String name, ExpressionVariableType type, String? testValue
});




}
/// @nodoc
class _$ExpressionVariableCopyWithImpl<$Res>
    implements $ExpressionVariableCopyWith<$Res> {
  _$ExpressionVariableCopyWithImpl(this._self, this._then);

  final ExpressionVariable _self;
  final $Res Function(ExpressionVariable) _then;

/// Create a copy of ExpressionVariable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? testValue = freezed,}) {
  return _then(ExpressionVariable(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExpressionVariableType,testValue: freezed == testValue ? _self.testValue : testValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpressionVariable].
extension ExpressionVariablePatterns on ExpressionVariable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpressionVariable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpressionVariable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpressionVariable value)  $default,){
final _that = this;
switch (_that) {
case _ExpressionVariable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpressionVariable value)?  $default,){
final _that = this;
switch (_that) {
case _ExpressionVariable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  ExpressionVariableType type,  String? testValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpressionVariable() when $default != null:
return $default(_that.name,_that.type,_that.testValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  ExpressionVariableType type,  String? testValue)  $default,) {final _that = this;
switch (_that) {
case _ExpressionVariable():
return $default(_that.name,_that.type,_that.testValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  ExpressionVariableType type,  String? testValue)?  $default,) {final _that = this;
switch (_that) {
case _ExpressionVariable() when $default != null:
return $default(_that.name,_that.type,_that.testValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpressionVariable extends ExpressionVariable {
  const _ExpressionVariable({required this.name, this.type = ExpressionVariableType.NUMBER, this.testValue}): super._();
  factory _ExpressionVariable.fromJson(Map<String, dynamic> json) => _$ExpressionVariableFromJson(json);

@override final  String name;
@override@JsonKey() final  ExpressionVariableType type;
@override final  String? testValue;

/// Create a copy of ExpressionVariable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpressionVariableCopyWith<_ExpressionVariable> get copyWith => __$ExpressionVariableCopyWithImpl<_ExpressionVariable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpressionVariableToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpressionVariable&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.testValue, testValue) || other.testValue == testValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type,testValue);
}

@override
String toString() {
    return 'ExpressionVariable(name: $name, type: $type, testValue: $testValue)';
}


}

/// @nodoc
abstract mixin class _$ExpressionVariableCopyWith<$Res> implements $ExpressionVariableCopyWith<$Res> {
  factory _$ExpressionVariableCopyWith(_ExpressionVariable value, $Res Function(_ExpressionVariable) _then) = __$ExpressionVariableCopyWithImpl;
@override @useResult
$Res call({
 String name, ExpressionVariableType type, String? testValue
});




}
/// @nodoc
class __$ExpressionVariableCopyWithImpl<$Res>
    implements _$ExpressionVariableCopyWith<$Res> {
  __$ExpressionVariableCopyWithImpl(this._self, this._then);

  final _ExpressionVariable _self;
  final $Res Function(_ExpressionVariable) _then;

/// Create a copy of ExpressionVariable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? testValue = freezed,}) {
  return _then(_ExpressionVariable(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExpressionVariableType,testValue: freezed == testValue ? _self.testValue : testValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ExpressionResult {

 String get value; String get type;
/// Create a copy of ExpressionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpressionResultCopyWith<ExpressionResult> get copyWith => _$ExpressionResultCopyWithImpl<ExpressionResult>(this as ExpressionResult, _$identity);

  /// Serializes this ExpressionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpressionResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpressionResult&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.type, _this.type) || other.type == _this.type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpressionResult;
  return Object.hash(runtimeType,_this.value,_this.type);
}

@override
String toString() {
  final _this = this as ExpressionResult;
  return 'ExpressionResult(value: ${_this.value}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $ExpressionResultCopyWith<$Res>  {
  factory $ExpressionResultCopyWith(ExpressionResult value, $Res Function(ExpressionResult) _then) = _$ExpressionResultCopyWithImpl;
@useResult
$Res call({
 String value, String type
});




}
/// @nodoc
class _$ExpressionResultCopyWithImpl<$Res>
    implements $ExpressionResultCopyWith<$Res> {
  _$ExpressionResultCopyWithImpl(this._self, this._then);

  final ExpressionResult _self;
  final $Res Function(ExpressionResult) _then;

/// Create a copy of ExpressionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? type = null,}) {
  return _then(ExpressionResult(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpressionResult].
extension ExpressionResultPatterns on ExpressionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpressionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpressionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpressionResult value)  $default,){
final _that = this;
switch (_that) {
case _ExpressionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpressionResult value)?  $default,){
final _that = this;
switch (_that) {
case _ExpressionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpressionResult() when $default != null:
return $default(_that.value,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String type)  $default,) {final _that = this;
switch (_that) {
case _ExpressionResult():
return $default(_that.value,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String type)?  $default,) {final _that = this;
switch (_that) {
case _ExpressionResult() when $default != null:
return $default(_that.value,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpressionResult implements ExpressionResult {
  const _ExpressionResult({required this.value, required this.type});
  factory _ExpressionResult.fromJson(Map<String, dynamic> json) => _$ExpressionResultFromJson(json);

@override final  String value;
@override final  String type;

/// Create a copy of ExpressionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpressionResultCopyWith<_ExpressionResult> get copyWith => __$ExpressionResultCopyWithImpl<_ExpressionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpressionResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpressionResult&&(identical(other.value, value) || other.value == value)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,value,type);
}

@override
String toString() {
    return 'ExpressionResult(value: $value, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ExpressionResultCopyWith<$Res> implements $ExpressionResultCopyWith<$Res> {
  factory _$ExpressionResultCopyWith(_ExpressionResult value, $Res Function(_ExpressionResult) _then) = __$ExpressionResultCopyWithImpl;
@override @useResult
$Res call({
 String value, String type
});




}
/// @nodoc
class __$ExpressionResultCopyWithImpl<$Res>
    implements _$ExpressionResultCopyWith<$Res> {
  __$ExpressionResultCopyWithImpl(this._self, this._then);

  final _ExpressionResult _self;
  final $Res Function(_ExpressionResult) _then;

/// Create a copy of ExpressionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? type = null,}) {
  return _then(_ExpressionResult(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ExpressionModel {

 String get uiName; String get expression; String? get id; String? get comment;@JsonKey(toJson: _variablesToJson) List<ExpressionVariable> get variables; String? get projectId; DateTime? get creationDate; DateTime? get modificationDate;
/// Create a copy of ExpressionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpressionModelCopyWith<ExpressionModel> get copyWith => _$ExpressionModelCopyWithImpl<ExpressionModel>(this as ExpressionModel, _$identity);

  /// Serializes this ExpressionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpressionModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpressionModel&&(identical(other.uiName, _this.uiName) || other.uiName == _this.uiName)&&(identical(other.expression, _this.expression) || other.expression == _this.expression)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&const DeepCollectionEquality().equals(other.variables, _this.variables)&&(identical(other.projectId, _this.projectId) || other.projectId == _this.projectId)&&(identical(other.creationDate, _this.creationDate) || other.creationDate == _this.creationDate)&&(identical(other.modificationDate, _this.modificationDate) || other.modificationDate == _this.modificationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpressionModel;
  return Object.hash(runtimeType,_this.uiName,_this.expression,_this.id,_this.comment,const DeepCollectionEquality().hash(_this.variables),_this.projectId,_this.creationDate,_this.modificationDate);
}

@override
String toString() {
  final _this = this as ExpressionModel;
  return 'ExpressionModel(uiName: ${_this.uiName}, expression: ${_this.expression}, id: ${_this.id}, comment: ${_this.comment}, variables: ${_this.variables}, projectId: ${_this.projectId}, creationDate: ${_this.creationDate}, modificationDate: ${_this.modificationDate})';
}


}

/// @nodoc
abstract mixin class $ExpressionModelCopyWith<$Res>  {
  factory $ExpressionModelCopyWith(ExpressionModel value, $Res Function(ExpressionModel) _then) = _$ExpressionModelCopyWithImpl;
@useResult
$Res call({
 String uiName, String expression, String? id, String? comment,@JsonKey(toJson: _variablesToJson) List<ExpressionVariable> variables, String? projectId, DateTime? creationDate, DateTime? modificationDate
});




}
/// @nodoc
class _$ExpressionModelCopyWithImpl<$Res>
    implements $ExpressionModelCopyWith<$Res> {
  _$ExpressionModelCopyWithImpl(this._self, this._then);

  final ExpressionModel _self;
  final $Res Function(ExpressionModel) _then;

/// Create a copy of ExpressionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uiName = null,Object? expression = null,Object? id = freezed,Object? comment = freezed,Object? variables = null,Object? projectId = freezed,Object? creationDate = freezed,Object? modificationDate = freezed,}) {
  return _then(ExpressionModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,variables: null == variables ? _self.variables : variables // ignore: cast_nullable_to_non_nullable
as List<ExpressionVariable>,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,creationDate: freezed == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,modificationDate: freezed == modificationDate ? _self.modificationDate : modificationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpressionModel].
extension ExpressionModelPatterns on ExpressionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpressionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpressionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpressionModel value)  $default,){
final _that = this;
switch (_that) {
case _ExpressionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpressionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExpressionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uiName,  String expression,  String? id,  String? comment, @JsonKey(toJson: _variablesToJson)  List<ExpressionVariable> variables,  String? projectId,  DateTime? creationDate,  DateTime? modificationDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpressionModel() when $default != null:
return $default(_that.uiName,_that.expression,_that.id,_that.comment,_that.variables,_that.projectId,_that.creationDate,_that.modificationDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uiName,  String expression,  String? id,  String? comment, @JsonKey(toJson: _variablesToJson)  List<ExpressionVariable> variables,  String? projectId,  DateTime? creationDate,  DateTime? modificationDate)  $default,) {final _that = this;
switch (_that) {
case _ExpressionModel():
return $default(_that.uiName,_that.expression,_that.id,_that.comment,_that.variables,_that.projectId,_that.creationDate,_that.modificationDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uiName,  String expression,  String? id,  String? comment, @JsonKey(toJson: _variablesToJson)  List<ExpressionVariable> variables,  String? projectId,  DateTime? creationDate,  DateTime? modificationDate)?  $default,) {final _that = this;
switch (_that) {
case _ExpressionModel() when $default != null:
return $default(_that.uiName,_that.expression,_that.id,_that.comment,_that.variables,_that.projectId,_that.creationDate,_that.modificationDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpressionModel extends ExpressionModel {
  const _ExpressionModel({required this.uiName, this.expression = '', this.id, this.comment, @JsonKey(toJson: _variablesToJson)  List<ExpressionVariable> variables = const [], this.projectId, this.creationDate, this.modificationDate}): _variables = variables,super._();
  factory _ExpressionModel.fromJson(Map<String, dynamic> json) => _$ExpressionModelFromJson(json);

@override final  String uiName;
@override@JsonKey() final  String expression;
@override final  String? id;
@override final  String? comment;
 final  List<ExpressionVariable> _variables;
@override@JsonKey(toJson: _variablesToJson) List<ExpressionVariable> get variables {
  if (_variables is EqualUnmodifiableListView) return _variables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_variables);
}

@override final  String? projectId;
@override final  DateTime? creationDate;
@override final  DateTime? modificationDate;

/// Create a copy of ExpressionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpressionModelCopyWith<_ExpressionModel> get copyWith => __$ExpressionModelCopyWithImpl<_ExpressionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpressionModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpressionModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.expression, expression) || other.expression == expression)&&(identical(other.id, id) || other.id == id)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.variables, _variables)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.creationDate, creationDate) || other.creationDate == creationDate)&&(identical(other.modificationDate, modificationDate) || other.modificationDate == modificationDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uiName,expression,id,comment,const DeepCollectionEquality().hash(_variables),projectId,creationDate,modificationDate);
}

@override
String toString() {
    return 'ExpressionModel(uiName: $uiName, expression: $expression, id: $id, comment: $comment, variables: $variables, projectId: $projectId, creationDate: $creationDate, modificationDate: $modificationDate)';
}


}

/// @nodoc
abstract mixin class _$ExpressionModelCopyWith<$Res> implements $ExpressionModelCopyWith<$Res> {
  factory _$ExpressionModelCopyWith(_ExpressionModel value, $Res Function(_ExpressionModel) _then) = __$ExpressionModelCopyWithImpl;
@override @useResult
$Res call({
 String uiName, String expression, String? id, String? comment,@JsonKey(toJson: _variablesToJson) List<ExpressionVariable> variables, String? projectId, DateTime? creationDate, DateTime? modificationDate
});




}
/// @nodoc
class __$ExpressionModelCopyWithImpl<$Res>
    implements _$ExpressionModelCopyWith<$Res> {
  __$ExpressionModelCopyWithImpl(this._self, this._then);

  final _ExpressionModel _self;
  final $Res Function(_ExpressionModel) _then;

/// Create a copy of ExpressionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uiName = null,Object? expression = null,Object? id = freezed,Object? comment = freezed,Object? variables = null,Object? projectId = freezed,Object? creationDate = freezed,Object? modificationDate = freezed,}) {
  return _then(_ExpressionModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,variables: null == variables ? _self._variables : variables // ignore: cast_nullable_to_non_nullable
as List<ExpressionVariable>,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,creationDate: freezed == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,modificationDate: freezed == modificationDate ? _self.modificationDate : modificationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
