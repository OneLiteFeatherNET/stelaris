import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';


@freezed
class Item with _$Item {

  const factory Item({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: "group") String? group,
    @JsonKey(name: "generator") String? generator,
    @JsonKey(name: 'material') String? material,
    @JsonKey(name: 'modelData') int? modelData,
    @JsonKey(name: 'amount') int? amount,
}) = _Item;


  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}