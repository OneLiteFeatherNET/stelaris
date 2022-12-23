import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

@freezed
class ItemModel extends DataModel with _$ItemModel {

  const factory ItemModel({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'displayName') String? displayName,
    @JsonKey(name: 'group') String? group,
    @JsonKey(name: "generator", defaultValue: "ItemGenerator") String? generator,
    @JsonKey(name: 'material') String? material,
    @JsonKey(name: 'customModelId') int? customModelId,
    @JsonKey(name: 'amount', defaultValue: 1) int? amount,
    @JsonKey(name: 'enchantments') Map<String, int>? enchantments,
    @JsonKey(name: 'itemFlags') Set<String>? flags,
    @JsonKey(name: 'lore') List<String>? lore,
}) = _ItemModel;


  factory ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);
}