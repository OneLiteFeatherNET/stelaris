import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/data_model.dart';

part 'font_model_dto.g.dart';

part 'font_model_dto.freezed.dart';

@freezed
abstract class FontModelDto with _$FontModelDto, DataModel {

  const FontModelDto._();

  const factory FontModelDto({
    required String uiName,
    String? id,
    String? variableName,
    String? provider,
    String? texturePath,
    String? comment,
    @Default('font') String mapper,
    @Default(0) int ascent,
    @Default(0) int height,
  }) = _FontModelDto;

  factory FontModelDto.fromJson(Map<String, dynamic> json) =>
      _$FontModelDtoFromJson(json);
}
