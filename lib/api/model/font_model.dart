import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'font_model.g.dart';

part 'font_model.freezed.dart';

@freezed
class FontModel extends DataModel with _$FontModel {
  const factory FontModel({
    String? id,
    String? modelName,
    String? name,
    String? description,
    @Default('bitmap') String? type, //Ignore
    List<String>? chars,
    int? ascent,
    int? height,
    List<double>? shift, //Ignore
  }) = _FontModel;

  factory FontModel.fromJson(Map<String, dynamic> json) =>
      _$FontModelFromJson(json);
}
