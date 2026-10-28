// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expression_catalog_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpressionCatalog {

 String get evalexVersion; List<CatalogFunction> get functions; List<CatalogOperator> get operators; List<CatalogConstant> get constants;
/// Create a copy of ExpressionCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpressionCatalogCopyWith<ExpressionCatalog> get copyWith => _$ExpressionCatalogCopyWithImpl<ExpressionCatalog>(this as ExpressionCatalog, _$identity);

  /// Serializes this ExpressionCatalog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpressionCatalog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpressionCatalog&&(identical(other.evalexVersion, _this.evalexVersion) || other.evalexVersion == _this.evalexVersion)&&const DeepCollectionEquality().equals(other.functions, _this.functions)&&const DeepCollectionEquality().equals(other.operators, _this.operators)&&const DeepCollectionEquality().equals(other.constants, _this.constants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpressionCatalog;
  return Object.hash(runtimeType,_this.evalexVersion,const DeepCollectionEquality().hash(_this.functions),const DeepCollectionEquality().hash(_this.operators),const DeepCollectionEquality().hash(_this.constants));
}

@override
String toString() {
  final _this = this as ExpressionCatalog;
  return 'ExpressionCatalog(evalexVersion: ${_this.evalexVersion}, functions: ${_this.functions}, operators: ${_this.operators}, constants: ${_this.constants})';
}


}

/// @nodoc
abstract mixin class $ExpressionCatalogCopyWith<$Res>  {
  factory $ExpressionCatalogCopyWith(ExpressionCatalog value, $Res Function(ExpressionCatalog) _then) = _$ExpressionCatalogCopyWithImpl;
@useResult
$Res call({
 String evalexVersion, List<CatalogFunction> functions, List<CatalogOperator> operators, List<CatalogConstant> constants
});




}
/// @nodoc
class _$ExpressionCatalogCopyWithImpl<$Res>
    implements $ExpressionCatalogCopyWith<$Res> {
  _$ExpressionCatalogCopyWithImpl(this._self, this._then);

  final ExpressionCatalog _self;
  final $Res Function(ExpressionCatalog) _then;

/// Create a copy of ExpressionCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? evalexVersion = null,Object? functions = null,Object? operators = null,Object? constants = null,}) {
  return _then(ExpressionCatalog(
evalexVersion: null == evalexVersion ? _self.evalexVersion : evalexVersion // ignore: cast_nullable_to_non_nullable
as String,functions: null == functions ? _self.functions : functions // ignore: cast_nullable_to_non_nullable
as List<CatalogFunction>,operators: null == operators ? _self.operators : operators // ignore: cast_nullable_to_non_nullable
as List<CatalogOperator>,constants: null == constants ? _self.constants : constants // ignore: cast_nullable_to_non_nullable
as List<CatalogConstant>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpressionCatalog].
extension ExpressionCatalogPatterns on ExpressionCatalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpressionCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpressionCatalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpressionCatalog value)  $default,){
final _that = this;
switch (_that) {
case _ExpressionCatalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpressionCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _ExpressionCatalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String evalexVersion,  List<CatalogFunction> functions,  List<CatalogOperator> operators,  List<CatalogConstant> constants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpressionCatalog() when $default != null:
return $default(_that.evalexVersion,_that.functions,_that.operators,_that.constants);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String evalexVersion,  List<CatalogFunction> functions,  List<CatalogOperator> operators,  List<CatalogConstant> constants)  $default,) {final _that = this;
switch (_that) {
case _ExpressionCatalog():
return $default(_that.evalexVersion,_that.functions,_that.operators,_that.constants);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String evalexVersion,  List<CatalogFunction> functions,  List<CatalogOperator> operators,  List<CatalogConstant> constants)?  $default,) {final _that = this;
switch (_that) {
case _ExpressionCatalog() when $default != null:
return $default(_that.evalexVersion,_that.functions,_that.operators,_that.constants);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpressionCatalog implements ExpressionCatalog {
  const _ExpressionCatalog({this.evalexVersion = '',  List<CatalogFunction> functions = const [],  List<CatalogOperator> operators = const [],  List<CatalogConstant> constants = const []}): _functions = functions,_operators = operators,_constants = constants;
  factory _ExpressionCatalog.fromJson(Map<String, dynamic> json) => _$ExpressionCatalogFromJson(json);

@override@JsonKey() final  String evalexVersion;
 final  List<CatalogFunction> _functions;
@override@JsonKey() List<CatalogFunction> get functions {
  if (_functions is EqualUnmodifiableListView) return _functions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_functions);
}

 final  List<CatalogOperator> _operators;
@override@JsonKey() List<CatalogOperator> get operators {
  if (_operators is EqualUnmodifiableListView) return _operators;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_operators);
}

 final  List<CatalogConstant> _constants;
@override@JsonKey() List<CatalogConstant> get constants {
  if (_constants is EqualUnmodifiableListView) return _constants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_constants);
}


