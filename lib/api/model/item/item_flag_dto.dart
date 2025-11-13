import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_flag_dto.g.dart';
part 'item_flag_dto.freezed.dart';

@freezed
abstract class ItemFlagDto with _$ItemFlagDto {

  const ItemFlagDto._();

  const factory ItemFlagDto({
    required String id,
    required String flag,
  }) = _ItemFlagDto;

  factory ItemFlagDto.fromJson(Map<String, dynamic> json) =>
      _$ItemFlagDtoFromJson(json);
}