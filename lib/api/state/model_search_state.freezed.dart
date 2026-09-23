// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ModelSearchState {

 String get query; Set<FilterOption> get activeFilters;/// The filters the current list page offers, registered by that page —
/// the AppBar has no other way to know which ones apply.
 List<FilterOption> get availableFilters; SortField get sortField; SortDirection get sortDirection;/// The section the search was typed for. Lets the AppBar search notice
/// a section change however it happens (side bar, browser back, URL).
 NavigationEntry? get section;
/// Create a copy of ModelSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelSearchStateCopyWith<ModelSearchState> get copyWith => _$ModelSearchStateCopyWithImpl<ModelSearchState>(this as ModelSearchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ModelSearchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelSearchState&&(identical(other.query, _this.query) || other.query == _this.query)&&const DeepCollectionEquality().equals(other.activeFilters, _this.activeFilters)&&const DeepCollectionEquality().equals(other.availableFilters, _this.availableFilters)&&(identical(other.sortField, _this.sortField) || other.sortField == _this.sortField)&&(identical(other.sortDirection, _this.sortDirection) || other.sortDirection == _this.sortDirection)&&(identical(other.section, _this.section) || other.section == _this.section));
}


@override
int get hashCode {
  final _this = this as ModelSearchState;
  return Object.hash(runtimeType,_this.query,const DeepCollectionEquality().hash(_this.activeFilters),const DeepCollectionEquality().hash(_this.availableFilters),_this.sortField,_this.sortDirection,_this.section);
}

@override
String toString() {
  final _this = this as ModelSearchState;
  return 'ModelSearchState(query: ${_this.query}, activeFilters: ${_this.activeFilters}, availableFilters: ${_this.availableFilters}, sortField: ${_this.sortField}, sortDirection: ${_this.sortDirection}, section: ${_this.section})';
}


}

/// @nodoc
abstract mixin class $ModelSearchStateCopyWith<$Res>  {
  factory $ModelSearchStateCopyWith(ModelSearchState value, $Res Function(ModelSearchState) _then) = _$ModelSearchStateCopyWithImpl;
@useResult
$Res call({
 String query, Set<FilterOption> activeFilters, List<FilterOption> availableFilters, SortField sortField, SortDirection sortDirection, NavigationEntry? section
});




}
/// @nodoc
class _$ModelSearchStateCopyWithImpl<$Res>
    implements $ModelSearchStateCopyWith<$Res> {
  _$ModelSearchStateCopyWithImpl(this._self, this._then);

  final ModelSearchState _self;
  final $Res Function(ModelSearchState) _then;

/// Create a copy of ModelSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? activeFilters = null,Object? availableFilters = null,Object? sortField = null,Object? sortDirection = null,Object? section = freezed,}) {
  return _then(ModelSearchState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,activeFilters: null == activeFilters ? _self.activeFilters : activeFilters // ignore: cast_nullable_to_non_nullable
as Set<FilterOption>,availableFilters: null == availableFilters ? _self.availableFilters : availableFilters // ignore: cast_nullable_to_non_nullable
as List<FilterOption>,sortField: null == sortField ? _self.sortField : sortField // ignore: cast_nullable_to_non_nullable
as SortField,sortDirection: null == sortDirection ? _self.sortDirection : sortDirection // ignore: cast_nullable_to_non_nullable
as SortDirection,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as NavigationEntry?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelSearchState].
extension ModelSearchStatePatterns on ModelSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelSearchState value)  $default,){
final _that = this;
switch (_that) {
case _ModelSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _ModelSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  Set<FilterOption> activeFilters,  List<FilterOption> availableFilters,  SortField sortField,  SortDirection sortDirection,  NavigationEntry? section)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelSearchState() when $default != null:
return $default(_that.query,_that.activeFilters,_that.availableFilters,_that.sortField,_that.sortDirection,_that.section);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  Set<FilterOption> activeFilters,  List<FilterOption> availableFilters,  SortField sortField,  SortDirection sortDirection,  NavigationEntry? section)  $default,) {final _that = this;
switch (_that) {
case _ModelSearchState():
return $default(_that.query,_that.activeFilters,_that.availableFilters,_that.sortField,_that.sortDirection,_that.section);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  Set<FilterOption> activeFilters,  List<FilterOption> availableFilters,  SortField sortField,  SortDirection sortDirection,  NavigationEntry? section)?  $default,) {final _that = this;
switch (_that) {
case _ModelSearchState() when $default != null:
return $default(_that.query,_that.activeFilters,_that.availableFilters,_that.sortField,_that.sortDirection,_that.section);case _:
  return null;

}
}

}

