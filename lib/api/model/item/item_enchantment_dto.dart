import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_enchantment_dto.freezed.dart';
part 'item_enchantment_dto.g.dart';

@freezed
abstract class ItemEnchantmentDto with _$ItemEnchantmentDto {

  const ItemEnchantmentDto._();

  const factory ItemEnchantmentDto({
    required String name,
    required int level,
    @Default(false) bool unsafe,
    String? id,
  }) = _ItemEnchantmentDto;

  factory ItemEnchantmentDto.fromJson(Map<String, dynamic> json) =>
      _$ItemEnchantmentDtoFromJson(json);
}