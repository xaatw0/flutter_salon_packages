import 'package:counter_app/domain/number_formatter.dart';
import 'package:counter_app/page/counter/counter_page.dart';
import 'package:counter_app/page/counter/counter_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'counter_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CounterPresenter>(),
  MockSpec<
      ThousandsSeparatedFormatter>(), // cannot create MockNumberFormatter because of sealed class
])
main() {
  group('widget', () {
    test('test mock', () {
      final target = MockCounterPresenter();
      when(target.counter).thenReturn('255');
      expect(target.counter, '255');
    });

    testWidgets('real presenter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CounterPage(
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
      when(target.counter).thenReturn('255');

      final mockFormatter = MockThousandsSeparatedFormatter();
      provideDummy<NumberFormatter>(mockFormatter);
      when(target.selectedFormatter).thenReturn(mockFormatter);

      await tester.pumpWidget(
        MaterialApp(
          home: CounterPage(
            title: 'Flutter Demo Home Page',
            presenter: (_) => target,
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

  group('test of mockito', () {
    test('provideDummy', () {
      final mockFormatter1 = MockThousandsSeparatedFormatter();
      final mockFormatter2 = MockThousandsSeparatedFormatter();

      final target = MockCounterPresenter();

      provideDummy<NumberFormatter>(mockFormatter1);
      expect(target.selectedFormatter, mockFormatter1);
      expect(target.selectedFormatter, isNot(mockFormatter2));

      provideDummy<NumberFormatter>(mockFormatter2);
      expect(target.selectedFormatter, mockFormatter2);
      expect(target.selectedFormatter, isNot(mockFormatter1));
    });

    test('provideDummyBuilder', () {
      final mockFormatter1 = MockThousandsSeparatedFormatter();
      final mockFormatter2 = MockThousandsSeparatedFormatter();

      final target = MockCounterPresenter();

      provideDummyBuilder<NumberFormatter>((parent, invocation) {
        expect(parent, target);
        expect(invocation.isGetter, true);
        expect(
          invocation.memberName.toString(),
          'Symbol("selectedFormatter")',
        );
        return mockFormatter1;
      });
      expect(target.selectedFormatter, mockFormatter1);
      expect(target.selectedFormatter, isNot(mockFormatter2));

      provideDummyBuilder<NumberFormatter>(
          (parent, invocation) => mockFormatter2);
      expect(target.selectedFormatter, mockFormatter2);
      expect(target.selectedFormatter, isNot(mockFormatter1));
    });
  });
}
