import 'package:stelaris_ui/api/model/notification_model.dart';

import '../model/block_model.dart';
import '../model/font_model.dart';
import '../model/item_model.dart';
import '../model/plugin_model.dart';

class UpdateItemAction {
  final Item item;

  UpdateItemAction(this.item);
}

class UpdateNotificationAction {
  final Notification notification;

  UpdateNotificationAction(this.notification);
}

class UpdateFontAction {
  final Font font;

  UpdateFontAction(this.font);
}

class UpdatePluginAction {
  final Plugin plugin;

  UpdatePluginAction(this.plugin);
}

class UpdateBlockAction {
  final Block block;

  UpdateBlockAction(this.block);
}