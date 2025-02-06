import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/util/minecraft/font_type.dart';
import 'data_model.dart';

part 'font_model.g.dart';
part 'font_model.freezed.dart';

@freezed
class FontModel with _$FontModel, DataModel {
  const factory FontModel({
    String? id,
    String? modelName,
    String? name,
    String? description,
    @Default(FontType.bitmap) FontType type,
    @Default([]) List<String>? chars,
    @Default(0) int? ascent,
    @Default(0) int? height,
    @Default([]) List<double>? shift,
  }) = _FontModel;

  factory FontModel.fromJson(Map<String, dynamic> json) =>
      _$FontModelFromJson(json);
}
