import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'notification_model.g.dart';
part 'notification_model.freezed.dart';

@freezed
class NotificationModel extends DataModel with _$NotificationModel {

  const factory NotificationModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'generator') @Default('NotificationGenerator') String? generator,
    @JsonKey(name: 'material') String? material,
    @JsonKey(name: 'frameType') String? frameType,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'description') String? description,
  }) = _Notification;


  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}