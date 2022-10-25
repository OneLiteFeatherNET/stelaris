import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';
import 'package:stelaris_ui/api/util/checks.dart';

class PluginBuilder extends BaseBuilder<PluginModel> {

  late String version;
  late String ref;

  @override
  BaseBuilder setGenerator(String generator) {
    throw Exception("A plugin can't have an generator string");
  }

  PluginBuilder setVersion(String version) {
    Checks.argCondition(version.trim().isEmpty, "The version can't be empty");
    this.version = version;
    return this;
  }

  PluginBuilder setRef(String ref) {
    Checks.argCondition(ref.trim().isEmpty, "The ref can't be empty");
    this.ref = ref;
    return this;
  }

  @override
  PluginModel toDTO() {
    return PluginModel(name: name, ref: ref, version: version);
  }
}