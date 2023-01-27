import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'block_model.freezed.dart';
part 'block_model.g.dart';

@freezed
class BlockModel extends DataModel with _$BlockModel {

  const factory BlockModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'generator', defaultValue: "BlockGenerator") @Default('BlockGenerator') String? generator,
    @JsonKey(name: 'customModelId') int? customModelId,
}) = _BlockModel;
  
  
  factory BlockModel.fromJson(Map<String, dynamic> json) =>
      _$BlockModelFromJson(json);
}
