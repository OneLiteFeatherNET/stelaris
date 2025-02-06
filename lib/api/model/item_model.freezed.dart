// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ItemModel _$ItemModelFromJson(Map<String, dynamic> json) {
  return _ItemModel.fromJson(json);
}

/// @nodoc
mixin _$ItemModel {
  String? get id => throw _privateConstructorUsedError;
  String? get modelName => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  ItemGroup get group => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  int? get customModelId => throw _privateConstructorUsedError;
  int? get amount => throw _privateConstructorUsedError;
  Map<String, int>? get enchantments => throw _privateConstructorUsedError;
  Set<String>? get flags => throw _privateConstructorUsedError;
  List<String>? get lore => throw _privateConstructorUsedError;

  /// Serializes this ItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemModelCopyWith<ItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemModelCopyWith<$Res> {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) then) =
      _$ItemModelCopyWithImpl<$Res, ItemModel>;
  @useResult
  $Res call(
      {String? id,
      String? modelName,
      String? name,
      String? description,
      String? displayName,
      ItemGroup group,
      String? material,
      int? customModelId,
      int? amount,
      Map<String, int>? enchantments,
      Set<String>? flags,
      List<String>? lore});
}

/// @nodoc
class _$ItemModelCopyWithImpl<$Res, $Val extends ItemModel>
    implements $ItemModelCopyWith<$Res> {
  _$ItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? modelName = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? displayName = freezed,
    Object? group = null,
    Object? material = freezed,
    Object? customModelId = freezed,
    Object? amount = freezed,
    Object? enchantments = freezed,
    Object? flags = freezed,
    Object? lore = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      group: null == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as ItemGroup,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      customModelId: freezed == customModelId
          ? _value.customModelId
          : customModelId // ignore: cast_nullable_to_non_nullable
              as int?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      enchantments: freezed == enchantments
          ? _value.enchantments
          : enchantments // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      flags: freezed == flags
          ? _value.flags
          : flags // ignore: cast_nullable_to_non_nullable
              as Set<String>?,
      lore: freezed == lore
          ? _value.lore
          : lore // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemModelImplCopyWith<$Res>
    implements $ItemModelCopyWith<$Res> {
  factory _$$ItemModelImplCopyWith(
          _$ItemModelImpl value, $Res Function(_$ItemModelImpl) then) =
      __$$ItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? modelName,
      String? name,
      String? description,
      String? displayName,
      ItemGroup group,
      String? material,
      int? customModelId,
      int? amount,
      Map<String, int>? enchantments,
      Set<String>? flags,
      List<String>? lore});
}

/// @nodoc
class __$$ItemModelImplCopyWithImpl<$Res>
    extends _$ItemModelCopyWithImpl<$Res, _$ItemModelImpl>
    implements _$$ItemModelImplCopyWith<$Res> {
  __$$ItemModelImplCopyWithImpl(
      _$ItemModelImpl _value, $Res Function(_$ItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? modelName = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? displayName = freezed,
    Object? group = null,
    Object? material = freezed,
    Object? customModelId = freezed,
    Object? amount = freezed,
    Object? enchantments = freezed,
    Object? flags = freezed,
    Object? lore = freezed,
  }) {
    return _then(_$ItemModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      modelName: freezed == modelName
          ? _value.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      group: null == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as ItemGroup,
      material: freezed == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String?,
      customModelId: freezed == customModelId
          ? _value.customModelId
          : customModelId // ignore: cast_nullable_to_non_nullable
              as int?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      enchantments: freezed == enchantments
          ? _value._enchantments
          : enchantments // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      flags: freezed == flags
          ? _value._flags
          : flags // ignore: cast_nullable_to_non_nullable
              as Set<String>?,
      lore: freezed == lore
          ? _value._lore
          : lore // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemModelImpl implements _ItemModel {
  const _$ItemModelImpl(
      {this.id,
      this.modelName,
      this.name,
      this.description,
      this.displayName,
      this.group = ItemGroup.misc,
      this.material,
      this.customModelId,
      this.amount = 1,
      final Map<String, int>? enchantments,
      final Set<String>? flags,
      final List<String>? lore})
      : _enchantments = enchantments,
        _flags = flags,
        _lore = lore;

  factory _$ItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemModelImplFromJson(json);

  @override
  final String? id;
  @override
  final String? modelName;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? displayName;
  @override
  @JsonKey()
  final ItemGroup group;
  @override
  final String? material;
  @override
  final int? customModelId;
  @override
  @JsonKey()
  final int? amount;
  final Map<String, int>? _enchantments;
  @override
  Map<String, int>? get enchantments {
    final value = _enchantments;
    if (value == null) return null;
    if (_enchantments is EqualUnmodifiableMapView) return _enchantments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Set<String>? _flags;
  @override
  Set<String>? get flags {
    final value = _flags;
    if (value == null) return null;
    if (_flags is EqualUnmodifiableSetView) return _flags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(value);
  }

  final List<String>? _lore;
  @override
  List<String>? get lore {
    final value = _lore;
    if (value == null) return null;
    if (_lore is EqualUnmodifiableListView) return _lore;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, modelName: $modelName, name: $name, description: $description, displayName: $displayName, group: $group, material: $material, customModelId: $customModelId, amount: $amount, enchantments: $enchantments, flags: $flags, lore: $lore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.customModelId, customModelId) ||
                other.customModelId == customModelId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            const DeepCollectionEquality()
                .equals(other._enchantments, _enchantments) &&
            const DeepCollectionEquality().equals(other._flags, _flags) &&
            const DeepCollectionEquality().equals(other._lore, _lore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      modelName,
      name,
      description,
      displayName,
      group,
      material,
      customModelId,
      amount,
      const DeepCollectionEquality().hash(_enchantments),
      const DeepCollectionEquality().hash(_flags),
      const DeepCollectionEquality().hash(_lore));

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemModelImplCopyWith<_$ItemModelImpl> get copyWith =>
      __$$ItemModelImplCopyWithImpl<_$ItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemModelImplToJson(
      this,
    );
  }
}

abstract class _ItemModel implements ItemModel {
  const factory _ItemModel(
      {final String? id,
      final String? modelName,
      final String? name,
      final String? description,
      final String? displayName,
      final ItemGroup group,
      final String? material,
      final int? customModelId,
      final int? amount,
      final Map<String, int>? enchantments,
      final Set<String>? flags,
      final List<String>? lore}) = _$ItemModelImpl;

  factory _ItemModel.fromJson(Map<String, dynamic> json) =
      _$ItemModelImpl.fromJson;

  @override
  String? get id;
  @override
  String? get modelName;
  @override
  String? get name;
  @override
  String? get description;
  @override
  String? get displayName;
  @override
  ItemGroup get group;
  @override
  String? get material;
  @override
  int? get customModelId;
  @override
  int? get amount;
  @override
  Map<String, int>? get enchantments;
  @override
  Set<String>? get flags;
  @override
  List<String>? get lore;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemModelImplCopyWith<_$ItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
