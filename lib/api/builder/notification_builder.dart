import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';

class NotificationBuilder extends BaseBuilder<NotificationModel>  {

  static const String _generatorKey = "NotificationGenerator";

  late String material;
  late String title;
  late String description;
  late String frameType;

  NotificationBuilder setMaterial(String material) {
    this.material = material;
    return this;
  }

  NotificationBuilder setTitle(String title) {
    this.title = title;
    return this;
  }

  NotificationBuilder setDescription(String description) {
    this.description = description;
    return this;
  }

  NotificationBuilder setFrameType(String frameType) {
    this.frameType = frameType;
    return this;
  }

  @override
  NotificationBuilder clear() {
    name = "";
    material = "";
    frameType = FrameType.task.name;
    title = "";
    description = "";
    return this;
  }

  @override
  NotificationModel toDTO() {
    return NotificationModel(
        name: name,
        generator: _generatorKey,
        material: material,
        frameType: frameType,
        title: title,
        description: description
    );
  }
}