import 'dart:async';

import 'package:ollama_talk_server/src/domain/commands/split_data.dart';

class SplitDataByMark implements ISplitData {
  const SplitDataByMark(
    this.mark1,
    this.mark2,
  );

  final Pattern mark1;
  final Pattern mark2;

  @override
  Stream<String> execute(String data) async* {
    final hasDataBeforeMark1 = 0 < data.indexOf(mark1);
    final paragraphs = data.split(mark1);
    final dataBeforeMark1 = hasDataBeforeMark1 ? paragraphs.first : '';

    for (final paragraph in paragraphs.skip(hasDataBeforeMark1 ? 1 : 0)) {
      final sessions = paragraph.split(mark2);
      final hasDataBeforeMark2 = 0 < paragraph.indexOf(mark2);
      final dataBeforeMark2 = hasDataBeforeMark2 ? sessions.first : '';

      for (final session in sessions.skip(hasDataBeforeMark2 ? 1 : 0)) {
        if (session.isEmpty) {
          continue;
        }
        yield session;
      }
    }
  }

  Stream<String> extract(
    String data,
    Pattern breakMark,
    int breakMarkLength,
  ) async* {
    for (int start = 0; start < data.length;) {
      final indexOf1 = data.indexOf(breakMark, start + 1);
      final indexOf2 =
          indexOf1 == -1 ? -1 : data.indexOf(breakMark, indexOf1 + 1);

      final noMoreElement = indexOf1 == -1 && indexOf2 == -1;

      if (noMoreElement) {
        yield data.substring(start);
        break;
      }

      final result = data.substring(start, indexOf1);
      yield result;

      start = indexOf1;
    }
  }
}
