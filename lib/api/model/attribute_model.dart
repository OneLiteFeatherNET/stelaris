import 'package:freezed_annotation/freezed_annotation.dart';

import 'data_model.dart';

part 'attribute_model.g.dart';

part 'attribute_model.freezed.dart';

AttributeModel attributeFromJson(dynamic json) =>
    AttributeModel.fromJson(json as Map<String, dynamic>);

Map<String, dynamic> attributeToJson(AttributeModel model) => model.toJson();

@freezed
abstract class AttributeModel with _$AttributeModel, DataModel {
  const AttributeModel._(); // Add this private constructor
  const factory AttributeModel({
    required String uiName,
    String? id,
    String? variableName,
    @freezed @Default(0.0) double? defaultValue,
    @Default(0.0) double? maximumValue,
  }) = _AttributeModel;

  factory AttributeModel.fromJson(Map<String, dynamic> json) =>
      _$AttributeModelFromJson(json);
}