/// Create a copy of ExpressionCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpressionCatalogCopyWith<_ExpressionCatalog> get copyWith => __$ExpressionCatalogCopyWithImpl<_ExpressionCatalog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpressionCatalogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpressionCatalog&&(identical(other.evalexVersion, evalexVersion) || other.evalexVersion == evalexVersion)&&const DeepCollectionEquality().equals(other.functions, _functions)&&const DeepCollectionEquality().equals(other.operators, _operators)&&const DeepCollectionEquality().equals(other.constants, _constants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,evalexVersion,const DeepCollectionEquality().hash(_functions),const DeepCollectionEquality().hash(_operators),const DeepCollectionEquality().hash(_constants));
}

@override
String toString() {
    return 'ExpressionCatalog(evalexVersion: $evalexVersion, functions: $functions, operators: $operators, constants: $constants)';
}


}

/// @nodoc
abstract mixin class _$ExpressionCatalogCopyWith<$Res> implements $ExpressionCatalogCopyWith<$Res> {
  factory _$ExpressionCatalogCopyWith(_ExpressionCatalog value, $Res Function(_ExpressionCatalog) _then) = __$ExpressionCatalogCopyWithImpl;
@override @useResult
$Res call({
 String evalexVersion, List<CatalogFunction> functions, List<CatalogOperator> operators, List<CatalogConstant> constants
});




}
/// @nodoc
class __$ExpressionCatalogCopyWithImpl<$Res>
    implements _$ExpressionCatalogCopyWith<$Res> {
  __$ExpressionCatalogCopyWithImpl(this._self, this._then);

  final _ExpressionCatalog _self;
  final $Res Function(_ExpressionCatalog) _then;

/// Create a copy of ExpressionCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? evalexVersion = null,Object? functions = null,Object? operators = null,Object? constants = null,}) {
  return _then(_ExpressionCatalog(
evalexVersion: null == evalexVersion ? _self.evalexVersion : evalexVersion // ignore: cast_nullable_to_non_nullable
as String,functions: null == functions ? _self._functions : functions // ignore: cast_nullable_to_non_nullable
as List<CatalogFunction>,operators: null == operators ? _self._operators : operators // ignore: cast_nullable_to_non_nullable
as List<CatalogOperator>,constants: null == constants ? _self._constants : constants // ignore: cast_nullable_to_non_nullable
as List<CatalogConstant>,
  ));
}


}


