import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:mvp/mvp.dart';
import 'mvp_test.mocks.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> implements BaseView {
  late final _presenter = CounterPresenter(this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${_presenter.counter}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _presenter.incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CounterModel {
  const CounterModel(this.counter);
  final int counter;

  CounterModel increase() => CounterModel(counter + 1);
}

class CounterPresenter {
  CounterPresenter(this._view);
  CounterModel get _model => _delegate.model;

  final BaseView _view;
  final _delegate = PresenterDelegate<CounterModel>(const CounterModel(0));

  // public property and method
  int get counter => _model.counter;
  void incrementCounter() => _delegate.refresh(_view, _model.increase());
}

@GenerateNiceMocks([MockSpec<BaseView>()])
void main() {
  group('Model', () {
    test('initialize', () {
      final model1 = CounterModel(0);
      expect(model1.counter, 0);

      final model100 = CounterModel(100);
      expect(model100.counter, 100);
    });
    test('increase', () {
      final model1 = CounterModel(0);
      expect(model1.counter, 0);

      final model2 = model1.increase();
      expect(model1.counter, 0);
      expect(model2.counter, 1);
    });
  });

  group('Presenter', () {
    test('initialize, increment', () {
      final view = MockBaseView();
      final target = CounterPresenter(view);
      expect(target.counter, 0);
      verifyNever(view.setState(any));

      target.incrementCounter();
      expect(target.counter, 1);
      verify(view.setState(any)).called(1);
    });
  });

  group('View', () {
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
  });
}
