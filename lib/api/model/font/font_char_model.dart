import 'package:freezed_annotation/freezed_annotation.dart';

part 'font_char_model.freezed.dart';
part 'font_char_model.g.dart';

@freezed
abstract class FontCharModel with _$FontCharModel {

  const FontCharModel._(); // Add this private constructor

  const factory FontCharModel({
    required String id,
    required List<String> chars,
  }) = _FontCharModel;

  factory FontCharModel.fromJson(Map<String, dynamic> json) =>
      _$FontCharModelFromJson(json);

}
