import 'package:async_redux/async_redux.dart';

import '../../api_service.dart';
import '../../model/plugin_model.dart';
import '../app_state.dart';

class UpdatePluginAction extends ReduxAction<AppState> {
  final PluginModel plugin;

  UpdatePluginAction(this.plugin);

  @override
  Future<AppState?> reduce() async {
    var plugins = await ApiService().pluginAPI.getAllPlugins();
    return state.copyWith(plugins: plugins);
  }
}

class InitPluginAction extends ReduxAction<AppState> {

  @override
  Future<AppState?> reduce() async {
    //var plugins = await ApiService().pluginAPI.getAllPlugins();
    return state.copyWith(plugins: []);
  }

  InitPluginAction();
}