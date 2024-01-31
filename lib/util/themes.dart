import 'package:flutter/material.dart';

var lightMode = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorSchemeSeed: Colors.green[400],
  secondaryHeaderColor: Colors.green[200],
);

var darkMode = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorSchemeSeed: Colors.teal[400],
  secondaryHeaderColor: Colors.teal[800],
);