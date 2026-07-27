import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_lore_dto.freezed.dart';
part 'item_lore_dto.g.dart';


@freezed
abstract class ItemLoreDto with _$ItemLoreDto {

  const ItemLoreDto._();

  const factory ItemLoreDto({
    required String text,
    String? id,
    @Default(0) int orderIndex,
  }) = _ItemLoreDto;

  factory ItemLoreDto.fromJson(Map<String, dynamic> json) =>
      _$ItemLoreDtoFromJson(json);
}