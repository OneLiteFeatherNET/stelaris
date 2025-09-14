import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_flag_model.g.dart';
part 'item_flag_model.freezed.dart';

@freezed
abstract class ItemFlagModel with _$ItemFlagModel {

  const ItemFlagModel._();

  const factory ItemFlagModel({
    required String id,
    required Set<String> flags,
  }) = _ItemFlagModel;

  factory ItemFlagModel.fromJson(Map<String, dynamic> json) =>
      _$ItemFlagModelFromJson(json);
}