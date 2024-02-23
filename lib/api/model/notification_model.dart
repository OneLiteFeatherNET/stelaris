import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'notification_model.g.dart';
part 'notification_model.freezed.dart';

@freezed
class NotificationModel extends DataModel with _$NotificationModel {

  const factory NotificationModel({
    String? id,
    String? modelName,
    String? name,
    String? material,
    @Default('goal') String? frameType,
    String? title,
    String? description,
  }) = _Notification;


  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}