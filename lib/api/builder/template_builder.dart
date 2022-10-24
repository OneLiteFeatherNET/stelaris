import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/template_model.dart';

class TemplateBuilder {

  @protected
  late String name;

  @protected
  late String description;

  @protected
  late Set<String> plugins = {};

  TemplateBuilder setName(String name) {
    this.name = name;
    return this;
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

  TemplateModel toDTO() {
    return TemplateModel(
        name: name, description: description, plugins: plugins.toList());
  }
}

