import 'package:flutter/material.dart';

class ThemeModeModel {
  const ThemeModeModel(this.themeMode);
  final ThemeMode themeMode;

  ThemeModeModel change({void Function(int index)? feedback}) {
    final nextTheme =
        themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    if (feedback != null) {
      feedback(nextTheme.index);
    }
    return ThemeModeModel(nextTheme);
  }

  factory ThemeModeModel.init(int index) {
    return ThemeModeModel(ThemeMode.values[index]);
  }
}
