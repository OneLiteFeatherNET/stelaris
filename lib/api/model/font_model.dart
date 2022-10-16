import 'package:freezed_annotation/freezed_annotation.dart';

part 'font_model.g.dart';
part 'font_model.freezed.dart';

@freezed
class FontModel with _$FontModel {

  const factory FontModel({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'generator') String? generator,
}) = _FontModel;


  factory FontModel.fromJson(Map<String, dynamic> json) =>
      _$FontModelFromJson(json);
}
