import 'package:counter_app/domain/number_formatter.dart';

import '../../domain/counter.dart';

class CounterModel {
  final Counter _counter;
  final NumberFormatter _formatter;

  const CounterModel(this._counter, this._formatter);

  static const formatters = [
    ThousandsSeparatedFormatter(),
    KanjiNumberFormatter(),
    SpelledOutFormatter(),
  ];

  factory CounterModel.initialValue() {
    return CounterModel(const Counter(0), formatters.first);
  }

  String get formattedValue => _formatter.format(_counter.counter);
  NumberFormatter get selectedFormatter => _formatter;

  CounterModel increase() {
    return CounterModel(_counter.increase(), _formatter);
  }

  CounterModel decrease() {
    return CounterModel(_counter.decrease(), _formatter);
  }

  CounterModel reset() {
    return CounterModel(_counter.reset(), _formatter);
  }

  CounterModel changeFormatter(NumberFormatter formatter) {
    return CounterModel(_counter, formatter);
  }
}
