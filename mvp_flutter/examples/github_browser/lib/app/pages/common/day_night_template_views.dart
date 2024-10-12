import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:github_browser/domain/entities/theme_mode_model.dart';
import 'package:mvp_flutter/mvp_flutter.dart';

class DayNightTemplatePresenter {
  final BaseView _view;
  final _delegate =
      PresenterDelegate<ThemeModeModel>(const ThemeModeModel(ThemeMode.light));

  ThemeModeModel get _model => _delegate.model;

  DayNightTemplatePresenter(this._view);

  ThemeMode get themeMode => _model.themeMode;

  void changeTheme() {
    _delegate.refresh(_view, _model.change());
  }
}
