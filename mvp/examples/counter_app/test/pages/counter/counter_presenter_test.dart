import 'package:counter_app/page/counter/counter_model.dart';
import 'package:counter_app/page/counter/counter_presenter.dart';
import 'package:counter_app/page/counter/counter_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'counter_presenter_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CounterView>(),
])
void main() {
  final mockView = MockCounterView();

  group('increase/decrease', () {
    test('increase', () {
      final target = CounterPresenter(mockView);

      expect(target.counter, '0');
      target.incrementCounter();
      expect(target.counter, '1');
      target.incrementCounter();
      expect(target.counter, '2');
    });

    test('decrease', () {
      final target = CounterPresenter(mockView);

      expect(target.counter, '0');
      target.decrementCounter();
      expect(target.counter, '-1');
      target.decrementCounter();
      expect(target.counter, '-2');
    });
  });

  group('when askReset', () {
    test('yes', () async {
      when(mockView.askReset()).thenAnswer((_) => Future.value(true));

      final target = CounterPresenter(mockView);
      target.incrementCounter();
      expect(target.counter, '1');
      await target.resetCounter();
      expect(target.counter, '0');
    });

    test('no', () async {
      when(mockView.askReset()).thenAnswer((_) => Future.value(false));

      final target = CounterPresenter(mockView);
      target.incrementCounter();
      expect(target.counter, '1');
      await target.resetCounter();
      expect(target.counter, '1');
    });

    test('null', () async {
      when(mockView.askReset()).thenAnswer((_) => Future.value(null));

      final target = CounterPresenter(mockView);
      target.incrementCounter();
      expect(target.counter, '1');
      await target.resetCounter();
      expect(target.counter, '1');
    });
  });

  group('NumberFormatter', () {
    test('change', () {
      final target = CounterPresenter(mockView);
      expect(target.counter, '0');
      target.onChangeNumberFormatter(CounterModel.formatters[1]);
      expect(target.counter, '零');
      target.onChangeNumberFormatter(CounterModel.formatters[2]);
      expect(target.counter, 'zero');
      target.onChangeNumberFormatter(CounterModel.formatters[0]);
      expect(target.counter, '0');
    });
  });
}
