import 'package:flutter/material.dart';

import 'package:mvp/mvp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    this.presenter,
  });

  final String title;
  final CounterPresenter? presenter;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements CounterView {
  late final CounterPresenter presenter =
      widget.presenter ?? CounterPresenter(this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mvp demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(bottom: 32.0),
              child: Text(
                "Click buttons to add and subtract.",
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FilledButton(
                  onPressed: () {
                    presenter.decrementCounter();
                  },
                  child: const Icon(Icons.remove),
                ),
                Text(
                  "${presenter.model.counter}",
                ),
                FilledButton(
                  onPressed: () {
                    presenter.incrementCounter();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.tonal(
              onPressed: () {
                presenter.resetCounter();
              },
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<bool?> askReset() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Would you reset counter?'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }
}

abstract class CounterView implements BaseView {
  Future<bool?> askReset();
}

class CounterModel {
  const CounterModel(this.counter);
  final int counter;

  CounterModel increase() {
    return CounterModel(counter + 1);
  }

  CounterModel decrease() {
    return CounterModel(counter - 1);
  }

  CounterModel reset() {
    return const CounterModel(0);
  }
}

class CounterPresenter extends BasePresenter<CounterModel> {
  final CounterView view;

  CounterPresenter(this.view) : super(const CounterModel(0));

  void incrementCounter() => refresh(view, model.increase());

  void decrementCounter() => refresh(view, model.decrease());

  Future<void> resetCounter() async {
    final willReset = await view.askReset();
    if (willReset == true) {
      refresh(view, model.reset());
    }
  }
}
