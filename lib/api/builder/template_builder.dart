import 'package:stelaris_ui/api/builder/base_builder.dart';
import 'package:stelaris_ui/api/model/template_model.dart';

class TemplateBuilder extends BaseBuilder<TemplateModel> {

  late String description;
  late Set<String> plugins = {};

  @override
  BaseBuilder setGenerator(String generator) {
    throw Exception("A template can't have an generator string");
  }

  TemplateBuilder setDescription(String description) {
    this.description = description;
    return this;
  }

  TemplateBuilder addPlugin(String plugin) {
    if (plugins.add(plugin)) {
      plugins.remove(plugin);
    }
    return this;
  }

  @override
  TemplateModel toDTO() {
    return TemplateModel(
        name: name, description: description, plugins: plugins.toList());
  }
}

