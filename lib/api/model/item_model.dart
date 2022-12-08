import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

@freezed
class ItemModel extends DataModel with _$ItemModel {

  const factory ItemModel({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: "group") String? group,
    @JsonKey(name: "generator") String? generator,
    @JsonKey(name: 'material') String? material,
    @JsonKey(name: 'modelData') int? modelData,
    @JsonKey(name: 'amount') int? amount,
    @JsonKey(name: 'enchantments') Map<String, int>? enchantments,
    @JsonKey(name: 'itemFlags') Set<String>? flags,
    @JsonKey(name: 'lore') List<String>? lore,
}) = _ItemModel;


  factory ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);
}