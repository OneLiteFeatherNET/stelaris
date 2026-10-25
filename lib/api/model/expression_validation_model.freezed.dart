// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expression_validation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpressionValidationError {

 String get message; int get start; int get end;
/// Create a copy of ExpressionValidationError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpressionValidationErrorCopyWith<ExpressionValidationError> get copyWith => _$ExpressionValidationErrorCopyWithImpl<ExpressionValidationError>(this as ExpressionValidationError, _$identity);

  /// Serializes this ExpressionValidationError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpressionValidationError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpressionValidationError&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpressionValidationError;
  return Object.hash(runtimeType,_this.message,_this.start,_this.end);
}

@override
String toString() {
  final _this = this as ExpressionValidationError;
  return 'ExpressionValidationError(message: ${_this.message}, start: ${_this.start}, end: ${_this.end})';
}


}

/// @nodoc
abstract mixin class $ExpressionValidationErrorCopyWith<$Res>  {
  factory $ExpressionValidationErrorCopyWith(ExpressionValidationError value, $Res Function(ExpressionValidationError) _then) = _$ExpressionValidationErrorCopyWithImpl;
@useResult
$Res call({
 String message, int start, int end
});




}
/// @nodoc
class _$ExpressionValidationErrorCopyWithImpl<$Res>
    implements $ExpressionValidationErrorCopyWith<$Res> {
  _$ExpressionValidationErrorCopyWithImpl(this._self, this._then);

  final ExpressionValidationError _self;
  final $Res Function(ExpressionValidationError) _then;

/// Create a copy of ExpressionValidationError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? start = null,Object? end = null,}) {
  return _then(ExpressionValidationError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpressionValidationError].
extension ExpressionValidationErrorPatterns on ExpressionValidationError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpressionValidationError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpressionValidationError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpressionValidationError value)  $default,){
final _that = this;
switch (_that) {
case _ExpressionValidationError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpressionValidationError value)?  $default,){
final _that = this;
switch (_that) {
case _ExpressionValidationError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  int start,  int end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpressionValidationError() when $default != null:
return $default(_that.message,_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  int start,  int end)  $default,) {final _that = this;
switch (_that) {
case _ExpressionValidationError():
return $default(_that.message,_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  int start,  int end)?  $default,) {final _that = this;
switch (_that) {
case _ExpressionValidationError() when $default != null:
return $default(_that.message,_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpressionValidationError implements ExpressionValidationError {
  const _ExpressionValidationError({required this.message, required this.start, required this.end});
  factory _ExpressionValidationError.fromJson(Map<String, dynamic> json) => _$ExpressionValidationErrorFromJson(json);

@override final  String message;
@override final  int start;
@override final  int end;

/// Create a copy of ExpressionValidationError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpressionValidationErrorCopyWith<_ExpressionValidationError> get copyWith => __$ExpressionValidationErrorCopyWithImpl<_ExpressionValidationError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpressionValidationErrorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpressionValidationError&&(identical(other.message, message) || other.message == message)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message,start,end);
}

@override
String toString() {
    return 'ExpressionValidationError(message: $message, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$ExpressionValidationErrorCopyWith<$Res> implements $ExpressionValidationErrorCopyWith<$Res> {
  factory _$ExpressionValidationErrorCopyWith(_ExpressionValidationError value, $Res Function(_ExpressionValidationError) _then) = __$ExpressionValidationErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, int start, int end
});




}
/// @nodoc
class __$ExpressionValidationErrorCopyWithImpl<$Res>
    implements _$ExpressionValidationErrorCopyWith<$Res> {
  __$ExpressionValidationErrorCopyWithImpl(this._self, this._then);

  final _ExpressionValidationError _self;
  final $Res Function(_ExpressionValidationError) _then;

/// Create a copy of ExpressionValidationError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? start = null,Object? end = null,}) {
  return _then(_ExpressionValidationError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExpressionValidation {

 bool get valid; List<ExpressionValidationError> get errors; List<String> get usedVariables; List<String> get undefinedVariables; List<String> get unusedVariables;
/// Create a copy of ExpressionValidation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpressionValidationCopyWith<ExpressionValidation> get copyWith => _$ExpressionValidationCopyWithImpl<ExpressionValidation>(this as ExpressionValidation, _$identity);

  /// Serializes this ExpressionValidation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpressionValidation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpressionValidation&&(identical(other.valid, _this.valid) || other.valid == _this.valid)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&const DeepCollectionEquality().equals(other.usedVariables, _this.usedVariables)&&const DeepCollectionEquality().equals(other.undefinedVariables, _this.undefinedVariables)&&const DeepCollectionEquality().equals(other.unusedVariables, _this.unusedVariables));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpressionValidation;
  return Object.hash(runtimeType,_this.valid,const DeepCollectionEquality().hash(_this.errors),const DeepCollectionEquality().hash(_this.usedVariables),const DeepCollectionEquality().hash(_this.undefinedVariables),const DeepCollectionEquality().hash(_this.unusedVariables));
}

@override
String toString() {
  final _this = this as ExpressionValidation;
  return 'ExpressionValidation(valid: ${_this.valid}, errors: ${_this.errors}, usedVariables: ${_this.usedVariables}, undefinedVariables: ${_this.undefinedVariables}, unusedVariables: ${_this.unusedVariables})';
}


}

/// @nodoc
abstract mixin class $ExpressionValidationCopyWith<$Res>  {
  factory $ExpressionValidationCopyWith(ExpressionValidation value, $Res Function(ExpressionValidation) _then) = _$ExpressionValidationCopyWithImpl;
@useResult
$Res call({
 bool valid, List<ExpressionValidationError> errors, List<String> usedVariables, List<String> undefinedVariables, List<String> unusedVariables
});




}
/// @nodoc
class _$ExpressionValidationCopyWithImpl<$Res>
    implements $ExpressionValidationCopyWith<$Res> {
  _$ExpressionValidationCopyWithImpl(this._self, this._then);

  final ExpressionValidation _self;
  final $Res Function(ExpressionValidation) _then;

/// Create a copy of ExpressionValidation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valid = null,Object? errors = null,Object? usedVariables = null,Object? undefinedVariables = null,Object? unusedVariables = null,}) {
  return _then(ExpressionValidation(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<ExpressionValidationError>,usedVariables: null == usedVariables ? _self.usedVariables : usedVariables // ignore: cast_nullable_to_non_nullable
as List<String>,undefinedVariables: null == undefinedVariables ? _self.undefinedVariables : undefinedVariables // ignore: cast_nullable_to_non_nullable
as List<String>,unusedVariables: null == unusedVariables ? _self.unusedVariables : unusedVariables // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpressionValidation].
extension ExpressionValidationPatterns on ExpressionValidation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpressionValidation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpressionValidation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpressionValidation value)  $default,){
final _that = this;
switch (_that) {
case _ExpressionValidation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpressionValidation value)?  $default,){
final _that = this;
switch (_that) {
case _ExpressionValidation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool valid,  List<ExpressionValidationError> errors,  List<String> usedVariables,  List<String> undefinedVariables,  List<String> unusedVariables)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpressionValidation() when $default != null:
return $default(_that.valid,_that.errors,_that.usedVariables,_that.undefinedVariables,_that.unusedVariables);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool valid,  List<ExpressionValidationError> errors,  List<String> usedVariables,  List<String> undefinedVariables,  List<String> unusedVariables)  $default,) {final _that = this;
switch (_that) {
case _ExpressionValidation():
return $default(_that.valid,_that.errors,_that.usedVariables,_that.undefinedVariables,_that.unusedVariables);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool valid,  List<ExpressionValidationError> errors,  List<String> usedVariables,  List<String> undefinedVariables,  List<String> unusedVariables)?  $default,) {final _that = this;
switch (_that) {
case _ExpressionValidation() when $default != null:
return $default(_that.valid,_that.errors,_that.usedVariables,_that.undefinedVariables,_that.unusedVariables);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpressionValidation implements ExpressionValidation {
  const _ExpressionValidation({required this.valid,  List<ExpressionValidationError> errors = const [],  List<String> usedVariables = const [],  List<String> undefinedVariables = const [],  List<String> unusedVariables = const []}): _errors = errors,_usedVariables = usedVariables,_undefinedVariables = undefinedVariables,_unusedVariables = unusedVariables;
  factory _ExpressionValidation.fromJson(Map<String, dynamic> json) => _$ExpressionValidationFromJson(json);

@override final  bool valid;
 final  List<ExpressionValidationError> _errors;
@override@JsonKey() List<ExpressionValidationError> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}

 final  List<String> _usedVariables;
@override@JsonKey() List<String> get usedVariables {
  if (_usedVariables is EqualUnmodifiableListView) return _usedVariables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usedVariables);
}

 final  List<String> _undefinedVariables;
@override@JsonKey() List<String> get undefinedVariables {
  if (_undefinedVariables is EqualUnmodifiableListView) return _undefinedVariables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_undefinedVariables);
}

 final  List<String> _unusedVariables;
@override@JsonKey() List<String> get unusedVariables {
  if (_unusedVariables is EqualUnmodifiableListView) return _unusedVariables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unusedVariables);
}


/// Create a copy of ExpressionValidation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpressionValidationCopyWith<_ExpressionValidation> get copyWith => __$ExpressionValidationCopyWithImpl<_ExpressionValidation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpressionValidationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpressionValidation&&(identical(other.valid, valid) || other.valid == valid)&&const DeepCollectionEquality().equals(other.errors, _errors)&&const DeepCollectionEquality().equals(other.usedVariables, _usedVariables)&&const DeepCollectionEquality().equals(other.undefinedVariables, _undefinedVariables)&&const DeepCollectionEquality().equals(other.unusedVariables, _unusedVariables));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,valid,const DeepCollectionEquality().hash(_errors),const DeepCollectionEquality().hash(_usedVariables),const DeepCollectionEquality().hash(_undefinedVariables),const DeepCollectionEquality().hash(_unusedVariables));
}

@override
String toString() {
    return 'ExpressionValidation(valid: $valid, errors: $errors, usedVariables: $usedVariables, undefinedVariables: $undefinedVariables, unusedVariables: $unusedVariables)';
}


}

/// @nodoc
abstract mixin class _$ExpressionValidationCopyWith<$Res> implements $ExpressionValidationCopyWith<$Res> {
  factory _$ExpressionValidationCopyWith(_ExpressionValidation value, $Res Function(_ExpressionValidation) _then) = __$ExpressionValidationCopyWithImpl;
@override @useResult
$Res call({
 bool valid, List<ExpressionValidationError> errors, List<String> usedVariables, List<String> undefinedVariables, List<String> unusedVariables
});




}
/// @nodoc
class __$ExpressionValidationCopyWithImpl<$Res>
    implements _$ExpressionValidationCopyWith<$Res> {
  __$ExpressionValidationCopyWithImpl(this._self, this._then);

  final _ExpressionValidation _self;
  final $Res Function(_ExpressionValidation) _then;

/// Create a copy of ExpressionValidation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valid = null,Object? errors = null,Object? usedVariables = null,Object? undefinedVariables = null,Object? unusedVariables = null,}) {
  return _then(_ExpressionValidation(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ExpressionValidationError>,usedVariables: null == usedVariables ? _self._usedVariables : usedVariables // ignore: cast_nullable_to_non_nullable
as List<String>,undefinedVariables: null == undefinedVariables ? _self._undefinedVariables : undefinedVariables // ignore: cast_nullable_to_non_nullable
as List<String>,unusedVariables: null == unusedVariables ? _self._unusedVariables : unusedVariables // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
