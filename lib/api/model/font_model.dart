import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/font/font_string_dto.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'data_model.dart';

part 'font_model.g.dart';
part 'font_model.freezed.dart';

FontModel fontFromJson(Object? json) =>
    FontModel.fromJson(json as Map<String, dynamic>);

Map<String, dynamic> fontToJson(FontModel item) => item.toJson();

@freezed
abstract class FontModel with _$FontModel, DataModel {
  const FontModel._(); // Add this private constructor

  // Define the specific const default directly within the class that uses it.
  // This is well-encapsulated.
  static const PaginatedResult<FontStringDTO> _defaultFiles = PaginatedResult(
    items: <FontStringDTO>[],
    totalItems: 0,
    totalPages: 0,
    currentPage: 0,
    pageSize: 0,
  );

  const factory FontModel({
    required String uiName,
    String? id,
    String? variableName,
    String? provider,
    String? texturePath,
    String? comment,
    @Default('font')String mapper,
    @Default(0) int ascent,
    @Default(0) int height,
    @Default(FontModel._defaultFiles)
    PaginatedResult<FontStringDTO> chars,
    @Default(false) @JsonKey(includeToJson: false) bool isLoadingChars,
  }) = _FontModel;

  factory FontModel.fromJson(Map<String, dynamic> json) =>
      _$FontModelFromJson(json);
}
