import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/domain/entities/theme_mode_model.dart';

void main() {
  test('constructor', () {
    const status1 = ThemeModeModel(ThemeMode.light);
    expect(status1.themeMode, ThemeMode.light);

    final status2 = status1.change();
    expect(status2.themeMode, ThemeMode.dark);

    final status3 = status2.change();
    expect(status3.themeMode, ThemeMode.light);
  });

  test('feedback', () {
    var status = -1;
    void feedback(value) {
      status = value;
    }

    const status1 = ThemeModeModel(ThemeMode.light);
    expect(status, -1);
    final status2 = status1.change(feedback: feedback);
    expect(status, 2);
    final status3 = status2.change(feedback: feedback);
    expect(status, 1);
  });
}
