import 'package:flutter/material.dart';
import 'package:mvp_flutter/mvp_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo with MVP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The state class for [MyHomePage], implements [BaseView].
class _MyHomePageState extends State<MyHomePage> implements BaseView {
  /// The presenter for managing the counter logic.
  late final _presenter = CounterPresenter(this);

  /// Builds the UI of the home page.
  ///
  /// - [context]: The build context.
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

/// A model representing the counter value.
class CounterModel {
  /// Creates a new [CounterModel] instance.
  ///
  /// - [counter]: The current value of the counter.
  const CounterModel(this.counter);

  /// The current value of the counter.
  final int counter;

  /// Increases the counter by one and returns a new [CounterModel].
  CounterModel increase() => CounterModel(counter + 1);
}

/// The presenter responsible for handling counter logic.
class CounterPresenter {
  /// Creates a new [CounterPresenter].
  ///
  /// - [_view]: The view that this presenter interacts with.
  CounterPresenter(this._view);

  /// The view that this presenter interacts with.
  final BaseView _view;

  /// The delegate that manages the [CounterModel] state.
  final _delegate = PresenterDelegate<CounterModel>(const CounterModel(0));

  /// Gets the current [CounterModel].
  CounterModel get _model => _delegate.model;

  /// Gets the current counter value.
  int get counter => _model.counter;

  /// Increments the counter and refreshes the view.
  void incrementCounter() => _delegate.refresh(_view, _model.increase());
}
