import 'package:counter_app/domain/number_formatter.dart';
import 'package:mvp_flutter/mvp_flutter.dart';

import 'counter_model.dart';
import 'counter_view.dart';

class CounterPresenter {
  CounterPresenter(this._view);
  CounterModel get _model => _delegate.model;

  static const numberWithCommas = ThousandsSeparatedFormatter();

  final CounterView _view;
  late final _delegate =
      PresenterDelegate<CounterModel>(CounterModel.initialValue());

  List<NumberFormatter> get formatters => CounterModel.formatters;

  String get counter => _model.formattedValue;
  void incrementCounter() => _delegate.refresh(_view, _model.increase());
  void decrementCounter() => _delegate.refresh(_view, _model.decrease());

  Future<void> resetCounter() async {
    final willReset = await _view.askReset();
    if (willReset == true) {
      _delegate.refresh(_view, _model.reset());
    }
  }

  NumberFormatter get selectedFormatter => _model.selectedFormatter;
  void onChangeNumberFormatter(NumberFormatter? formatter) {
    if (formatter != null) {
      _delegate.refresh(_view, _model.changeFormatter(formatter));
    }
  }
}
