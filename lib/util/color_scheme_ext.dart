import 'package:material_ui/material_ui.dart';

extension ColorSchemeExt on ColorScheme {
  /// Background of the app chrome (AppBar + NavigationSideBar) around the
  /// content panel. Dark themes need one tone more contrast than light ones —
  /// their surfaceContainer sits too close to surface to read as separate.
  Color get appChrome =>
      brightness == Brightness.dark ? surfaceContainerHigh : surfaceContainer;
}
