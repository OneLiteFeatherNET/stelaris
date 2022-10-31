import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'block_model.freezed.dart';
part 'block_model.g.dart';

@freezed
class BlockModel extends DataModel with _$BlockModel {

  const factory BlockModel({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: "generator") String? generator,
    @JsonKey(name: 'modelData') int? modelData,
    @JsonKey(name: 'amount') int? amount,
}) = _BlockModel;
  
  
  factory BlockModel.fromJson(Map<String, dynamic> json) =>
      _$BlockModelFromJson(json);
}
