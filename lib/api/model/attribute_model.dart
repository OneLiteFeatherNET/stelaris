import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'attribute_model.g.dart';
part 'attribute_model.freezed.dart';

@freezed
class AttributeModel extends DataModel with _$AttributeModel {

  const factory AttributeModel({
    String? name,
    double? defaultValue,
    double? maximumValue
  }) = _AttributeModel;

  factory AttributeModel.fromJson(Map<String, dynamic> json) =>
      _$AttributeModelFromJson(json);
}
