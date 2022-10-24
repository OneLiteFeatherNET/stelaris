import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_model.freezed.dart';

part 'template_model.g.dart';

@freezed
class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'plugins') List<String>? plugins
  }) = _TemplateModel;

  factory TemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateModelFromJson(json);
}