/// @nodoc


class _ModelSearchState implements ModelSearchState {
  const _ModelSearchState({this.query = '', this.activeFilters = const <FilterOption>{}, this.availableFilters = const <FilterOption>[], this.sortField = SortField.name, this.sortDirection = SortDirection.ascending, this.section});
  

@override@JsonKey() final  String query;
@override@JsonKey() final  Set<FilterOption> activeFilters;
/// The filters the current list page offers, registered by that page —
/// the AppBar has no other way to know which ones apply.
@override@JsonKey() final  List<FilterOption> availableFilters;
@override@JsonKey() final  SortField sortField;
@override@JsonKey() final  SortDirection sortDirection;
/// The section the search was typed for. Lets the AppBar search notice
/// a section change however it happens (side bar, browser back, URL).
@override final  NavigationEntry? section;

/// Create a copy of ModelSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelSearchStateCopyWith<_ModelSearchState> get copyWith => __$ModelSearchStateCopyWithImpl<_ModelSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelSearchState&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.activeFilters, activeFilters)&&const DeepCollectionEquality().equals(other.availableFilters, availableFilters)&&(identical(other.sortField, sortField) || other.sortField == sortField)&&(identical(other.sortDirection, sortDirection) || other.sortDirection == sortDirection)&&(identical(other.section, section) || other.section == section));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query,const DeepCollectionEquality().hash(activeFilters),const DeepCollectionEquality().hash(availableFilters),sortField,sortDirection,section);
}

@override
String toString() {
    return 'ModelSearchState(query: $query, activeFilters: $activeFilters, availableFilters: $availableFilters, sortField: $sortField, sortDirection: $sortDirection, section: $section)';
}


}

/// @nodoc
abstract mixin class _$ModelSearchStateCopyWith<$Res> implements $ModelSearchStateCopyWith<$Res> {
  factory _$ModelSearchStateCopyWith(_ModelSearchState value, $Res Function(_ModelSearchState) _then) = __$ModelSearchStateCopyWithImpl;
@override @useResult
$Res call({
 String query, Set<FilterOption> activeFilters, List<FilterOption> availableFilters, SortField sortField, SortDirection sortDirection, NavigationEntry? section
});




}
/// @nodoc
class __$ModelSearchStateCopyWithImpl<$Res>
    implements _$ModelSearchStateCopyWith<$Res> {
  __$ModelSearchStateCopyWithImpl(this._self, this._then);

  final _ModelSearchState _self;
  final $Res Function(_ModelSearchState) _then;

/// Create a copy of ModelSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? activeFilters = null,Object? availableFilters = null,Object? sortField = null,Object? sortDirection = null,Object? section = freezed,}) {
  return _then(_ModelSearchState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,activeFilters: null == activeFilters ? _self.activeFilters : activeFilters // ignore: cast_nullable_to_non_nullable
as Set<FilterOption>,availableFilters: null == availableFilters ? _self.availableFilters : availableFilters // ignore: cast_nullable_to_non_nullable
as List<FilterOption>,sortField: null == sortField ? _self.sortField : sortField // ignore: cast_nullable_to_non_nullable
as SortField,sortDirection: null == sortDirection ? _self.sortDirection : sortDirection // ignore: cast_nullable_to_non_nullable
as SortDirection,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as NavigationEntry?,
  ));
}


}

// dart format on
