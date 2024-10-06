import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CounterModel', () {
    const counter0 = CounterModel(0);
    expect(counter0.counter, 0);
    final counter1 = counter0.increase();
    expect(counter1.counter, 1);
  });
}
