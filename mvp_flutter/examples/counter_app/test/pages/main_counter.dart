import 'package:counter_app/domain/number_formatter.dart';
import 'package:counter_app/page/counter/counter_page.dart';
import 'package:counter_app/page/counter/counter_presenter.dart';
import 'package:flutter/material.dart';

// flutter run  -t test\pages\main_counter.dart
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
      home: CounterPage(
        title: 'Flutter mvp Dummy Demo',
        presenter: (view) => _DummyCounterPresenter(view),
      ),
    );
  }
}

class _DummyCounterPresenter extends CounterPresenter {
  _DummyCounterPresenter(super.view);

  @override
  String get counter => '\${counter}';

  @override
  void decrementCounter() {
    debugPrint('called: decrementCounter() ');
  }

  @override
  void incrementCounter() {
    debugPrint('called: incrementCounter()');
  }

  @override
  void onChangeNumberFormatter(NumberFormatter? formatter) {
    debugPrint('called: onChangeNumberFormatter(${formatter?.name ?? 'NULL'})');
  }

  @override
  Future<void> resetCounter() async {
    debugPrint('called: resetCounter()');
  }
}
