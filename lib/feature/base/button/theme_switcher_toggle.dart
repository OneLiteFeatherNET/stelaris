import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/home/home.dart';

const Icon nightMode = Icon(Icons.nights_stay_sharp);
const Icon lightMode = Icon(Icons.sunny_snowing);

class ThemeSwitcherToggle extends StatelessWidget {

  const ThemeSwitcherToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          _changeNightModeState();
        },
        icon: notifier.value == ThemeMode.light ? lightMode : nightMode);
  }

  void _changeNightModeState() {
    notifier.value =
        notifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
