// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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

 String get uiName; String? get id; String? get variableName; String? get description; String? get displayName; ItemGroup get group; String? get material; int? get customModelId; int? get amount; Map<String, int>? get enchantments; Set<String>? get flags; List<String>? get lore;
/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemModelCopyWith<ItemModel> get copyWith => _$ItemModelCopyWithImpl<ItemModel>(this as ItemModel, _$identity);

  /// Serializes this ItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.description, description) || other.description == description)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.group, group) || other.group == group)&&(identical(other.material, material) || other.material == material)&&(identical(other.customModelId, customModelId) || other.customModelId == customModelId)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other.enchantments, enchantments)&&const DeepCollectionEquality().equals(other.flags, flags)&&const DeepCollectionEquality().equals(other.lore, lore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,description,displayName,group,material,customModelId,amount,const DeepCollectionEquality().hash(enchantments),const DeepCollectionEquality().hash(flags),const DeepCollectionEquality().hash(lore));

@override
String toString() {
  return 'ItemModel(uiName: $uiName, id: $id, variableName: $variableName, description: $description, displayName: $displayName, group: $group, material: $material, customModelId: $customModelId, amount: $amount, enchantments: $enchantments, flags: $flags, lore: $lore)';
}


}

/// @nodoc
abstract mixin class $ItemModelCopyWith<$Res>  {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) _then) = _$ItemModelCopyWithImpl;
@useResult
$Res call({
 String uiName, String? id, String? variableName, String? description, String? displayName, ItemGroup group, String? material, int? customModelId, int? amount, Map<String, int>? enchantments, Set<String>? flags, List<String>? lore
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
@pragma('vm:prefer-inline') @override $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? description = freezed,Object? displayName = freezed,Object? group = null,Object? material = freezed,Object? customModelId = freezed,Object? amount = freezed,Object? enchantments = freezed,Object? flags = freezed,Object? lore = freezed,}) {
  return _then(_self.copyWith(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as ItemGroup,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,customModelId: freezed == customModelId ? _self.customModelId : customModelId // ignore: cast_nullable_to_non_nullable
as int?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,enchantments: freezed == enchantments ? _self.enchantments : enchantments // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,flags: freezed == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as Set<String>?,lore: freezed == lore ? _self.lore : lore // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ItemModel extends ItemModel {
  const _ItemModel({required this.uiName, this.id, this.variableName, this.description, this.displayName, this.group = ItemGroup.misc, this.material, this.customModelId, this.amount = 1, final  Map<String, int>? enchantments, final  Set<String>? flags, final  List<String>? lore}): _enchantments = enchantments,_flags = flags,_lore = lore,super._();
  factory _ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);

@override final  String uiName;
@override final  String? id;
@override final  String? variableName;
@override final  String? description;
@override final  String? displayName;
@override@JsonKey() final  ItemGroup group;
@override final  String? material;
@override final  int? customModelId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemModel&&(identical(other.uiName, uiName) || other.uiName == uiName)&&(identical(other.id, id) || other.id == id)&&(identical(other.variableName, variableName) || other.variableName == variableName)&&(identical(other.description, description) || other.description == description)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.group, group) || other.group == group)&&(identical(other.material, material) || other.material == material)&&(identical(other.customModelId, customModelId) || other.customModelId == customModelId)&&(identical(other.amount, amount) || other.amount == amount)&&const DeepCollectionEquality().equals(other._enchantments, _enchantments)&&const DeepCollectionEquality().equals(other._flags, _flags)&&const DeepCollectionEquality().equals(other._lore, _lore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uiName,id,variableName,description,displayName,group,material,customModelId,amount,const DeepCollectionEquality().hash(_enchantments),const DeepCollectionEquality().hash(_flags),const DeepCollectionEquality().hash(_lore));

@override
String toString() {
  return 'ItemModel(uiName: $uiName, id: $id, variableName: $variableName, description: $description, displayName: $displayName, group: $group, material: $material, customModelId: $customModelId, amount: $amount, enchantments: $enchantments, flags: $flags, lore: $lore)';
}


}

/// @nodoc
abstract mixin class _$ItemModelCopyWith<$Res> implements $ItemModelCopyWith<$Res> {
  factory _$ItemModelCopyWith(_ItemModel value, $Res Function(_ItemModel) _then) = __$ItemModelCopyWithImpl;
@override @useResult
$Res call({
 String uiName, String? id, String? variableName, String? description, String? displayName, ItemGroup group, String? material, int? customModelId, int? amount, Map<String, int>? enchantments, Set<String>? flags, List<String>? lore
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
@override @pragma('vm:prefer-inline') $Res call({Object? uiName = null,Object? id = freezed,Object? variableName = freezed,Object? description = freezed,Object? displayName = freezed,Object? group = null,Object? material = freezed,Object? customModelId = freezed,Object? amount = freezed,Object? enchantments = freezed,Object? flags = freezed,Object? lore = freezed,}) {
  return _then(_ItemModel(
uiName: null == uiName ? _self.uiName : uiName // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,variableName: freezed == variableName ? _self.variableName : variableName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as ItemGroup,material: freezed == material ? _self.material : material // ignore: cast_nullable_to_non_nullable
as String?,customModelId: freezed == customModelId ? _self.customModelId : customModelId // ignore: cast_nullable_to_non_nullable
as int?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,enchantments: freezed == enchantments ? _self._enchantments : enchantments // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,flags: freezed == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as Set<String>?,lore: freezed == lore ? _self._lore : lore // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
