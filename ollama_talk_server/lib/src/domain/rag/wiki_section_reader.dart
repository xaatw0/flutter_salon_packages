import 'dart:async';
import 'dart:convert';

import 'package:ollama_talk_server/src/domain/rag/abstract_rag_reader.dart';

class WikiSectionReader {
  //}implements AbstractRagReader {
  WikiSectionReader();

  static const _kSeparator = '<h3';

  Stream<String> read(Stream<String> stream) async* {
    final buffer = StringBuffer();
    await for (final newData in stream) {
      buffer.write(newData);
      final lines = buffer.toString().split(_kSeparator);
      if (lines.length == 1) {
        continue;
      }

      for (int i = 0; i < lines.length - 1; i++) {
        yield lines[i];
      }

      buffer.clear();
      buffer.write(lines.last);
    }

    if (buffer.isNotEmpty) {
      yield buffer.toString();
    }
  }
}
