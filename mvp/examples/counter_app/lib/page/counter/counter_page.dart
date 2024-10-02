import 'package:counter_app/domain/number_formatter.dart';
import 'package:flutter/material.dart';

import 'counter_presenter.dart';
import 'counter_view.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({
    super.key,
    required this.title,
    this.presenter,
  });

  final String title;
  final CounterPresenter Function(CounterView view)? presenter;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> implements CounterView {
  late final CounterPresenter _presenter = widget.presenter == null
      ? CounterPresenter(this)
      : widget.presenter!(this);

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
            DropdownButton<NumberFormatter>(
              value: _presenter.selectedFormatter,
              items: _presenter.formatters
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (value) => _presenter.onChangeNumberFormatter(value),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 32.0),
              child: Text(
                'Click buttons to add and subtract.',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FilledButton(
                  onPressed: () {
                    _presenter.decrementCounter();
                  },
                  child: const Icon(Icons.remove),
                ),
                Text(
                  '${_presenter.counter}',
                ),
                FilledButton(
                  onPressed: () {
                    _presenter.incrementCounter();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.tonal(
              onPressed: () {
                _presenter.resetCounter();
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
