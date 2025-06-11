import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/util/minecraft/frame_type.dart';

import 'data_model.dart';

part 'notification_model.g.dart';
part 'notification_model.freezed.dart';

@freezed
abstract class NotificationModel with _$NotificationModel, DataModel {
  const NotificationModel._(); // Add this private constructor

  const factory NotificationModel({
    required String uiName,
    String? id,
    String? variableName,
    String? material,
    @Default(FrameType.task) FrameType frameType,
    String? title,
    String? description,
  }) = _Notification;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}