import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:counter_app/main.dart';
import 'main_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CounterView>(),
  MockSpec<CounterPresenter>(),
])
void main() {
  group('model', () {
    test('increase', () {
      var target = const CounterModel(0);
      expect(target.counter, 0);
      target = target.increase();
      expect(target.counter, 1);
      target = target.increase();
      expect(target.counter, 2);
    });

    test('decrease', () {
      var target = const CounterModel(0);
      expect(target.counter, 0);
      target = target.decrease();
      expect(target.counter, -1);
      target = target.decrease();
      expect(target.counter, -2);
    });

    test('reset', () {
      var target = const CounterModel(5);
      expect(target.counter, 5);
      target = target.reset();
      expect(target.counter, 0);
    });
  });

  group('presenter', () {
    final mockView = MockCounterView();
    test('increase', () {
      final target = CounterPresenter(mockView);

      expect(target.model.counter, 0);
      target.incrementCounter();
      expect(target.model.counter, 1);
      target.incrementCounter();
      expect(target.model.counter, 2);
    });

    test('decrease', () {
      final target = CounterPresenter(mockView);

      expect(target.model.counter, 0);
      target.decrementCounter();
      expect(target.model.counter, -1);
      target.decrementCounter();
      expect(target.model.counter, -2);
    });
  });

  group('when askReset', () {
    final mockView = MockCounterView();

    test('yes', () async {
      when(mockView.askReset()).thenAnswer((_) => Future.value(true));

      final target = CounterPresenter(mockView);
      target.incrementCounter();
      expect(target.model.counter, 1);
      await target.resetCounter();
      expect(target.model.counter, 0);
    });

    test('no', () async {
      when(mockView.askReset()).thenAnswer((_) => Future.value(false));

      final target = CounterPresenter(mockView);
      target.incrementCounter();
      expect(target.model.counter, 1);
      await target.resetCounter();
      expect(target.model.counter, 1);
    });
    test('null', () async {
      when(mockView.askReset()).thenAnswer((_) => Future.value(null));

      final target = CounterPresenter(mockView);
      target.incrementCounter();
      expect(target.model.counter, 1);
      await target.resetCounter();
      expect(target.model.counter, 1);
    });
  });

  group('widget', () {
    test('test mock', () {
      final target = MockCounterPresenter();
      when(target.model).thenReturn(const CounterModel((255)));
      expect(target.model.counter, 255);
    });

    testWidgets('real presenter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(
            title: 'Flutter Demo Home Page',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('mock presenter', (WidgetTester tester) async {
      final target = MockCounterPresenter();
      when(target.model).thenReturn(const CounterModel((255)));

      await tester.pumpWidget(
        MaterialApp(
          home: MyHomePage(
            title: 'Flutter Demo Home Page',
            presenter: target,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('255'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('255'), findsOneWidget);
    });
  });
}
