import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/home/home.dart';

const Icon nightMode = Icon(Icons.nights_stay_sharp);
const Icon lightMode = Icon(Icons.sunny_snowing);

class ThemeSwitcherToggle extends StatefulWidget {

  const ThemeSwitcherToggle({super.key});

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
        icon: notifier.value == ThemeMode.light ? lightMode : nightMode
    );
  }

  void _changeNightModeState() {
    notifier.value = notifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