/// @nodoc
mixin _$CatalogFunction {

 String get name;@JsonKey(unknownEnumValue: CatalogFunctionCategory.other) CatalogFunctionCategory get category; List<CatalogParameter> get parameters; String? get description;@JsonKey(fromJson: _functionKindFromJson) ExpressionFunctionKind? get kind;@JsonKey(fromJson: _functionReturnTypeFromJson) ExpressionFunctionReturnType? get returnType;
/// Create a copy of CatalogFunction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogFunctionCopyWith<CatalogFunction> get copyWith => _$CatalogFunctionCopyWithImpl<CatalogFunction>(this as CatalogFunction, _$identity);

  /// Serializes this CatalogFunction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CatalogFunction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogFunction&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.category, _this.category) || other.category == _this.category)&&const DeepCollectionEquality().equals(other.parameters, _this.parameters)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.returnType, _this.returnType) || other.returnType == _this.returnType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CatalogFunction;
  return Object.hash(runtimeType,_this.name,_this.category,const DeepCollectionEquality().hash(_this.parameters),_this.description,_this.kind,_this.returnType);
}

@override
String toString() {
  final _this = this as CatalogFunction;
  return 'CatalogFunction(name: ${_this.name}, category: ${_this.category}, parameters: ${_this.parameters}, description: ${_this.description}, kind: ${_this.kind}, returnType: ${_this.returnType})';
}


}

