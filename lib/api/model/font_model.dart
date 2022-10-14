import 'package:freezed_annotation/freezed_annotation.dart';

part 'font_model.g.dart';
part 'font_model.freezed.dart';

@freezed
class Font with _$FontModel {

  const factory Font({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'generator') String? generator,
}) = _FontModel;


  factory Font.fromJson(Map<String, dynamic> json) =>
      _$FontModelFromJson(json);
}
