import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_lore_model.freezed.dart';
part 'item_lore_model.g.dart';

@freezed
abstract class ItemLoreModel with _$ItemLoreModel {

  const ItemLoreModel._();

  const factory ItemLoreModel({
    required String id,
    required Map<String, int> enchantments,
  }) = _ItemLoreModel;

  factory ItemLoreModel.fromJson(Map<String, dynamic> json) =>
      _$ItemLoreModelFromJson(json);
}