import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/util/minecraft/frame_type.dart';

class NotificationBuilder extends BaseBuilder<NotificationModel>  {

  late String material;
  late String title;
  late String description;
  late FrameType frameType;

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

  NotificationBuilder setFrameType(FrameType frameType) {
    this.frameType = frameType;
    return this;
  }

  @override
  NotificationModel toDTO() {
    return NotificationModel(
        name: name,
        generator: generator,
        material: material,
        frameType: frameType.value,
        title: title,
        description: description
    );
  }
}