import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/util/checks.dart';

abstract class BaseBuilder<T> {

  @protected
  late String name;

  @protected
  late String generator;

  /// Set the name for a given object / structure.
  BaseBuilder setName(String name) {
    Checks.argCondition(name.trim().isEmpty, "Name can't be empty");
    this.name = name;
    return this;
  }

  /// Set the used generator to the object / structure.
  BaseBuilder setGenerator(String generator) {
    Checks.argCondition(generator.trim().isEmpty, "Generator can't be empty");
    this.generator = generator;
    return this;
  }

  T toDTO();

}