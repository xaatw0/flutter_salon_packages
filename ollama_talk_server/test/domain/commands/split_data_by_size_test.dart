import 'package:ollama_talk_server/src/domain/commands/split_data_by_size.dart';
import 'package:test/test.dart';

main() {
  test('12文字毎、10文字ずらす', () {
    final target = SplitDataBySize(12, 10);
    final stream = target.execute('123456789A123456789B123456789C');

    expectLater(
        stream,
        emitsInOrder([
          '123456789A12',
          '123456789B12',
          '123456789C',
          emitsDone,
        ]));
  });

  test('10文字毎、10文字ずらす', () {
    final target = SplitDataBySize(10, 10);
    final stream = target.execute('123456789A123456789B123456789C');

    expectLater(
        stream,
        emitsInOrder([
          '123456789A',
          '123456789B',
          '123456789C',
          emitsDone,
        ]));
  });

  test('5文字毎、5文字ずらす', () {
    final target = SplitDataBySize(5, 5);
    final stream = target.execute('123456789A123456789B123456789C12');

    expectLater(
        stream,
        emitsInOrder([
          '12345',
          '6789A',
          '12345',
          '6789B',
          '12345',
          '6789C',
          '12',
          emitsDone,
        ]));
  });
}
