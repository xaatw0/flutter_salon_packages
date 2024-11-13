import 'dart:async';
import 'dart:convert';

import 'package:ollama_talk_server/src/domain/rag/abstract_rag_reader.dart';

class LineSeparateStreamReader implements AbstractRagReader {
  LineSeparateStreamReader(this._stream);

  final Stream<String> _stream;

  @override
  Stream<String> read() async* {
    // return LineSplitter().bind(_stream).skipWhile((e) => e.trim().isEmpty);

    final splitter = LineSplitter();
    final buffer = StringBuffer();
    await for (final data in _stream) {
      final lines = splitter.convert(data + '\n');
      if (lines.length == 1) {
        buffer.write(lines.first);
        continue;
      } else if (lines.every((e) => e.isEmpty)) {
        yield buffer.toString();
        buffer.clear();
        continue;
      }

      for (int i = 0; i < lines.length - 1; i++) {
        if (lines[i].isNotEmpty) {
          yield buffer.toString() + lines[i];
          buffer.clear();
        }
      }
      if (lines.last.isNotEmpty) {
        buffer.write(lines.last);
      }
    }

    // after stream was closed
    if (buffer.isNotEmpty) {
      yield buffer.toString();
    }
  }
}
