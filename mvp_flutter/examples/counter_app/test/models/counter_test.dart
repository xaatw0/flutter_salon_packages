import 'package:counter_app/domain/counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('model', () {
    test('increase', () {
      var target = const Counter(0);
      expect(target.counter, 0);
      target = target.increase();
      expect(target.counter, 1);
      target = target.increase();
      expect(target.counter, 2);
    });

    test('decrease', () {
      var target = const Counter(0);
      expect(target.counter, 0);
      target = target.decrease();
      expect(target.counter, -1);
      target = target.decrease();
      expect(target.counter, -2);
    });

    test('reset', () {
      var target = const Counter(5);
      expect(target.counter, 5);
      target = target.reset();
      expect(target.counter, 0);
    });
  });
}
