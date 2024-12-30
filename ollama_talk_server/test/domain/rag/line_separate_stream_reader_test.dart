import 'dart:async';
import 'dart:convert';

import 'package:ollama_talk_server/src/domain/rag/line_separate_stream_reader.dart';
import 'package:test/test.dart';

void main() {
  group('read', () {
    test('one data', () async {
      final controller = StreamController<String>();
      final stream = LineSeparateStreamReader(controller.stream).read();

      expectLater(
        stream,
        emitsInOrder(['Ready.', 'Set', 'Go!', emitsDone]),
      );
      controller
        ..add('\nReady.\nSet\n\nGo!\n')
        ..close();
    });

    test('separated data', () async {
      final controller = StreamController<String>();
      final stream = LineSeparateStreamReader(controller.stream).read();

      expectLater(
        stream,
        emitsInOrder(['Ready.', 'Set', 'Go!Go!', 'Go!', emitsDone]),
      );
      controller
        ..add('Rea')
        ..add('dy.\nSe')
        ..add('t\n\nGo!')
        ..add('Go!')
        ..add('\n')
        ..add('Go!')
        ..close();
    });

    Stream<String> continueTest(Stream<String> stream) async* {
      await for (final data in stream) {
        if (data.contains('b')) {
          continue;
        }

        yield data;
      }
    }

    test('continue in await', () async* {
      final controller = StreamController<String>();
      continueTest(controller.stream);

      expectLater(
        continueTest(controller.stream),
        emitsInOrder(['a', 'c', emitsDone]),
      );
      controller
        ..add('a')
        ..add('b')
        ..add('c')
        ..close();
    });
  });
}
