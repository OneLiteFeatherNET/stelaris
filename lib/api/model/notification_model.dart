import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.g.dart';
part 'notification_model.freezed.dart';

@freezed
class NotificationModel with _$NotificationModel {

  const factory NotificationModel({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: "generator") String? generator,
    @JsonKey(name: 'material') String? material,
    @JsonKey(name: 'frameType') String? frameType,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'description') String? description,
  }) = _Notification;


  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}