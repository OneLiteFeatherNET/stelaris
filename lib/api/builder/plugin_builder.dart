import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';
import 'package:stelaris_ui/api/util/checks.dart';

class PluginBuilder extends BaseBuilder<PluginModel> {

  late String version;
  late String ref;
  late String description;

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

  PluginBuilder setDescription(String description) {
    Checks.argCondition(description.trim().isEmpty, "The description can't be empty");
    this.description = description;
    return this;
  }

  @override
  PluginModel toDTO() {
    return PluginModel(
        name: name,
        ref: ref,
        versionsString: version,description: description
    );
  }
}