/// @nodoc
abstract mixin class $CatalogFunctionCopyWith<$Res>  {
  factory $CatalogFunctionCopyWith(CatalogFunction value, $Res Function(CatalogFunction) _then) = _$CatalogFunctionCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(unknownEnumValue: CatalogFunctionCategory.other) CatalogFunctionCategory category, List<CatalogParameter> parameters, String? description,@JsonKey(fromJson: _functionKindFromJson) ExpressionFunctionKind? kind,@JsonKey(fromJson: _functionReturnTypeFromJson) ExpressionFunctionReturnType? returnType
});




}
/// @nodoc
class _$CatalogFunctionCopyWithImpl<$Res>
    implements $CatalogFunctionCopyWith<$Res> {
  _$CatalogFunctionCopyWithImpl(this._self, this._then);

  final CatalogFunction _self;
  final $Res Function(CatalogFunction) _then;

/// Create a copy of CatalogFunction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? category = null,Object? parameters = null,Object? description = freezed,Object? kind = freezed,Object? returnType = freezed,}) {
  return _then(CatalogFunction(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CatalogFunctionCategory,parameters: null == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<CatalogParameter>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ExpressionFunctionKind?,returnType: freezed == returnType ? _self.returnType : returnType // ignore: cast_nullable_to_non_nullable
as ExpressionFunctionReturnType?,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogFunction].
extension CatalogFunctionPatterns on CatalogFunction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogFunction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogFunction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogFunction value)  $default,){
final _that = this;
switch (_that) {
case _CatalogFunction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogFunction value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogFunction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(unknownEnumValue: CatalogFunctionCategory.other)  CatalogFunctionCategory category,  List<CatalogParameter> parameters,  String? description, @JsonKey(fromJson: _functionKindFromJson)  ExpressionFunctionKind? kind, @JsonKey(fromJson: _functionReturnTypeFromJson)  ExpressionFunctionReturnType? returnType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogFunction() when $default != null:
return $default(_that.name,_that.category,_that.parameters,_that.description,_that.kind,_that.returnType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(unknownEnumValue: CatalogFunctionCategory.other)  CatalogFunctionCategory category,  List<CatalogParameter> parameters,  String? description, @JsonKey(fromJson: _functionKindFromJson)  ExpressionFunctionKind? kind, @JsonKey(fromJson: _functionReturnTypeFromJson)  ExpressionFunctionReturnType? returnType)  $default,) {final _that = this;
switch (_that) {
case _CatalogFunction():
return $default(_that.name,_that.category,_that.parameters,_that.description,_that.kind,_that.returnType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(unknownEnumValue: CatalogFunctionCategory.other)  CatalogFunctionCategory category,  List<CatalogParameter> parameters,  String? description, @JsonKey(fromJson: _functionKindFromJson)  ExpressionFunctionKind? kind, @JsonKey(fromJson: _functionReturnTypeFromJson)  ExpressionFunctionReturnType? returnType)?  $default,) {final _that = this;
switch (_that) {
case _CatalogFunction() when $default != null:
return $default(_that.name,_that.category,_that.parameters,_that.description,_that.kind,_that.returnType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogFunction implements CatalogFunction {
  const _CatalogFunction({required this.name, @JsonKey(unknownEnumValue: CatalogFunctionCategory.other) this.category = CatalogFunctionCategory.other,  List<CatalogParameter> parameters = const [], this.description, @JsonKey(fromJson: _functionKindFromJson) this.kind, @JsonKey(fromJson: _functionReturnTypeFromJson) this.returnType}): _parameters = parameters;
  factory _CatalogFunction.fromJson(Map<String, dynamic> json) => _$CatalogFunctionFromJson(json);

@override final  String name;
@override@JsonKey(unknownEnumValue: CatalogFunctionCategory.other) final  CatalogFunctionCategory category;
 final  List<CatalogParameter> _parameters;
@override@JsonKey() List<CatalogParameter> get parameters {
  if (_parameters is EqualUnmodifiableListView) return _parameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parameters);
}

@override final  String? description;
@override@JsonKey(fromJson: _functionKindFromJson) final  ExpressionFunctionKind? kind;
@override@JsonKey(fromJson: _functionReturnTypeFromJson) final  ExpressionFunctionReturnType? returnType;

/// Create a copy of CatalogFunction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogFunctionCopyWith<_CatalogFunction> get copyWith => __$CatalogFunctionCopyWithImpl<_CatalogFunction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogFunctionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogFunction&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.parameters, _parameters)&&(identical(other.description, description) || other.description == description)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.returnType, returnType) || other.returnType == returnType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,category,const DeepCollectionEquality().hash(_parameters),description,kind,returnType);
}

@override
String toString() {
    return 'CatalogFunction(name: $name, category: $category, parameters: $parameters, description: $description, kind: $kind, returnType: $returnType)';
}


}

/// @nodoc
abstract mixin class _$CatalogFunctionCopyWith<$Res> implements $CatalogFunctionCopyWith<$Res> {
  factory _$CatalogFunctionCopyWith(_CatalogFunction value, $Res Function(_CatalogFunction) _then) = __$CatalogFunctionCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(unknownEnumValue: CatalogFunctionCategory.other) CatalogFunctionCategory category, List<CatalogParameter> parameters, String? description,@JsonKey(fromJson: _functionKindFromJson) ExpressionFunctionKind? kind,@JsonKey(fromJson: _functionReturnTypeFromJson) ExpressionFunctionReturnType? returnType
});




}
/// @nodoc
class __$CatalogFunctionCopyWithImpl<$Res>
    implements _$CatalogFunctionCopyWith<$Res> {
  __$CatalogFunctionCopyWithImpl(this._self, this._then);

  final _CatalogFunction _self;
  final $Res Function(_CatalogFunction) _then;

/// Create a copy of CatalogFunction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? category = null,Object? parameters = null,Object? description = freezed,Object? kind = freezed,Object? returnType = freezed,}) {
  return _then(_CatalogFunction(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CatalogFunctionCategory,parameters: null == parameters ? _self._parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<CatalogParameter>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ExpressionFunctionKind?,returnType: freezed == returnType ? _self.returnType : returnType // ignore: cast_nullable_to_non_nullable
as ExpressionFunctionReturnType?,
  ));
}


}


/// @nodoc
mixin _$CatalogParameter {

 String get name;@JsonKey(fromJson: _parameterTypeFromJson) ExpressionVariableType? get type; bool get varArg; bool get lazy; bool get nonZero; bool get nonNegative;
/// Create a copy of CatalogParameter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogParameterCopyWith<CatalogParameter> get copyWith => _$CatalogParameterCopyWithImpl<CatalogParameter>(this as CatalogParameter, _$identity);

  /// Serializes this CatalogParameter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CatalogParameter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogParameter&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.varArg, _this.varArg) || other.varArg == _this.varArg)&&(identical(other.lazy, _this.lazy) || other.lazy == _this.lazy)&&(identical(other.nonZero, _this.nonZero) || other.nonZero == _this.nonZero)&&(identical(other.nonNegative, _this.nonNegative) || other.nonNegative == _this.nonNegative));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CatalogParameter;
  return Object.hash(runtimeType,_this.name,_this.type,_this.varArg,_this.lazy,_this.nonZero,_this.nonNegative);
}

