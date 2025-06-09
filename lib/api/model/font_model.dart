import 'package:freezed_annotation/freezed_annotation.dart';
import 'data_model.dart';

part 'font_model.g.dart';
part 'font_model.freezed.dart';

@freezed
abstract class FontModel with _$FontModel, DataModel {
  const FontModel._(); // Add this private constructor

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
    @Default([]) List<String> chars,
  }) = _FontModel;

  factory FontModel.fromJson(Map<String, dynamic> json) =>
      _$FontModelFromJson(json);
}
