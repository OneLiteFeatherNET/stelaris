import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';

import '../model/item_model.dart';

class AppState {

  List<Item> items;
  List<Notification> notifications;
  List<Font> fonts;
  List<Plugin> plugins;
  List<Block> blocks;

  AppState({
    this.items = const [],
    this.notifications = const [],
    this.fonts = const [],
    this.plugins = const [],
    this.blocks = const []
  });
}