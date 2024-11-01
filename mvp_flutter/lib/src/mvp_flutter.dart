import 'dart:io';

import 'package:flutter/material.dart';

/// **BaseView** interface defines the basic view contract with a `setState` method.
///
/// This interface ensures that any class implementing it provides a way to update the UI state.
abstract interface class BaseView {
  /// Calls the `setState` method to update the UI.
  ///
  /// - [fn]: The callback function that contains the code to update the state.
  void setState(VoidCallback fn);
}

/// **PresenterDelegate** is a delegate class that manages the model state and refreshes the view when necessary.
///
/// This class follows the MVP (Model-View-Presenter) pattern to separate business logic from the UI.
class PresenterDelegate<T> {
  /// Creates a new `PresenterDelegate` with the initial model.
  ///
  /// - [this._model]: The initial model state.
  PresenterDelegate(this._model);

  /// The current model state.
  T _model;

  /// Gets the current model.
  T get model => _model;

  /// Refreshes the view if the model has changed.
  ///
  /// - [view]: The view to refresh, must implement `BaseView`.
  /// - [newModel]: The new model state.
  /// - [updateWhen]: Optional function to determine when to update the view based on the model.
  void refresh(BaseView view, T newModel, {Object Function(T e)? updateWhen}) {
    /// Ensures that the view is a StatefulWidget's State class or we're in a test environment.
    assert(
      view is State || Platform.environment.containsKey('FLUTTER_TEST'),
      'view must be StatefulWidget\'s State class',
    );

    /// If the model hasn't changed, no need to update the view.
    if (_model == newModel) {
      return;
    }

    /// Update the model with the new value.
    final oldValue = _model;
    _model = newModel;

    /// If `updateWhen` is not provided or the update condition is met, refresh the view by calling `setState`.
    if (updateWhen == null || updateWhen(oldValue) != updateWhen(newModel)) {
      view.setState(() {});
    }
  }
}
