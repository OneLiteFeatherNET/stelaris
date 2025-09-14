import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_enchantment_model.g.dart';
part 'item_enchantment_model.freezed.dart';

@freezed
abstract class ItemEnchantmentModel with _$ItemEnchantmentModel {

  const ItemEnchantmentModel._();

  const factory ItemEnchantmentModel({
    required String id,
    required Map<String, int> enchantments,
  }) = _ItemEnchantmentModel;

  factory ItemEnchantmentModel.fromJson(Map<String, dynamic> json) =>
      _$ItemEnchantmentModelFromJson(json);
}
