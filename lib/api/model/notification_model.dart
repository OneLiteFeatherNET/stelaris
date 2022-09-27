import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.g.dart';
part 'notification_model.freezed.dart';

@freezed
class Notification with _$Notification {

  const factory Notification({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: "generator") String? generator,
    @JsonKey(name: 'material') String? material,
    @JsonKey(name: 'frameType') String? frameType,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'description') String? description,
  }) = _Notification;


  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}