@override
String toString() {
  final _this = this as CatalogParameter;
  return 'CatalogParameter(name: ${_this.name}, type: ${_this.type}, varArg: ${_this.varArg}, lazy: ${_this.lazy}, nonZero: ${_this.nonZero}, nonNegative: ${_this.nonNegative})';
}


}

/// @nodoc
abstract mixin class $CatalogParameterCopyWith<$Res>  {
  factory $CatalogParameterCopyWith(CatalogParameter value, $Res Function(CatalogParameter) _then) = _$CatalogParameterCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(fromJson: _parameterTypeFromJson) ExpressionVariableType? type, bool varArg, bool lazy, bool nonZero, bool nonNegative
});




}
/// @nodoc
class _$CatalogParameterCopyWithImpl<$Res>
    implements $CatalogParameterCopyWith<$Res> {
  _$CatalogParameterCopyWithImpl(this._self, this._then);

  final CatalogParameter _self;
  final $Res Function(CatalogParameter) _then;

/// Create a copy of CatalogParameter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = freezed,Object? varArg = null,Object? lazy = null,Object? nonZero = null,Object? nonNegative = null,}) {
  return _then(CatalogParameter(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExpressionVariableType?,varArg: null == varArg ? _self.varArg : varArg // ignore: cast_nullable_to_non_nullable
as bool,lazy: null == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool,nonZero: null == nonZero ? _self.nonZero : nonZero // ignore: cast_nullable_to_non_nullable
as bool,nonNegative: null == nonNegative ? _self.nonNegative : nonNegative // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogParameter].
extension CatalogParameterPatterns on CatalogParameter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogParameter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogParameter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogParameter value)  $default,){
final _that = this;
switch (_that) {
case _CatalogParameter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogParameter value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogParameter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(fromJson: _parameterTypeFromJson)  ExpressionVariableType? type,  bool varArg,  bool lazy,  bool nonZero,  bool nonNegative)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogParameter() when $default != null:
return $default(_that.name,_that.type,_that.varArg,_that.lazy,_that.nonZero,_that.nonNegative);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(fromJson: _parameterTypeFromJson)  ExpressionVariableType? type,  bool varArg,  bool lazy,  bool nonZero,  bool nonNegative)  $default,) {final _that = this;
switch (_that) {
case _CatalogParameter():
return $default(_that.name,_that.type,_that.varArg,_that.lazy,_that.nonZero,_that.nonNegative);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(fromJson: _parameterTypeFromJson)  ExpressionVariableType? type,  bool varArg,  bool lazy,  bool nonZero,  bool nonNegative)?  $default,) {final _that = this;
switch (_that) {
case _CatalogParameter() when $default != null:
return $default(_that.name,_that.type,_that.varArg,_that.lazy,_that.nonZero,_that.nonNegative);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogParameter implements CatalogParameter {
  const _CatalogParameter({required this.name, @JsonKey(fromJson: _parameterTypeFromJson) this.type, this.varArg = false, this.lazy = false, this.nonZero = false, this.nonNegative = false});
  factory _CatalogParameter.fromJson(Map<String, dynamic> json) => _$CatalogParameterFromJson(json);

@override final  String name;
@override@JsonKey(fromJson: _parameterTypeFromJson) final  ExpressionVariableType? type;
@override@JsonKey() final  bool varArg;
@override@JsonKey() final  bool lazy;
@override@JsonKey() final  bool nonZero;
@override@JsonKey() final  bool nonNegative;

/// Create a copy of CatalogParameter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogParameterCopyWith<_CatalogParameter> get copyWith => __$CatalogParameterCopyWithImpl<_CatalogParameter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogParameterToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogParameter&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.varArg, varArg) || other.varArg == varArg)&&(identical(other.lazy, lazy) || other.lazy == lazy)&&(identical(other.nonZero, nonZero) || other.nonZero == nonZero)&&(identical(other.nonNegative, nonNegative) || other.nonNegative == nonNegative));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type,varArg,lazy,nonZero,nonNegative);
}

@override
String toString() {
    return 'CatalogParameter(name: $name, type: $type, varArg: $varArg, lazy: $lazy, nonZero: $nonZero, nonNegative: $nonNegative)';
}


}

/// @nodoc
abstract mixin class _$CatalogParameterCopyWith<$Res> implements $CatalogParameterCopyWith<$Res> {
  factory _$CatalogParameterCopyWith(_CatalogParameter value, $Res Function(_CatalogParameter) _then) = __$CatalogParameterCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(fromJson: _parameterTypeFromJson) ExpressionVariableType? type, bool varArg, bool lazy, bool nonZero, bool nonNegative
});




}
/// @nodoc
class __$CatalogParameterCopyWithImpl<$Res>
    implements _$CatalogParameterCopyWith<$Res> {
  __$CatalogParameterCopyWithImpl(this._self, this._then);

  final _CatalogParameter _self;
  final $Res Function(_CatalogParameter) _then;

/// Create a copy of CatalogParameter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = freezed,Object? varArg = null,Object? lazy = null,Object? nonZero = null,Object? nonNegative = null,}) {
  return _then(_CatalogParameter(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ExpressionVariableType?,varArg: null == varArg ? _self.varArg : varArg // ignore: cast_nullable_to_non_nullable
as bool,lazy: null == lazy ? _self.lazy : lazy // ignore: cast_nullable_to_non_nullable
as bool,nonZero: null == nonZero ? _self.nonZero : nonZero // ignore: cast_nullable_to_non_nullable
as bool,nonNegative: null == nonNegative ? _self.nonNegative : nonNegative // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CatalogOperator {

 String get symbol;@JsonKey(unknownEnumValue: CatalogOperatorKind.other) CatalogOperatorKind get kind; int get precedence; bool get leftAssociative;
/// Create a copy of CatalogOperator
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogOperatorCopyWith<CatalogOperator> get copyWith => _$CatalogOperatorCopyWithImpl<CatalogOperator>(this as CatalogOperator, _$identity);

  /// Serializes this CatalogOperator to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CatalogOperator;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogOperator&&(identical(other.symbol, _this.symbol) || other.symbol == _this.symbol)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.precedence, _this.precedence) || other.precedence == _this.precedence)&&(identical(other.leftAssociative, _this.leftAssociative) || other.leftAssociative == _this.leftAssociative));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CatalogOperator;
  return Object.hash(runtimeType,_this.symbol,_this.kind,_this.precedence,_this.leftAssociative);
}

@override
String toString() {
  final _this = this as CatalogOperator;
  return 'CatalogOperator(symbol: ${_this.symbol}, kind: ${_this.kind}, precedence: ${_this.precedence}, leftAssociative: ${_this.leftAssociative})';
}


}

/// @nodoc
abstract mixin class $CatalogOperatorCopyWith<$Res>  {
  factory $CatalogOperatorCopyWith(CatalogOperator value, $Res Function(CatalogOperator) _then) = _$CatalogOperatorCopyWithImpl;
@useResult
$Res call({
 String symbol,@JsonKey(unknownEnumValue: CatalogOperatorKind.other) CatalogOperatorKind kind, int precedence, bool leftAssociative
});




}
/// @nodoc
class _$CatalogOperatorCopyWithImpl<$Res>
    implements $CatalogOperatorCopyWith<$Res> {
  _$CatalogOperatorCopyWithImpl(this._self, this._then);

  final CatalogOperator _self;
  final $Res Function(CatalogOperator) _then;

/// Create a copy of CatalogOperator
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? kind = null,Object? precedence = null,Object? leftAssociative = null,}) {
  return _then(CatalogOperator(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CatalogOperatorKind,precedence: null == precedence ? _self.precedence : precedence // ignore: cast_nullable_to_non_nullable
as int,leftAssociative: null == leftAssociative ? _self.leftAssociative : leftAssociative // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogOperator].
extension CatalogOperatorPatterns on CatalogOperator {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogOperator value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogOperator() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogOperator value)  $default,){
final _that = this;
switch (_that) {
case _CatalogOperator():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogOperator value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogOperator() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol, @JsonKey(unknownEnumValue: CatalogOperatorKind.other)  CatalogOperatorKind kind,  int precedence,  bool leftAssociative)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogOperator() when $default != null:
return $default(_that.symbol,_that.kind,_that.precedence,_that.leftAssociative);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol, @JsonKey(unknownEnumValue: CatalogOperatorKind.other)  CatalogOperatorKind kind,  int precedence,  bool leftAssociative)  $default,) {final _that = this;
switch (_that) {
case _CatalogOperator():
return $default(_that.symbol,_that.kind,_that.precedence,_that.leftAssociative);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol, @JsonKey(unknownEnumValue: CatalogOperatorKind.other)  CatalogOperatorKind kind,  int precedence,  bool leftAssociative)?  $default,) {final _that = this;
switch (_that) {
case _CatalogOperator() when $default != null:
return $default(_that.symbol,_that.kind,_that.precedence,_that.leftAssociative);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogOperator implements CatalogOperator {
  const _CatalogOperator({required this.symbol, @JsonKey(unknownEnumValue: CatalogOperatorKind.other) this.kind = CatalogOperatorKind.other, this.precedence = 0, this.leftAssociative = true});
  factory _CatalogOperator.fromJson(Map<String, dynamic> json) => _$CatalogOperatorFromJson(json);

@override final  String symbol;
@override@JsonKey(unknownEnumValue: CatalogOperatorKind.other) final  CatalogOperatorKind kind;
@override@JsonKey() final  int precedence;
@override@JsonKey() final  bool leftAssociative;

/// Create a copy of CatalogOperator
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogOperatorCopyWith<_CatalogOperator> get copyWith => __$CatalogOperatorCopyWithImpl<_CatalogOperator>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogOperatorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogOperator&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.precedence, precedence) || other.precedence == precedence)&&(identical(other.leftAssociative, leftAssociative) || other.leftAssociative == leftAssociative));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,symbol,kind,precedence,leftAssociative);
}

