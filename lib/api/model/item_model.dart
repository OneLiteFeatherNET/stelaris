import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/feature/item/item_group.dart';
import 'data_model.dart';

part 'item_model.g.dart';
part 'item_model.freezed.dart';

@freezed
abstract class ItemModel with _$ItemModel, DataModel {
  const ItemModel._(); // Add this private constructor
  const factory ItemModel({
    String? id,
    String? modelName,
    String? name,
    String? description,
    String? displayName,
    @Default(ItemGroup.misc) ItemGroup group,
    String? material,
    int? customModelId,
    @Default(1) int? amount,
    Map<String, int>? enchantments,
    Set<String>? flags,
    List<String>? lore,
  }) = _ItemModel;

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);
}