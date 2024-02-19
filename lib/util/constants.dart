import 'package:flutter/material.dart';

/// Strings
const String appName = "Stelaris";
const String itemPage = "Items";
const String entityPage = "Entities";
const String unknownEntry = "Unknown";

/// EdgeInsets
const EdgeInsets eightEdgeInsets = EdgeInsets.all(8.0);
const EdgeInsets padding = EdgeInsets.only(top: 10, left: 10);

Text appText = const Text(appName);
Text appTitle = const Text("S T E L A R I S");
Text emptyText = const Text(emptyString);

/// Regs
RegExp numberPattern = RegExp("[1-9]\\d*");
RegExp fontNumberPattern = RegExp("^(0|[1-9][0-9]*)");
RegExp letterPattern = RegExp("[a-zA-Z]*");
RegExp decimalPattern = RegExp(r'^\d*\.?\d*');
RegExp stringPattern = RegExp("[a-zA-Z]\\w*");
RegExp dotPattern = RegExp("\\.");
RegExp minecraftPattern = RegExp("minecraft:");
RegExp namePattern = RegExp("^[a-zA-z]\\w*");

/// Formatter
const TextInputType numberInput = TextInputType.numberWithOptions(signed: true);
const TextInputType decimalInput = TextInputType.numberWithOptions(decimal: true, signed: true);

/// Input field
const int maxInputLength = 20;

/// Minecraft related values
const String zeroString = "0";
const String emptyString = "";
const int maxItemSize = 64;
const String defaultMaterial = "minecraft:dirt";

// Text
// Button
Icon addModelIcon = const Icon(Icons.add);
Icon deleteIcon = const Icon(Icons.delete_forever, color: Colors.red);
Icon saveIcon = const Icon(Icons.save);
Icon editIcon = const Icon(Icons.edit, color: Colors.white);

/// Styles
TextStyle whiteStyle = const TextStyle(color: Colors.white);
TextStyle redStyle = const TextStyle(color: Colors.red);

// Boxes
const SizedBox horizontalSpacing5 = SizedBox(width: 5);
const SizedBox spacing10 = SizedBox(width: 10, height: 10);
const SizedBox heightTen = SizedBox(height: 10);
const SizedBox horizontalSpacing10 = SizedBox(width: 10);
const SizedBox verticalSpacing10 = SizedBox(height: 15);
const SizedBox verticalSpacing25 = SizedBox(height: 25);

const EdgeInsets dialogPadding = EdgeInsets.all(20);
const EdgeInsets top = EdgeInsets.only(top: 10);
const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 8);
const EdgeInsets largePadding = EdgeInsets.all(20);

const double dialogWidth = 500;
const double dialogHeight = 350;

const double cardElevation = 0.8;
