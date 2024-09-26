import 'dart:io';

import 'package:flutter/material.dart';

abstract interface class BaseView<T> {
  void setState(VoidCallback fn);
}

abstract class BasePresenter<T> {
  BasePresenter(this._model);
  T _model;
  T get model => _model;

  void refresh(BaseView view, T newModel) {
    assert(
      view is State || Platform.environment.containsKey('FLUTTER_TEST'),
      'view must be StatefulWidget\'s State class',
    );
    _model = newModel;
    view.setState(() {});
  }
}
