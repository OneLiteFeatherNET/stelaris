import 'package:freezed_annotation/freezed_annotation.dart';

part 'font_string_dto.g.dart';

part 'font_string_dto.freezed.dart';

@freezed
abstract class FontStringDTO with _$FontStringDTO {
  const FontStringDTO._(); // Add this private constructor

  const factory FontStringDTO({
    required String line,
    String? id,
    @Default(0) int? orderIndex,
  }) = _FontStringDto;

  factory FontStringDTO.fromJson(Map<String, dynamic> json) =>
      _$FontStringDtoFromJson(json);
}
