import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'font_model.g.dart';
part 'font_model.freezed.dart';

@freezed
class FontModel extends DataModel with _$FontModel {

  const factory FontModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'generator', defaultValue: 'FontGenerator') @Default('FontGenerator') String? generator,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'chars') List<String>? chars,
    @JsonKey(name: 'ascent') int? ascent,
    @JsonKey(name: 'height') int? height
}) = _FontModel;


  factory FontModel.fromJson(Map<String, dynamic> json) =>
      _$FontModelFromJson(json);
}
