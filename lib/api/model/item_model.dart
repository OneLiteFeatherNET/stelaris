import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';
import 'package:stelaris_ui/feature/item/item_group.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

@freezed
class ItemModel extends DataModel with _$ItemModel {

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

  factory ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);
}