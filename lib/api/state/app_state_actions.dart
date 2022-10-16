import 'package:stelaris_ui/api/model/notification_model.dart';

import '../model/block_model.dart';
import '../model/font_model.dart';
import '../model/item_model.dart';
import '../model/plugin_model.dart';

class UpdateItemAction {
  final ItemModel item;

  UpdateItemAction(this.item);
}

class UpdateNotificationAction {
  final NotificationModel notification;

  UpdateNotificationAction(this.notification);
}

class UpdateFontAction {
  final FontModel font;

  UpdateFontAction(this.font);
}

class UpdatePluginAction {
  final PluginModel plugin;

  UpdatePluginAction(this.plugin);
}

class UpdateBlockAction {
  final BlockModel block;

  UpdateBlockAction(this.block);
}