import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/util/checks.dart';

abstract class BaseBuilder<T> {

  @protected
  late String name;

  /// Set the name for a given object / structure.
  BaseBuilder setName(String name) {
    Checks.argCondition(name.trim().isEmpty, "Name can't be empty");
    this.name = name;
    return this;
  }

  T toDTO();

}