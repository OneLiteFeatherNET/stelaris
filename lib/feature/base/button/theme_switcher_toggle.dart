import 'package:flutter/material.dart';

const Icon nightMode = Icon(Icons.nights_stay_sharp);
const Icon lightMode = Icon(Icons.sunny_snowing);

class ThemeSwitcherToggle extends StatefulWidget {

  bool _darkMode = false;

  ThemeSwitcherToggle({Key? key}) : super(key: key);

  @override
  State<ThemeSwitcherToggle> createState() => _ThemeSwitcherToggleState();
}

class _ThemeSwitcherToggleState extends State<ThemeSwitcherToggle> {

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          setState(() => _changeNightModeState());
        },
        icon: widget._darkMode ? lightMode : nightMode
    );
  }

  void _changeNightModeState() {
    widget._darkMode = !widget._darkMode;
  }
}
