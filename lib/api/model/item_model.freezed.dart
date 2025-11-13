// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemModel {

 String get uiName; String? get id; String? get variableName; String? get comment; String? get displayName; EnchantmentGroup get group; String? get material; int? get customModelData; int? get amount; Map<String, int>? get enchantments; Set<String>? get flags; List<String>? get lore;
/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemModelCopyWith<ItemModel> get copyWith => _$ItemModelCopyWithImpl<ItemModel>(this as ItemModel, _$identity);

  /// Serializes this ItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.group, group) || other.group == group)&&(identical(other.material, material) || other.material == material)&&(identical(other.customModelData, customModelData) || other.customModelData == customModelData)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other.enchantments, enchantments)&&const DeepCollectionEquality().equals(other.flags, flags)&&const DeepCollectionEquality().equals(other.lore, lore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,comment,displayName,group,material,customModelData,amount,const DeepCollectionEquality().hash(enchantments),const DeepCollectionEquality().hash(flags),const DeepCollectionEquality().hash(lore));

@override
String toString() {
  return 'ItemModel(uiName: $uiName, id: $id, variableName: $variableName, comment: $comment, displayName: $displayName, group: $group, material: $material, customModelData: $customModelData, amount: $amount, enchantments: $enchantments, flags: $flags, lore: $lore)';
}


}

/// @nodoc
abstract mixin class $ItemModelCopyWith<$Res>  {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) _then) = _$ItemModelCopyWithImpl;
@useResult
$Res call({
 String uiName, String? id, String? variableName, String? comment, String? displayName, EnchantmentGroup group, String? material, int? customModelData, int? amount, Map<String, int>? enchantments, Set<String>? flags, List<String>? lore
});




}
/// @nodoc
class _$ItemModelCopyWithImpl<$Res>
    implements $ItemModelCopyWith<$Res> {
  _$ItemModelCopyWithImpl(this._self, this._then);

  final ItemModel _self;
  final $Res Function(ItemModel) _then;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? comment = freezed,Object? displayName = freezed,Object? group = null,Object? material = freezed,Object? customModelData = freezed,Object? amount = freezed,Object? enchantments = freezed,Object? flags = freezed,Object? lore = freezed,}) {
  return _then(_self.copyWith(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as EnchantmentGroup,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,customModelData: freezed == customModelData ? _self.customModelData : customModelData // ignore: cast_nullable_to_non_nullable
as int?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,enchantments: freezed == enchantments ? _self.enchantments : enchantments // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,flags: freezed == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as Set<String>?,lore: freezed == lore ? _self.lore : lore // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemModel].
extension ItemModelPatterns on ItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uiName,  String? id,  String? variableName,  String? comment,  String? displayName,  EnchantmentGroup group,  String? material,  int? customModelData,  int? amount,  Map<String, int>? enchantments,  Set<String>? flags,  List<String>? lore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that.uiName,_that.id,_that.variableName,_that.comment,_that.displayName,_that.group,_that.material,_that.customModelData,_that.amount,_that.enchantments,_that.flags,_that.lore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uiName,  String? id,  String? variableName,  String? comment,  String? displayName,  EnchantmentGroup group,  String? material,  int? customModelData,  int? amount,  Map<String, int>? enchantments,  Set<String>? flags,  List<String>? lore)  $default,) {final _that = this;
switch (_that) {
case _ItemModel():
return $default(_that.uiName,_that.id,_that.variableName,_that.comment,_that.displayName,_that.group,_that.material,_that.customModelData,_that.amount,_that.enchantments,_that.flags,_that.lore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uiName,  String? id,  String? variableName,  String? comment,  String? displayName,  EnchantmentGroup group,  String? material,  int? customModelData,  int? amount,  Map<String, int>? enchantments,  Set<String>? flags,  List<String>? lore)?  $default,) {final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that.uiName,_that.id,_that.variableName,_that.comment,_that.displayName,_that.group,_that.material,_that.customModelData,_that.amount,_that.enchantments,_that.flags,_that.lore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemModel extends ItemModel {
  const _ItemModel({required this.uiName, this.id, this.variableName, this.comment, this.displayName, this.group = EnchantmentGroup.meta, this.material, this.customModelData, this.amount = 1, final  Map<String, int>? enchantments, final  Set<String>? flags, final  List<String>? lore}): _enchantments = enchantments,_flags = flags,_lore = lore,super._();
  factory _ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);

@override final  String uiName;
@override final  String? id;
@override final  String? variableName;
@override final  String? comment;
@override final  String? displayName;
@override@JsonKey() final  EnchantmentGroup group;
@override final  String? material;
@override final  int? customModelData;
@override@JsonKey() final  int? amount;
 final  Map<String, int>? _enchantments;
@override Map<String, int>? get enchantments {
  final value = _enchantments;
  if (value == null) return null;
  if (_enchantments is EqualUnmodifiableMapView) return _enchantments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Set<String>? _flags;
@override Set<String>? get flags {
  final value = _flags;
  if (value == null) return null;
  if (_flags is EqualUnmodifiableSetView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(value);
}

 final  List<String>? _lore;
@override List<String>? get lore {
  final value = _lore;
  if (value == null) return null;
  if (_lore is EqualUnmodifiableListView) return _lore;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemModelCopyWith<_ItemModel> get copyWith => __$ItemModelCopyWithImpl<_ItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.group, group) || other.group == group)&&(identical(other.material, material) || other.material == material)&&(identical(other.customModelData, customModelData) || other.customModelData == customModelData)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other._enchantments, _enchantments)&&const DeepCollectionEquality().equals(other._flags, _flags)&&const DeepCollectionEquality().equals(other._lore, _lore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,comment,displayName,group,material,customModelData,amount,const DeepCollectionEquality().hash(_enchantments),const DeepCollectionEquality().hash(_flags),const DeepCollectionEquality().hash(_lore));

@override
String toString() {
  return 'ItemModel(uiName: $uiName, id: $id, variableName: $variableName, comment: $comment, displayName: $displayName, group: $group, material: $material, customModelData: $customModelData, amount: $amount, enchantments: $enchantments, flags: $flags, lore: $lore)';
}


}

/// @nodoc
abstract mixin class _$ItemModelCopyWith<$Res> implements $ItemModelCopyWith<$Res> {
  factory _$ItemModelCopyWith(_ItemModel value, $Res Function(_ItemModel) _then) = __$ItemModelCopyWithImpl;
@override @useResult
$Res call({
 String uiName, String? id, String? variableName, String? comment, String? displayName, EnchantmentGroup group, String? material, int? customModelData, int? amount, Map<String, int>? enchantments, Set<String>? flags, List<String>? lore
});




}
/// @nodoc
class __$ItemModelCopyWithImpl<$Res>
    implements _$ItemModelCopyWith<$Res> {
  __$ItemModelCopyWithImpl(this._self, this._then);

  final _ItemModel _self;
  final $Res Function(_ItemModel) _then;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? comment = freezed,Object? displayName = freezed,Object? group = null,Object? material = freezed,Object? customModelData = freezed,Object? amount = freezed,Object? enchantments = freezed,Object? flags = freezed,Object? lore = freezed,}) {
  return _then(_ItemModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as EnchantmentGroup,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,customModelData: freezed == customModelData ? _self.customModelData : customModelData // ignore: cast_nullable_to_non_nullable
as int?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,enchantments: freezed == enchantments ? _self._enchantments : enchantments // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,flags: freezed == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as Set<String>?,lore: freezed == lore ? _self._lore : lore // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
