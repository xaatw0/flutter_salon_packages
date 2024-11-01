import 'package:counter_app/domain/number_formatter.dart';
import 'package:counter_app/page/counter/counter_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:counter_app/page/counter/counter_view.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<CounterView>(),
])
main() {
  group('value', () {
    final initValue = CounterModel.initialValue();
    test('init value', () {
      expect(initValue.selectedFormatter, CounterModel.formatters.first);
      expect(initValue.formattedValue, '0');
    });

    test('increase', () {
      final result = initValue.increase();
      expect(result.formattedValue, '1');
    });

    test('decrease', () {
      final result = initValue.decrease();
      expect(result.formattedValue, '-1');
    });
  });

  group('formatter', () {
    final initValue = CounterModel.initialValue();
    test('ThousandsSeparatedFormatter', () {
      expect(CounterModel.formatters[0], isA<ThousandsSeparatedFormatter>());
      var target = initValue.changeFormatter(CounterModel.formatters[0]);
      expect(target.formattedValue, '0');
      for (int i = 0; i < 1000; i++) {
        target = target.increase();
      }
      expect(target.formattedValue, '1,000');
    });

    test('KanjiNumberFormatter', () {
      expect(CounterModel.formatters[1], isA<KanjiNumberFormatter>());
      var target = initValue.changeFormatter(CounterModel.formatters[1]);
      expect(target.formattedValue, '零');
      for (int i = 0; i < 1000; i++) {
        target = target.increase();
      }
      expect(target.formattedValue, '千');
    });

    test('SpelledOutFormatter', () {
      expect(CounterModel.formatters[2], isA<SpelledOutFormatter>());
      var target = initValue.changeFormatter(CounterModel.formatters[2]);
      expect(target.formattedValue, 'zero');
      for (int i = 0; i < 1000; i++) {
        target = target.increase();
      }
      expect(target.formattedValue, 'one thousand');
    });
  });
}
