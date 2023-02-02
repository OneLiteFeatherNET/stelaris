import 'package:flutter/material.dart';

/// Strings
const String appName = "Stelaris";
const String itemPage = "Items";
const String entityPage = "Entities";
const String unknownEntry = "Unknown";

/// EdgeInsets
const EdgeInsets eightEdgeInsets = EdgeInsets.all(8.0);

Text appText = const Text(appName);
Text appTitle = const Text("S T E L A R I S");
Text emptyText = const Text(empty);

/// Regs
RegExp numberPattern = RegExp("[1-9]\\d*");
RegExp stringPattern = RegExp("[a-zA-Z]\\w*");
RegExp dotPattern = RegExp("\\.");

/// Formatter
const TextInputType numberInput = TextInputType.numberWithOptions(signed: true);

/// Minecraft related values
const String zero = "0";
const String empty = "";
const int maxItemSize = 64;
const String defaultMaterial = "minecraft:dirt";

//Template Stepper
const String templateStepperTitle = "Create a server template";

// Text
// Button
Icon addModelIcon = const Icon(Icons.add);
Icon deleteIcon = const Icon(Icons.delete_forever, color: Colors.red);
Icon saveIcon = const Icon(Icons.save);

/// Styles
TextStyle whiteStyle = const TextStyle(color: Colors.white);
TextStyle redStyle = const TextStyle(color: Colors.red);

// Boxes
const SizedBox spaceFiveBox = SizedBox(width: 5);
const SizedBox spaceTenAndTenBox = SizedBox(width: 10, height: 10);
const SizedBox spaceTenBox = SizedBox(width: 10);
const SizedBox fifteenBox = SizedBox(height: 15);
const SizedBox spaceTwentyFiveHeightBox = SizedBox(height: 25);

const EdgeInsets dialogPadding = EdgeInsets.all(20.0);
