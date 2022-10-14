import 'package:freezed_annotation/freezed_annotation.dart';

part 'block_model.freezed.dart';
part 'block_model.g.dart';

@freezed
class Block with _$BlockModel {

  const factory Block({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: "generator") String? generator,
    @JsonKey(name: 'modelData') int? modelData,
    @JsonKey(name: 'amount') int? amount,
}) = _BlockModel;
  
  
  factory Block.fromJson(Map<String, dynamic> json) =>
      _$BlockModelFromJson(json);
}
