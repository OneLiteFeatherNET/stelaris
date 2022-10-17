import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

import '../model/block_model.dart';
import '../model/font_model.dart';
import '../model/item_model.dart';
import '../model/plugin_model.dart';

class UpdateItemAction extends ReduxAction<AppState> {
  final ItemModel item;

  UpdateItemAction(this.item);

  @override
  Future<AppState?> reduce() async {
    var items = await ApiService().itemApi.getAllItems();
    return state.copyWith(items: items);
  }
}

class UpdateNotificationAction extends ReduxAction<AppState> {
  final NotificationModel notification;

  UpdateNotificationAction(this.notification);

  @override
  Future<AppState?> reduce() async {
    var notifications = await ApiService().notificationAPI.getAllNotifications();
    return state.copyWith(notifications: notifications);
  }
}

class UpdateFontAction extends ReduxAction<AppState> {
  final FontModel font;

  UpdateFontAction(this.font);

  @override
  Future<AppState?> reduce() async {
    var fonts = await ApiService().fontAPI.getAllFonts();
    return state.copyWith(fonts: fonts);
  }
}

class UpdatePluginAction extends ReduxAction<AppState> {
  final PluginModel plugin;

  UpdatePluginAction(this.plugin);

  @override
  Future<AppState?> reduce() async {
    var plugins = await ApiService().pluginAPI.getAllPlugins();
    return state.copyWith(plugins: plugins);
  }
}

class UpdateBlockAction extends ReduxAction<AppState> {
  final BlockModel block;

  UpdateBlockAction(this.block);

  @override
  Future<AppState?> reduce() async {
    var blocks = await ApiService().blockAPI.getAllBlocks();
    return state.copyWith(blocks: blocks);
  }
}