@override
String toString() {
    return 'CatalogOperator(symbol: $symbol, kind: $kind, precedence: $precedence, leftAssociative: $leftAssociative)';
}


}

/// @nodoc
abstract mixin class _$CatalogOperatorCopyWith<$Res> implements $CatalogOperatorCopyWith<$Res> {
  factory _$CatalogOperatorCopyWith(_CatalogOperator value, $Res Function(_CatalogOperator) _then) = __$CatalogOperatorCopyWithImpl;
@override @useResult
$Res call({
 String symbol,@JsonKey(unknownEnumValue: CatalogOperatorKind.other) CatalogOperatorKind kind, int precedence, bool leftAssociative
});




}
/// @nodoc
class __$CatalogOperatorCopyWithImpl<$Res>
    implements _$CatalogOperatorCopyWith<$Res> {
  __$CatalogOperatorCopyWithImpl(this._self, this._then);

  final _CatalogOperator _self;
  final $Res Function(_CatalogOperator) _then;

/// Create a copy of CatalogOperator
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? kind = null,Object? precedence = null,Object? leftAssociative = null,}) {
  return _then(_CatalogOperator(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CatalogOperatorKind,precedence: null == precedence ? _self.precedence : precedence // ignore: cast_nullable_to_non_nullable
as int,leftAssociative: null == leftAssociative ? _self.leftAssociative : leftAssociative // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CatalogConstant {

 String get name;@JsonKey(unknownEnumValue: CatalogConstantType.other) CatalogConstantType get type; String get value;
/// Create a copy of CatalogConstant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogConstantCopyWith<CatalogConstant> get copyWith => _$CatalogConstantCopyWithImpl<CatalogConstant>(this as CatalogConstant, _$identity);

  /// Serializes this CatalogConstant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CatalogConstant;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogConstant&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CatalogConstant;
  return Object.hash(runtimeType,_this.name,_this.type,_this.value);
}

@override
String toString() {
  final _this = this as CatalogConstant;
  return 'CatalogConstant(name: ${_this.name}, type: ${_this.type}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $CatalogConstantCopyWith<$Res>  {
  factory $CatalogConstantCopyWith(CatalogConstant value, $Res Function(CatalogConstant) _then) = _$CatalogConstantCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(unknownEnumValue: CatalogConstantType.other) CatalogConstantType type, String value
});




}
/// @nodoc
class _$CatalogConstantCopyWithImpl<$Res>
    implements $CatalogConstantCopyWith<$Res> {
  _$CatalogConstantCopyWithImpl(this._self, this._then);

  final CatalogConstant _self;
  final $Res Function(CatalogConstant) _then;

/// Create a copy of CatalogConstant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? value = null,}) {
  return _then(CatalogConstant(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CatalogConstantType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogConstant].
extension CatalogConstantPatterns on CatalogConstant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogConstant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogConstant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogConstant value)  $default,){
final _that = this;
switch (_that) {
case _CatalogConstant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogConstant value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogConstant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(unknownEnumValue: CatalogConstantType.other)  CatalogConstantType type,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogConstant() when $default != null:
return $default(_that.name,_that.type,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(unknownEnumValue: CatalogConstantType.other)  CatalogConstantType type,  String value)  $default,) {final _that = this;
switch (_that) {
case _CatalogConstant():
return $default(_that.name,_that.type,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(unknownEnumValue: CatalogConstantType.other)  CatalogConstantType type,  String value)?  $default,) {final _that = this;
switch (_that) {
case _CatalogConstant() when $default != null:
return $default(_that.name,_that.type,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogConstant implements CatalogConstant {
  const _CatalogConstant({required this.name, @JsonKey(unknownEnumValue: CatalogConstantType.other) this.type = CatalogConstantType.other, this.value = ''});
  factory _CatalogConstant.fromJson(Map<String, dynamic> json) => _$CatalogConstantFromJson(json);

@override final  String name;
@override@JsonKey(unknownEnumValue: CatalogConstantType.other) final  CatalogConstantType type;
@override@JsonKey() final  String value;

/// Create a copy of CatalogConstant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogConstantCopyWith<_CatalogConstant> get copyWith => __$CatalogConstantCopyWithImpl<_CatalogConstant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogConstantToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogConstant&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type,value);
}

@override
String toString() {
    return 'CatalogConstant(name: $name, type: $type, value: $value)';
}


}

/// @nodoc
abstract mixin class _$CatalogConstantCopyWith<$Res> implements $CatalogConstantCopyWith<$Res> {
  factory _$CatalogConstantCopyWith(_CatalogConstant value, $Res Function(_CatalogConstant) _then) = __$CatalogConstantCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(unknownEnumValue: CatalogConstantType.other) CatalogConstantType type, String value
});




}
/// @nodoc
class __$CatalogConstantCopyWithImpl<$Res>
    implements _$CatalogConstantCopyWith<$Res> {
  __$CatalogConstantCopyWithImpl(this._self, this._then);

  final _CatalogConstant _self;
  final $Res Function(_CatalogConstant) _then;

/// Create a copy of CatalogConstant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? value = null,}) {
  return _then(_CatalogConstant(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CatalogConstantType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
